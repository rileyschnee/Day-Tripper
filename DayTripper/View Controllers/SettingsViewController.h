//
//  SettingsViewController.h
//  DayTripper
//
//  Created by Riley Schnee on 7/23/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "HomeViewController.h"
@protocol SettingsViewControllerDelegate
- (void)reloadUserInfo;
@end

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet PFImageView *profilePicView;
@property (strong, nonatomic) id<SettingsViewControllerDelegate> delegate;
@end
