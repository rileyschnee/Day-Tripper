//
//  CategoryCollectionCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/19/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryCollectionCellDelegate
-(void)addCategoryToArray:(NSString *) cat;
-(void)removeCategoryFromArray:(NSString *) cat;
-(BOOL)isCategoryInArray:(NSString *) cat;
@end

@interface CategoryCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) NSString *categoryAlias;
@property (strong, nonatomic) id<CategoryCollectionCellDelegate> delegate;
- (void)toggleCatStatus:(UITapGestureRecognizer *)sender;
@end
