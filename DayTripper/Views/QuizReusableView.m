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
}
- (void)dismissKeyboard:(UITapGestureRecognizer *)sender {
    [self.locationField resignFirstResponder];
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
            MKMapItem *item = response.mapItems[0];
            self.delegate.latitude = item.placemark.location.coordinate.latitude;
            self.delegate.longitude = item.placemark.location.coordinate.longitude;
            self.delegate.location = self.locationField.text;
        }
    }];
}

- (void) completer:(MKLocalSearchCompleter *)completer didFailWithError:(NSError *)error {
    NSLog(@"Completer failed with error: %@",error.description);
}

@end
