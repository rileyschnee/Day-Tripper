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
#import "Trip.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet MKMapView *userMapView;
@property (strong, nonatomic) NSMutableArray *triparray;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameLabel.text = self.user.username;
    self.nameLabel.text = self.user[@"name"];
    self.profilePicView.file = self.user[@"picture"];
    [self.profilePicView loadInBackground];
    self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.width/2;
    
    [self sortTrips:self.usernameLabel.text];
    
    for (Trip *trip in self.triparray) {
        MKPointAnnotation *point = [MKPointAnnotation new];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(trip.latitude, trip.longitude);
        point.coordinate = coor;
        [self.userMapView addAnnotation:point];
    }
    
    
    
}

- (void) sortTrips:(NSString*) username {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            if (users.count > 0) {
                PFUser* user = users[0];
                PFQuery *query = [PFQuery queryWithClassName:@"Trip"];
                [query orderByDescending:@"createdAt"];
                [query includeKey:@"planner"];
                [query whereKey:@"attendees" equalTo:user];
                query.limit = 20;
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *trips, NSError *error) {
                    if (trips != nil) {
                        for (Trip *trip in trips) {
                            for (PFUser *attendee in trip.attendees) {
                                if (attendee == user) {
                                    [self.triparray addObject:trip];
                                }
                            }
                        }
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
                
                    //if attendee = user then add the trip to an array (so u can display)
            }
            else {
                // TODO handle user not existing
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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


@end
