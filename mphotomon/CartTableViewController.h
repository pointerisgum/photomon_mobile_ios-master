//
//  CartTableViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 2..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartItem.h"

@interface CartTableViewController : UIViewController

@property (strong, nonatomic) UIImage *normal_image, *press_image;
@property (strong, nonatomic) CartItem *sel_item;

@property (strong, nonatomic) IBOutlet UITableView *table_view;
@property (strong, nonatomic) IBOutlet UIButton *checkall_button;
@property (strong, nonatomic) IBOutlet UILabel *selcount_label;
@property (strong, nonatomic) IBOutlet UILabel *totalprice_label;

- (int)updateInfo;
- (CartItem *)getSelCartItem:(id)sender;

- (IBAction)clickDelete:(id)sender;
- (IBAction)clickCheckAll:(id)sender;
- (IBAction)clickCheck:(id)sender;
- (IBAction)clickAmount:(id)sender;
- (IBAction)clickPreview:(id)sender;
- (IBAction)cancel:(id)sender;

@end
