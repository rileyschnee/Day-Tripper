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

//turns hex into ui color
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// constant for keyboard movement
int MOVEMENT_KEYBOARD = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    //fix extra space at the top of the table view
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    self.messageBody.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chats = [[NSMutableArray alloc] init];
    
    [self displayChatConversation];
    //start the message refresh method
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(displayChatConversation) userInfo:nil repeats:true];
}

- (void)viewDidAppear:(BOOL)animated {
    //hide bar button item
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    //if no backbutton
    if (self.navigationController.navigationBar.backItem == nil) {
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style: UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = homeButton;
    }
}

- (void)back{
    [self performSegueWithIdentifier:@"chatToHome" sender:nil];
    self.tabBarController.tabBar.hidden = YES;
}

# pragma mark - Button functions

- (IBAction)onTapGestureRecognizer:(id)sender {
    [self.messageBody resignFirstResponder];
}

//send a message
- (IBAction)sendMessageTapped:(id)sender {
    if(![self.messageBody.text isEqualToString:@""]){
        NSString *username = PFUser.currentUser.username;
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
    
}

# pragma mark - Chat Functions

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

#pragma mark - Animation Methods

//function that moves element by delta y
- (void) moveElementVertically:(int) points {
    [UIView animateWithDuration:0.25f animations:^{
        //move text field
        CGRect frame = self.messageBody.frame;
        frame.origin.y = frame.origin.y + points;
        [self.messageBody setFrame:frame];
        //move submit button
        CGRect frame2 = self.submitButton.frame;
        frame2.origin.y = frame2.origin.y + points;
        [self.submitButton setFrame:frame2];
    }];
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
    //message styling
    cell.messageContainerView.layer.cornerRadius = cell.messageContainerView.frame.size.height /8;
    cell.messageContainerView.clipsToBounds = true;
    cell.usernameLabel.text = [NSString stringWithFormat:@"%@%@", chat.username, @":"];
    cell.messageLabel.text = chat.message;
    //color the message blue if from user
    if ([chat.username isEqualToString:[PFUser currentUser].username]) {
        cell.messageContainerView.backgroundColor = UIColorFromRGB(0x5C8EC3);
        cell.messageLabel.textColor = [UIColor whiteColor];
    }
    
   
    return cell;
}

@end
