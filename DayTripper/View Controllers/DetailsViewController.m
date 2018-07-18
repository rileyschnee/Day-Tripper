//
//  DetailsViewController.m
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "DetailsViewController.h"
#import <Corelocation/Corelocation.h>

@interface DetailsViewController ()
@property (strong, nonatomic) NSArray<CLPlacemark *> *somePlacemarks;
@property (strong, nonatomic) CLPlacemark *somePlacemark;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.activity.name;
    self.somePlacemarks = [[NSArray<CLPlacemark *> alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.activity.latitude longitude:self.activity.longitude];
    NSLog(@"%f", self.activity.latitude);
    NSLog(@"%f", self.activity.longitude);
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error){
            NSLog (@"%@", error.localizedDescription);
        }else{
            self.somePlacemarks = [placemarks copy];
            self.somePlacemark = [placemarks firstObject];
            NSLog(@"%@", self.somePlacemark);
            NSLog(@"Name: %@, City: %@, Street Address: %@", self.somePlacemarks[0].name, self.somePlacemarks[0].locality, self.somePlacemarks[0].thoroughfare);
            
        }
    }];
    
    
    //self.locationLabel.text = self.activity.location;
    self.categoriesLabel.text = self.activity.category;
    
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
