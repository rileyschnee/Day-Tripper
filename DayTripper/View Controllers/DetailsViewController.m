//
//  DetailsViewController.m
//  DayTripper
//
//  Created by Kimora Kong on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "DetailsViewController.h"
#import <Corelocation/Corelocation.h>
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "Functions.h"
#import <HCSStarRatingView/HCSStarRatingView.h>

// macro to convert hex to uicolor
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@import UberRides;
@import LyftSDK;

@interface DetailsViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray<CLPlacemark *> *somePlacemarks;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CLPlacemark *somePlacemark;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *imageUrls;
@property (nonatomic) int currentImageIndex;
- (IBAction)didTapDirections:(id)sender;
@property (nonatomic) int currNumEventPhotos;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UIButton *websiteLink;
@property (strong, nonatomic) NSString* websiteToGoTo;
@property (weak, nonatomic) IBOutlet UIView *uberView;
@property (weak, nonatomic) IBOutlet UIView *lyftButton;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (nonatomic) double currentLat;
@property (nonatomic) double currentLong;
//for storing the previous back button
@property (nonatomic,strong) UIBarButtonItem* prevBarButton;
@property (nonatomic) BOOL loaded;
@property (nonatomic) BOOL allowAddToTrip;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.activity.name;
    self.lyftButton.layer.cornerRadius = self.lyftButton.frame.size.height / 4;
    self.uberView.layer.cornerRadius = self.uberView.frame.size.height / 4;
    self.directionsButton.layer.cornerRadius = self.directionsButton.frame.size.height / 4;
    
    //UBER + LOCATION
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    self.loaded = false;
    //CATEGORIES
    self.categoriesLabel.text = [Functions primaryActivityCategory:self.activity];
    
    //IMAGES
    //init the images arrays that will be used for storing images
    self.imageUrls = [[NSMutableArray alloc] init];
    self.images = [[NSMutableArray alloc] init];
    self.currentImageIndex = 0;

    self.categoriesLabel.text = [Functions primaryActivityCategory:self.activity];
        
    //get the images related to location
    if([[self.activity activityType] isEqualToString:@"Place"]){
        [self.hoursLabel setHidden:YES];
        //get foursquare images
        [self fetch4SQPhotos:self.activity.apiId];
        //hide website button
        [self.websiteLink setHidden:YES];
    } else if([[self.activity activityType] isEqualToString:@"Food"]){
        //get yelp images
        [self fetchYelpPhotos:self.activity.apiId];
        //get the hours and rating
        [self fetchYelpDetails:self.activity.apiId];
        //set website url
        self.websiteToGoTo = self.activity.website;
    } else if ([[self.activity activityType] isEqualToString:@"Event"]){
        [self.hoursLabel setHidden:YES];
        [self getEventPhotoObjectsByLocation];
        [self.websiteLink setHidden:YES];
    }
    
    //if coming from itin
    if (self.titleForItin.length > 0) {
        //override back button because previous behavior takes you to wrong screen
        self.prevBarButton = self.tabBarController.navigationItem.leftBarButtonItem;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackToPrevScreen)];
        self.tabBarController.navigationItem.hidesBackButton = YES;
        self.tabBarController.navigationItem.leftBarButtonItem = item;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    //remove edit button that sometimes comes from the itin view
    [super viewDidAppear:YES];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.currentImageIndex = 0;
    if (self.fromMap) {
        //nav bar from map
        UINavigationBar* navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
        
        UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"Details"];
        // [navbar setBarTintColor:[UIColor lightGrayColor]];
        UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onTapBack:)];
        navItem.leftBarButtonItem = backBtn;
        
        
        [navbar setItems:@[navItem]];
        [self.view addSubview:navbar];
    }
    // Add to trip button
    if(self.allowAddToTrip){
        UIBarButtonItem *addToTrip = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"circle"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleActivityInTripStatus:)];
        self.navigationItem.rightBarButtonItem = addToTrip;
    }
}

//
//- (void)toggleActivityInTripStatus{
//    if(self.delegate.chosenActivities)
//    [self.delegate addActivityToTrip:self.activity];
//}
//

# pragma mark - Navigation

// back to map view
-(void)onTapBack:(UIBarButtonItem*)item{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) goBackToPrevScreen {
    [self.navigationController popViewControllerAnimated:YES];
    self.tabBarController.navigationItem.leftBarButtonItem = self.prevBarButton;
    self.tabBarController.navigationItem.hidesBackButton = NO;
}

