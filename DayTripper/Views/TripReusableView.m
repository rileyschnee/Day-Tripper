//
//  TripReusableView.m
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "TripReusableView.h"
#import "APIManager.h"
#import "ResourcesViewController.h"
#import <NYAlertViewController/NYAlertViewController.h>

@implementation TripReusableView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    // Add style to Trip Photos button
    self.shareToImgurButton.layer.cornerRadius = self.shareToImgurButton.frame.size.height / 4;

    // Configure description label
    self.descriptionLabel.hidden = [self.trip.summary isEqualToString:@""];
    self.descriptionLabel.text = self.trip.summary;

    // Add style to IOUs button
    self.iouButton.layer.cornerRadius = self.iouButton.frame.size.height / 4;
    
    // Add style to weather view
    [self.weatherView.layer setBorderColor:[[UIColor colorWithRed:0.94 green:0.40 blue:0.23 alpha:1.0] CGColor]];
    [self.weatherView.layer setBorderWidth:1];
    self.weatherView.layer.cornerRadius = self.weatherView.frame.size.height / 8;

    // Set textField to Hidden
    self.usernameToAdd.hidden = YES;
    self.addAttendeeButton.selected = YES;
    self.attendeeLabel.textAlignment = NSTextAlignmentCenter;
    [self.attendeeLabel sizeToFit];
    self.attendeeLabel.frame = CGRectMake(self.attendeeBar.frame.size.width/2 - self.attendeeLabel.frame.size.width/2, self.attendeeBar.frame.size.height/2 - self.attendeeLabel.frame.size.height/2, self.attendeeLabel.frame.size.width, self.attendeeLabel.frame.size.height);
    
}

- (void)setTrip:(Trip *)trip{
    _trip = trip;
    self.tripNameLabel.text = self.trip.name;
    if([self.trip.city containsString:@","]){
        self.tripCityLabel.text = [self.trip.city substringToIndex:[self.trip.city rangeOfString:@","].location];
    } else {
        self.tripCityLabel.text = self.trip.city;
    }
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
    self.tripDateLabel.text = [dateFormatter stringFromDate:self.trip.tripDate];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTap:)]];
}

//when clicked, this button will add the given username to the attendees trip array
- (IBAction)addUserToTrip:(id)sender {
    if(self.addAttendeeButton.selected){
        [UIView animateWithDuration:0.2f animations:^{
            self.attendeeLabel.frame = CGRectMake(21, self.attendeeBar.frame.size.height/2 - self.attendeeLabel.frame.size.height/2, self.attendeeLabel.frame.size.width, self.attendeeLabel.frame.size.height);
        }];
        [UIView transitionWithView:self.attendeeBar duration:.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.addAttendeeButton.selected = NO;
            self.usernameToAdd.hidden = NO;
            self.usernameToAdd.text = @"";
        } completion:NULL];
        
        
    } else {
        NSString* usernameToAdd = [self.usernameToAdd.text lowercaseString];
        [self getUserByUsername:usernameToAdd];
        [UIView transitionWithView:self.attendeeBar duration:.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.addAttendeeButton.selected = YES;
            self.usernameToAdd.hidden = YES;
        } completion:NULL];
        [UIView animateWithDuration:0.2f animations:^{
            self.attendeeLabel.frame = CGRectMake(self.attendeeBar.frame.size.width/2 - self.attendeeLabel.frame.size.width/2, self.attendeeBar.frame.size.height/2 - self.attendeeLabel.frame.size.height/2, self.attendeeLabel.frame.size.width, self.attendeeLabel.frame.size.height);
            //self.attendeeLabel.transform = CGAffineTransformMakeTranslation(100, 0);
        }];
        
    }
}

- (IBAction)tapGestureTap:(id)sender {
    [self.usernameToAdd resignFirstResponder];
}

- (void)refreshDescription{
    self.descriptionLabel.hidden = [self.trip.summary isEqualToString:@""];
    self.descriptionLabel.text = self.trip.summary;
    self.summaryBtn.hidden = ![self.trip.summary isEqualToString:@""];
}

//gets the user by the given username
- (void) getUserByUsername:(NSString*) username {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query includeKey:@"picture"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            if (users.count > 0) {
                PFUser* user = users[0];
                [self addUserToAttendee:user];
            }
            else {
                [self alertUserNotFound];
                self.usernameToAdd.text = @"";
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

//reloads the tableview asynchronously
-(void) clearUsernameLabelAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.usernameToAdd.text = @"";
    });
}

//takes the user object and adds the object to the attendees for the trip
- (void) addUserToAttendee:(PFUser*) user {
    if (![self.trip.attendees containsObject:user.objectId]) {
        [self.trip addUniqueObject:user.objectId forKey:@"attendees"];
        //[currAttendees addObject:user];
        //self.trip.attendees = [currAttendees mutableCopy];
        //save trip
        [self.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self clearUsernameLabelAsync];
                //send email to other user
                //[self sendAdditionEmail:user];
                NSLog(@"Successfully saved attendees list");
                [self.delegate reloadAttendeeData];
            } else {
                NSLog(@"Problem saving attendee list");
            }
        }];
    } else {
        NSLog(@"User already added");
        [self alertUserAlreadyAttending];
    }
}

