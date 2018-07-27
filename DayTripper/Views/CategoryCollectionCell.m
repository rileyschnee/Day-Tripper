//
//  CategoryCollectionCell.m
//  DayTripper
//
//  Created by Riley Schnee on 7/19/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "CategoryCollectionCell.h"

@implementation CategoryCollectionCell
- (void)awakeFromNib{
    [super awakeFromNib];
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCatStatus:)];
    //[self addGestureRecognizer:tap];
    //self.selected = [self.delegate isCategoryInArray:self.categoryLabel.text];

    //[self toggleWordColor];
}

- (void)toggleCatStatus:(UITapGestureRecognizer *)sender{
    if(!self.selected){
        [self.delegate addCategoryToArray:self.categoryLabel.text];
        self.selected = true;
        
    } else {
        [self.delegate removeCategoryFromArray:self.categoryLabel.text];
        self.selected = false;
    }
    [self toggleWordColor];
}

- (void)toggleWordColor{
    if(self.selected){
        self.categoryLabel.textColor = [UIColor colorWithRed:0.93 green:0.35 blue:0.02 alpha:1.0];
    } else {
        self.categoryLabel.textColor = [UIColor blackColor];
    }
}



@end