# pragma mark - Uber and Lyft Functions

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currLocation = [locations lastObject];
    self.currentLat = currLocation.coordinate.latitude;
    self.currentLong = currLocation.coordinate.longitude;
        // stopping locationManager from fetching again
        [self.locationManager stopUpdatingLocation];
    
    //add the uber button
    UBSDKRideParametersBuilder *builder = [[UBSDKRideParametersBuilder alloc] init];
    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:self.currentLat longitude:self.currentLong];
    CLLocation *dropoffLocation = [[CLLocation alloc] initWithLatitude:self.activity.latitude longitude:self.activity.longitude];
    [builder setPickupLocation:pickupLocation];
    [builder setDropoffLocation:dropoffLocation];
    [builder setDropoffNickname:[NSString stringWithFormat:@"%@", self.activity.name]];
    UBSDKRideParameters *rideParameters = [builder build];
    
    self.somePlacemarks = [[NSArray<CLPlacemark *> alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.activity.latitude longitude:self.activity.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error){
            NSLog (@"%@", error.localizedDescription);
        }else{
            self.somePlacemarks = [placemarks copy];
            self.somePlacemark = [placemarks firstObject];
            
            //NSArray *partsAddr = [[NSArray alloc] initWithObjects: self.somePlacemark.name, self.somePlacemark.locality, self.somePlacemark.administrativeArea, self.somePlacemark.postalCode, self.somePlacemark.country, nil];
            //NSString *address = [partsAddr componentsJoinedByString:@", "];
            NSString *displayAddress = [NSString stringWithFormat:@"%@\r%@, %@ %@\r%@", self.somePlacemark.name, self.somePlacemark.locality, self.somePlacemark.administrativeArea, self.somePlacemark.postalCode, self.somePlacemark.country];
            if(self.somePlacemark.postalCode == nil){
                displayAddress = [NSString stringWithFormat:@"%@\r%@, %@\r%@", self.somePlacemark.name, self.somePlacemark.locality, self.somePlacemark.administrativeArea, self.somePlacemark.country];
            }
            self.locationLabel.text =  displayAddress;
            [self.locationLabel sizeToFit];
            [builder setDropoffAddress:[NSString stringWithFormat:@"%@", self.somePlacemark.name]];
        }
    }];
    
    UBSDKRideRequestButton *button = [[UBSDKRideRequestButton alloc] initWithRideParameters:rideParameters];
    //[button setFrame:CGRectMake(self.uberView.frame.origin.x, self.uberView.frame.origin.y, self.uberView.frame.size.width, self.uberView.frame.size.height)];
    [self.uberView addSubview:button];
    //make button fill uberView
    button.translatesAutoresizingMaskIntoConstraints = false;
    
//    NSLayoutConstraint* leftConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.uberView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
//    NSLayoutConstraint* rightConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.uberView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint* centeredConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.uberView attribute:NSLayoutAttributeCenterX multiplier:1 constant:self.uberView.frame.origin.x - button.frame.origin.x];
    NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.uberView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.uberView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//    [self.view addConstraint:leftConstraint];
//    [self.view addConstraint:rightConstraint];
    [self.view addConstraint:centeredConstraint];
    [self.view addConstraint:topConstraint];
    [self.view addConstraint:bottomConstraint];

    
    
    // Add Lyft Button
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressLyft:)];
    [self.lyftButton addGestureRecognizer:tap];
}

- (void)didPressLyft:(UITapGestureRecognizer *)sender{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    if ([self lyftInstalled]) {
        NSString *rideRequestURL = [NSString stringWithFormat:@"lyft://ridetype?id=lyft&pickup[latitude]=%f&pickup[longitude]=%f&destination[latitude]=%f&destination[longitude]=%f&partner=%@", self.currentLat, self.currentLong, self.activity.latitude, self.activity.longitude, [apiDict valueForKey:@"CLIENT_ID_LYFT"]];
        [self open:rideRequestURL];
        
    }
    else {
        [self open:[NSString stringWithFormat:@"https://www.lyft.com/signup/SDKSIGNUP?clientId=%@&sdkName=iOS_direct", [apiDict valueForKey:@"CLIENT_ID_LYFT"]]];
    }
}

- (BOOL)lyftInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"lyft://"]];
}

- (void)open:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{} completionHandler:nil];
    } else {
        [application openURL:URL options:@{} completionHandler:^(BOOL success) {
            if (success){
                NSLog(@"Successfully navigated to Lyft!");
            }
        }];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}

# pragma mark - Directions Function

- (IBAction)didTapDirections:(id)sender {
    NSString *baseURL = @"https://www.google.com/maps/dir/?api=1";
    NSString *url = [NSString stringWithFormat:@"%@%f%@%f%@%f%@%f", @"&origin=", self.currentLat, @",", self.currentLong,@"&destination=", self.activity.latitude, @",", self.activity.longitude];
    NSString *URL = [baseURL stringByAppendingString:url];
    NSURL *googleURL = [NSURL URLWithString:URL];
        [[UIApplication sharedApplication] openURL:googleURL options:@{} completionHandler:^(BOOL success) {
        if (success){
            NSLog(@"YAY dir");
        }else{
            NSLog(@" NO YAY fail");
        }
    }];
}

