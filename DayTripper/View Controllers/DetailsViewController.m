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
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.activity.name;
    self.somePlacemarks = [[NSArray<CLPlacemark *> alloc] init];
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
            
        }
    }];
    
    //self.locationLabel.text = self.activity.location;
    if([[self.activity activityType] isEqualToString:@"Place"]){
        self.categoriesLabel.text = self.activity.categories[0][@"name"];
    } else if([[self.activity activityType] isEqualToString:@"Food"]){
        self.categoriesLabel.text = self.activity.categories[0][@"title"];
    } else if ([[self.activity activityType] isEqualToString:@"Event"]){
        self.categoriesLabel.text = [NSString stringWithFormat:@"%@", self.activity.categories[0]];
    }
    //self.categoriesLabel.text = self.activity.category;
    
    //get the images related to location
    if([[self.activity activityType] isEqualToString:@"Place"]){
        //get foursquare images
        [self fetch4SQPhotos:self.activity.apiId];
    } else if([[self.activity activityType] isEqualToString:@"Food"]){
        //get yelp images
        [self fetchYelpPhotos:self.activity.apiId];
    }
    
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
        UIImage *image = self.images[0];
        [self.imageView setImage:image];
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
    if(self.currentImageIndex < (self.imageUrls.count - 1))
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



@end
