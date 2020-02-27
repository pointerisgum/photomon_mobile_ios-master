//
//  LoginUserInfo.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUserInfo : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSString *check;
@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone_num;
@property (strong, nonatomic) NSString *post_num;
@property (strong, nonatomic) NSString *address_basic;
@property (strong, nonatomic) NSString *address_detail;

// search id/pw info
@property (strong, nonatomic) NSString *search_user_id;
@property (strong, nonatomic) NSString *search_email;

// parsing temp var.
@property (strong, nonatomic) NSString *parsing_element;

- (void)clear;
- (BOOL)isAvailable;
- (BOOL)checkLogin;
- (BOOL)updateUserInfo;
- (BOOL)sendLoginInfo:(NSString *)userID PW:(NSString *)password LOGINTYPE:(NSString *)loginType;
- (BOOL)sendLogout;
- (NSString *)sendSearchIDInfo:(NSString *)userName Email:(NSString *)emailAddress;
- (NSString *)sendSearchPWInfo:(NSString *)userName Email:(NSString *)emailAddress ID:(NSString *)userID;

@end
