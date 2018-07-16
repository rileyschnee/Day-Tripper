//
//  Trip.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trip : NSObject
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSMutableArray *places;

@end
