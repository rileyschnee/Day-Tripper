//
//  Event.m
//  DayTripper
//
//  Created by Michael Abelar on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Event.h"

@implementation Event
@dynamic name;
@dynamic categories;
@dynamic latitude;
@dynamic longitude;
@dynamic duration;
@dynamic endTime;
@dynamic startTime;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}
-(NSString *)activityType{
    return @"Event";
}

@end
