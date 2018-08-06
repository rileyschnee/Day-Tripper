//
//  IOUCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IOU.h"
#import <NYAlertViewController/NYAlertViewController.h>

@protocol IOUCellDelegate
- (void)showAlert:(NYAlertViewController *)alert;
- (void)dismissAlert:(NYAlertViewController *)alert;

@end

@interface IOUCell : UITableViewCell
@property (strong, nonatomic) IOU *iou;
@property (weak, nonatomic) IBOutlet UILabel *iouLabel;
@property (weak, nonatomic) IBOutlet UIImageView *paidStatusImage;
@property (strong, nonatomic) id<IOUCellDelegate> delegate;
- (void)togglePaidStatus:(UITapGestureRecognizer *)sender;
@end
