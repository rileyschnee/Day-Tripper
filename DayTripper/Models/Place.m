//
//  Place.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Place.h"
#import "Activity.h"
@implementation Place
@dynamic name;
@dynamic categories;
@dynamic latitude;
@dynamic longitude;
@dynamic duration;
@dynamic endTime;
@dynamic startTime;

+ (nonnull NSString *)parseClassName {
    return @"Place";
}
- (NSString *)activityType{
    return @"Place";
}

@end
