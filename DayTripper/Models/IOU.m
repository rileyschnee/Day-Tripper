//
//  IOU.m
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "IOU.h"

@implementation IOU
@dynamic payer;
@dynamic payee;
@dynamic amount;
@dynamic description;
@dynamic completed;

+ (void) saveIOUwithAmount: ( NSNumber * )amount fromPayer: (PFUser * )payer toPayee: (PFUser *)payee withDescription: (NSString * )description toTrip:(Trip * )trip withCompletion:(void (^)(BOOL))completion{
    
    IOU *newIOU = [IOU new];
    newIOU.amount = amount;
    newIOU.payer = payer;
    newIOU.payee = payee;
    newIOU.description = description;
    //newIOU.completed = @0;
    [newIOU setObject:[NSNumber numberWithBool:FALSE] forKey:@"completed"];

    //actually save the IOU
    [newIOU saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"IOU successfully saved!");
            NSMutableArray *tempIOUs = [NSMutableArray new];
            tempIOUs = [trip.ious mutableCopy];
            [tempIOUs addObject:newIOU.objectId];
            trip.ious = [tempIOUs copy];
            //[trip addUniqueObject:newIOU.objectId forKey:@"ious"];
            [trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    NSLog(@"Successfully updated IOUs in trip");
                    completion(YES);
                } else {
                    NSLog(@"Error updating IOUs in trip");
                    completion(NO);
                }
            }];
        } else {
            NSLog(@"Error saving IOU");
        }
    }];
}

+ (nonnull NSString *)parseClassName {
    return @"IOU";
}

@end
