//
//  ResultsViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ResultsViewController.h"
#import "ResultsCell.h"
#import "ItinViewController.h"
#import "Trip.h"
#import "APIManager.h"
#import "Activity.h"
#import "DetailsViewController.h"
#import "SVProgressHUD.h"
#import <NYAlertViewController/NYAlertViewController.h>
#import "ResourcesViewController.h"

@interface ResultsViewController () <UITableViewDelegate, UITableViewDataSource, ResultsCellDelegate>
@property (strong, nonatomic) NSMutableArray *activities;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Trip *trip;
@property (strong, nonatomic) NSMutableArray *food;
@property (strong, nonatomic) NSMutableArray *places;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSString* tripName;
@property (strong, nonatomic) NSMutableArray *tempArray;
@property (strong, nonatomic) NSMutableString *catQueryPlace;
@property (strong, nonatomic) NSMutableString *catQueryFood;
@property (strong, nonatomic) NSMutableString *catQueryEvent;
@end

@implementation ResultsViewController
NSString *HeaderViewIdentifier = @"ResultsViewHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tripName = @"";
    
    self.trip = [Trip new];
    self.trip.city = self.location;
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
    
    //set up different arrays for different types of things to do
    self.activities = [NSMutableArray new];
    self.places = [NSMutableArray new];
    self.food = [NSMutableArray new];
    self.events = [NSMutableArray new];
    
    [self.activities addObject:self.places];
    [self.activities addObject:self.food];
    [self.activities addObject:self.events];
    [SVProgressHUD show];
    [self setQueryStrings];
    [self fetchResults4SQ];
    [self fetchResultsYelp];
    [self fetchResultsEvents];
}

#pragma mark - Table View Functions

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.activity = self.activities[indexPath.section][indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentifier];
    //    if(section == 0){
    //        header.textLabel.text = @"Places";
    //    } else if(section == 1){
    //        header.textLabel.text = @"Food";
    //    } else {
    //        header.textLabel.text = @"Events";
    //    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.frame.size.width-15, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:20]];
    // set font color to orange - [UIColor colorWithRed:0.94 green:0.40 blue:0.23 alpha:1.0]
    [label setTextColor:[UIColor whiteColor]];
    /* Section header is in 0th index... */
    NSString *string = @"";
    if(section == 0){
        string = @"Places";
    } else if(section == 1){
        string = @"Food";
    } else {
        string = @"Events";
    }
    [label setText:string];
    [view addSubview:label];
    //Set background to blue - [UIColor colorWithRed:0.36 green:0.56 blue:0.76 alpha:1.0]
    [view setBackgroundColor:[UIColor colorWithRed:0.36 green:0.56 blue:0.76 alpha:1.0]]; //your background color...
    return view;
    
    //    return header;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.activities[section] count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.activities.count;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([sender isKindOfClass:[ResultsCell class]]){
        ResultsCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        DetailsViewController * detailPage = [segue destinationViewController];
        detailPage.activity = self.activities[indexPath.section][indexPath.row];

    }
    
    //this is called if the "Done" button is pressed
    else {
        //if there is no trip name yet, then ask the user for a trip name
        if (self.tripName.length == 0) {
            [self alertForTripName];
        }
        //reaches here is a trip name exists
        else {
            [Trip saveTrip:self.trip withName:self.tripName withDate:self.tripDate withLat:self.latitude withLon:self.longitude withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded){
                    NSLog(@"YAY! YOUR TRIP SAVED");
                } else {
                    NSLog(@"Trip didn't save");
                }
            }];
            
            UITabBarController *tabbar = [segue destinationViewController];
            UINavigationController *navController = [tabbar.viewControllers objectAtIndex:0];
            ResourcesViewController *resViewController = (ResourcesViewController *) navController.topViewController;
            
            //ItinViewController *itinViewController = (ItinViewController *) [tabbar.viewControllers objectAtIndex:0];
            resViewController.trip = self.trip;
            //create a home button that goes to Home View Controller
            UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style: UIBarButtonItemStylePlain target:resViewController action:@selector(back)];
            resViewController.navigationItem.hidesBackButton = YES;
            resViewController.navigationItem.leftBarButtonItem = homeButton;
        }
    }
}

#pragma mark - Fetch Functions

