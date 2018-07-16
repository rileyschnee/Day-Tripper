//
//  ItinCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/16/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface ItinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (strong, nonatomic) Place *place;
@end
