//
//  TripReusableView.h
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface TripReusableView : UICollectionReusableView
@property (strong, nonatomic) Trip *trip;
@property (weak, nonatomic) IBOutlet UIView *weatherView;
@property (weak, nonatomic) IBOutlet UILabel *tripNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *tripDateLabel;
@end
