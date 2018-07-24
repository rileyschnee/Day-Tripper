//
//  ResourcesViewController.m
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ResourcesViewController.h"
#import "APIManager.h"
#import "ProfileViewController.h"

@interface ResourcesViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ResourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
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
    if([sender isKindOfClass:[UICollectionViewCell class]]){
        UICollectionViewCell  *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
        PFUser *user = self.trip.attendees[indexPath.item];
        NSLog(@"%d", [[segue destinationViewController] isKindOfClass:[ProfileViewController class]]);
        ProfileViewController *profileViewController = [segue destinationViewController];
        
        profileViewController.user = user;
    }
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UserCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionCell" forIndexPath:indexPath];
    cell.user = self.trip.attendees[indexPath.item];
    NSLog(@"%i", self.trip.attendees.count);
    cell.profilePicView.file = cell.user[@"picture"];
    [cell.profilePicView loadInBackground];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    TripReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TripReusableView" forIndexPath:indexPath];
    header.trip = self.trip;
    header.tripNameLabel.text = self.trip.name;
    
    //get weather info
    [self getWeather:header];
    
    
    return header;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.trip.attendees.count;
}


//gets the high and low for the day
- (void) getWeather:(TripReusableView* ) header {
    APIManager *apiManager = [[APIManager alloc] init];
    NSString *baseURL =  @"https://api.openweathermap.org/data/2.5/forecast";
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:[NSString stringWithFormat:@"%f", self.trip.latitude] forKey:@"lat"];
    [paramsDict setObject:[NSString stringWithFormat:@"%f", self.trip.longitude] forKey:@"lon"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_OPENWEATHER"] forKey:@"appid"];
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        //forecasts are every three hours and only go up to five days
        NSArray *forecasts = responseDict[0][@"list"];
        // TODO: get weather beyond today
        NSString* currDay = @"";
        double currHigh = 0;
        double currLow = 0;
        for (NSDictionary* forecast in forecasts) {
            NSString* listedDateTime = forecast[@"dt_txt"];
            double listedHigh = [forecast[@"main"][@"temp_max"] doubleValue];
            double listedLow = [forecast[@"main"][@"temp_min"] doubleValue];
            //extract date from date_time
            NSString* listedDate = [listedDateTime componentsSeparatedByString:@" "][1];
            // see if new day
            if (currDay.length == 0) {
                currDay = listedDate;
                currHigh = listedHigh;
                currLow = listedLow;
            }
            else {
                if ([currDay isEqualToString:listedDate]) {
                    //compare high and lows
                    if (listedHigh > currHigh) {
                        currHigh = listedHigh;
                    }
                    if (listedLow < currLow) {
                        currLow = listedLow;
                    }
                }
            }
            
        }
        [weakSelf setWeatherLabels:header high:currHigh low:currLow];
        
    }];
}

- (void) setWeatherLabels:(TripReusableView* ) header high:(double)high low:(double)low {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* highString = [NSString stringWithFormat:@"%.1f%@", [self kelvinToFahrenheit:high], @" F"];
        NSString* lowString = [NSString stringWithFormat:@"%.1f%@", [self kelvinToFahrenheit:low], @" F"];
        header.highLabel.text = highString;
        header.lowLabel.text = lowString;
    });
}

- (double) kelvinToFahrenheit:(double)kelvin {
    return (kelvin * (9.0/5.0)) - 459.67;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
