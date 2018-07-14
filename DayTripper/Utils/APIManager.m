//
//  APIManager.m
//  DayTripper
//
//  Created by Michael Abelar on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

- (void) getRequest:(NSString *)url params:(NSDictionary*)params completion:(void (^)(NSArray *))completion{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //iterate through dictionary
    NSString* appendStr = [self buildQueryStringFromDictionary:params];
    [request setHTTPMethod:@"GET"];
    NSString* finalURL = [NSString stringWithFormat:@"%@%@", url, appendStr];
    [request setURL:[NSURL URLWithString:finalURL]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableArray* mutableReturnArray = [[NSMutableArray alloc] init];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if (error == nil) {
                        NSArray *receivedObject = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                        if ([receivedObject isKindOfClass:[NSArray class]]) {
                            completion(receivedObject);
                            
                        } else if ([receivedObject isKindOfClass:[NSDictionary class]]) {
                            [mutableReturnArray addObject:receivedObject];
                            NSArray* returnArray = [mutableReturnArray copy];
                            completion(returnArray);
                        } else if ([receivedObject isKindOfClass:[NSString class]]) {
                            NSString* stringRep = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            NSData *data = [stringRep dataUsingEncoding:NSUTF8StringEncoding];
                            NSError* convertError = nil;
                            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&convertError];
                            [mutableReturnArray addObject:json];
                            NSArray* returnArray = [mutableReturnArray copy];
                            completion(returnArray);
                        }
                    }
                    else {
                        completion(nil);
                    }
                }] resume];
}

-(NSString *) buildQueryStringFromDictionary:(NSDictionary *)parameters {
    NSString *urlVars = nil;
    for (NSString *key in parameters) {
        NSString *value = parameters[key];
        value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        urlVars = [NSString stringWithFormat:@"%@%@=%@", urlVars ? @"&": @"", key, value];
    }
    return [NSString stringWithFormat:@"%@%@", urlVars ? @"?" : @"", urlVars ? urlVars : @""];
}

- (void) getRequest:(NSString *)url completion:(void (^)(NSArray *))completion{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableArray* mutableReturnArray = [[NSMutableArray alloc] init];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                if (error == nil) {
                    NSArray *receivedObject = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                    if ([receivedObject isKindOfClass:[NSArray class]]) {
                        completion(receivedObject);
                        
                    } else if ([receivedObject isKindOfClass:[NSDictionary class]]) {
                        [mutableReturnArray addObject:receivedObject];
                        NSArray* returnArray = [mutableReturnArray copy];
                        completion(returnArray);
                    } else if ([receivedObject isKindOfClass:[NSString class]]) {
                        NSString* stringRep = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        NSData *data = [stringRep dataUsingEncoding:NSUTF8StringEncoding];
                        NSError* convertError = nil;
                        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&convertError];
                        [mutableReturnArray addObject:json];
                        NSArray* returnArray = [mutableReturnArray copy];
                        completion(returnArray);
                    }
                }
                else {
                    completion(nil);
                }
            }] resume];
}

- (void) postRequest:(NSString *)url params:(NSDictionary*)params completion:(void (^)(NSArray *))completion{
    //iterate through dictionary
    NSEnumerator *enumerator = [params keyEnumerator];
    id key;
    BOOL firstInstance = YES;
    NSString* bodyParams = @"";
    while((key = [enumerator nextObject])) {
        NSString* oneVarString = @"";
        if (firstInstance == NO) {
            oneVarString = [NSString stringWithFormat:@"&%@=%@", key, [params objectForKey:key]];
        }
        else {
            oneVarString = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]];
        }
        bodyParams = [NSString stringWithFormat:@"%@%@", bodyParams, oneVarString];
        if (firstInstance == YES) {
            firstInstance = NO;
        }
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyParams length]];
    //set body
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[bodyParams dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableArray* mutableReturnArray = [[NSMutableArray alloc] init];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if (error == nil) {
                        NSArray *receivedObject = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
                        if ([receivedObject isKindOfClass:[NSArray class]]) {
                            completion(receivedObject);
                            
                        } else if ([receivedObject isKindOfClass:[NSDictionary class]]) {
                            [mutableReturnArray addObject:receivedObject];
                            NSArray* returnArray = [mutableReturnArray copy];
                            completion(returnArray);
                        } else if ([receivedObject isKindOfClass:[NSString class]]) {
                            NSString* stringRep = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            NSData *data = [stringRep dataUsingEncoding:NSUTF8StringEncoding];
                            NSError* convertError = nil;
                            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&convertError];
                            [mutableReturnArray addObject:json];
                            NSArray* returnArray = [mutableReturnArray copy];
                            completion(returnArray);
                        }
                    }
                    else {
                        completion(nil);
                    }
                }] resume];
}
@end
