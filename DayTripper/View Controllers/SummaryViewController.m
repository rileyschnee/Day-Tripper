//
//  SummaryViewController.m
//  DayTripper
//
//  Created by Kimora Kong on 7/31/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "SummaryViewController.h"

@interface SummaryViewController ()

@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationBar* navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"Details"];
    // [navbar setBarTintColor:[UIColor lightGrayColor]];
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onTapBack:)];
    navItem.leftBarButtonItem = backBtn;
    
    
    [navbar setItems:@[navItem]];
    [self.view addSubview:navbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onTapBack:(UIBarButtonItem *)button {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickBtn:(id)sender {
    self.trip.summary = self.summaryField.text;
    [self.trip saveInBackground];
    [self dismissViewControllerAnimated:true completion:nil];
    
}
@end
