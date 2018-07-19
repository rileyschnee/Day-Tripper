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

@interface ItinViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ItinViewController

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style: UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = homeButton;
    
    self.tabBarController.delegate = self;
    // Do any additional setup after loading the view.
    [self.tableView reloadData];
}

- (void)back{
    [self performSegueWithIdentifier:@"itinToHome" sender:nil];
}


-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if([viewController isKindOfClass:[MapViewController class]]){
        MapViewController *mapController = (MapViewController *) viewController;
        mapController.trip = self.trip;
        mapController.latitude = self.latitude;
        mapController.longitude = self.longitude;
        
    }
    return TRUE;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ItinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItinCell" forIndexPath:indexPath];
    cell.activity = self.trip.activities[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trip.activities.count;
}


@end
