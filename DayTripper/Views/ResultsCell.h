//
//  ResultsCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "Food.h"
#import "Activity.h"

@protocol ResultsCellDelegate
-(void)addActivityToTrip:(id <Activity>) activity;
-(void)removeActivityFromTrip:(id <Activity>) activity;
-(BOOL)isActivityInTrip:(id <Activity>) activity;
@end

@interface ResultsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (strong, nonatomic) id <Activity> activity;
@property (weak, nonatomic) id<ResultsCellDelegate> delegate;
@end
