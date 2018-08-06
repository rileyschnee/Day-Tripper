//
//  MapResultsViewController.m
//  DayTripper
//
//  Created by Kimora Kong on 8/3/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "MapResultsViewController.h"
#import "Activity.h"
#import "SVProgressHUD.h"
#import "DetailsViewController.h"

@interface MapResultsViewController () <MKMapViewDelegate> 
@property (strong, nonatomic) NSString *name;
// contains all activities
@property (strong, nonatomic) NSMutableArray *allActivities;

@end

@implementation MapResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.resultsMap.delegate = self;
    [SVProgressHUD show];
    NSMutableArray *arrayOfPoints = [[NSMutableArray alloc] init];
    // iterate through the three sub arrays of activities to make one array consisting of all activities
    self.allActivities = [[NSMutableArray alloc] init];
    for (NSMutableArray* placeFoodEventArray in self.activities) {
        for (id<Activity> activity in placeFoodEventArray) {
            [self.allActivities addObject:activity];
        }
    }
    for (id<Activity> activity in self.allActivities) {
        MKPointAnnotation *point = [MKPointAnnotation new];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(activity.latitude, activity.longitude);
        point.coordinate = coor;
        point.title = activity.name;
        //[self.mapView addAnnotation:point];
        [arrayOfPoints addObject:point];
    }
    
    // Calculate center of points
    CLLocation *center = [self centerOfAnnotations:arrayOfPoints];
    CLLocationDistance maxdistance = 0.0;
    
    for (int i = 1; i < [self.allActivities count]; i++) {
        CLLocation *temploc = [[CLLocation alloc] initWithLatitude:[[self.allActivities objectAtIndex:i] latitude] longitude:[[self.allActivities objectAtIndex:i] longitude]];
        CLLocationDistance distant = [center distanceFromLocation:temploc];
        if (distant > maxdistance) {
            maxdistance = distant;
        }
    }
    
    // Set region
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(center.coordinate.latitude, center.coordinate.longitude), 1.5*maxdistance, 1.5*maxdistance);
    [self.resultsMap setRegion:region animated:false];
    // Add points to map
    for(MKPointAnnotation *point in arrayOfPoints){
        [self.resultsMap addAnnotation:point];
    }
    
    [SVProgressHUD dismiss];
}
// returns a MKCoordinateRegion that encompasses an array of MKAnnotations

- (CLLocation *)centerOfAnnotations:(NSArray *)annotations {
    
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees minLon = 180.0;
    CLLocationDegrees maxLon = -180.0;
    
    for (id <MKAnnotation> annotation in annotations) {
        if (annotation.coordinate.latitude < minLat) {
            minLat = annotation.coordinate.latitude;
        }
        if (annotation.coordinate.longitude < minLon) {
            minLon = annotation.coordinate.longitude;
        }
        if (annotation.coordinate.latitude > maxLat) {
            maxLat = annotation.coordinate.latitude;
        }
        if (annotation.coordinate.longitude > maxLon) {
            maxLon = annotation.coordinate.longitude;
        }
    }
    
    // MKCoordinateSpan span = MKCoordinateSpanMake(maxLat - minLat + .05, maxLon - minLon + .05);
    
    //CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat - (maxLat - minLat) / 2), maxLon - (maxLon - minLon)/ 2);
    CLLocation *center = [[CLLocation alloc] initWithLatitude:(maxLat - (maxLat - minLat) / 2) longitude:(maxLon - (maxLon - minLon)/ 2)];
    return center;
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
    [self performSegueWithIdentifier:@"resultsCallOut" sender:view];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    DetailsViewController *detailPage = [segue destinationViewController];
    for (id<Activity> activity in self.allActivities) {
        if ([activity.name isEqualToString:self.name]) {
            detailPage.activity = activity;
        }
    }
    detailPage.fromMap = YES;
}

- (IBAction)didTapBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
