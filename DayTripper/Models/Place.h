//
//  Place.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface Place : PFObject <PFSubclassing>
@property (strong, nonatomic) NSString *name;

@end
