//
//  ChatViewController.m
//  DayTripper
//
//  Created by Michael Abelar on 7/25/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageBody;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController

// constant for keyboard movement
int MOVEMENT_KEYBOARD = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageBody.delegate = self;
}

- (IBAction)onTapGestureRecognizer:(id)sender {
    [self.messageBody resignFirstResponder];
}
- (IBAction)sendMessageTapped:(id)sender {
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self moveElementVertically:(-1* MOVEMENT_KEYBOARD)];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
     [self moveElementVertically:MOVEMENT_KEYBOARD];
    
    [self.view endEditing:YES];
    return YES;
}


//function that moves element by delta y
- (void) moveElementVertically:(int) points {
    //move text field
    CGRect frame = self.messageBody.frame;
    frame.origin.y = frame.origin.y + points;
    [self.messageBody setFrame:frame];
    //move submit button
    CGRect frame2 = self.submitButton.frame;
    frame2.origin.y = frame2.origin.y + points;
    [self.submitButton setFrame:frame2];
}


@end
