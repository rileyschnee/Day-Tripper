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
@property (strong, nonatomic) NSString* startTime;
@property (strong, nonatomic) NSString* endTime;
@property (nonatomic) double duration;
@property (strong, nonatomic) NSString *website;
- (NSString *)activityType;

@end
