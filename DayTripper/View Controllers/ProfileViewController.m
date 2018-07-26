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
#import "ResourcesViewController.h"
#import "ItinViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet MKMapView *userMapView;
@property (strong, nonatomic) NSMutableArray *triparray;
- (IBAction)didTapBack:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameLabel.text = self.user.username;
    self.profilePicView.file = self.user[@"picture"];
    [self.profilePicView loadInBackground];

    
    [self sortTrips:self.usernameLabel.text];
    
    
    
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
                [query includeKey:@"latitude"];
                [query includeKey:@"longitude"];
                //[query whereKey:@"attendees" equalTo:user.objectId];
                [query whereKey:@"attendees" containsString:user.objectId];
                query.limit = 20;
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *trips, NSError *error) {
                    if (trips != nil) {
//                        for (Trip *trip in trips) {
//                            for (PFUser *attendee in trip.attendees) {
//                                if (attendee == user) {
//                                    [self.triparray addObject:trip];
//                                }
//                            }
//                        }
                        self.triparray = [NSMutableArray arrayWithArray:trips];
                        
                        
                        for (Trip *trip in self.triparray) {
                            MKPointAnnotation *point = [MKPointAnnotation new];
                            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(trip.latitude, trip.longitude);
                            point.coordinate = coor;
                            [self.userMapView addAnnotation:point];
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

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//
//    MKAnnotationView *theView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
//    theView.pinTintColor = MKPinAnnotationColorGreen;
//
//    return theView;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapBack:(id)sender {
    [self performSegueWithIdentifier:@"backToTab" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    UITabBarController *tabbar = [segue destinationViewController];
    UINavigationController *navController = [tabbar.viewControllers objectAtIndex:0];
    ItinViewController *itinerary = (ItinViewController *) navController.topViewController;
    itinerary.trip = self.trip;
    //set the trip title
    tabbar.title = self.trip.name;
    
    
//    ResourcesViewController *resourceViewController = [tabbar.viewControllers objectAtIndex:2];
//    resourceViewController.trip = self.trip;
}




@end
