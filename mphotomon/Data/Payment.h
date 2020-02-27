//
//  Payment.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 17..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject

@property (strong, nonatomic) NSString *user_id;        //아이디
@property (strong, nonatomic) NSString *email;          //이메일
@property (strong, nonatomic) NSString *user_name;      //고객명
@property (strong, nonatomic) NSString *phone_num;      //전화번호
@property (strong, nonatomic) NSString *post_num;       //우편번호
@property (strong, nonatomic) NSString *addr1;          //주소1
@property (strong, nonatomic) NSString *addr2;          //주소2
@property (strong, nonatomic) NSString *delivery_msg;   //택배기사 메시지
@property (strong, nonatomic) NSString *delivery_type;  //방문0, 택배3, 퀵4
@property (strong, nonatomic) NSString *delivery_cost;  //배송비
@property (strong, nonatomic) NSString *total_price;    //총비용

@property (strong, nonatomic) NSString *p_oid;          //
@property (strong, nonatomic) NSString *cart_indices;   //
@property (strong, nonatomic) NSString *goods;          //
@property (strong, nonatomic) NSString *pay_type;       //휴대폰,카드,무통장
@property (strong, nonatomic) NSString *coupon_vals;    //
@property (strong, nonatomic) NSString *coupon_amts;    //
@property (strong, nonatomic) NSString *coupon_idxs;    //

@end
