//
//  Place.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Place.h"

@implementation Place
@dynamic name;

+ (nonnull NSString *)parseClassName {
    return @"Place";
}

- (void) setEndTime:(NSDate *)endTime {
    self.endTime = endTime;
    //calculate duration of event
    if (self.startTime != nil) {
        self.duration = [self.endTime timeIntervalSinceDate:self.startTime];
    }
}

@end
