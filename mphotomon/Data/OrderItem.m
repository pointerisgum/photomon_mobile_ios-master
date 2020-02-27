//
//  OrderItem.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 7..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "OrderItem.h"

@implementation OrderItem

- (id)init {
    if (self = [super init]) {
        _senddate = @"";
        _orderno = @"";
        _orderstr = @"";
        _total_price = @"";
        _state = @"";
        _tuid = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end

@implementation OrderItemEx

- (id)init {
    if (self = [super init]) {
        _tuid = @"";
        _senddate = @"";
        _state = @"";
        _username = @"";
        _total_price = @"";
        _orginal_price = @"";
        _delivery_info = @"";
        _acc_info = @"";
        _postnum = @"";
        _address1 = @"";
        _address2 = @"";
        _user_memo = @"";
        _ship_info = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end

@implementation OrderDetailItem

- (id)init {
    if (self = [super init]) {
        _orderno = @"";
        _orderstr = @"";
        _total_price = @"";
        _file_count = @"";
        _upload_count = @"";
        _delivery_cost = @"";
        _thumb_url = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
