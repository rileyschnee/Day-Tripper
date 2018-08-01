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

@interface imgurShareViewController () <IMGSessionDelegate>

@end

@implementation imgurShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [IMGSession anonymousSessionWithClientID:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_IMGUR"] withDelegate:self];
    
    
    
    if ([self.trip.albumId isEqualToString:@""]) {
        //set up a new album
        [IMGAlbumRequest createAlbumWithTitle:self.trip.name imageIDs:[NSArray new] success:^(NSString *albumID, NSString *albumDeleteHash) {
            self.trip.albumId = albumID;
        } failure:^(NSError *error) {
            NSLog(error.localizedDescription);
        }];
        
    }
}




@end
