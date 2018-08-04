//
//  IOUCell.m
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "IOUCell.h"
#import <Parse/Parse.h>
#import <NYAlertViewController/NYAlertViewController.h>

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
        
        NYAlertViewController *alert = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
        
        // Set a title and message
        NSString *title = [NSString stringWithFormat:@"Mark as %@?", switchToStatus];
        alert.title = NSLocalizedString(title, nil);
        alert.message = NSLocalizedString(@"", nil);
        
        // Customize appearance as desired
        alert.buttonCornerRadius = 20.0f;
        alert.alertViewCornerRadius = 20.0f;
        alert.view.tintColor = [UIColor blueColor];
        
        alert.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
        alert.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        alert.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alert.buttonTitleFont.pointSize];
        alert.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alert.cancelButtonTitleFont.pointSize];
        
        alert.swipeDismissalGestureEnabled = NO;
        alert.backgroundTapDismissalGestureEnabled = NO;
        
        // Add alert actions
        [alert addAction:[NYAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
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
        }]];
        
        [alert addAction:[NYAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
            [self.delegate dismissAlert:alert];
        }]];
        [self.delegate showAlert:alert];
        
    }
}

@end
