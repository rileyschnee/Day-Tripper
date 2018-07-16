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
@interface ResultsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *places;
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
    [self fetchResults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSMutableArray *chosenPlaces = [[NSMutableArray alloc] init];
    for(ResultsCell *cell in [self.functions getCellsFromTable:self.tableView]){
        if(cell.checkButton.selected){
            [chosenPlaces addObject:cell.place];
        }
        
    }
    
    ItinViewController *itinViewController = [segue destinationViewController];
    itinViewController.places = chosenPlaces;
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsCell" forIndexPath:indexPath];
    cell.place = self.places[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (void)fetchResults{
    self.places = [[NSMutableArray alloc] init];
    Place *temp1 = [[Place alloc] init];
    Place *temp2 = [[Place alloc] init];
    Place *temp3 = [[Place alloc] init];
    Place *temp4 = [[Place alloc] init];
    Place *temp5 = [[Place alloc] init];

    temp1.name = @"MOMA";
    [self.places addObject:temp1];
    temp2.name = @"Palace of Fine Arts";
    [self.places addObject:temp2];
    temp3.name = @"Ghiridelli Square";
    [self.places addObject:temp3];
    temp4.name = @"Fisherman's Wharf";
    [self.places addObject:temp4];
    temp5.name = @"Sausalito";
    [self.places addObject:temp5];
    [self.tableView reloadData];
    
}


@end
