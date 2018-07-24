//
//  ProfileViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/24/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ProfileViewController.h"
#import <MapKit/MapKit.h>
#import <Corelocation/CoreLocation.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet MKMapView *userMapView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setUser:(PFUser *)user{
    _user = user;
    self.profilePicView.file = user[@"picture"];
    self.usernameLabel.text = user.username;
}

@end
