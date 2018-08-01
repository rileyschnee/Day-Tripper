//
//  IOUViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface IOUViewController : UIViewController
@property (strong, nonatomic) Trip *trip;
@property (strong, nonatomic) NSMutableArray *attendeeUsers;
@property (nonatomic) BOOL isUsersIOUs;
@property (strong, nonatomic) NSMutableArray *iouArray;

@end
