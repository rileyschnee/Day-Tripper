//
//  ChatMessage.h
//  DayTripper
//
//  Created by Michael Abelar on 7/25/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "PFObject.h"

@interface ChatMessage : PFObject <PFSubclassing>
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* message;
@end
