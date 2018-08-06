//
//  Functions.m
//  DayTripper
//
//  Created by Michael Abelar on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Functions.h"
#import "Activity.h"

@implementation Functions

// common functions that will be needed


+ (NSArray*) getCellsFromTable:(UITableView*)tableView {
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
        {
            [cells addObject:[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    return [cells copy];
}

- (double) distanceBetweenTwoPlaces:(Place*)place1 place2:(Place*)place2 {
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:place1.latitude longitude:place1.longitude];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:place2.latitude longitude:place2.longitude];
    return [startLocation distanceFromLocation:endLocation];
}

+ (NSString *)primaryActivityCategory:(id<Activity>)activity{
    if(activity.categories.count == 0){
        return @"";
    } else if([[activity activityType] isEqualToString:@"Place"]){\
        return [[activity.categories[0][@"name"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if([[activity activityType] isEqualToString:@"Food"]){
        return [[activity.categories[0][@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if ([[activity activityType] isEqualToString:@"Event"]){
        return [[activity.categories[0] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else {
        return @"NO CATEGORY";
    }
}

+ (void)fetchUserIOUs:(PFUser *)user withCompletion:(void (^)(NSArray *ious))completionHandler {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"payee == %@ OR payer == %@", PFUser.currentUser, PFUser.currentUser];
        PFQuery *query = [PFQuery queryWithClassName:@"IOU" predicate:pred];
        [query includeKeys:@[@"payer", @"payee", @"description", @"amount", @"completed"]];
        [query orderByAscending:@"completed"];
        //query.limit = 20;
        [query findObjectsInBackgroundWithBlock:^(NSArray *ious, NSError *error) {
            if (ious != nil){
                NSLog(@"FUNCTIONS %@", ious);
                completionHandler(ious);
            } else {
                NSLog(@"%@", error.localizedDescription);
                NSLog(@"Error fetching ious");
                //return [NSMutableArray new];
            }
        }];
}

+ (NYAlertViewController *)alertWithTitle:(NSString *)title withMessage:(NSString *)message{
    
    NYAlertViewController *alert = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    // Set a title and message
    alert.title = NSLocalizedString(title, nil);
    alert.message = NSLocalizedString(message, nil);
    
    // Customize appearance as desired
    alert.buttonCornerRadius = 20.0f;
    alert.alertViewCornerRadius = 20.0f;
    alert.view.tintColor = [UIColor colorWithRed:0.94 green:0.40 blue:0.23 alpha:1.0];
    
    alert.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alert.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alert.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alert.buttonTitleFont.pointSize];
    alert.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alert.cancelButtonTitleFont.pointSize];
    alert.cancelButtonColor = [UIColor colorWithRed:0.36 green:0.56 blue:0.76 alpha:1.0];
    alert.buttonColor = [UIColor colorWithRed:0.36 green:0.56 blue:0.76 alpha:1.0];
    alert.titleColor = [UIColor blackColor];
    alert.messageColor = [UIColor blackColor];
    
    alert.swipeDismissalGestureEnabled = NO;
    alert.backgroundTapDismissalGestureEnabled = NO;
    return alert;
}

@end
