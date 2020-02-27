//
//  AmountViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 15..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartItem.h"

@interface AmountViewController : UIViewController

@property (assign) int type;
@property (strong, nonatomic) NSString *param;
@property (strong, nonatomic) CartItem *cart_item;

@property (strong, nonatomic) NSMutableArray *count_array;
@property (strong, nonatomic) IBOutlet UILabel *batch_count;
@property (strong, nonatomic) IBOutlet UITableView *table_view;

- (int)getItemIndex:(id)sender;
- (IBAction)clickAddTotal:(id)sender;
- (IBAction)clickDelTotal:(id)sender;
- (IBAction)clickAdd:(id)sender;
- (IBAction)clickDel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
@end
