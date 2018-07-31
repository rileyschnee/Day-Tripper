//
//  IOUViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "IOUViewController.h"
#import "IOUCell.h"
#import "IOU.h"

@interface IOUViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IOUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //fix extra space at the top of the table view
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
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
    IOUCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IOUCell" forIndexPath:indexPath];
    cell.iou = self.trip.ious[indexPath.row];
    cell.iouLabel.text = [NSString stringWithFormat:@"%@ owes %@ $%@ for %@", cell.iou.payer.username, cell.iou.payee.username, cell.iou.amount, cell.iou.description];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trip.ious.count;
}

- (IBAction)clickedAddIOU:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add IOU" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Payer Username";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Payee Username";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Amount";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Description";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Save IOU" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self processAddIOUParamsWithAmount:[alertController textFields][2].text fromPayer:[alertController textFields][0].text toPayee:[alertController textFields][1].text withDescription:[alertController textFields][3].text];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)processAddIOUParamsWithAmount:(NSString *)amountString fromPayer:(NSString *)payerString toPayee:(NSString *)payeeString withDescription:(NSString *)description {
    // format amount
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    //NSNumber *amount = [f numberFromString:amountString];
    double amountDouble = [amountString doubleValue];
    NSNumber *amount = [NSNumber numberWithDouble:amountDouble];
    NSLog(@"%@", amount);
    
    // find and verify users
    if([payeeString isEqualToString:payerString]){
        NSLog(@"Invalid");
        return;
    }
    if(![PFUser.currentUser.username isEqualToString:payerString] && ![PFUser.currentUser.username isEqualToString:payeeString]){
        NSLog(@"You cannot make an IOU that doesn't involve yourself");
        return;
    }
    PFUser *payer;
    PFUser *payee;
    for(PFUser *user in self.attendeeUsers){
        if([user.username isEqualToString:payerString]){
            payer = user;
        } else if ([user.username isEqualToString:payeeString]){
            payee = user;
        }
    }
    if(payer == nil || payee == nil){
        NSLog(@"Payer or Payee not included in attendee list");
        return;
    }
    NSString *desc = description;
    
    [IOU saveIOUwithAmount:amount fromPayer:payer toPayee:payee withDescription:desc toTrip:self.trip];
    [self.tableView reloadData];
}

@end
