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
#import "TripReusableView.h"
#import "IOUViewController.h"
#import "SVProgressHUD.h"

@interface ResourcesViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, TripReusableViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *attendeeUsers;
@property (strong, nonatomic) IBOutlet UIView *resourceView;
- (IBAction)onTapSummary:(id)sender;
@end

@implementation ResourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    // Setup collection view interface
    CGFloat itemWidth = (self.collectionView.frame.size.width - 60) / 3;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth+25);
    [SVProgressHUD show];
    [self fetchAttendees];
    
   
    
}


- (void)viewDidAppear:(BOOL)animated {
    //hide bar button item
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([sender isKindOfClass:[UICollectionViewCell class]]){
        UICollectionViewCell  *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
        PFUser *user = self.attendeeUsers[indexPath.item];
        NSLog(@"%d", [[segue destinationViewController] isKindOfClass:[ProfileViewController class]]);
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileViewController = (ProfileViewController *)navController.topViewController;
        NSLog(@"%@", user.username);
        profileViewController.user = user;
        profileViewController.trip = self.trip;
    }
    if([sender isKindOfClass:[UIButton class]]){
        UINavigationController *navController = [segue destinationViewController];
        IOUViewController *iouVC = (IOUViewController *)navController.topViewController;
        iouVC.attendeeUsers = [self.attendeeUsers mutableCopy];
        iouVC.trip = self.trip;
        iouVC.isUsersIOUs = FALSE;
    }
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UserCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionCell" forIndexPath:indexPath];
    cell.user = self.attendeeUsers[indexPath.item];
    PFFile* file = cell.user[@"picture"];
    cell.profilePicView.file = file;
    [cell.profilePicView loadInBackground];
    cell.profilePicView.layer.cornerRadius = cell.profilePicView.frame.size.width/2;
    cell.nameLabel.text = cell.user[@"name"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    TripReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TripReusableView" forIndexPath:indexPath];
    header.trip = self.trip;
    header.delegate = self;
    header.tripNameLabel.text = self.trip.name;
    
    if ([[self.trip objectForKey:@"summary"] isEqualToString:@""] || [self.trip objectForKey:@"summary"] == nil) {
        //[header.summaryBtn addTarget:self action:@selector(didTapDescription:) forControlEvents:UIControlEventTouchDown];
        // [self.resourceView addSubview:button];
        header.summaryBtn.hidden = NO;
    }else{
        header.summaryBtn.hidden = YES;
        header.descriptionLabel.hidden = NO;
        header.descriptionLabel.text = self.trip.summary;
    }
    
    //get weather info
    [self getWeather:header];
    
    
    return header;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%lu", self.attendeeUsers.count);
    return self.attendeeUsers.count;
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
        //hence if the trip date is over 5 days we will treat the trip date as 5 days away
        NSDate* tripDay = self.trip.tripDate;
        //get the day difference
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:[NSDate date]
                                                              toDate:tripDay
                                                             options:0];
        if ([components day] > 4) {
            //set the tripDate equal to 4 days from now
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:4];
            tripDay = [[NSCalendar currentCalendar]
                                  dateByAddingComponents:dateComponents
                                  toDate:[NSDate date] options:0];
        }
        
        //transform date into yyyy-mm-dd
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString* tripDayStringRep = [formatter stringFromDate:tripDay];
        double currHigh = 0;
        double currLow = 0;
        NSString* weatherDesc = @"";
        NSArray *forecasts = responseDict[0][@"list"];
        BOOL highAndLowSetSoFar = NO;
        for (NSDictionary* forecast in forecasts) {
            NSString* listedDateTime = forecast[@"dt_txt"];
            NSString* listedDate = [listedDateTime componentsSeparatedByString:@" "][0];
            if ([tripDayStringRep isEqualToString:listedDate]) {
                double listedHigh = [forecast[@"main"][@"temp_max"] doubleValue];
                double listedLow = [forecast[@"main"][@"temp_min"] doubleValue];
                NSDictionary* weatherDict = forecast[@"weather"];
                weatherDesc = forecast[@"weather"][0][@"description"];
                if (highAndLowSetSoFar) {
                    if (listedHigh > currHigh) {
                        currHigh = listedHigh;
                    }
                    if (listedLow < currLow) {
                        currLow = listedLow;
                    }
                }
                else {
                    currHigh = listedHigh;
                    currLow = listedLow;
                    highAndLowSetSoFar = YES;
                }
            }
            
        }
        [weakSelf setWeatherLabels:header high:currHigh low:currLow description:weatherDesc];
        
    }];
}

- (void) setWeatherLabels:(TripReusableView* ) header high:(double)high low:(double)low description:(NSString *)description {
    dispatch_async(dispatch_get_main_queue(), ^{
        // if there is no weather (the high and low both equal 0) then set the high and low equal to dash
        if (high == 0.0 && low == 0.0) {
            header.highLabel.text = @"-";
            header.lowLabel.text = @"-";
            header.descLabel.text = @"-";
        } else {
            NSString* highString = [NSString stringWithFormat:@"%.1f%@", [self kelvinToFahrenheit:high], @" F"];
            NSString* lowString = [NSString stringWithFormat:@"%.1f%@", [self kelvinToFahrenheit:low], @" F"];
            header.highLabel.text = highString;
            header.lowLabel.text = lowString;
            header.descLabel.text = [description capitalizedString];
        }
    });
}
- (void)fetchAttendees{
    NSLog(@"%@", self.trip.attendees);
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"objectId IN %@", self.trip.attendees];
    PFQuery *query = [PFUser query /*WithPredicate:pred*/];
    [query whereKey:@"objectId" containedIn:self.trip.attendees];
    [query includeKey:@"picture"];
    [query includeKey:@"username"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil){
            self.attendeeUsers = [users mutableCopy];
            [self.collectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
            NSLog(@"Error fetching attendees");
        }
        [SVProgressHUD dismiss];
    }];
}

- (double) kelvinToFahrenheit:(double)kelvin {
    return (kelvin * (9.0/5.0)) - 459.67;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareToAlbum:(id)sender {
    // GOOGLE PHOTOS FUNCTIONALITY HERE
    
}

- (void)reloadAttendeeData {
    [self fetchAttendees];
}

- (void)showAlert:(UIAlertController *)alert {
    [self presentViewController:alert animated:YES completion:nil];

}
- (void)showAlertView:(UIAlertView *)alert{
    [alert show];
}

@end
