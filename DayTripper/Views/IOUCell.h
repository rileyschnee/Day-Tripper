//
//  IOUCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IOU.h"

@interface IOUCell : UITableViewCell
@property (strong, nonatomic) IOU *iou;
@property (weak, nonatomic) IBOutlet UILabel *iouLabel;

@end
