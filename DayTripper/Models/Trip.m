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
@dynamic attendees;
@dynamic tripDate;

+ (nonnull NSString *)parseClassName {
    return @"Trip";
}

+ (void) saveTrip: ( Trip * _Nullable )trip withName: (NSString * _Nullable)name withDate: (NSDate *_Nullable)date withLat: (double)lat withLon:(double)lon withCompletion: (PFBooleanResultBlock  _Nullable)completion {

    Trip *newTrip = trip;
    newTrip.name = name;
    newTrip.planner = [PFUser currentUser];
    newTrip.tripDate = date;
    newTrip.latitude = lat;
    newTrip.longitude = lon;
    newTrip.attendees = [NSMutableArray new];
    [newTrip addUniqueObject:[PFUser currentUser] forKey:@"attendees"];
    
    //actually save the trip
    [newTrip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Trip successfully saved!");
        } else {
            NSLog(@"Error saving trip");
        }
    }];
}
@end
