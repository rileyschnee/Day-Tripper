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
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) NSString* albumUrlString;
@property (strong, nonatomic) UIImage* imageToPost;

@end

@implementation imgurShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [IMGSession anonymousSessionWithClientID:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_IMGUR"] withDelegate:self];
    //disable upload button until image view has something
    [self.uploadButton setEnabled:NO];
    self.imageToPost = nil;
}


- (void)viewDidAppear:(BOOL)animated {
    
    if ([self.trip.albumId isEqualToString:@""]) {
        //set up a new album
        [IMGAlbumRequest createAlbumWithTitle:self.trip.name imageIDs:[NSArray new] success:^(NSString *albumID, NSString *albumDeleteHash) {
            self.trip.albumId = albumID;
            self.trip.albumHash = albumDeleteHash;
            [self.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    //set the url to the album url
                    NSString* albumURLStringLabel = [NSString stringWithFormat:@"Album URL: https://imgur.com/a/%@", self.trip.albumId];
                    NSString* albumURLString = [NSString stringWithFormat:@"https://imgur.com/a/%@", self.trip.albumId];
                    self.urlLabel.text = albumURLStringLabel;
                    [self setWebViewWithString:albumURLString];
                    self.albumUrlString = albumURLString;
                } else {
                    NSLog(@"Error saving trip");
                }
            }];
            
        } failure:^(NSError *error) {
            NSLog(error.localizedDescription);
        }];
    } else {
        //already have album so load it
        NSString* albumURLStringLabel = [NSString stringWithFormat:@"Album URL: https://imgur.com/a/%@", self.trip.albumId];
        NSString* albumURLString = [NSString stringWithFormat:@"https://imgur.com/a/%@", self.trip.albumId];
        self.urlLabel.text = albumURLStringLabel;
        self.albumUrlString = albumURLString;
        [self setWebViewWithString:albumURLString];
    }
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

//sets the webview with a url in the form of string
- (void) setWebViewWithString:(NSString*) stringUrl {
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (IBAction)uploadButtonPressed:(id)sender {
    
    //transform image to NSDATA
    NSData *imageData = UIImagePNGRepresentation(self.imageToPost);
    NSString* title = [self generateTitle];
    [IMGImageRequest uploadImageWithData:imageData title:title description:title linkToAlbumWithID:self.trip.albumHash progress:^(NSProgress *progress) {
        [SVProgressHUD show];
    } success:^(IMGImage *image) {
        [SVProgressHUD dismiss];
        //set timer for 3 seconds then refresh webview
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.webView reload];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(error.localizedDescription);
    }];
    
}

//copy imgur album url to clipboard
- (IBAction)copyURLPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = self.albumUrlString ;
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
