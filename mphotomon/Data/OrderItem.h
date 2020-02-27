//
//  OrderItem.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 7..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderItem : NSObject

@property (strong, nonatomic) NSString *senddate;
@property (strong, nonatomic) NSString *orderno;
@property (strong, nonatomic) NSString *orderstr;
@property (strong, nonatomic) NSString *total_price;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *tuid;

@end


@interface OrderItemEx : NSObject

@property (strong, nonatomic) NSString *tuid;
@property (strong, nonatomic) NSString *senddate;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *total_price;
@property (strong, nonatomic) NSString *orginal_price;
@property (strong, nonatomic) NSString *delivery_info;
@property (strong, nonatomic) NSString *acc_info;
@property (strong, nonatomic) NSString *postnum;
@property (strong, nonatomic) NSString *address1;
@property (strong, nonatomic) NSString *address2;
@property (strong, nonatomic) NSString *user_memo;
@property (strong, nonatomic) NSString *ship_info;

@end

@interface OrderDetailItem : NSObject

@property (strong, nonatomic) NSString *orderno;
@property (strong, nonatomic) NSString *orderstr;
@property (strong, nonatomic) NSString *total_price;
@property (strong, nonatomic) NSString *file_count;
@property (strong, nonatomic) NSString *upload_count;
@property (strong, nonatomic) NSString *delivery_cost;
@property (strong, nonatomic) NSString *thumb_url;

@end
