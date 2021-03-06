//
//  SettingsViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/23/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <NYAlertViewController/NYAlertViewController.h>
#import "Functions.h"

@interface SettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldFirst;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldSecond;

@property (strong, nonatomic) PFFile *profilePic;
@end


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // UI for Text Fields
    [self.emailField setBorderStyle:UITextBorderStyleNone];
    [self.nameField setBorderStyle:UITextBorderStyleNone];
    [self.passwordFieldFirst setBorderStyle:UITextBorderStyleNone];
    [self.passwordFieldSecond setBorderStyle:UITextBorderStyleNone];
    
    // Setting initial information
    self.profilePicView.file = PFUser.currentUser[@"picture"];
    [self.profilePicView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error loading picture");
        }
    }];
    self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.width/2;
    self.emailField.text = PFUser.currentUser.email;
    self.nameField.text = PFUser.currentUser[@"name"];
    
    // Tap Gesture Recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Image Picker Functions

- (IBAction)clickedChangePic:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    //self.profilePic = [PFFile fileWithName:@"photo.png" data:UIImagePNGRepresentation(editedImage)];
    // Do something with the images (based on your use case)
    //editedImage = [self resizeImage:originalImage withSize:CGSizeMake(100, 100)];
    [self.profilePicView setImage:editedImage];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Button Functions

- (IBAction)saveProfile:(id)sender {
    if((![self.passwordFieldFirst.text isEqualToString:@""] && ![self.passwordFieldSecond.text isEqualToString:@""]) && [self.passwordFieldFirst.text isEqualToString:self.passwordFieldSecond.text]){
        PFUser.currentUser.password = self.passwordFieldFirst.text;
    } else if(![self.passwordFieldFirst.text isEqualToString:self.passwordFieldSecond.text]){
        [self sendPasswordAlert];
        return;
    }
    
    NSLog(@"Saving...");
    // Set current user's new information
    PFUser.currentUser[@"picture"] = [PFFile fileWithName:@"photo.png" data:UIImagePNGRepresentation(self.profilePicView.image)];
    PFUser.currentUser.email = self.emailField.text;
    PFUser.currentUser[@"name"] = self.nameField.text;
    // Save changes
    [SVProgressHUD show];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"Successfully saved profile changes");
            

        }else{
            NSLog(@"Unable to save profile changes");
        }
        [SVProgressHUD dismiss];
        
    }];
    NSLog(@"Saved!");
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.delegate reloadUserInfo];

}

- (IBAction)clickedLogout:(id)sender {
    
    NYAlertViewController *alert = [Functions alertWithTitle:@"Confirm Logout" withMessage:@"Are you sure you want to log out?"];
    [alert addAction:[NYAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[NYAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self logout];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logout{
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        appDelegate.window.rootViewController = loginViewController;
    }];
}

- (IBAction)clickedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


# pragma mark - Alert Functions

- (void)sendPasswordAlert{
    NYAlertViewController *alert = [Functions alertWithTitle:@"Password Error" withMessage:@"Passwords do not match. Try again."];
    
    [alert addAction:[NYAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];

//    UIAlertController *pwdAlert = [UIAlertController alertControllerWithTitle:@"Password Error" message:@"Passwords do not match" preferredStyle:(UIAlertControllerStyleAlert)];
//
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { // handle response here.
//    }];
//    // add the OK action to the alert controller
//    [pwdAlert addAction:okAction];
//    [self presentViewController:pwdAlert animated:YES completion:nil];
}

# pragma mark - Other Helper Functions

-(void)dismissKeyboard {
    [self.nameField endEditing:YES];
    [self.emailField endEditing:YES];
    [self.passwordFieldFirst endEditing:YES];
    [self.passwordFieldSecond endEditing:YES];
}


@end
