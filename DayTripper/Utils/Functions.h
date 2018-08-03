//
//  Functions.h
//  DayTripper
//
//  Created by Michael Abelar on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

// this class is for commonmly used functions throughout code

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface Functions : NSObject

+ (NSArray*) getCellsFromTable:(UITableView*)tableView;
+ (NSString *)primaryActivityCategory:(id<Activity>)activity;
+ (void)fetchUserIOUs:(PFUser *)user withCompletion:(void (^)(NSArray *ious))completionHandler;
@end
