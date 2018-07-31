//
//  DMConvo.h
//  DayTripper
//
//  Created by Michael Abelar on 7/31/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "PFObject.h"
#import <Parse/Parse.h>

@interface DMConvo : PFObject  <PFSubclassing>
@property (strong, nonatomic) NSArray* chats;
@property (strong, nonatomic) NSString* name;
@end
