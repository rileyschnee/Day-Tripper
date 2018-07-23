//
//  DTUser.h
//  DayTripper
//
//  Created by Riley Schnee on 7/23/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "PFUser.h"
#import <Parse/Parse.h>

@interface DTUser : PFUser <PFSubclassing>
@property (strong, nonatomic) PFFile *picture;

@end