//sends an email to added user saying they were added
- (void) sendAdditionEmail:(PFUser*) user {
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        UINavigationController* navController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UITabBarController* tabBarController = (UITabBarController *)navController.topViewController;
        UIViewController* activeVC = tabBarController.selectedViewController;
        mailCont.mailComposeDelegate = activeVC;
        
        [mailCont setSubject:@"You were invited to a trip!"];
        [mailCont setToRecipients:[NSArray arrayWithObject:user.email]];
        [mailCont setMessageBody:@"Message body" isHTML:NO];
        
        [activeVC presentViewController:mailCont animated:YES completion:nil];
    }
}


- (void)alertUserAlreadyAttending{
    NYAlertViewController *alert = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    // Set a title and message
    alert.title = NSLocalizedString(@"User Already Attending", nil);
    NSString *message = [NSString stringWithFormat:@"%@ is already attending %@", self.usernameToAdd.text, self.trip.name];
    alert.message = NSLocalizedString(message, nil);
    
    // Customize appearance as desired
    alert.buttonCornerRadius = 20.0f;
    alert.alertViewCornerRadius = alert.accessibilityFrame.size.height / 4;
    alert.view.tintColor = [UIColor blueColor];
    
    alert.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alert.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alert.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alert.buttonTitleFont.pointSize];
    alert.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alert.cancelButtonTitleFont.pointSize];
    
    alert.swipeDismissalGestureEnabled = NO;
    alert.backgroundTapDismissalGestureEnabled = NO;
    
    // Add alert actions
    [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self.delegate dismissAlert:alert];
    }]];
    
    // Present the alert view controller
    
    
    /* // OLD
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User Already Attending" message:[NSString stringWithFormat:@"%@ is already attending %@", self.usernameToAdd.text, self.trip.name] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    */
    [self.delegate showAlert:alert];
}

- (void)alertUserNotFound{
    NYAlertViewController *alert = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    // Set a title and message
    alert.title = NSLocalizedString(@"User Not Found", nil);
    NSString *message = [NSString stringWithFormat:@"Cannot find user %@", self.usernameToAdd.text];
    alert.message = NSLocalizedString(message, nil);
    
    // Customize appearance as desired
    alert.buttonCornerRadius = 20.0f;
    alert.alertViewCornerRadius = 20.0f;
    alert.view.tintColor = [UIColor blueColor];
    
    alert.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alert.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alert.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alert.buttonTitleFont.pointSize];
    alert.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alert.cancelButtonTitleFont.pointSize];
    
    alert.swipeDismissalGestureEnabled = NO;
    alert.backgroundTapDismissalGestureEnabled = NO;
    
    // Add alert actions
    [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self.delegate dismissAlert:alert];
    }]];
    
    // Present the alert view controller
    [self.delegate showAlert:alert];

    
    /* // OLD
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User Already Attending" message:[NSString stringWithFormat:@"%@ is already attending %@", self.usernameToAdd.text, self.trip.name] preferredStyle:(UIAlertControllerStyleAlert)];
     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
     }];
     // add the OK action to the alert controller
     [alert addAction:okAction];
     */
}

-(void)alertForSummaryWithMessage:(NSString *)message{
    
    NYAlertViewController *alert = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    // Set a title and message
    alert.title = NSLocalizedString(message, nil);
    alert.message = NSLocalizedString(@"", nil);
    
    // Create view for textview
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    textView.tag = 1;
    textView.text = self.trip.summary;
    [contentView addSubview:textView];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView(100)]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(textView)]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textView]-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(textView)]];
    alert.alertViewContentView = contentView;

    // Customize appearance as desired
    alert.buttonCornerRadius = 20.0f;
    alert.alertViewCornerRadius = 20.0f;
    alert.view.tintColor = [UIColor blueColor];
    
    alert.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alert.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alert.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alert.buttonTitleFont.pointSize];
    alert.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alert.cancelButtonTitleFont.pointSize];
    
    alert.swipeDismissalGestureEnabled = NO;
    alert.backgroundTapDismissalGestureEnabled = NO;
    
    // Add alert actions
    [alert addAction:[NYAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(NYAlertAction *action) {
        [self.delegate dismissAlert:alert];
    }]];
    [alert addAction:[NYAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        self.delegate.trip.summary = ((UITextView *)[alert.alertViewContentView viewWithTag:1]).text;
        NSLog(@"%@", ((UITextView *)[alert.alertViewContentView viewWithTag:1]).text);
        [self.delegate.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                NSLog(@"succeeded saving descr: %@", self.delegate.trip.summary);
                [self refreshDescription];
                [self.delegate dismissAlert:alert];
                if(![self.trip.summary isEqualToString:@""]){
                    self.summaryBtn.hidden = YES;
                    self.editDescripBtn.hidden = NO;
                } else {
                    self.summaryBtn.hidden = NO;
                    self.editDescripBtn.hidden = YES;
                }
            } else {
                NSLog(@"error saving descr");
                [self.delegate dismissAlert:alert];
            }
        }];
    }]];
    [self.delegate showAlert:alert];
    
    
    /* // OLD
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Enter your summary"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [alert setValue:self.textView forKey:@"accessoryView"];
    [self.delegate showAlertView:alert];
     */
}

- (IBAction)didTapDescription:(id)sender {
    [self alertForSummaryWithMessage:@"Add Trip Description"];
    
}

- (IBAction)didTapEdit:(id)sender {
    [self alertForSummaryWithMessage:@"Edit Trip Description"];
}
@end
