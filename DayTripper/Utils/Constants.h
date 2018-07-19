//
//  Constants.h
//  DayTripper
//
//  Created by Riley Schnee on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
@property (strong, nonatomic) NSDictionary *placeCategories;
@property (strong, nonatomic) NSDictionary *foodCategories;
@property (strong, nonatomic) NSDictionary *eventCategories;
-(void)cats;
@end
