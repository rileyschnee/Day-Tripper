//
//  Constants.m
//  DayTripper
//
//  Created by Riley Schnee on 7/18/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "Constants.h"

@implementation Constants

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
        [placeDictionary setObject:title forKey:alias];
        for (NSDictionary *cat2 in [cat objectForKey:@"categories"]){
            NSString *title = [cat2 objectForKey:@"name"];
            NSString *alias = [cat2 objectForKey:@"id"];
            // Add alias-title key-value pair to dictionary
            [placeDictionary setObject:alias forKey:title];
        }
    }
    self.placeCategories = placeDictionary;
    
    // FOOD
    NSMutableDictionary *foodDictionary = [NSMutableDictionary dictionary];
    //get JSON file
    NSMutableDictionary *fullDictFood = [self JSONFromFile:@"yelpCategories"];
    for (NSMutableDictionary *cat in fullDictFood) {
        NSString *title = [cat objectForKey:@"title"];
        NSString *alias = [cat objectForKey:@"alias"];
        // Add alias-title key-value pair to dictionary
        [foodDictionary setObject:alias forKey:title];
    }
    self.foodCategories = foodDictionary;
    
    //EVENTS
    NSMutableDictionary *eventDictionary = [NSMutableDictionary dictionary];
    NSArray *catarray = @[@"school-holidays", @"public-holidays", @"observances", @"politics",
                          @"conferences", @"expos", @"concerts", @"festivals", @"performing-arts",
                          @"sports", @"community", @"daylight-savings", @"airport-delays", @"severe-weather",
                          @"disasters", @"terror"];
    //get JSON file
    for (NSString *cat in catarray) {
        NSString *title = [[cat stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
        NSString *alias = cat;
        // Add alias-title key-value pair to dictionary
        [eventDictionary setObject:alias forKey:title];
    }
    self.eventCategories = eventDictionary;
    
}
    


- (NSMutableDictionary *)JSONFromFile:(NSString *)filename{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


@end
