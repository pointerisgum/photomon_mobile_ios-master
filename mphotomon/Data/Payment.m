//
//  Payment.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 17..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "Payment.h"

@implementation Payment

-(id)init {
    if (self = [super init]) {
        _user_id = @"";
        _email = @"";
        _user_name = @"";
        _phone_num = @"";
        _post_num = @"";
        _addr1 = @"";
        _addr2 = @"";
        _delivery_type = @"";
        _delivery_msg = @"";
        _delivery_cost = @"";
        _total_price = @"";
        
        _p_oid = @"";
        _cart_indices = @"";
        _goods = @"";
        _pay_type = @"";
        _coupon_vals = @"";
        _coupon_amts = @"";
        _coupon_idxs = @"";
    }
    return self;
}

@end
