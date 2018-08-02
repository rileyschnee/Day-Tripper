//
//  TripReusableView.h
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@protocol TripReusableViewDelegate
- (void)reloadAttendeeData;
- (void)showAlert:(UIAlertController *)alert;
- (void)showAlertView:(UIAlertView *)alert;
@property (strong, nonatomic) Trip *trip;
@end


@interface TripReusableView : UICollectionReusableView <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *googlePhotosButton;
@property (strong, nonatomic) Trip *trip;
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (weak, nonatomic) IBOutlet UILabel *tripNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *highLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareToImgurButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameToAdd;
@property (weak, nonatomic) IBOutlet UIButton *iouButton;
@property (weak, nonatomic) IBOutlet UIView *attendeeBar;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
//description of the weather
@property (weak, nonatomic) IBOutlet UILabel *attendeeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addAttendeeButton;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) id<TripReusableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *summaryBtn;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) UITextView *textView;
- (IBAction)didTapDescription:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *editDescripBtn;
- (IBAction)didTapEdit:(id)sender;
@end
