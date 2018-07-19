//
//  QuizReusableViewDelegate.h
//  DayTripper
//
//  Created by Riley Schnee on 7/19/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

@protocol QuizReusableViewDelegate
@property (strong, nonatomic) NSString *location;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@end
