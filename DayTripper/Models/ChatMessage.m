//
//  ChatMessage.m
//  DayTripper
//
//  Created by Michael Abelar on 7/25/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage
@dynamic username;
@dynamic message;

+ (nonnull NSString *)parseClassName {
return @"ChatMessage";
}


@end
