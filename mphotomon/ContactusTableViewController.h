//
//  ContactusTableViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 13..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ContactusTableViewController : BaseViewController

@property (assign) int selected_row;
@property (assign) int text_h;

@property (strong, nonatomic) IBOutlet UITableView *table_view;

- (UITableViewCell *)getSelectedCell:(id)sender;
- (IBAction)clickDetail:(id)sender;
- (IBAction)clickCall:(id)sender;
- (IBAction)cancel:(id)sender;

@end
