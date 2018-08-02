//
//  Constants.m
//  DayTripper
//
//  Created by Riley Schnee on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Constants.h"

@implementation Constants

// categories for quiz view

- (void)setCategories{
    NSMutableDictionary *placeDictionary = [NSMutableDictionary dictionary];
    //PLACES
    //get JSON file
    NSDictionary *fullDict = [self JSONFromFile:@"4SQCategories"];
    //NSLog(@"CAT ARRAY: %@", fullDict);
    for (NSDictionary *cat in fullDict) {
        NSString *title = [cat objectForKey:@"name"];
        NSString *alias = [cat objectForKey:@"id"];
        // Add alias-title key-value pair to dictionary
        [placeDictionary setObject:alias forKey:title];
        for (NSDictionary *cat2 in [cat objectForKey:@"categories"]){
            NSString *title = [cat2 objectForKey:@"name"];
            NSString *alias = [cat2 objectForKey:@"id"];
            // Add alias-title key-value pair to dictionary
            [placeDictionary setObject:alias forKey:title];
        }
    }
    NSLog(@"%i", (int)placeDictionary.count);
    self.placeCategories = placeDictionary;
    
    // FOOD
    NSMutableDictionary *foodDictionary = [NSMutableDictionary dictionary];
    //get JSON file
    NSMutableDictionary *fullDictFood = [self JSONFromFile:@"yelpCategories"];
    for (NSMutableDictionary *cat in fullDictFood) {
        if([self isFoodCategory:cat]){
            NSString *title = [cat objectForKey:@"title"];
            NSString *alias = [cat objectForKey:@"alias"];
            // Add alias-title key-value pair to dictionary
            [foodDictionary setObject:alias forKey:title];
        }
    }
    NSLog(@"%i", (int)foodDictionary.count);
    self.foodCategories = foodDictionary;
    
    //EVENTS
    NSMutableDictionary *eventDictionary = [NSMutableDictionary dictionary];
    NSArray *catarray = @[@"observances", @"politics",
                          @"conferences", @"expos", @"concerts", @"festivals", @"performing-arts",
                          @"sports", @"community"];
    //get JSON file
    for (NSString *cat in catarray) {
        NSString *title = [[cat stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
        NSString *alias = cat;
        // Add alias-title key-value pair to dictionary
        [eventDictionary setObject:alias forKey:title];
    }
    self.eventCategories = eventDictionary;
    
}


- (BOOL)isFoodCategory:(NSMutableDictionary *)cat{
    return [[cat objectForKey:@"parents"] containsObject:@"food"] || [[cat objectForKey:@"parents"] containsObject:@"retaurants"] || [[cat objectForKey:@"parents"] containsObject:@"nightlife"];
}
    


- (NSMutableDictionary *)JSONFromFile:(NSString *)filename{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


@end
