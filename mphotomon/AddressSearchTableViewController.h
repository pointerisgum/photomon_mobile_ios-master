//
//  AddressSearchTableViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DeliveryViewController.h"

@interface AddressSearchTableViewController : BaseViewController

@property (strong, nonatomic) DeliveryViewController *delivery_controller;

@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) IBOutlet UITableView *table_view;

- (IBAction)clickSearch:(id)sender;
- (IBAction)cancel:(id)sender;

@end
