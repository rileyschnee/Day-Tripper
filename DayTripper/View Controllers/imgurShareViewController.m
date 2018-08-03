//
//  imgurShareViewController.m
//  DayTripper
//
//  Created by Michael Abelar on 8/1/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "imgurShareViewController.h"
#import "APIManager.h"
#import "ImgurSession.h"
#import "SVProgressHUD.h"

@interface imgurShareViewController () <IMGSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) NSString* albumUrlString;
@property (strong, nonatomic) UIImage* imageToPost;
@property (weak, nonatomic) IBOutlet UIButton *selectImageButton;

@end

@implementation imgurShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
     [IMGSession anonymousSessionWithClientID:[apiDict valueForKey:@"CLIENT_ID_IMGUR"] withDelegate:self];
    //disable upload button until image view has something
    [self.uploadButton setEnabled:NO];
    self.imageToPost = nil;
    self.uploadButton.layer.cornerRadius = self.uploadButton.frame.size.height / 4;
    self.selectImageButton.layer.cornerRadius = self.selectImageButton.frame.size.height / 4;
}

- (void) viewWillAppear:(BOOL)animated {
    //create nav bar because does not have one
    //offset by 20 to account for status bar
    UINavigationBar* navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 150)];
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"Upload Photo to Imgur"];
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onTapBack)];
    navItem.leftBarButtonItem = backBtn;
    [navbar setItems:@[navItem]];
    [self.view addSubview:navbar];
}


//go back to prev screen
- (void) onTapBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// open image picker
- (IBAction)selectImageTapped:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.imageToPost = editedImage;
    [self.imageView setImage:editedImage];
    [self.uploadButton setEnabled:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadButtonPressed:(id)sender {
    
    //transform image to NSDATA
    NSData *imageData = UIImagePNGRepresentation(self.imageToPost);
    NSString* title = [self generateTitle];
    [IMGImageRequest uploadImageWithData:imageData title:title description:title linkToAlbumWithID:self.trip.albumHash progress:^(NSProgress *progress) {
        [SVProgressHUD show];
    } success:^(IMGImage *image) {
        [SVProgressHUD dismiss];
        // go back to album screen
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", error.localizedDescription);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

// creates a title and description for Imgur image post
//defaults to trip name - curr date
- (NSString*) generateTitle {
    //get string of current date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy "];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    return [NSString stringWithFormat:@"%@ - %@", self.trip.name, dateString];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
