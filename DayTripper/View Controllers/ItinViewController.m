//
//  ItinViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ItinViewController.h"
#import "ItinCell.h"
#import "MapViewController.h"
#import "ResourcesViewController.h"
#import "DetailsViewController.h"
#import "ChatViewController.h"
#import "AppDelegate.h"

@interface ItinViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//this variable represents the array of activities in their table view ordering
@property (nonatomic, strong) NSMutableArray* tableOrdering;
@end

@implementation ItinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //fix extra space at the top of the table view
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tabBarController.delegate = self;
    self.tableOrdering = [self.trip.activities mutableCopy];
    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    //create edit bar button item
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style: UIBarButtonItemStylePlain target:self action:@selector(editTableView:)];
    if (self.fromHomeEdit) {
        self.tabBarController.navigationItem.rightBarButtonItem = editButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = editButton;
    }
    
    // switch to resource view if coming to itin for first time from home
    if (self.fromHomeToResources) {
        [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[self.tabBarController.viewControllers objectAtIndex:2]];
        [self.tabBarController setSelectedIndex:2];
        self.fromHomeToResources = NO;
    }
    
    //set global Trip
    //needed to transfer data between tabs
     AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.currTrip = self.trip;
}



- (void)back{
    [self performSegueWithIdentifier:@"itinToHome" sender:nil];
}

- (IBAction)editTableView:(UIBarButtonItem*)sender {
    if ([sender.title isEqualToString:@"Edit"]) {
        self.tableView.editing = YES;
        sender.title = @"Done";
    }
    else {
        self.tableView.editing = NO;
        sender.title = @"Edit";
        //save the table
        self.trip.activities = [self.tableOrdering copy];
        [self.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            } else {
                NSLog(@"Error saving trip");
            }
        }];
        
    }
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    //pass data to map view if going to map view
    if([viewController isKindOfClass:[MapViewController class]]){
        MapViewController *mapController = (MapViewController *) viewController;
        mapController.trip = self.trip;
        mapController.latitude = self.latitude;
        mapController.longitude = self.longitude;
    }
    if([viewController isKindOfClass:[UINavigationController class]]){
        UINavigationController *navController =  (UINavigationController *) viewController;
        //[tabBarController.viewControllers objectAtIndex:2];
        
        ResourcesViewController *resController = (ResourcesViewController *)navController.topViewController;
        resController.trip = self.trip;
    }
    return TRUE;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([sender isKindOfClass:[ItinCell class]]){
        ItinCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        DetailsViewController * detailPage = [segue destinationViewController];
        detailPage.activity = self.trip.activities[indexPath.row];
        detailPage.titleForItin = self.trip.name;

    }
}


#pragma mark - Table View methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ItinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItinCell" forIndexPath:indexPath];
    cell.activity = self.tableOrdering[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableOrdering.count;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id <Activity> activity = self.tableOrdering[sourceIndexPath.row];
    [self.tableOrdering removeObjectAtIndex:sourceIndexPath.row];
    [self.tableOrdering insertObject:activity atIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableOrdering removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}



@end
