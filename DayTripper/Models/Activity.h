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
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSString *primaryCategory;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
//what the id the api assigns to the Activity
@property (strong, nonatomic) NSString *apiId;
@property (strong, nonatomic) NSDate* startTime;
@property (strong, nonatomic) NSDate* endTime;
@property (nonatomic) double duration;
- (NSString *)activityType;

@end
