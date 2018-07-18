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
        [self.delegate addPlaceToTrip:self.place];
        self.checkButton.selected = YES;
    } else {
        [self.delegate removePlaceFromTrip:self.place];
        self.checkButton.selected = NO;
    }
}

-(void)setPlace:(Place *)place{
    _place = place;
    self.placeNameLabel.text = place.name;
    // Make the button checked if the place is found in the places added to the chosen places array
    self.checkButton.selected = [self.delegate isPlaceInTrip:place];
    NSLog(@"%d", [self.delegate isPlaceInTrip:place]);
}


@end
