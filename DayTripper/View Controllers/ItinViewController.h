//
//  ItinViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "Activity.h"
#import "Place.h"
#import "Food.h"

@interface ItinViewController : UIViewController <UITabBarControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (strong, nonatomic) Trip *trip;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
//property indicating if coming from home vc so we can make edit bar button
@property (nonatomic) BOOL fromHomeEdit;
//property indicating if coming from home for the first time so can redirect to resources
@property (nonatomic) BOOL fromHomeToResources;
- (void)back;
@end
