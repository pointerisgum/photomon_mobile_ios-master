//
//  CouponItem.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 12..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "CouponItem.h"

@implementation CouponItem

- (id)init {
    if (self = [super init]) {
        _couponname = @"";
        _enddate = @"";
        _code = @"";
        _intnum = @"";
        _discount = @"";
        _coupontype = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
