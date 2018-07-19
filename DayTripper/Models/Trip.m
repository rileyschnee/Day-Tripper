//
//  Trip.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Trip.h"

@implementation Trip

@dynamic city;
@dynamic name;
@dynamic activities;
@dynamic planner;
@dynamic latitude;
@dynamic longitude;

+ (nonnull NSString *)parseClassName {
    return @"Trip";
}

+ (void) saveTrip: ( Trip * _Nullable )trip withName: (NSString * _Nullable)name withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Trip *newTrip = trip;
    newTrip.city = name;
    newTrip.planner = [PFUser currentUser];
    
    [newTrip saveInBackgroundWithBlock: completion];
}
@end
