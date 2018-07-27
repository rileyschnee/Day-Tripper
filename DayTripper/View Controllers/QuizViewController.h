//
//  QuizViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuizReusableViewDelegate.h"
#import "QuizViewControllerDelegate.h"
#import "QuizViewControllerForCellDelegate.h"
#import "QuizReusableView.h"
#import "CategoryCollectionCell.h"
#import "CategoryCollectionViewDelegate.h"

@interface QuizViewController : UIViewController <QuizReusableViewDelegate, CategoryCollectionCellDelegate>
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSDate *tripDate;
@property (strong, nonatomic) id<QuizViewControllerDelegate> delegate;
@property (strong, nonatomic) id<QuizViewControllerForCellDelegate> catDelegate;

@end
