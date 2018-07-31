//
//  IOU.h
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "PFObject.h"
#import "Trip.h"

@interface IOU : PFObject <PFSubclassing>
@property (strong, nonatomic) PFUser *payer;
@property (strong, nonatomic) PFUser *payee;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSNumber *completed;

+ (void) saveIOUwithAmount: (NSNumber *)amount fromPayer: (PFUser *)payer toPayee: (PFUser *)payee withDescription: (NSString *)description toTrip:(Trip *)trip;

@end
