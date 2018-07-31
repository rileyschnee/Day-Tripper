//
//  DMViewController.m
//  DayTripper
//
//  Created by Michael Abelar on 7/30/18.
//  Copyright © 2018 MakerApps. All rights reserved.
//

#import "DMViewController.h"
#import <Parse/Parse.h>
#import "ChatMessage.h"
#import "DMConvo.h"
#import "ChatCell.h"

@interface DMViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageBody;
@property (strong, nonatomic) NSString* chatName;
@property (strong, nonatomic) NSMutableArray *chats;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) DMConvo* convo;

@end

@implementation DMViewController

//turns hex into ui color
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// constant for keyboard movement
int MOVEMENT_KEYBOARD = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageBody.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chats = [[NSMutableArray alloc] init];
    self.chatName = @"";
    
    // we have username of other user and current user which we combine to make chat convo name for db ref
    self.chatName = [NSString stringWithFormat:@"%@%@%@", [PFUser currentUser].username, @"-", self.otherPersonUserName];
    
    //get the chat conversation
    
    [self displayDMConversation];
    //start the message refresh method
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(displayDMConversation) userInfo:nil repeats:true];
    
}

- (IBAction)sendMessageTapped:(id)sender {
    NSString *username = PFUser.currentUser.username;
    NSString *message = self.messageBody.text;
    ChatMessage* chat = [ChatMessage new];
    chat.username = username;
    chat.message = message;
    //now save the message
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            //now add to convo
            NSMutableArray* currChats = [self.convo.chats mutableCopy];
            if (currChats == nil) {
                currChats = [[NSMutableArray alloc] init];
            }
            [currChats addObject:chat];
            self.convo.chats = [currChats copy];
            [self.convo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                if (succeeded) {
                    //clear chat message
                    self.messageBody.text = @"";
                    [self displayDMConversation];
                } else {
                    NSLog(@"Problem saving trip: %@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"Problem saving chat: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)tapGesturePressed:(id)sender {
    [self.messageBody resignFirstResponder];
}

//this function will search conversations table for the current convo
- (void) displayDMConversation {
    //perform query
    PFQuery *query = [PFQuery queryWithClassName:@"DMConvo"]; //how to define a query
    [query includeKey:@"chats"];
    [query whereKey:@"name" equalTo:self.chatName];
    query.limit = 1;
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *convoObj, NSError *error) {
        if (convoObj != nil) {
            DMConvo *convo = (DMConvo*) convoObj;
            self.chats = [convo.chats mutableCopy];
            self.convo = convo;
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
    //color the message blue if from user
    if ([chat.username isEqualToString:[PFUser currentUser].username]) {
        cell.messageContainerView.backgroundColor = UIColorFromRGB(0x5C8EC3);
        cell.messageLabel.textColor = [UIColor whiteColor];
    }
    
    //message styling
    cell.messageContainerView.layer.cornerRadius = cell.messageContainerView.frame.size.height /4;
    cell.messageContainerView.clipsToBounds = true;
    return cell;
}

@end
