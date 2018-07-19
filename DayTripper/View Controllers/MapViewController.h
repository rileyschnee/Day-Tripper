//
//  MapViewController.h
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"


@interface MapViewController : UIViewController

@property (strong, nonatomic) Trip *trip;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@end
