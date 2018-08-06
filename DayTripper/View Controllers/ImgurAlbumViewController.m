//
//  ImgurAlbumViewController.m
//  DayTripper
//
//  Created by Michael Abelar on 8/2/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ImgurAlbumViewController.h"
#import "ImgurSession.h"
#import "imgurShareViewController.h"
#import "ImgurCell.h"

@interface ImgurAlbumViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIButton *cpURLButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString* albumUrlString;
@end

@implementation ImgurAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    // Do any additional setup after loading the view.
    self.cpURLButton.layer.cornerRadius = self.cpURLButton.frame.size.height / 4;

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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.webView reload];
        });
    }
}

//sets the webview with a url in the form of string
- (void) setWebViewWithString:(NSString*) stringUrl {
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[imgurShareViewController class]]) {
        imgurShareViewController *imgurVC = (imgurShareViewController*) segue.destinationViewController;
        imgurVC.trip = self.trip;
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButtonPressed:(id)sender {
}

- (IBAction)copyUrlButtonPressed:(id)sender {
    [UIPasteboard generalPasteboard].string = self.albumUrlString;
}

//- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    ImgurCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImgurCell" forIndexPath:indexPath];
//}
//
//- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    
//}

@end
