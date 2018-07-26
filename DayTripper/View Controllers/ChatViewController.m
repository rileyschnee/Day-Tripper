//
//  ChatViewController.m
//  DayTripper
//
//  Created by Michael Abelar on 7/25/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCell.h"
#import "ChatMessage.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
@interface ChatViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *messageBody;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation ChatViewController

// constant for keyboard movement
int MOVEMENT_KEYBOARD = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageBody.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.chats = [[NSMutableArray alloc] init];
    
    //get the trip from the itin view
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.trip = delegate.currTrip;
    
    [self displayChatConversation];
    //start the message refresh method
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(displayChatConversation) userInfo:nil repeats:true];
}

- (IBAction)onTapGestureRecognizer:(id)sender {
    [self.messageBody resignFirstResponder];
}

//send a message
- (IBAction)sendMessageTapped:(id)sender {
    NSString *username = [PFUser currentUser][@"username"];
    NSString *message = self.messageBody.text;
    ChatMessage* chat = [ChatMessage new];
    chat.username = username;
    chat.message = message;
    //now save the message
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            //now make a pointer to trip
            NSMutableArray* currChats = self.trip.chats;
            if (currChats == nil) {
                currChats = [[NSMutableArray alloc] init];
            }
            [currChats addObject:chat];
            self.trip.chats = currChats;
            [self.trip saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (succeeded) {
                    //clear chat message
                    self.messageBody.text = @"";
                    [self displayChatConversation];
                } else {
                    NSLog(@"Problem saving trip: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Problem saving chat: %@", error.localizedDescription);
        }
    }];
    
}


//function that will load the chat conversation
- (void) displayChatConversation {
    //get the one trip
    NSString* currObjectId = self.trip.objectId;
    //perform query
    PFQuery *query = [PFQuery queryWithClassName:@"Trip"]; //how to define a query
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"chats"];
    [query whereKey:@"objectId" equalTo:currObjectId];
    query.limit = 1;
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *tripObj, NSError *error) {
        if (tripObj != nil) {
            Trip *trip = (Trip*) tripObj;
            self.chats = trip.chats;
            self.trip = trip;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

#pragma mark - animation methods

//function that moves element by delta y
- (void) moveElementVertically:(int) points {
    //move text field
    CGRect frame = self.messageBody.frame;
    frame.origin.y = frame.origin.y + points;
    [self.messageBody setFrame:frame];
    //move submit button
    CGRect frame2 = self.submitButton.frame;
    frame2.origin.y = frame2.origin.y + points;
    [self.submitButton setFrame:frame2];
}

//function that reduces the height of an element
- (void) reduceHeight:(int) points {
    //make table view shorter
    CGRect frame = self.tableView.frame;
    frame.size.height = frame.size.height + (-1 * points);
    [self.tableView setFrame:frame];
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self reduceHeight:MOVEMENT_KEYBOARD];
    [self moveElementVertically:(-1* MOVEMENT_KEYBOARD)];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self reduceHeight:(-1 * MOVEMENT_KEYBOARD)];
    [self moveElementVertically:MOVEMENT_KEYBOARD];
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    ChatMessage* chat = self.chats[indexPath.row];
    cell.usernameLabel.text = [NSString stringWithFormat:@"%@%@", chat.username, @":"];
    cell.messageLabel.text = chat.message;
    return cell;
}

@end
