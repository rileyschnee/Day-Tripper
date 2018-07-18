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
@interface ResultsViewController () <UITableViewDelegate, UITableViewDataSource, ResultsCellDelegate>
@property (strong, nonatomic) NSMutableArray *places;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Functions *functions;
@property (strong, nonatomic) NSMutableArray *chosenPlaces;
@property (strong, nonatomic) Trip *trip;
@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.functions = [[Functions alloc] init];
    NSMutableArray *chosenPlaces = [[NSMutableArray alloc] init];
    self.trip = [Trip new];
    self.trip.city = self.location;

    // Do any additional setup after loading the view.
    [self fetchResults];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //NSMutableArray *chosenPlaces = [[NSMutableArray alloc] init];
//    for(ResultsCell *cell in [self.functions getCellsFromTable:self.tableView]){
//        if(cell.checkButton.selected){
//            [self.chosenPlaces addObject:cell.place];
//        }
//
//    }
    //save the trip
    //declare trip object
    
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
    
    ItinViewController *itinViewController = [segue destinationViewController];
    itinViewController.trip = self.trip;
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.place = self.places[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (void)fetchResults{
    self.places = [NSMutableArray new];

    APIManager *apiManager = [[APIManager alloc] init];
    //make the request
    NSString *baseURL =  @"https://api.foursquare.com/v2/venues/search";
    //params
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:@"40.7484,-73.9857" forKey:@"ll"];
    [paramsDict setObject:@"20180716" forKey:@"v"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_ID_4SQ"] forKey:@"client_id"];
    [paramsDict setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"CLIENT_SECRET_4SQ"] forKey:@"client_secret"];
    
    __weak typeof(self) weakSelf = self;
    [apiManager getRequest:baseURL params:[paramsDict copy] completion:^(NSArray* responseDict) {
            NSArray *venues = responseDict[0][@"response"][@"venues"];
            for (NSDictionary *venue in venues) {
                Place *place = [Place new];
                place.name = venue[@"name"];
                [weakSelf.places addObject:place];
            }
            [weakSelf refreshAsync];
    }];
    
    
}

-(void) refreshAsync {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}



- (void)addPlaceToTrip:(Place *)place {
    [self.trip addUniqueObject:place forKey:@"places"];
    NSLog(@"Added %@ to chosenPlaces", place.name);
    //[self.trip saveInBackground];
}

- (BOOL)isPlaceInTrip:(Place *)place {
    NSLog(@"%d - for place %@", [self.chosenPlaces containsObject:place], place.name);
    return [self.trip.places containsObject:place];
    
}

- (void)removePlaceFromTrip:(Place *)place {
    [self.trip removeObject:place forKey:@"places"];
    NSLog(@"Removed %@ from chosenPlaces", place.name);
    //[self.trip saveInBackground];

}

@end
