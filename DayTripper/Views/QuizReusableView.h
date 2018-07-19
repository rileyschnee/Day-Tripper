//
//  QuizReusableView.h
//  DayTripper
//
//  Created by Riley Schnee on 7/19/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "QuizViewControllerDelegate.h"

#import "QuizReusableViewDelegate.h"
#import "QuizViewController.h"


//@protocol QuizReusableViewDelegate
//@property (strong, nonatomic) NSString *location;
//@property (nonatomic) double latitude;
//@property (nonatomic) double longitude;
//- (void)dismissKeyboard:(id)sender;
//@end


@interface QuizReusableView : UICollectionReusableView <MKLocalSearchCompleterDelegate, UITextFieldDelegate, QuizViewControllerDelegate>

@property (strong, nonatomic) MKLocalSearchCompleter *completer;
@property(nonatomic, readonly, strong) NSArray <MKLocalSearchCompletion *> *results;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (strong, nonatomic) id<QuizReusableViewDelegate> delegate;

@property (nonatomic) int lastEditedLocation;
@property (nonatomic) int prevTextFieldLength;

- (void)textFieldDidChange:(UITextField *)textField;

@end
