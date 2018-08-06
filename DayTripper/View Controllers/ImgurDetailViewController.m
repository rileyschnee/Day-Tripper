//
//  ImgurDetailViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 8/6/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ImgurDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ImgurDetailViewController ()

@end

@implementation ImgurDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.pictureView setImageWithURL:self.imageURL];
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

@end
