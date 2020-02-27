//
//  SideTableViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 7. 21..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *welcomeMsg;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UILabel *cartItemCount;

- (void)toggleState;
- (IBAction)goHome:(id)sender;
- (IBAction)logout:(id)sender;

@end
