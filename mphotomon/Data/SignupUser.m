//
//  SignupUser.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SignupUser.h"
#import "Common.h"

@implementation SignupUser

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)clear {
    _userName = @"";
    _emailAddress = @"";
    _password = @"";
    _cellNum = @"";
    _recvEmail = @"";
    _recvSMS = @"";
    _birth1 = @"";
    _birth2 = @"";
    _birth3 = @"";
    _gender = @"";
}

+ (BOOL)sendIDCheck:(NSString *)userID {
    NSString *url_str = [NSString stringWithFormat:URL_ID_CHECK, userID];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> sendIDCheck Result: %@", data);
        
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        NSLog(@">> sendIDCheck OK!!");
    }
    else return FALSE;
    
    return TRUE;
}

+ (BOOL)sendEmailCheck:(NSString *)email {
    NSString *url_str = [NSString stringWithFormat:URL_EMAIL_CHECK, email];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> sendEmailCheck Result: %@", data);
        
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        NSLog(@">> sendEmailCheck OK!!");
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)sendSignupUserInfo {
    NSString *url_str = [NSString stringWithFormat:URL_USER_SIGNUP, _userName, _emailAddress, _password, _cellNum, _recvEmail, _recvSMS, _birth1, _birth2, _birth3, _gender];
    NSLog(@"sendSignupUserInfo : %@", url_str);
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> signupUser Result: %@", data);
        
        if (data == nil) {
            return false;
        }
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];

        if ([dict[@"mcheck"]isEqualToString:@"Y"]) {
            NSLog(@">> signupUser OK!!");
            return true;
        }
        
//        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
//        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
//        if (range.location == NSNotFound) {
//            return FALSE;
//        }
    }
    else return FALSE;
    
    return TRUE;
}

@end
