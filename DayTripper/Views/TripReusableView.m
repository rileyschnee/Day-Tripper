//
//  TripReusableView.m
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "TripReusableView.h"

@implementation TripReusableView
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
    NSString* usernameToAdd = [self.usernameToAdd.text lowercaseString];
    [self getUserByUsername:usernameToAdd];
}

- (IBAction)tapGestureTap:(id)sender {
    [self.usernameToAdd resignFirstResponder];
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


@end
