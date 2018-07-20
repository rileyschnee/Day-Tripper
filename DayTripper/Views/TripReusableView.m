//
//  TripReusableView.m
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "TripReusableView.h"

@implementation TripReusableView
- (void)setTrip:(Trip *)trip{
    _trip = trip;
    self.tripNameLabel.text = self.trip.name;
    self.tripCityLabel.text = [self.trip.city substringToIndex:[self.trip.city rangeOfString:@","].location];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
    self.tripDateLabel.text = [dateFormatter stringFromDate:self.trip.tripDate];
    NSLog(@"SETTING TRIP IN REUSABLE VIEW");
}
@end