- (void)setActivity:(id<Activity>)activity{
    _activity = activity;
}

# pragma mark - UI Functions

- (IBAction)swipeLeft:(id)sender {
    if(self.loaded)
        [self handleSwipeLeft:sender];
}

- (IBAction)swipeRight:(id)sender {
    if(self.loaded)
        [self handleSwipeRight:sender];
}


#pragma mark - FourSquare fetch function

- (void) fetch4SQPhotos: (NSString*) tripId {
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@%@", @"https://api.foursquare.com/v2/venues/", tripId, @"/photos"];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:[apiDict valueForKey:@"CLIENT_ID_4SQ"] forKey:@"client_id"];
    [paramsDict setObject:[apiDict valueForKey:@"CLIENT_SECRET_4SQ"] forKey:@"client_secret"];
    NSString *currDate = [self generatCurrentDateFourSquare];
    [paramsDict setObject:currDate forKey:@"v"];
    
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *photoObjs = responseDict[0][@"response"][@"photos"][@"items"];
        for (NSDictionary *photoObj in photoObjs) {
            NSString* url = [self constructURLFromDict:photoObj];
            [self.imageUrls addObject:url];
        }
        [self populateImageArray];
    }];
}

# pragma mark - FourSquare date and time functions

- (NSString *) generatCurrentDateFourSquare {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    return [dateFormatter stringFromDate:today];
}

- (NSString *) constructURLFromDict:(NSDictionary*) dict {
    NSString* prefix = dict[@"prefix"];
    NSString* suffix = dict[@"suffix"];
    NSString* width = [dict[@"width"] stringValue];
    NSString* height = [dict[@"height"] stringValue];
    return [NSString stringWithFormat:@"%@%@%@%@%@", prefix, width, @"x", height, suffix];
}

# pragma mark - Yelp fetch function

- (void) fetchYelpPhotos: (NSString*) tripId {
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@", @"https://api.yelp.com/v3/businesses/", tripId];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [apiDict valueForKey:@"APIKEY_YELP"]];
    [paramsDict setObject:apiToken forKey:@"Authorization"];

    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *photos = responseDict[0][@"photos"];
        for (NSString* photo in photos) {
            [self.imageUrls addObject:photo];
        }
        [self populateImageArray];

    }];
}

//gets hours and rating of operation
- (void) fetchYelpDetails: (NSString*) tripId {
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    //get index of current day of the week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    int oldweekdayIndex = (int) [comps weekday];
    //now map such that monday represents 0 and sunday is 6
    int weekdayIndex = [self mapToNewIndex:oldweekdayIndex];
    
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@", @"https://api.yelp.com/v3/businesses/", tripId];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [apiDict valueForKey:@"APIKEY_YELP"]];
    [paramsDict setObject:apiToken forKey:@"Authorization"];
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        //set the rating
        double rating = [responseDict[0][@"rating"] doubleValue];
        //set the hours
        NSArray *days = responseDict[0][@"hours"][0][@"open"];
        if(days != nil && days.count > weekdayIndex){
            NSDictionary* currDayObject = days[weekdayIndex];
            NSString* startTimeString = [self militaryTimeToAMPM: currDayObject[@"start"]];
            NSString* endTimeString = [self militaryTimeToAMPM: currDayObject[@"end"]];
            [weakSelf setHoursAndRatingAsync:startTimeString endTimeString:endTimeString rating:rating];
        } else {
            [weakSelf setHoursAndRatingAsync:@"" endTimeString:@"" rating:rating];
        }
        
    }];
}

# pragma mark - Yelp date and time functions

//this function converts the Yelp Military time to normal AM/PM time
- (NSString*) militaryTimeToAMPM: (NSString *) milTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HHmm";
    NSDate *date = [dateFormatter dateFromString:milTime];
    
    dateFormatter.dateFormat = @"hh:mm a";
    NSString *pmamDateString = [dateFormatter stringFromDate:date];
    return pmamDateString;
}

//converts week index starting at sunday to week index number starting at monday
- (int) mapToNewIndex:(int) oldIndex {
    switch (oldIndex)
    {
        case 0:
            return 6;
            break;
        case 1:
            return 0;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 3;
            break;
        case 5:
            return 4;
            break;
        case 6:
            return 5;
            break;
        default:
            return 0;
            break;
    }
}

# pragma mark - Image functions

