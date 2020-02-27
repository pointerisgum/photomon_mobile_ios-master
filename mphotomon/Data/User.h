//
//  User.h
//  PHOTOMON
//
//  Created by 김민아 on 16/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol User

@end

@interface User : JSONModel

@property (strong, nonatomic) NSString *mcheck;
@property (strong, nonatomic) NSString *logintype;
@property (strong, nonatomic) NSString *mUserid;
@property (strong, nonatomic) NSString *mUserName;
@property (strong, nonatomic) NSString *mMileage;
@property (strong, nonatomic) NSString *mCouponCount;
@property (strong, nonatomic) NSString *mBookmileage;
@property (strong, nonatomic) NSString *mCountdelivery;

@end
