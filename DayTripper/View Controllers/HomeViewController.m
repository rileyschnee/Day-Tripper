//
//  HomeViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "HomeViewController.h"
#import "Trip.h"
#import "TripCell.h"
#import "ItinViewController.h"
#import "ProfileCell.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *trips;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.navigationItem setHidesBackButton:YES];
    // Do any additional setup after loading the view.
    ProfileCell *profCell = [ProfileCell new];
    [self.tableView addSubview:profCell];
    [self fetchTrips];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchTrips {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Trip"]; //how to define a query
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"planner"];
    [query includeKey:@"activities"];
    [query whereKey:@"planner" equalTo:[PFUser currentUser]];
    query.limit = 20;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *trips, NSError *error) {
        if (trips != nil) {
            self.trips = trips;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue destinationViewController] isKindOfClass:[ItinViewController class]]){
        UITableViewCell  *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Trip *trip = self.trips[indexPath.item];
        ItinViewController *itinerary = [segue destinationViewController];
        itinerary.trip = trip;
    }
}

 
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TripCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCell" forIndexPath:indexPath];
    cell.trip = self.trips[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trips.count;
}
@end

