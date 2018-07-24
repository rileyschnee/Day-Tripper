//
//  LoginViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
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

//when the selector goes to sign up or to login
- (IBAction)actionSelectorChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        // sign up - show email
        [self.emailField setHidden:NO];
        [self.emailBar setHidden:NO];
        [self.emailLabel setHidden:NO];
        [self.actionButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    } else {
        // login - hide the email
        [self.emailField setHidden:YES];
        [self.emailBar setHidden:YES];
        [self.emailLabel setHidden:YES];
        [self.actionButton setTitle:@"Login" forState:UIControlStateNormal];
    }
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
    NSString *username = self.usernameField.text;
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
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    UIImage *image = [UIImage imageNamed:@"profile-pic-placeholder"];
    newUser[@"picture"] = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    newUser.email = self.emailField.text;
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self errorAlert];
        } else {
            // manually segue to logged in view
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}



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
