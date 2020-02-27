//
//  CouponItem.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 12..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponItem : NSObject

@property (strong, nonatomic) NSString *couponname;
@property (strong, nonatomic) NSString *enddate;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *intnum;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *coupontype;

@end
