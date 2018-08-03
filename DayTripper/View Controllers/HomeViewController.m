//
//  HomeViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "HomeViewController.h"
#import "Trip.h"
#import "TripCell.h"
#import "ItinViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "SettingsViewController.h"
#import "IOUViewController.h"
#import "Functions.h"
#import "SVProgressHUD.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *trips;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addTripButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.navigationItem setHidesBackButton:YES];
    // Do any additional setup after loading the view.

    self.profileImageView.file = (PFFile *)PFUser.currentUser[@"picture"];
    //[self.profileImageView loadInBackground];
    [self.profileImageView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error loading picture");
        }
    }];
    self.usernameLabel.text = PFUser.currentUser.username;
    self.nameLabel.text = PFUser.currentUser[@"name"];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
    self.addTripButton.layer.cornerRadius = self.addTripButton.frame.size.height / 4;

    [self fetchTrips];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TripCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCell" forIndexPath:indexPath];
    cell.trip = self.trips[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trips.count;
}

- (void)fetchTrips {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Trip"]; 
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"planner"];
    [query includeKey:@"activities"];
    [query whereKey:@"attendees" containsString:[PFUser currentUser].objectId];
    query.limit = 20;
    [SVProgressHUD show];
    [query findObjectsInBackgroundWithBlock:^(NSArray *trips, NSError *error) {
        if (trips != nil) {
            self.trips = [trips mutableCopy];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].

    if([[segue destinationViewController] isKindOfClass:[UITabBarController class]]){
        UITableViewCell  *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Trip *trip = self.trips[indexPath.item];
        UITabBarController *tabbar = [segue destinationViewController];
        UINavigationController *navController = [tabbar.viewControllers objectAtIndex:0];
        ItinViewController *itinerary = (ItinViewController *) navController.topViewController;
        //create edit bar button item
        itinerary.trip = trip;
        itinerary.fromHomeEdit = YES;
        itinerary.fromHomeToResources = YES;
        //set the trip title
        tabbar.title = trip.name;
    }
    else if([[segue destinationViewController] isKindOfClass:[UINavigationController class]]){
        UINavigationController *navController = [segue destinationViewController];
        if([navController.topViewController isKindOfClass:[IOUViewController class]]){
            UINavigationController *navController = [segue destinationViewController];
            IOUViewController *iouVC = (IOUViewController *)navController.topViewController;
            iouVC.isUsersIOUs = TRUE;
            iouVC.title = @"My IOUs";
            [Functions fetchUserIOUs:PFUser.currentUser withCompletion:^(NSArray *ious) {
                iouVC.iouArray = [ious mutableCopy];
                NSLog(@"COMPLETION HANDLER %@", iouVC.iouArray);
            }];
        }
    }
}

- (void)reloadUserInfo{
    self.profileImageView.file = (PFFile *)PFUser.currentUser[@"picture"];
    [self.profileImageView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error loading profile picture");
        }
    }];
    self.usernameLabel.text = PFUser.currentUser.username;
    self.nameLabel.text = PFUser.currentUser[@"name"];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
}

@end

