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
#import "Constants.h"

@interface QuizViewController () <MKLocalSearchCompleterDelegate>
@property (strong, nonatomic) MKLocalSearchCompleter *completer;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;
@property(nonatomic, readonly, strong) NSArray <MKLocalSearchCompletion *> *results;

- (IBAction)didTap:(id)sender;
//used to identify last location typed by user
@property (nonatomic) int lastEditedLocation;
@property (nonatomic) int prevTextFieldLength;
@end

@implementation QuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.locationField setDelegate:self];
    self.latitude = 0;
    self.longitude = 0;
    [self.locationField addTarget:self
                           action:@selector(textFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
    Constants *yelpCats = [[Constants alloc] init];
    [yelpCats cats];
    
}

- (void)textFieldDidChange:(UITextField *)textField {
    
    if ([textField.text length] > 4)
    {
        
        if (textField.text.length < self.prevTextFieldLength) {
            self.prevTextFieldLength = (int) textField.text.length;
        }
        else {
            self.lastEditedLocation = ((int) [textField.text length]);
            [self completerRunText:textField.text];
        }
    }

    
}

- (void) completerRunText:(NSString *)query {
    self.completer = [[MKLocalSearchCompleter alloc] init];
    self.completer.delegate = self;
    self.completer.filterType = MKSearchCompletionFilterTypeLocationsAndQueries;
    self.completer.queryFragment = query;
}



- (void) completerDidUpdateResults:(MKLocalSearchCompleter *)completer {
    if (completer.results.count > 0) {
        MKLocalSearchCompletion *result  = completer.results[0];
        NSString *completion = [result.description componentsSeparatedByString:@">"][1];
        [self getAddressFromName:completion];
        self.locationField.text = completion;
        [self selectPartOfTextField:self.locationField];
        self.prevTextFieldLength = (int) self.locationField.text.length;
    }
}

- (void) selectPartOfTextField:(UITextField*) textField {
    UITextRange *selectedRange = [textField selectedTextRange];
    int positionToStartHighlighting = ( (int) self.locationField.text.length) - self.lastEditedLocation;
    UITextPosition *newPosition = [textField positionFromPosition:selectedRange.end offset:-positionToStartHighlighting];
    UITextRange *newRange = [textField textRangeFromPosition:newPosition toPosition:selectedRange.start];
    [textField setSelectedTextRange:newRange];
}

- (void) getAddressFromName:(NSString*) name {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = name;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count>0) {
            MKMapItem *item =response.mapItems[0];
            self.latitude = item.placemark.location.coordinate.latitude;
            self.longitude = item.placemark.location.coordinate.longitude;
        }
    }];
}

- (void) completer:(MKLocalSearchCompleter *)completer didFailWithError:(NSError *)error {
    NSLog(@"Completer failed with error: %@",error.description);
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ResultsViewController *resultsViewController = [segue destinationViewController];
    resultsViewController.location = self.locationField.text;
    resultsViewController.latitude = self.latitude;
    resultsViewController.longitude = self.longitude;
}


- (IBAction)didTap:(id)sender {
    [self.locationField resignFirstResponder];
}
@end
