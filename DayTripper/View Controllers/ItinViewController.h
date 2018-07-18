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

@interface ItinViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (strong, nonatomic) Trip *trip;
@end
