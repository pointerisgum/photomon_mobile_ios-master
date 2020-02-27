//
//  OrderTableViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 7..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *tuidLabel;
@property (strong, nonatomic) IBOutlet UILabel *senddateLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderstateLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *originalpriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalpriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliveryLabel;
@property (strong, nonatomic) IBOutlet UILabel *payinfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *etcLabel;


@end
