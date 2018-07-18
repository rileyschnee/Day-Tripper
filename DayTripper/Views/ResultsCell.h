//
//  ResultsCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@protocol ResultsCellDelegate
-(void)addPlaceToTrip:(Place *)place;
-(void)removePlaceFromTrip:(Place *)place;
-(BOOL)isPlaceInTrip:(Place *)place;

@end

@interface ResultsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (strong, nonatomic) Place *place;
@property (weak, nonatomic) id<ResultsCellDelegate> delegate;
@end
