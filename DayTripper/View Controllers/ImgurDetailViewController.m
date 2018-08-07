//
//  ImgurDetailViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 8/6/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ImgurDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import <Photos/Photos.h>
#import <NYAlertViewController/NYAlertViewController.h>
#import "Functions.h"

@interface ImgurDetailViewController ()

@end

@implementation ImgurDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.pictureView setImageWithURL:self.imageURL];
}

- (IBAction)didTapDownloadImage:(id)sender {
    UIImage* image = self.pictureView.image;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        changeRequest.creationDate          = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            [self indicateSaved];
        }
        else {
            NSLog(@"error saving to photos: %@", error);
        }
    }];
}

// function to tell the user that the image has been successfully saved
- (void) indicateSaved {
    dispatch_async(dispatch_get_main_queue(), ^{
        NYAlertViewController *alert = [Functions alertWithTitle:@"Image Saved!" withMessage:@"Your image has been saved to the camera roll"];
        [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}


@end
