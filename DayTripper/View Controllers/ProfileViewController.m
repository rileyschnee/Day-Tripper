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
#import "DMViewController.h"
#import "ResourcesViewController.h"

@interface ProfileViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet MKMapView *userMapView;
@property (strong, nonatomic) NSMutableArray *triparray;

- (IBAction)didTapBack:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userMapView.delegate = self;
    self.usernameLabel.text = self.user.username;
    self.nameLabel.text = self.user[@"name"];
    self.profilePicView.file = self.user[@"picture"];
    [self.profilePicView loadInBackground];
    self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.width/2;
    
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
//                         }
                        self.triparray = [NSMutableArray arrayWithArray:trips];
                        
                        
                        for (Trip *trip in self.triparray) {
                            MKPointAnnotation *point = [MKPointAnnotation new];
                            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(trip.latitude, trip.longitude);
                            point.coordinate = coor;
                            point.title = trip.city;
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

        MKPinAnnotationView *annotView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (annotView == nil) {
            annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            // UIColor *orange = [UIColor colorWithRed:240.0f/255.0f green:102.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
            UIColor *blue = [UIColor colorWithRed:92.0f/255.0f green:142.0f/255.0f blue:195.0f/255.0f alpha:1.0f];
            annotView.pinTintColor = blue;
            
            annotView.canShowCallout = YES;
            // annotView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }

    return annotView;
}

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
    
    if ([segue.destinationViewController isKindOfClass:[DMViewController class]]) {
        DMViewController* dmViewController = [segue destinationViewController];
        dmViewController.otherPersonUserName = self.user.username;
    }
    else {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
    
}




@end
