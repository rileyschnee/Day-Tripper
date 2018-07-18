//
//  ResultsViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ResultsViewController.h"


@interface ResultsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *activities;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Functions *functions;
@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.functions = [[Functions alloc] init];
    // Do any additional setup after loading the view.
    self.activities = [NSMutableArray new];
    [self fetchResults4SQ];
    [self fetchResultsYelp];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSMutableArray *chosenPlaces = [[NSMutableArray alloc] init];
    for(ResultsCell *cell in [self.functions getCellsFromTable:self.tableView]){
        if(cell.checkButton.selected){
            [chosenPlaces addObject:cell.activity];
        }
        
    }
    //save the trip
    //declare trip object
    Trip *trip = [Trip new];
    trip.city = self.location;
    trip.activities = [chosenPlaces copy];
    trip.planner = [PFUser currentUser];
    
    //actually save the trip
    [trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
        }
    }];
    
    //end saving the trip
    
    ItinViewController *itinViewController = [segue destinationViewController];
    itinViewController.trip = trip;
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell" forIndexPath:indexPath];
    cell.activity = self.activities[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activities.count;
}

- (void)fetchResults4SQ{

    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.foursquare.com/v2/venues/search";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSString *coordinates = [NSString stringWithFormat:@"%f%@%f",self.latitude, @",", self.longitude];
    [paramsDict setObject:coordinates forKey:@"ll"];
    [paramsDict setObject:@"20180716" forKey:@"v"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_4SQ"] forKey:@"client_id"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_SECRET_4SQ"] forKey:@"client_secret"];
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
            NSArray *venues = responseDict[0][@"response"][@"venues"];
            for (NSDictionary *venue in venues) {
                Place *place = [Place new];
                place.name = venue[@"name"];
                [self.activities addObject:place];
            }
        //[weakSelf fetchResultsYelp];
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
            [self.activities addObject:food];
        }
        [weakSelf refreshAsync];
    }];
    
    
}


-(void) refreshAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}



@end
