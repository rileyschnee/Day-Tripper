//
//  ResourcesViewController.h
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import "TripReusableView.h"
#import "UserCollectionCell.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ResourcesViewController : UIViewController <UITabBarControllerDelegate>
@property (strong, nonatomic) Trip *trip;

@end
