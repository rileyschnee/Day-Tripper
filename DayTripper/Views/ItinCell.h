//
//  ItinCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "Activity.h"
#import "Food.h"
#import "Functions.h"

@interface ItinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeCategoryLabel;
@property (strong, nonatomic) id<Activity> activity;
@end
