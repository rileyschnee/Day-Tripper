//
//  SummaryViewController.h
//  DayTripper
//
//  Created by Kimora Kong on 7/31/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface SummaryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *summaryField;
- (IBAction)onClickBtn:(id)sender;
@property (strong, nonatomic) Trip *trip;
@end
