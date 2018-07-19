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
#import "Functions.h"
#import "Trip.h"
#import "APIManager.h"
#import "Activity.h"
#import "DetailsViewController.h"

@interface ResultsViewController () <UITableViewDelegate, UITableViewDataSource, ResultsCellDelegate>
@property (strong, nonatomic) NSMutableArray *activities;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Functions *functions;
@property (strong, nonatomic) Trip *trip;
@property (strong, nonatomic) NSMutableArray *food;
@property (strong, nonatomic) NSMutableArray *places;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSString* tripName;

@end

@implementation ResultsViewController
NSString *HeaderViewIdentifier = @"ResultsViewHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tripName = @"";

    self.functions = [[Functions alloc] init];
    self.trip = [Trip new];
    self.trip.city = self.location;

    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];

    // Do any additional setup after loading the view.
    self.activities = [NSMutableArray new];
    self.places = [NSMutableArray new];
    self.food = [NSMutableArray new];
    self.events = [NSMutableArray new];

    [self.activities addObject:self.places];
    [self.activities addObject:self.food];
    [self.activities addObject:self.events];
    [self fetchResults4SQ];
    [self fetchResultsYelp];
    [self fetchResultsEvents];
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

    } else {
        if (self.tripName.length == 0) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Trip Name"
                                                                                      message: @"Enter the trip name"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Trip Name";
                textField.textColor = [UIColor blueColor];
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.borderStyle = UITextBorderStyleRoundedRect;
            }];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSArray * textfields = alertController.textFields;
                UITextField * namefield = textfields[0];
                if (namefield.text.length == 0) {
                    self.tripName = self.trip.city;
                }
                else {
                    self.tripName = namefield.text;
                }
                [self performSegueWithIdentifier:@"toItenView" sender:nil];
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
            
        }
        else {
            self.trip.planner = [PFUser currentUser];
            self.trip.name = self.tripName;

            //actually save the trip
            [self.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Trip successfully saved!");
                } else {
                    NSLog(@"Error saving trip");
                }
            }];
        
            //end saving the trip
        
    } else if ([sender isKindOfClass:[UIBarButtonItem class]]){
        self.trip.planner = [PFUser currentUser];

        //actually save the trip
        [self.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Trip successfully saved!");
            } else {
                NSLog(@"Error saving trip");
            }
        }];
    
        //end saving the trip
    
        
        UITabBarController *tabbar = [segue destinationViewController];
        ItinViewController *itinViewController = (ItinViewController *) [tabbar.viewControllers objectAtIndex:0];
        itinViewController.trip = self.trip;
    }
    }   
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.activity = self.activities[indexPath.section][indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentifier];
    if(section == 0){
        header.textLabel.text = @"Places";
    } else if(section == 1){
        header.textLabel.text = @"Food";
    } else {
        header.textLabel.text = @"Events";
    }
    return header;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.activities[section] count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.activities.count;
}

- (void)fetchResults4SQ{
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.foursquare.com/v2/venues/search";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *coordinates = [NSString stringWithFormat:@"%f%@%f",self.latitude, @",", self.longitude];
    NSString *currDate = [self generatCurrentDateFourSquare];
    [paramsDict setObject:coordinates forKey:@"ll"];
    [paramsDict setObject:currDate forKey:@"v"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_4SQ"] forKey:@"client_id"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_SECRET_4SQ"] forKey:@"client_secret"];
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
            NSArray *venues = responseDict[0][@"response"][@"venues"];
            for (NSDictionary *venue in venues) {
                Place *place = [Place new];
                place.name = venue[@"name"];
                place.latitude = [venue[@"location"][@"lat"] doubleValue];
                place.longitude = [venue[@"location"][@"lng"] doubleValue];
                place.categories = venue[@"categories"];
                [weakSelf.activities[0] addObject:place];
            }
        [weakSelf refreshAsync];

    }];
}

- (void)fetchResultsYelp{
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.yelp.com/v3/businesses/search";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *lat = [NSString stringWithFormat:@"%f",self.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f",self.longitude];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_YELP"]];
    [paramsDict setObject:lat forKey:@"latitude"];
    [paramsDict setObject:lon forKey:@"longitude"];
    [paramsDict setObject:@"food" forKey:@"categories"];
    [paramsDict setObject:apiToken forKey:@"Authorization"];
    
    
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
            [self.activities[1] addObject:food];
        }
        [weakSelf refreshAsync];

    }];
}

- (void)fetchResultsEvents{
    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.predicthq.com/v1/events/";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    
    NSString *locationString = [NSString stringWithFormat:@"%f%@%f", self.latitude, @",", self.longitude];
    NSString *apiToken = [NSString stringWithFormat:@"%@%@", @"Bearer ", [[[NSProcessInfo processInfo] environment] objectForKey:@"APIKEY_PREDICTHQ"]];
    
    //date processing
    NSString *startDate = [self generatCurrentDateEvents];
    //defaults to one week from now
    NSString *endDate = [self generatEndDateEvents];
    
    [paramsDict setObject:locationString forKey:@"location_around.origin"];
    [paramsDict setObject:startDate forKey:@"start_around.origin"];
    [paramsDict setObject:startDate forKey:@"end.gte"];
    [paramsDict setObject:endDate forKey:@"end.lte"];
    [paramsDict setObject:apiToken forKey:@"Authorization"];
    
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
        NSArray *events = responseDict[0][@"results"];
        for (NSDictionary *event in events) {
            Event *eventObj = [Event new];
            eventObj.name = event[@"title"];
            eventObj.longitude = [event[@"location"][0] doubleValue];
            eventObj.latitude = [event[@"location"][1] doubleValue];
            eventObj.categories = [[NSMutableArray alloc] init];
            [eventObj.categories addObject:event[@"category"]];
            [self.activities[2] addObject:eventObj];
        }
        [weakSelf refreshAsync];
    }];
}

- (NSString *) generatCurrentDateFourSquare {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    return [dateFormatter stringFromDate:today];
}

- (NSString *) generatCurrentDateEvents {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:today];
}

- (NSString *) generatEndDateEvents {
    NSDate *today = [NSDate date];
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


-(void) refreshAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


-(void)addActivityToTrip:(id <Activity>) activity {
    [self.trip addUniqueObject:activity forKey:@"activities"];
    //[self.trip saveInBackground];
    
}
-(void)removeActivityFromTrip:(id <Activity>) activity {
    [self.trip removeObject:activity forKey:@"activities"];
    //[self.trip saveInBackground];
    
}
-(BOOL)isActivityInTrip:(id <Activity>) activity {
    return [self.trip.activities containsObject:activity];
    
}



@end
