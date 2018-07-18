//
//  ResultsCell.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ResultsCell.h"

@implementation ResultsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickedCheckButton:(id)sender {
    if(!self.checkButton.selected){
        [self.delegate addActivityToTrip:self.activity];
        self.checkButton.selected = YES;
    } else {
        [self.delegate removeActivityFromTrip:self.activity];
        self.checkButton.selected = NO;
    }
}

-(void)setActivity:(id<Activity>)activity{
    _activity = activity;
    self.placeNameLabel.text = activity.name;
    // Make the button checked if the place is found in the places added to the chosen places array
    self.checkButton.selected = [self.delegate isActivityInTrip:activity];
}


@end
