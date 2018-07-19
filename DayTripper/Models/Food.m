//
//  Food.m
//  DayTripper
//
//  Created by Kimora Kong on 7/17/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Food.h"

@implementation Food
@dynamic website;
@dynamic name;
@dynamic categories;
@dynamic latitude;
@dynamic longitude;
@dynamic duration;
@dynamic endTime;
@dynamic startTime;

+ (nonnull NSString *)parseClassName {
    return @"Food";
}
-(NSString *)activityType{
    return @"Food";
}

@end
