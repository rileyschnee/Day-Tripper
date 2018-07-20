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

@interface DetailsViewController ()
@property (strong, nonatomic) NSArray<CLPlacemark *> *somePlacemarks;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CLPlacemark *somePlacemark;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *imageUrls;
@property (nonatomic) int currentImageIndex;
- (IBAction)didTapDirections:(id)sender;

@property (nonatomic) int currNumEventPhotos;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.activity.name;
    self.somePlacemarks = [[NSArray<CLPlacemark *> alloc] init];
    //init the images arrays that will be used for storing images
    self.imageUrls = [[NSMutableArray alloc] init];
    self.images = [[NSMutableArray alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.activity.latitude longitude:self.activity.longitude];
    self.currentImageIndex = 0;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error){
            NSLog (@"%@", error.localizedDescription);
        }else{
            self.somePlacemarks = [placemarks copy];
            self.somePlacemark = [placemarks firstObject];

            NSArray *partsAddr = [[NSArray alloc] initWithObjects: self.somePlacemark.name, self.somePlacemark.locality, self.somePlacemark.administrativeArea, self.somePlacemark.postalCode, self.somePlacemark.country, nil];
            NSString *address = [partsAddr componentsJoinedByString:@", "];
            self.locationLabel.text =  address;
        }
    }];
    
    if([[self.activity activityType] isEqualToString:@"Place"]){
        self.categoriesLabel.text = [[self.activity.categories[0][@"name"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if([[self.activity activityType] isEqualToString:@"Food"]){
        self.categoriesLabel.text = [[self.activity.categories[0][@"title"] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    } else if ([[self.activity activityType] isEqualToString:@"Event"]){
        self.categoriesLabel.text = [[self.activity.categories[0] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    }
    //self.categoriesLabel.text = self.activity.category;
    
    //get the images related to location
    if([[self.activity activityType] isEqualToString:@"Place"]){
        //get foursquare images
        [self fetch4SQPhotos:self.activity.apiId];
    } else if([[self.activity activityType] isEqualToString:@"Food"]){
        //get yelp images
        [self fetchYelpPhotos:self.activity.apiId];
    } else if ([[self.activity activityType] isEqualToString:@"Event"]){
        [self getEventPhotoObjectsByLocation];
    }
}


- (IBAction)didTapDirections:(id)sender {
    NSString *baseURL = @"https://www.google.com/maps/dir/?api=1";
    NSNumber *numberlat = [NSNumber numberWithDouble:self.activity.latitude];
    NSNumber *numberlong = [NSNumber numberWithDouble:self.activity.longitude];
    NSString *destinationlat = [numberlat stringValue];
    NSString *destinationlong = [numberlong stringValue];
    NSArray *array = [[NSArray alloc] initWithObjects:@"&destination=", destinationlat, @",", destinationlong, nil];
    NSString *url = [array componentsJoinedByString:@""];
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


- (IBAction)swipeLeft:(id)sender {
    [self handleSwipeLeft:sender];

}

- (IBAction)swipeRight:(id)sender {
    [self handleSwipeRight:sender];
}


#pragma mark - API requests
- (void) fetch4SQPhotos: (NSString*) tripId {
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@%@", @"https://api.foursquare.com/v2/venues/", tripId, @"/photos"];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_4SQ"] forKey:@"client_id"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_SECRET_4SQ"] forKey:@"client_secret"];
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

- (void) fetchYelpPhotos: (NSString*) tripId {
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  [NSString stringWithFormat:@"%@%@", @"https://api.yelp.com/v3/businesses/", tripId];
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_YELP"]];
    [paramsDict setObject:apiToken forKey:@"Authorization"];
    

    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *photos = responseDict[0][@"photos"];
        for (NSString* photo in photos) {
            [self.imageUrls addObject:photo];
        }
        [self populateImageArray];

    }];
}

- (void) populateImageArray {
    __weak typeof(self) weakSelf = self;
    for (NSString* url in self.imageUrls) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];
        [self.images addObject:image];
    }
    [weakSelf setImageAsync];
    
}

-(void) setImageAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.images.count > 0) {
            UIImage *image = self.images[0];
            [self.imageView setImage:image];
        }
    });
}



#pragma mark - Image Scroll Animation

- (void)addAnimationPresentToView:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

- (void)addAnimationPresentToViewOut:(UIView *)viewTobeAnimated
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.30;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimated.layer addAnimation:transition forKey:nil];
    
}

-(void)changeImage
{
    //set image with url
    UIImage *image = self.images[self.currentImageIndex];
    [self.imageView setImage:image];
}
-(void)handleSwipeLeft:(id)sender
{
    if(self.currentImageIndex < (self.images.count - 1))
    {
        self.currentImageIndex = self.currentImageIndex + 1;
        [self addAnimationPresentToView:self.imageView];
        [self changeImage];
    }
    
}
-(void)handleSwipeRight:(id)sender
{
    if (self.currentImageIndex > 0)
    {
        self.currentImageIndex = self.currentImageIndex - 1;
        [self addAnimationPresentToViewOut:self.imageView];
        [self changeImage];
    }
    
}


# pragma mark - Google Places Request for Event API
//given a lat and long will search to find nearby places and their photo ids
- (void) getEventPhotoObjectsByLocation {
    __weak typeof(self) weakSelf = self;
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    //params
    NSString* locationParam = [NSString stringWithFormat:@"%f%@%f", self.activity.latitude, @",", self.activity.longitude];
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_GOOGLE"] forKey:@"key"];
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
    APIManager *apiManager = [[APIManager alloc] init];
    
    NSString *baseURL = @"https://maps.googleapis.com/maps/api/place/photo";
    NSString* maxWidth = @"?maxwidth=600";
    NSString* photoRef = [NSString stringWithFormat:@"%@%@", @"&photoreference=", photoReference];
    NSString* key = [NSString stringWithFormat:@"%@%@", @"&key=", [[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_GOOGLE"]];
    NSString* finalURL = [NSString stringWithFormat:@"%@%@%@%@", baseURL, maxWidth, photoRef, key];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:finalURL]];
    UIImage *image = [UIImage imageWithData:data];
    [self.images addObject:image];
    
}



@end
