//
//  Functions.m
//  DayTripper
//
//  Created by Michael Abelar on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Functions.h"

@implementation Functions

// common functions that will be needed


- (NSArray*) getCellsFromTable:(UITableView*)tableView {
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
        {
            [cells addObject:[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    return [cells copy];
}

- (double) distanceBetweenTwoPlaces:(Place*)place1 place2:(Place*)place2 {
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:place1.latitude longitude:place1.longitude];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:place2.latitude longitude:place2.longitude];
    return [startLocation distanceFromLocation:endLocation];
}

@end
