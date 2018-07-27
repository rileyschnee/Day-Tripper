//
//  CategoryCollectionViewDelegate.h
//  DayTripper
//
//  Created by Riley Schnee on 7/26/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol CategoryCollectionCellDelegate
-(void)addCategoryToArray:(NSString *) cat;
-(void)removeCategoryFromArray:(NSString *) cat;
-(BOOL)isCategoryInArray:(NSString *) cat;
@end
