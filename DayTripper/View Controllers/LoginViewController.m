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
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.usernameField endEditing:YES];
    [self.passwordField endEditing:YES];
}

- (IBAction)clickSignUp:(id)sender {
    if([self.passwordField.text isEqual:@""]){
        [self noPasswordAlert];
    } else if([self.usernameField.text isEqual:@""]){
        [self noUsernameAlert];
    }else{
        [self registerUser];
    }
}
- (IBAction)clickLogin:(id)sender {
    if([self.passwordField.text isEqual:@""]){
        [self noPasswordAlert];
    } else if([self.usernameField.text isEqual:@""]){
        [self noUsernameAlert];
    }else{
        [self loginUser];
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
    UIAlertController *emptyUSRAlert = [UIAlertController alertControllerWithTitle:@"Empty Username" message:@"You must enter a username" preferredStyle:(UIAlertControllerStyleAlert)];
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
