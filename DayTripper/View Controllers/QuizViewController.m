//
//  QuizViewController.m
//  DayTripper
//
//  Created by Riley Schnee on 7/13/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "QuizViewController.h"
#import "ResultsViewController.h"
#import <MapKit/MapKit.h>

@interface QuizViewController () <MKLocalSearchCompleterDelegate>
@property (strong, nonatomic) MKLocalSearchCompleter *completer;
@property(nonatomic, readonly, strong) NSArray <MKLocalSearchCompletion *> *results;

@end

@implementation QuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.completer = [[MKLocalSearchCompleter alloc] init];
    self.completer.delegate = self;
    self.completer.filterType = MKSearchCompletionFilterTypeLocationsAndQueries;
    
}



- (void) completerDidUpdateResults:(MKLocalSearchCompleter *)completer {
    for (MKLocalSearchCompletion *completion in completer.results) {
        NSLog(@"------ %@",completion.description);
    }
}

- (void) completer:(MKLocalSearchCompleter *)completer didFailWithError:(NSError *)error {
    NSLog(@"Completer failed with error: %@",error.description);
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ResultsViewController *resultsViewController = [segue destinationViewController];
    resultsViewController.location = self.locationField.text;
}


@end
