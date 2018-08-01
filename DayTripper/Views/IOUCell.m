//
//  IOUCell.m
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "IOUCell.h"
#import <Parse/Parse.h>

@implementation IOUCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setIou:(IOU *)iou {
    _iou = iou;
    
}

- (void)togglePaidStatus:(UITapGestureRecognizer *)sender{
    PFUser *payee = self.iou[@"payee"];
    PFUser *payer = self.iou[@"payer"];
    if([payee.username isEqualToString:PFUser.currentUser.username] || [payer.username isEqual:PFUser.currentUser.username]){
        NSString *switchToStatus;
        if([self.iou[@"completed"] isEqual:[NSNumber numberWithBool:TRUE]]){
            switchToStatus = @"unpaid";
        } else{
            switchToStatus = @"paid";
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Mark as %@?", switchToStatus]  message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"%@ completed bool before", self.iou[@"completed"]);
            
            if([self.iou[@"completed"] isEqual:[NSNumber numberWithBool:TRUE]]){
                [self.iou setObject:[NSNumber numberWithBool:FALSE] forKey:@"completed"];
                self.paidStatusImage.image = [UIImage imageNamed:@"unpaid"];
            } else {
                [self.iou setObject:[NSNumber numberWithBool:TRUE] forKey:@"completed"];
                self.paidStatusImage.image = [UIImage imageNamed:@"paid"];
            }
            NSLog(@"%@ completed bool after", self.iou[@"completed"]);

            [self.iou saveInBackground];
        }];
        [alertController addAction:yesAction];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Cancelled");
        }];
        [alertController addAction:noAction];
        [self.delegate showAlert:alertController];
    }
}

@end
