//
//  LoginViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
// password ui components
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *passwordContainingView;

//email ui components
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIView *emailBar;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@property (weak, nonatomic) IBOutlet UISegmentedControl *actionSelector;
//the action button is either sign up or login depending on what the selector is selected to
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //set up field styles
    [self setUpTextFieldStyles:self.usernameField];
    [self setUpTextFieldStyles:self.passwordField];
    [self setUpTextFieldStyles:self.emailField];
    
    self.usernameField.delegate = self;
    
}

//this function sets up the text field styles by removing border and bg
- (void) setUpTextFieldStyles:(UITextField*) field {
    //init the uitextfield styles
    [field setBorderStyle:UITextBorderStyleNone];
    [field setNeedsDisplay];
}

-(void)dismissKeyboard {
    [self.usernameField endEditing:YES];
    [self.passwordField endEditing:YES];
    [self.emailField endEditing:YES];
}

//prevent user from typing spaces in user name or if username is too long
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
        return NO;
    }
    if (textField.text.length > 16 && range.length == 0) {
        return NO;
    }
    return YES;

}

//when the selector goes to sign up or to login
- (IBAction)actionSelectorChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        // sign up - show email
        [self.emailField setHidden:NO];
        [self.emailBar setHidden:NO];
        [self.emailLabel setHidden:NO];
        [self.actionButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        //move down password
        [UIView animateWithDuration:0.5f animations:^{
            [self moveElementVertically:30];
        }];
    } else {
        [self.actionButton setTitle:@"Login" forState:UIControlStateNormal];
        // login - hide the email
        [self.emailField setHidden:YES];
        [self.emailBar setHidden:YES];
        [self.emailLabel setHidden:YES];
        //move up password
        [UIView animateWithDuration:0.5f animations:^{
            [self moveElementVertically:-30];
        }];
        
    }
}

//function that moves element by delta y
- (void) moveElementVertically:(int) points {
    CGRect frame = self.passwordContainingView.frame;
    frame.origin.y = frame.origin.y + points;
    [self.passwordContainingView setFrame:frame];
}


- (IBAction)actionButtonPressed:(id)sender {
    if (self.actionSelector.selectedSegmentIndex == 0) {
        //sign up
        if([self.passwordField.text isEqual:@""]){
            [self noPasswordAlert];
        } else if([self.usernameField.text isEqual:@""]){
            [self noUsernameAlert];
        } else if([self.emailField.text isEqual:@""]){
            [self noEmailAlert];
        } else{
            [self registerUser];
        }
    }
    else {
        //login
        if([self.passwordField.text isEqual:@""]){
            [self noPasswordAlert];
        } else if([self.usernameField.text isEqual:@""]){
            [self noUsernameAlert];
        }else{
            [self loginUser];
        }
    }
}

- (void)loginUser{
    NSString *username = [self.usernameField.text lowercaseString];
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self errorAlert];
        } else {
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
    
    
}

- (void)registerUser{
    // initialize a user object
    PFUser *newUser = [PFUser user];
    // set user properties
    newUser.username = [self.usernameField.text lowercaseString];
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    UIImage *image = [UIImage imageNamed:@"profile-pic-placeholder"];
    PFFile *file = [PFFile fileWithName:@"photo.png" data:UIImagePNGRepresentation(image)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            newUser[@"picture"] = file;
        }
    }];
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            if ([error.localizedDescription containsString:@"Account already exists for this email"]) {
                [self emailAlreadyExistsAlert];
            }
            else if ([error.localizedDescription containsString:@"Account already exists for this username"]) {
                [self usernameAlreadyExistsAlert];
            }
            else {
                [self errorAlert];
            }
        } else {
            // manually segue to logged in view
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}


/****** ALERT FUNCTIONS ******/

- (void)noPasswordAlert{
    UIAlertController *emptyPWDAlert = [UIAlertController alertControllerWithTitle:@"Empty Password" message:@"You must enter a password" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [emptyPWDAlert addAction:okAction];
    [self presentViewController:emptyPWDAlert animated:YES completion:nil];
}

- (void)noUsernameAlert{
    UIAlertController *emptyUSRAlert = [UIAlertController alertControllerWithTitle:@"Empty Username" message:@"You must enter an username" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [emptyUSRAlert addAction:okAction];
    [self presentViewController:emptyUSRAlert animated:YES completion:nil];
}

- (void)noEmailAlert{
    UIAlertController *emptyUSRAlert = [UIAlertController alertControllerWithTitle:@"Empty Email" message:@"You must enter an email" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [emptyUSRAlert addAction:okAction];
    [self presentViewController:emptyUSRAlert animated:YES completion:nil];
}

- (void)usernameAlreadyExistsAlert{
    // Present error alert controller
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Username already exists" message:@"Please try using a different username" preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [errorAlert addAction:okAction];
    [self presentViewController:errorAlert animated:YES completion:nil];
}

- (void) emailAlreadyExistsAlert{
    // Present error alert controller
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Email already exists" message:@"Please try using a different email" preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [errorAlert addAction:okAction];
    [self presentViewController:errorAlert animated:YES completion:nil];
}

- (void)errorAlert{
    // Present error alert controller
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"An Error Occurred" message:@"Please try again later" preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
    }];
    // add the OK action to the alert controller
    [errorAlert addAction:okAction];
    [self presentViewController:errorAlert animated:YES completion:nil];
}

@end
