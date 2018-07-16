//
//  TripCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trip.h"

@interface TripCell : UITableViewCell
@property (strong, nonatomic) Trip *trip;
@property (weak, nonatomic) IBOutlet UILabel *tripNameLabel;
@end
