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
    self.selected = [self.delegate isCategoryInArray:self.categoryLabel.text];
    if(self.selected){
        self.backgroundColor = [UIColor yellowColor];
    }
}
- (void)toggleCatStatus:(UITapGestureRecognizer *)sender{
    if(!self.selected){
        [self.delegate addCategoryToArray:self.categoryLabel.text];
        self.selected = YES;
        
    } else {
        [self.delegate removeCategoryFromArray:self.categoryLabel.text];
        self.selected = NO;
    }
    
    if(self.selected){
        self.backgroundColor = [UIColor yellowColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}


- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}



@end
