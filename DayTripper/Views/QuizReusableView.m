//
//  QuizReusableView.m
//  DayTripper
//
//  Created by Riley Schnee on 7/19/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "QuizReusableView.h"

@implementation QuizReusableView
- (void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self addGestureRecognizer:tap];
    [self.datePicker setMinimumDate: [NSDate date]];
    //set make date for trip only a week from the current day
    NSDate *sevenDaysOut = [[NSDate date] dateByAddingTimeInterval:60*60*24*7];
    [self.datePicker setMaximumDate: sevenDaysOut];
    [self.locationField setBorderStyle:UITextBorderStyleNone];
    self.locationField.delegate = self;
}
- (void)dismissKeyboard:(UITapGestureRecognizer *)sender {
    [self.locationField resignFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([textField.text length] > 3)
    {
        [self completerRunText:textField.text];
    }
}

- (void) completerRunText:(NSString *)query {
    self.completer = [[MKLocalSearchCompleter alloc] init];
    self.completer.delegate = self;
    self.completer.filterType = MKSearchCompletionFilterTypeLocationsAndQueries;
    self.completer.queryFragment = query;
}


- (void) completerDidUpdateResults:(MKLocalSearchCompleter *)completer {
    self.searchResults = [[NSMutableArray alloc] init];
    for (MKLocalSearchCompletion* result in completer.results) {
        NSString *completion = [result.description componentsSeparatedByString:@"> "][1];
        [self.searchResults addObject:completion];
    }
}

- (IBAction)changeDate:(id)sender {
    self.delegate.tripDate = self.datePicker.date;
}

- (void) getAddressFromName:(NSString*) name {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = name;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count>0) {
            MKMapItem *item = response.mapItems[0];
            self.delegate.latitude = item.placemark.location.coordinate.latitude;
            self.delegate.longitude = item.placemark.location.coordinate.longitude;
            self.delegate.location = self.locationField.text;
            self.delegate.tripDate = self.datePicker.date;
        }
    }];
}

- (void) completer:(MKLocalSearchCompleter *)completer didFailWithError:(NSError *)error {
    NSLog(@"Completer failed with error: %@",error.description);
}

# pragma mark - MPGTextFieldDelegate
- (NSArray*) dataForPopoverInTextField:(MPGTextField *)textField {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSString* result in self.searchResults) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setValue:result forKey:@"DisplayText"];
        [array addObject:[dict copy]];
    }
    return [array copy];
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result {
     [self getAddressFromName:result[@"DisplayText"]];
}


@end
