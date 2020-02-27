//
//  SignupUser.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignupUser : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *cellNum;
@property (strong, nonatomic) NSString *recvEmail;
@property (strong, nonatomic) NSString *recvSMS;
@property (strong, nonatomic) NSString *birth1;
@property (strong, nonatomic) NSString *birth2;
@property (strong, nonatomic) NSString *birth3;
@property (strong, nonatomic) NSString *gender;


- (void)clear;
+ (BOOL)sendIDCheck:(NSString *)userID;
+ (BOOL)sendEmailCheck:(NSString *)email;
- (BOOL)sendSignupUserInfo;

@end
