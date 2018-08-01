//
//  TripReusableView.m
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "TripReusableView.h"
#import "ResourcesViewController.h"

@implementation TripReusableView

- (void)awakeFromNib{
    [super awakeFromNib];
    // Add shadow to GPhotos button
    [self.googlePhotosButton.layer setShadowOffset:CGSizeMake(2, 2)];
    [self.googlePhotosButton.layer setShadowColor:[[UIColor grayColor] CGColor]];
    [self.googlePhotosButton.layer setShadowOpacity:0.5];
    
    self.descriptionLabel.hidden = [self.trip.summary isEqualToString:@""];
    self.descriptionLabel.text = self.trip.summary;

}

- (void)setTrip:(Trip *)trip{
    _trip = trip;
    self.tripNameLabel.text = self.trip.name;
    if([self.trip.city containsString:@","]){
        self.tripCityLabel.text = [self.trip.city substringToIndex:[self.trip.city rangeOfString:@","].location];
    } else {
        self.tripCityLabel.text = self.trip.city;
    }
    NSLog(@"Set trip - reusable view");
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
    self.tripDateLabel.text = [dateFormatter stringFromDate:self.trip.tripDate];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTap:)]];
}

//when clicked, this button will add the given username to the attendees trip array
- (IBAction)addUserToTrip:(id)sender {    
    NSString* usernameToAdd = [self.usernameToAdd.text lowercaseString];
    [self getUserByUsername:usernameToAdd];
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
                // TODO handle user not existing
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
        UINavigationController* navController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UITabBarController* tabBarController = navController.topViewController;
        UIViewController* activeVC = tabBarController.selectedViewController;
        mailCont.mailComposeDelegate = activeVC;
        
        [mailCont setSubject:@"You were invited to a trip!"];
        [mailCont setToRecipients:[NSArray arrayWithObject:user.email]];
        [mailCont setMessageBody:@"Message body" isHTML:NO];
        
        [activeVC presentViewController:mailCont animated:YES completion:nil];
    }
}


- (void)alertUserAlreadyAttending{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User Already Attending" message:[NSString stringWithFormat:@"%@ is already attending %@", self.usernameToAdd.text, self.trip.name] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self.delegate showAlert:alert];
}

-(void)alertForSummary{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Enter your summary"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    [alert setValue:textView forKey:@"accessoryView"];
    [self.delegate showAlertView:alert];
    self.trip.summary = textView.text;
    [self.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"succeeded saving descr");
            [self refreshDescription];
        } else {
            NSLog(@"error saving descr");
        }
    }];
    
    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Trip Description"
    //                                                                              message: @"Enter the trip description"
    //                                                                       preferredStyle:UIAlertControllerStyleAlert];
    ////    alertController.view.autoresizesSubviews = YES;
    ////    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    ////    textView.translatesAutoresizingMaskIntoConstraints = NO;
    //////    textView.editable = YES;
    //////    textView.dataDetectorTypes = UIDataDetectorTypeAll;
    //////    // textView.text = @"Some really long text here";
    //////    textView.userInteractionEnabled = YES;
    //////    textView.backgroundColor = [UIColor whiteColor];
    //////    textView.scrollEnabled = YES;
    ////    NSLayoutConstraint *leadConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-8.0];
    ////    NSLayoutConstraint *trailConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
    ////
    ////    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-64.0];
    ////    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:alertController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:64.0];
    ////    [alertController.view addSubview:textView];
    ////    [NSLayoutConstraint activateConstraints:@[leadConstraint, trailConstraint, topConstraint, bottomConstraint]];
    //
    //
    //    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //        self.trip.summary = textView.text;
    //        [self.trip saveInBackground];
    //        [alertController dismissViewControllerAnimated:YES completion:nil];
    //
    //
    //    }]];
    //    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //        [alertController dismissViewControllerAnimated:YES completion:nil];
    //
    //    }]];
    //
    //    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)didTapDescription:(id)sender {
    [self alertForSummary];
    
}

@end
