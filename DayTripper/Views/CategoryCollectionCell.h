//
//  CategoryCollectionCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/19/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuizViewController.h"
#import "CategoryCollectionViewDelegate.h"
#import "QuizViewControllerForCellDelegate.h"

@interface CategoryCollectionCell : UICollectionViewCell <QuizViewControllerForCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) NSString *categoryAlias;
@property (strong, nonatomic) id<CategoryCollectionCellDelegate> delegate;
- (void)toggleCatStatus:(UITapGestureRecognizer *)sender;
@end
