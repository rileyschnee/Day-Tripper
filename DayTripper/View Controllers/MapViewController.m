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

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%f", self.trip.latitude);
    self.mapView.delegate = self;

    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.trip.latitude, self.trip.longitude), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:region animated:false];
    
    for (id<Activity> activity in self.trip.activities) {
        MKPointAnnotation *point = [MKPointAnnotation new];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(activity.latitude, activity.longitude);
        point.coordinate = coor;
        [self.mapView addAnnotation:point];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKPinAnnotationView *annotView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (annotView == nil) {
        annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        UIColor *orange = [UIColor colorWithRed:240.0f/255.0f green:102.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
        UIColor *blue = [UIColor colorWithRed:92.0f/255.0f green:142.0f/255.0f blue:195.0f/255.0f alpha:1.0f];
        annotView.pinTintColor = blue;
    }
    
    return annotView;
}

- (void)viewDidAppear:(BOOL)animated {
    //hide bar button item
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
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
