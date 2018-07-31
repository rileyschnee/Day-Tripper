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

+ (void) saveIOUwithAmount: ( NSNumber * )amount fromPayer: (PFUser * )payer toPayee: (PFUser *)payee withDescription: (NSString * )description toTrip:(Trip * )trip{
    
    IOU *newIOU = [IOU new];
    newIOU.amount = amount;
    newIOU.payer = payer;
    newIOU.payee = payee;
    newIOU.description = description;
    newIOU.completed = @NO;
    //actually save the IOU
    [newIOU saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"IOU successfully saved!");
        } else {
            NSLog(@"Error saving IOU");
        }
    }];
    [trip addUniqueObject:newIOU forKey:@"ious"];
    [trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"Successfully updated IOUs in trip");
        } else {
            NSLog(@"Error updating IOUs in trip");
        }
    }];
    
}
+ (nonnull NSString *)parseClassName {
    return @"IOU";
}

@end
