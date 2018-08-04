//
//  MapResultsViewController.h
//  DayTripper
//
//  Created by Kimora Kong on 8/3/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapResultsViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *activities; 
@property (weak, nonatomic) IBOutlet MKMapView *resultsMap;
@end
