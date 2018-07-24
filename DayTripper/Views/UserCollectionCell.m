//
//  UserCollectionCell.m
//  DayTripper
//
//  Created by Riley Schnee on 7/20/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "UserCollectionCell.h"

@implementation UserCollectionCell
- (void)setUser:(PFUser *)user{
    _user = user;
    //self.profilePicView.file = user[@"picture"];
    //[self.profilePicView loadInBackground];
    self.image = user[@"picture"];
    //self.profilePicView.file = self.image;
}
@end
