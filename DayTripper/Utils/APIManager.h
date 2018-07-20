//
//  APIManager.h
//  DayTripper
//
//  Created by Michael Abelar on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject
// this method will perform a get request given a URL
//parameters should be strings
- (void) getRequest:(NSString *)url completion:(void (^)(NSArray *))completion;

// this method will perform a get request given a URL and a dictionary of parameters for header fields
/*Example usage:
     NSDictionary* params = @{ @"paramName": @"value"};
     [self getRequest:@"URL_HERE" params:params completion:^(NSArray* responseDict) {
     NSLog(@"%@", responseDict);
     }];
 */

- (void) postRequest:(NSString *)url params:(NSDictionary*)params completion:(void (^)(NSArray *))completion;
//this method will perform a post request given a url and a dictionary of parameters for the body
/*Example usage:
    NSDictionary* params = @{ @"title": @"foo", @"body": @"bar"};
    [self postRequest:@"URL" params:params completion:^(NSArray* responseDict) {
        NSLog(@"%@", responseDict);
    }];
 
 */

//see above
- (void) getRequest:(NSString *)url params:(NSDictionary*)params completion:(void (^)(NSArray *))completion;

@end
