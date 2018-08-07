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
#import "APIManager.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ImgurDetailViewController.h"
#import "SVProgressHUD.h"

@interface ImgurAlbumViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIButton *cpURLButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString* albumUrlString;
// mutable array to hold all imgur image urls
@property (strong, nonatomic) NSMutableArray *imageStringUrls;
@end

@implementation ImgurAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    // Do any additional setup after loading the view.
    self.cpURLButton.layer.cornerRadius = self.cpURLButton.frame.size.height / 4;
    self.title = @"Trip Photos";
    self.imageStringUrls = [NSMutableArray new];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    self.imageStringUrls = [NSMutableArray new];

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
                  //  [self setWebViewWithString:albumURLString];
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
        
        [SVProgressHUD show];
        [self populateUrls:^{
            [self refreshAsync];
        }];
        
        [self setWebViewWithString:albumURLString];
    }
}

-(void) refreshAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [SVProgressHUD dismiss];
    });
}


- (void) populateUrls:(void (^)(void))completion {
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    APIManager *apiManager = [[APIManager alloc] init];
    NSString *baseURL =  [NSString stringWithFormat:@"https://api.imgur.com/3/album/%@/images", self.trip.albumId];
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    
    NSString *clientId = [NSString stringWithFormat:@"%@%@", @"Client-ID ", [apiDict valueForKey:@"CLIENT_ID_IMGUR"]];
    [paramsDict setObject:clientId forKey:@"Authorization"];

    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *images = responseDict[0][@"data"];
        for (NSDictionary* image in images) {
            [self.imageStringUrls addObject:image[@"link"]];
            // now have image urls here
            
        }
        completion();
    }];
    
}

//sets the webview with a url in the form of string
- (void) setWebViewWithString:(NSString*) stringUrl {
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  //  [self.webView loadRequest:requestObj];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[imgurShareViewController class]]) {
        imgurShareViewController *imgurVC = (imgurShareViewController*) segue.destinationViewController;
        imgurVC.trip = self.trip;
    } else if ([sender isKindOfClass:[ImgurCell class]]){
        ImgurCell  *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
        ImgurDetailViewController *imgurDetailVC = (ImgurDetailViewController*) segue.destinationViewController;
        imgurDetailVC.imageURL = [NSURL URLWithString:self.imageStringUrls[indexPath.item]];
        [imgurDetailVC.pictureView setImageWithURL:imgurDetailVC.imageURL];
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

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ImgurCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImgurCell" forIndexPath:indexPath];
    cell.imageURL = [NSURL URLWithString:self.imageStringUrls[indexPath.item]];
    [cell.pictureView setImageWithURL:cell.imageURL];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageStringUrls.count;
}

@end
