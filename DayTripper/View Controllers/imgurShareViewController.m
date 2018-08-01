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

@interface imgurShareViewController () <IMGSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) NSString* albumUrlString;

@end

@implementation imgurShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [IMGSession anonymousSessionWithClientID:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_IMGUR"] withDelegate:self];
    
    //disable upload button until image view has something
    [self.uploadButton setEnabled:NO];
    
    if ([self.trip.albumId isEqualToString:@""]) {
        //set up a new album
        [IMGAlbumRequest createAlbumWithTitle:self.trip.name imageIDs:[NSArray new] success:^(NSString *albumID, NSString *albumDeleteHash) {
            self.trip.albumId = albumID;
            //set the url to the album url
            NSString* albumURLStringLabel = [NSString stringWithFormat:@"Album URL: https://imgur.com/a/%@", self.trip.albumId];
            NSString* albumURLString = [NSString stringWithFormat:@"https://imgur.com/a/%@", self.trip.albumId];
            self.urlLabel.text = albumURLStringLabel;
            [self setWebViewWithString:albumURLString];
            self.albumUrlString = albumURLString;
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
    [self.imageView setImage:editedImage];
    [self.uploadButton setEnabled:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setWebViewWithString:(NSString*) stringUrl {
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (IBAction)uploadButtonPressed:(id)sender {
    
}

- (IBAction)copyURLPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = self.albumUrlString ;
}


@end
