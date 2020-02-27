//
//  CouponViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 10..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PayCheckViewController.h"

@interface CouponViewController : BaseViewController

@property (strong, nonatomic) PayCheckViewController *sender;
@property (strong, nonatomic) NSString *sel_intnum;
@property (strong, nonatomic) NSString *sel_seqnum;
@property (strong, nonatomic) NSString *sel_cartidx;
@property (assign) int sel_index;

@property (strong, nonatomic) IBOutlet UITextField *couponText;
@property (strong, nonatomic) IBOutlet UITableView *table_view;

- (IBAction)regist:(id)sender;
- (IBAction)cancel:(id)sender;

@end
