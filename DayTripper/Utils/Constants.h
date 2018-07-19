//
//  Constants.h
//  DayTripper
//
//  Created by Riley Schnee on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
@property (strong, nonatomic) NSMutableDictionary *placeCategories;
@property (strong, nonatomic) NSMutableDictionary *foodCategories;
@property (strong, nonatomic) NSMutableDictionary *eventCategories;

- (void)setCategories;
@end
