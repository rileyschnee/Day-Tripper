//
//  Event.h
//  DayTripper
//
//  Created by Michael Abelar on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "PFObject.h"
#import "Activity.h"

@interface Event : PFObject <PFSubclassing, Activity>

@property (strong, nonatomic) NSString *eventType;

@end