//gets the places for the results
- (void)fetchResults4SQ{
    //access apikeys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.foursquare.com/v2/venues/search";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *coordinates = [NSString stringWithFormat:@"%f%@%f",self.latitude, @",", self.longitude];
    NSString *currDate = [self generatCurrentDateFourSquare];
    [paramsDict setObject:coordinates forKey:@"ll"];
    [paramsDict setObject:currDate forKey:@"v"];
    [paramsDict setObject:[dict valueForKey:@"CLIENT_ID_4SQ"] forKey:@"client_id"];
    [paramsDict setObject:[dict valueForKey:@"CLIENT_SECRET_4SQ"] forKey:@"client_secret"];
    if(![self.catQueryPlace isEqualToString:@""]){
        [paramsDict setObject:self.catQueryPlace forKey:@"categoryId"];
    }
    else {
        [paramsDict setObject:@"4d4b7104d754a06370d81259,4d4b7105d754a06372d81259,4d4b7105d754a06376d81259,4d4b7105d754a06377d81259,4d4b7105d754a06378d81259" forKey:@"categoryId"];
    }
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        //parse the request
        NSArray *venues = responseDict[0][@"response"][@"venues"];
        for (NSDictionary *venue in venues) {
            Place *place = [Place new];
            place.name = venue[@"name"];
            place.website = venue[@"url"];
            place.latitude = [venue[@"location"][@"lat"] doubleValue];
            place.longitude = [venue[@"location"][@"lng"] doubleValue];
            place.categories = venue[@"categories"];
            place.apiId = venue[@"id"];
            [weakSelf.activities[0] addObject:place];
        }
        
    }];
}

//gets the food results
- (void)fetchResultsYelp{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.yelp.com/v3/businesses/search";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *lat = [NSString stringWithFormat:@"%f",self.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f",self.longitude];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [apiDict valueForKey:@"APIKEY_YELP"]];
    [paramsDict setObject:lat forKey:@"latitude"];
    [paramsDict setObject:lon forKey:@"longitude"];
    [paramsDict setObject:@"food" forKey:@"categories"];
    [paramsDict setObject:apiToken forKey:@"Authorization"];
    if(![self.catQueryFood isEqualToString:@""]){
        [paramsDict setObject:self.catQueryFood forKey:@"categories"];
    } else {
        [paramsDict setObject:@"restaurants,food" forKey:@"categories"];
    }
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *venues = responseDict[0][@"businesses"];
        for (NSDictionary *venue in venues) {
            Food *food = [Food new];
            food.name = venue[@"name"];
            food.website = venue[@"url"];
            food.latitude = [venue[@"coordinates"][@"latitude"] doubleValue];
            food.longitude = [venue[@"coordinates"][@"longitude"] doubleValue];
            food.categories = venue[@"categories"];
            food.apiId = venue[@"id"];
            [self.activities[1] addObject:food];
        }
        
    }];
}

- (void)fetchResultsEvents{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"apikeys" ofType:@"plist"];
    NSDictionary *apiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.predicthq.com/v1/events/";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    
    NSString *locationString = [NSString stringWithFormat:@"%f%@%f", self.latitude, @",", self.longitude];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [apiDict valueForKey:@"APIKEY_PREDICTHQ"]];
    
    //date processing
    NSString *startDate = [self generatCurrentDateEvents];
    //defaults to one week from now
    NSString *endDate = [self generatEndDateEvents];
    
    [paramsDict setObject:locationString forKey:@"location_around.origin"];
    [paramsDict setObject:startDate forKey:@"start_around.origin"];
    [paramsDict setObject:startDate forKey:@"end.gte"];
    [paramsDict setObject:endDate forKey:@"end.lte"];
    [paramsDict setObject:apiToken forKey:@"Authorization"];
    if(![self.catQueryEvent isEqualToString:@""]){
        [paramsDict setObject:self.catQueryEvent forKey:@"category"];
    }
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *events = responseDict[0][@"results"];
        for (NSDictionary *event in events) {
            Event *eventObj = [Event new];
            eventObj.name = event[@"title"];
            //no website exists for the event yet
            eventObj.website = @"";
            eventObj.longitude = [event[@"location"][0] doubleValue];
            eventObj.latitude = [event[@"location"][1] doubleValue];
            eventObj.categories = [[NSMutableArray alloc] init];
            [eventObj.categories addObject:event[@"category"]];
            [self.activities[2] addObject:eventObj];
        }
        [weakSelf refreshAsync];
    }];
}

#pragma mark - Protocol Implementations

