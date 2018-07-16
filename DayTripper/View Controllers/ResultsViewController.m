//
//  ResultsViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ResultsViewController.h"
#import "ResultsCell.h"

@interface ResultsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *places;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    self.places = [[NSMutableArray alloc] init];
    Place *temp = [[Place alloc] init];
    temp.name = @"MOMA";
    [self.places addObject:temp];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell" forIndexPath:indexPath];
    cell.place = self.places[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}


@end
