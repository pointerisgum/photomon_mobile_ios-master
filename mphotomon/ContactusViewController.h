//
//  ContactusViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 10..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactusTableViewController.h"
#import "BaseViewController.h"

@interface ContactusViewController : BaseViewController

@property (assign) BOOL done_clicked;
@property (strong, nonatomic) UIView *activeTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) ContactusTableViewController *parent_controller;

@property (strong, nonatomic) IBOutlet UIButton *securityButton;
@property (strong, nonatomic) IBOutlet UILabel *typeText;
@property (strong, nonatomic) IBOutlet UITextField *titleText;
@property (strong, nonatomic) IBOutlet UITextView *contentText;

- (IBAction)clickSecurity:(id)sender;
- (IBAction)clickType:(id)sender;
- (IBAction)clickCall:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end
