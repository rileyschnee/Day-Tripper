//
//  MapViewController.m
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "QuizViewController.h"
#import "Activity.h"
#import <Corelocation/CoreLocation.h>
#import "DetailsViewController.h"
#import "SVProgressHUD.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *name;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%f", self.trip.latitude);
    self.mapView.delegate = self;

    [SVProgressHUD show];
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.trip.latitude, self.trip.longitude), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:false];
    
    for (id<Activity> activity in self.trip.activities) {
        MKPointAnnotation *point = [MKPointAnnotation new];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(activity.latitude, activity.longitude);
        point.coordinate = coor;
        point.title = activity.name;
        [self.mapView addAnnotation:point];
    }
    [SVProgressHUD dismiss];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKPinAnnotationView *annotView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (annotView == nil) {
        annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        // UIColor *orange = [UIColor colorWithRed:240.0f/255.0f green:102.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
        UIColor *blue = [UIColor colorWithRed:92.0f/255.0f green:142.0f/255.0f blue:195.0f/255.0f alpha:1.0f];
        annotView.pinTintColor = blue;
        
         annotView.canShowCallout = YES;
         annotView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    }
    
    return annotView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    self.name = view.annotation.title;
    [self performSegueWithIdentifier:@"CallOutSegue" sender:view];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    //hide bar button item
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    if (self.navigationController.navigationBar.backItem == nil) {
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style: UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = homeButton;
    }
}

- (void)back{
    [self performSegueWithIdentifier:@"mapToHome" sender:nil];
    self.tabBarController.tabBar.hidden = YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[DetailsViewController class]]) {
        DetailsViewController *detailPage = [segue destinationViewController];
        for (id<Activity> activity in self.trip.activities) {
            if ([activity.name isEqualToString:self.name]) {
                detailPage.activity = activity;
            }
        }
        detailPage.fromMap = YES;
    }
}


@end