-(void)addActivityToTrip:(id <Activity>) activity {
    [self.trip addUniqueObject:activity forKey:@"activities"];
}
-(void)removeActivityFromTrip:(id <Activity>) activity {
    self.tempArray = self.trip[@"activities"];
    [self.tempArray removeObject:activity];
    self.trip[@"activities"] = self.tempArray;
}
-(BOOL)isActivityInTrip:(id <Activity>) activity {
    return [self.trip.activities containsObject:activity];
}


#pragma mark - Helper Functions

//reloads the tableview asynchronously
-(void) refreshAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    });
}

//sets up querying for all of the categories
-(void)setQueryStrings{
    self.catQueryPlace = [NSMutableString new];
    self.catQueryFood = [NSMutableString new];
    self.catQueryEvent = [NSMutableString new];
    for(NSString *cat in self.placeCategories){
        [self.catQueryPlace appendString:[NSString stringWithFormat:@"%@", cat]];
        if(![cat isEqual:[self.placeCategories lastObject]]){
            [self.catQueryPlace appendString:@","];
        }
    }
    for(NSString *cat in self.foodCategories){
        [self.catQueryFood appendString:[NSString stringWithFormat:@"%@", cat]];
        if(![cat isEqual:[self.foodCategories lastObject]]){
            [self.catQueryFood appendString:@","];
        }
    }
    for(NSString *cat in self.eventCategories){
        [self.catQueryEvent appendString:[NSString stringWithFormat:@"%@", cat]];
        if(![cat isEqual:[self.eventCategories lastObject]]){
            [self.catQueryEvent appendString:@","];
        }
    }
    NSLog(@"%@", self.catQueryPlace);
    NSLog(@"%@", self.catQueryFood);
    NSLog(@"%@", self.catQueryEvent);
}

#pragma mark - Date Functions

//gets the current date in the format that four square wants
- (NSString *) generatCurrentDateFourSquare {
    NSDate *today = self.tripDate;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    return [dateFormatter stringFromDate:today];
}

//gets current date in format that predicthq wants
- (NSString *) generatCurrentDateEvents {
    NSDate *today = self.tripDate;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:today];
}

//gets the date one week from now
- (NSString *) generatEndDateEvents {
    NSDate *today = self.tripDate;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    //push 7 days ahead
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:7];
    NSDate *newDate = [[NSCalendar currentCalendar]
                       dateByAddingComponents:dateComponents
                       toDate:today options:0];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:newDate];
}


#pragma mark - Alert Functions

- (void)alertForTripName{
    NYAlertViewController *alert = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    // Set a title and message
    alert.title = NSLocalizedString(@"Trip Name", nil);
    alert.message = NSLocalizedString(@"What would you like to call this trip?", nil);
    
    // Customize appearance as desired
    alert.buttonCornerRadius = 20.0f;
    alert.alertViewCornerRadius = alert.accessibilityFrame.size.height / 4;
    alert.view.tintColor = [UIColor blueColor];
    
    alert.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    alert.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    alert.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:alert.buttonTitleFont.pointSize];
    alert.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:alert.cancelButtonTitleFont.pointSize];
    
    alert.swipeDismissalGestureEnabled = NO;
    alert.backgroundTapDismissalGestureEnabled = NO;
    
    // Add alert actions
    [alert addAction:[NYAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissViewControllerAnimated:alert completion:nil];
    }]];
    [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        NSArray * textfields = alert.textFields;
        UITextField * namefield = textfields[0];
        //if the user does not provide a trip name, then set the name equal to the city
        if (namefield.text.length == 0) {
            self.tripName = self.trip.city;
        }
        else {
            self.tripName = namefield.text;
        }
        [self performSegueWithIdentifier:@"toItinView" sender:nil];

    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
//   // OLD
//    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Trip Name"
//                                                                              message: @"Enter the trip name"
//                                                                       preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"Trip Name";
//        textField.textColor = [UIColor blueColor];
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    }];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self dismissViewControllerAnimated:alertController completion:nil];
//    }]];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSArray * textfields = alertController.textFields;
//        UITextField * namefield = textfields[0];
//        //if the user does not provide a trip name, then set the name equal to the city
//        if (namefield.text.length == 0) {
//            self.tripName = self.trip.city;
//        }
//        else {
//            self.tripName = namefield.text;
//        }
//        [self performSegueWithIdentifier:@"toItinView" sender:nil];
//
//    }]];
//    [self presentViewController:alertController animated:YES completion:nil];
}

@end
    