- (void) populateImageArray {
    __weak typeof(self) weakSelf = self;
    for (NSString* url in self.imageUrls) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];
        [self.images addObject:image];
    }
    [weakSelf setImageAsync];
    self.loaded = true;
    
}

-(void) setImageAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.images.count > 0) {
            UIImage *image = self.images[0];
            [self.imageView setImage:image];
        }
    });
}

-(void) setHoursAndRatingAsync:(NSString*)startTimeString endTimeString:(NSString*)endTimeString rating:(double)rating {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![endTimeString isEqualToString:@""] && ![startTimeString isEqualToString:@""]){
            self.hoursLabel.text = [NSString stringWithFormat:@"%@\r%@%@", startTimeString, @"-", endTimeString];
        } else {
            self.hoursLabel.text = @"";
        }
        
        [self setUpFiveStars:rating];
    });
   
}

// sets up the five star rating
- (void) setUpFiveStars:(double) rating {
    // rating variable is out of five
    HCSStarRatingView *starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(210, 350, 160, 50)];
    starRatingView.maximumValue = 5;
    starRatingView.minimumValue = 0;
    starRatingView.enabled = NO;
    starRatingView.alpha = 1.0;
    starRatingView.allowsHalfStars = YES;
    starRatingView.value = ((float) rating);
    starRatingView.tintColor = UIColorFromRGB(0xF0663A);
    [starRatingView addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:starRatingView];
}

# pragma mark - Button functions

- (IBAction)tapWebsiteLink:(id)sender {
    if (![self.websiteLink isHidden]) {
        //go to url if not hidden
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.websiteToGoTo]];
    }
}

#pragma mark - Image Scroll Animation

- (void)addAnimationPresentToView:(UIView *)viewTobeAnimated {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

- (void)addAnimationPresentToViewOut:(UIView *)viewTobeAnimated {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

-(void)changeImage {
    //set image with url
    UIImage *image = self.images[self.currentImageIndex];
    [self.imageView setImage:image];
}
-(void)handleSwipeLeft:(id)sender {
    if(self.currentImageIndex < (self.images.count - 1))
    {
        self.currentImageIndex = self.currentImageIndex + 1;
        [self addAnimationPresentToView:self.imageView];
        [self changeImage];
    }
    
}
-(void)handleSwipeRight:(id)sender {
    if (self.currentImageIndex > 0)
    {
        self.currentImageIndex = self.currentImageIndex - 1;
        [self addAnimationPresentToViewOut:self.imageView];
        [self changeImage];
    }
    
}


# pragma mark - Google Places Request for Event API and helper functions
//given a lat and long will search to find nearby places and their photo ids
- (void) getEventPhotoObjectsByLocation {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    __weak typeof(self) weakSelf = self;
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    //params
    NSString* locationParam = [NSString stringWithFormat:@"%f%@%f", self.activity.latitude, @",", self.activity.longitude];
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    
    [paramsDict setObject:[apiDict valueForKey:@"APIKEY_GOOGLE"] forKey:@"key"];
    [paramsDict setObject:locationParam forKey:@"location"];
    [paramsDict setObject:@"100" forKey:@"radius"];
    
    int maxNumPhotos = 3;
    
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *placesResults = responseDict[0][@"results"];
        for (NSDictionary* place in placesResults) {
            if (self.currNumEventPhotos >= maxNumPhotos) {
                break;
            }
            NSArray* photoRefs = place[@"photos"];
            if (photoRefs.count > 0) {
                for (NSDictionary* photoRef in photoRefs) {
                    if (self.currNumEventPhotos >= maxNumPhotos) {
                        break;
                    }
                    NSString* photoRefString = photoRef[@"photo_reference"];
                    if (photoRefString.length > 0) {
                        if (self.currNumEventPhotos < maxNumPhotos) {
                            [self getImageFromPhotoRef: photoRefString];
                            self.currNumEventPhotos = self.currNumEventPhotos + 1;
                        }
                    }
                }
            }
        }
        [weakSelf setImageAsync];
    }];
}

- (void) getImageFromPhotoRef:(NSString*) photoReference {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    APIManager *apiManager = [[APIManager alloc] init];
    
    NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/photo";
    NSString* maxWidth = @"?maxwidth=600";
    NSString* photoRef = [NSString stringWithFormat:@"%@%@", @"&photoreference=", photoReference];
    NSString* key = [NSString stringWithFormat:@"%@%@", @"&key=", [apiDict valueForKey:@"APIKEY_GOOGLE"]];
    NSString* finalURL = [NSString stringWithFormat:@"%@%@%@%@", baseURL, maxWidth, photoRef, key];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalURL]];
    UIImage *image = [UIImage imageWithData:data];
    if (image != nil) {
        [self.images addObject:image];
    }
    
}



@end
