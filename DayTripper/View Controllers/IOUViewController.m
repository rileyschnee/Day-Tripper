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
#import "SVProgressHUD.h"

@interface IOUViewController () <UITableViewDelegate, UITableViewDataSource, IOUCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addIOUButton;

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
    self.addIOUButton.enabled = !self.isUsersIOUs;
    if(!self.isUsersIOUs){
        [self fetchIOUs];
    }
    NSLog(@"IOU VC %@", self.iouArray);
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.addIOUButton.enabled = !self.isUsersIOUs;
    if(!self.isUsersIOUs){
        [self fetchIOUs];
    }
    NSLog(@"IOU VC %@", self.iouArray);
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
    //IOU *temp = self.trip.ious[indexPath.row];
    cell.iou = self.iouArray[indexPath.row];
    cell.delegate = self;
    NSLog(@"%@ current iou", cell.iou);
    cell.iouLabel.text = [NSString stringWithFormat:@"%@ owes %@ $%@ for %@", cell.iou[@"payer"][@"username"], cell.iou[@"payee"][@"username"], cell.iou[@"amount"], cell.iou[@"description"]];
    NSLog(@"%@ Completed", cell.iou[@"completed"]);
    if([cell.iou[@"completed"] isEqual:[NSNumber numberWithBool:TRUE]]){
        cell.paidStatusImage.image = [UIImage imageNamed:@"paid"];
    } else {
        cell.paidStatusImage.image = [UIImage imageNamed:@"unpaid"];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(togglePaidStatus:)];
    [cell addGestureRecognizer:tap];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.iouArray count];
}

- (void)fetchIOUs{
    PFQuery *query = [PFQuery queryWithClassName:@"IOU"];
    [query whereKey:@"objectId" containedIn:self.trip.ious];
    [query includeKeys:@[@"payer", @"payee", @"description", @"amount", @"completed"]];
    [query orderByAscending:@"completed"];
    
    //query.limit = 20;
    [SVProgressHUD show];
    [query findObjectsInBackgroundWithBlock:^(NSArray *ious, NSError *error) {
        if (ious != nil){
            self.iouArray = [ious mutableCopy];
            NSLog(@"%@", self.iouArray);
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
            NSLog(@"Error fetching ious");
        }
        [SVProgressHUD dismiss];
    }];
}


- (IBAction)clickedAddIOU:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add IOU" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Payer Username";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Payee Username";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Amount";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Description";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
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
    
    [IOU saveIOUwithAmount:amount fromPayer:payer toPayee:payee withDescription:desc toTrip:self.trip withCompletion:^(BOOL complete) {
        NSLog(@"In completion block");
        [self fetchIOUs];
        //[self.tableView reloadData];
    }];
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlert:(UIAlertController *)alert {
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
