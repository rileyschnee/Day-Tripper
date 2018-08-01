//
//  Trip.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Trip.h"
#import "ChatMessage.h"

@implementation Trip

@dynamic city;
@dynamic name;
@dynamic activities;
@dynamic chats;
@dynamic planner;
@dynamic latitude;
@dynamic longitude;
@dynamic attendees;
@dynamic tripDate;
@dynamic summary;
@dynamic ious;
@dynamic albumId;
@dynamic albumHash;

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
    newTrip.summary = @""; 
    newTrip.chats = [[NSMutableArray alloc] init];
    newTrip.ious = [NSMutableArray new];
    newTrip.attendees = [NSMutableArray new];
    newTrip.albumId = @"";
    newTrip.albumHash = @"";
    [newTrip addUniqueObject:[PFUser currentUser].objectId forKey:@"attendees"];
    
    //actually save the trip
    [newTrip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Trip successfully saved!");
        } else {
            NSLog(@"Error saving trip");
        }
    }];
    [newTrip checkForActionItems];
    
}

// Checks all trip activities for certain categories and sends chat message from Day Tripper if necessary
- (void)checkForActionItems{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd"];
    
    for(id<Activity> activity in self.activities){
        if([[activity activityType] isEqualToString:@"Food"]){
            [self addDTActionItemToChatWithMessage:[NSString stringWithFormat:@"Check to see if %@ requires reservations!", activity.name]];
        }
        if([[activity activityType] isEqualToString:@"Place"]){
            for(NSDictionary *cat in activity.categories){
                if([[cat objectForKey:@"name"] isEqualToString:@"Movie Theater"]){
                    //NSLog(@"%@ Activity : %@ Category", activity.name, cat);
                    [self addDTActionItemToChatWithMessage:[NSString stringWithFormat:@"Don't forget to buy your movie tickets for %@ by %@!", activity.name, [dateFormatter stringFromDate:self.tripDate]]];
                }
            }
        }
        if([[activity activityType] isEqualToString:@"Event"]){
            for(NSString *cat in activity.categories){
                if([cat isEqualToString:@"conferences"] || [cat isEqualToString:@"expos"]){
                    [self addDTActionItemToChatWithMessage:[NSString stringWithFormat:@"Do you have your tickets for %@, yet?", activity.name]];
                }
                if([cat isEqualToString: @"concerts"] || [cat isEqualToString: @"performing-arts"]){
                    [self addDTActionItemToChatWithMessage:[NSString stringWithFormat:@"Be sure to get your tickets for %@!", activity.name]];
                       
                }
                if([cat isEqualToString:@"festivals"]){
                    [self addDTActionItemToChatWithMessage:[NSString stringWithFormat:@"Do you need tickets for %@?", activity.name]];
                    
                } if ([cat isEqualToString:@"sports"]) {
                    
                    [self addDTActionItemToChatWithMessage:[NSString stringWithFormat:@"Be sure to get your tickets for %@ by %@!", activity.name, [dateFormatter stringFromDate:self.tripDate]]];
                    
                }
            }
        }
    }
}

// Sends chat message from DayTripper with message
- (void)addDTActionItemToChatWithMessage:(NSString *)message{
    ChatMessage* chat = [ChatMessage new];
    chat.username = @"DayTripper";
    chat.message = message;
    //now save the message
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            //now make a pointer to trip
            NSMutableArray* currChats = self.chats;
            if (currChats == nil) {
                currChats = [[NSMutableArray alloc] init];
            }
            [currChats addObject:chat];
            self.chats = currChats;
            [self saveInBackground];
        } else {
            NSLog(@"Problem saving chat: %@", error.localizedDescription);
        }
    }];
}



@end
