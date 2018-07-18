//
//  Activity.h
//  DayTripper
//
//  Created by Kimora Kong on 7/17/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "PFObject.h"
#import <Parse/Parse.h>

@protocol Activity

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *category;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
