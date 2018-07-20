//
//  UserCollectionCell.h
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface UserCollectionCell : UICollectionViewCell
@property (strong, nonatomic) PFUser *user;
@end
