//
//  PayCheckViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartItem.h"
#import "CouponItem.h"

@interface DeliveryItem : NSObject
@property (strong, nonatomic) NSString *recvname;
@property (strong, nonatomic) NSString *recvamt;
@end


//
@interface PayCheckViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *deliveryInfo;
@property (strong, nonatomic) NSMutableArray *useCoupon;

@property (strong, nonatomic) IBOutlet UILabel *sum_label;
@property (strong, nonatomic) IBOutlet UILabel *coupon_label;
@property (strong, nonatomic) IBOutlet UILabel *delivery_label;
@property (strong, nonatomic) IBOutlet UILabel *out_delivery_label;
@property (strong, nonatomic) IBOutlet UILabel *totalprice_label;
@property (strong, nonatomic) IBOutlet UITableView *table_view;

- (BOOL)isUsedPhotobookCoupon;
- (int)getTotalPrice;
- (int)getUnitPrice:(CartItem *)item ApplyCoupon:(CouponItem *)coupon_item;
- (int)getTotalCouponDC;
- (int)getPhotomonDeliveryCost;
- (int)getOuterDeliveryCost;

- (IBAction)clickCoupon:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)updateInfo;

@end
