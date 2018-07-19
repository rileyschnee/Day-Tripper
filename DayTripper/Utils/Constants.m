//
//  Constants.m
//  DayTripper
//
//  Created by Riley Schnee on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Constants.h"

@implementation Constants

- (void)cats{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@"object1" forKey:@"key"];
    
    //get JSON file
    NSDictionary *dict = [self JSONFromFile:@"yelpCategories"];
    for (NSDictionary *cat in dict) {
        NSString *title = [cat objectForKey:@"title"];
        NSString *alias = [cat objectForKey:@"alias"];
        // Add alias-title key-value pair to dictionary
        [dictionary setObject:title forKey:alias];
    }
    NSLog(@"%@", dictionary);
    
}




- (NSDictionary *)foodCategories{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@"object1" forKey:@"key"];
    
    //get JSON file
    NSDictionary *fullDict = [self JSONFromFile:@"yelpCategories"];
    for (NSDictionary *cat in fullDict) {
        NSString *title = [cat objectForKey:@"title"];
        NSString *alias = [cat objectForKey:@"alias"];
        // Add alias-title key-value pair to dictionary
        [dictionary setObject:title forKey:alias];
    }
    NSLog(@"%@", dictionary);
    return dictionary;
}

- (NSDictionary *)JSONFromFile:(NSString *)filename{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


@end
