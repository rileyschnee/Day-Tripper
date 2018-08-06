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
#import <NYAlertViewController/NYAlertViewController.h>
#import "Functions.h"

@interface IOUViewController () <UITableViewDelegate, UITableViewDataSource, IOUCellDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addIOUButton;
@property (strong, nonatomic) NYAlertViewController *alert;

@end

@implementation IOUViewController

// constant for keyboard movement
int MOVEMENT_NUM = 200;

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

# pragma mark - Table View Functions

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

# pragma mark - Fetch Functions

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

# pragma mark - Button functions

- (IBAction)clickedAddIOU:(id)sender {
    
    self.alert = [[NYAlertViewController alloc] initWithNibName:nil bundle:nil];
    
    // Set a title and message
    self.alert.title = NSLocalizedString(@"Add IOU", nil);
    self.alert.message = NSLocalizedString(@"", nil);
    
    // Customize appearance as desired
    self.alert.buttonCornerRadius = 20.0f;
    self.alert.alertViewCornerRadius = 20.0f;
    self.alert.view.tintColor = [UIColor colorWithRed:0.94 green:0.40 blue:0.23 alpha:1.0];
    
    self.alert.titleFont = [UIFont fontWithName:@"AvenirNext-Bold" size:19.0f];
    self.alert.messageFont = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    self.alert.buttonTitleFont = [UIFont fontWithName:@"AvenirNext-Regular" size:self.alert.buttonTitleFont.pointSize];
    self.alert.cancelButtonTitleFont = [UIFont fontWithName:@"AvenirNext-Medium" size:self.alert.cancelButtonTitleFont.pointSize];
    self.alert.cancelButtonColor = [UIColor colorWithRed:0.36 green:0.56 blue:0.76 alpha:1.0];
    self.alert.buttonColor = [UIColor colorWithRed:0.36 green:0.56 blue:0.76 alpha:1.0];
    self.alert.titleColor = [UIColor blackColor];
    self.alert.messageColor = [UIColor blackColor];
    
    self.alert.swipeDismissalGestureEnabled = NO;
    self.alert.backgroundTapDismissalGestureEnabled = NO;
    
    //Add textfields
    [self.alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Payer Username";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [self.alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Payee Username";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;

    }];
    [self.alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Amount";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;

    }];
    [self.alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Description";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;

    }];
    
    // Add alert actions
    [self.alert addAction:[NYAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self.alert addAction:[NYAlertAction actionWithTitle:@"Save IOU" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        NSString *amt = ((UITextField *)[self.alert textFields][2]).text;
        NSString *payer = [((UITextField *)[self.alert textFields][0]).text lowercaseString];
        NSString *payee = [((UITextField *)[self.alert textFields][1]).text lowercaseString];
        NSString *desc = ((UITextField *)[self.alert textFields][3]).text;
        [self dismissViewControllerAnimated:YES completion:nil];
        if([amt isEqualToString:@""] || [payer isEqualToString:@""] ||
           [payee isEqualToString:@""] || [desc isEqualToString:@""]){
            [self alertIncomplete];
        } else {
            [self processAddIOUParamsWithAmount:amt fromPayer:payer toPayee:payee withDescription:desc];
        }
    }]];
    
    [self presentViewController:self.alert animated:YES completion:nil];

    
    
    // OLD WAY
//
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add IOU" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"Payer Username";
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    }];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"Payee Username";
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    }];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"Amount";
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    }];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"Description";
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    }];
//    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Save IOU" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self processAddIOUParamsWithAmount:[alertController textFields][2].text fromPayer:[alertController textFields][0].text toPayee:[alertController textFields][1].text withDescription:[alertController textFields][3].text];
//    }];
//    [alertController addAction:confirmAction];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        NSLog(@"Cancelled");
//    }];
//    [alertController addAction:cancelAction];
//    [self presentViewController:alertController animated:YES completion:nil];
    
}

# pragma mark - Helper Functions

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
        [self alertPayerIsPayee];
        return;
    }
    if(![PFUser.currentUser.username isEqualToString:payerString] && ![PFUser.currentUser.username isEqualToString:payeeString]){
        NSLog(@"You cannot make an IOU that doesn't involve yourself");
        [self alertCurrentUserNotInvolved];
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
        [self alertNotInAttendeeList];
        return;
    }
    NSString *desc = description;
    
    [IOU saveIOUwithAmount:amount fromPayer:payer toPayee:payee withDescription:desc toTrip:self.trip withCompletion:^(BOOL complete) {
        NSLog(@"In completion block");
        [self fetchIOUs];
        //[self.tableView reloadData];
    }];
    
}

# pragma mark - Alert Functions
- (void)alertPayerIsPayee{
    NYAlertViewController *alert = [Functions alertWithTitle:@"Invalid Entry" withMessage:@"Payer cannot be the same as payee."];
    [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissAlert:alert];
    }]];
    [self showAlert:alert];
}

- (void)alertCurrentUserNotInvolved{
    NYAlertViewController *alert = [Functions alertWithTitle:@"Invalid Entry" withMessage:@"You must either be the payer or the payee."];
    [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissAlert:alert];
    }]];
    [self showAlert:alert];
}

- (void)alertNotInAttendeeList{
    NYAlertViewController *alert = [Functions alertWithTitle:@"Invalid Entry" withMessage:@"Payer or payee not in attendee list."];
    [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissAlert:alert];
    }]];
    [self showAlert:alert];
}

- (void)alertIncomplete{
    NYAlertViewController *alert = [Functions alertWithTitle:@"Incomplete Entry" withMessage:@"A field was left blank."];
    [alert addAction:[NYAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(NYAlertAction *action) {
        [self dismissAlert:alert];
    }]];
    [self showAlert:alert];
}

# pragma mark - Navigation

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Protocol Implementations

- (void)showAlert:(UIAlertController *)alert {
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissAlert:(NYAlertViewController *)alert{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
