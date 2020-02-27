//
//  LoginUserInfo.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "LoginUserInfo.h"
#import "Common.h"
#import "User.h"

@implementation LoginUserInfo

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
    _check = @"N";
    _user_name = @"";
    _user_id = @"";
    _password = @"";
    _email = @"";
    _phone_num = @"";
    _post_num = @"";
    _address_basic = @"";
    _address_detail = @"";
    
    _search_user_id = @"";
    _search_email = @"";
}

- (BOOL)isAvailable {
    if ([_check isEqualToString:@"Y"]) {
        return YES;
    }
    else if ([_check isEqualToString:@"S"]) {
        return NO;
    }
    return NO;
}

- (BOOL)checkLogin {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDefault stringForKey:@"userID"];
    NSString *password = [userDefault stringForKey:@"userPassword"];
    NSString *loginType = [userDefault stringForKey:@"loginType"];
    if (user_id.length > 0 && (password.length > 0 || loginType.length > 0)) {
        [self sendLoginInfo:user_id PW:password LOGINTYPE:loginType];
        return TRUE;
    }
    return FALSE;
}

// SJYANG : 2016.06.28
- (BOOL)sendLoginInfo:(NSString *)userID PW:(NSString *)password LOGINTYPE:(NSString *)loginType {
    [self clear];
    
    if (![loginType isEqualToString:@""]) {
        NSString *url_str = [NSString stringWithFormat:URL_USER_SOCIAL_LOGIN, userID, loginType];
        url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
        if (ret_val != nil) {
            NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
            NSLog(@">> sendLoginInfo Result: %@", data);
            
            NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
            
            User *user = [[User alloc]initWithDictionary:dict error:nil];
            [Common info].user = user;
            
            if ([user.mcheck isEqualToString:@"Y"]) {
                return true;
            }
        }
        return FALSE;
    } else {
        
        NSString *url_str = [NSString stringWithFormat:URL_USER_LOGIN, userID, password, loginType, [Common info].device_uuid];
        url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
        if (ret_val != nil) {
            NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
            NSLog(@">> sendLoginInfo Result: %@", data);
            
            NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
            
            User *user = [[User alloc]initWithDictionary:dict error:nil];
            [Common info].user = user;
            
            if ([user.mcheck isEqualToString:@"Y"]) {
                return true;
            }
        }
        return FALSE;

    }
}

- (BOOL)updateUserInfo {
    
    NSString *url_str = [NSString stringWithFormat:URL_USER_INFO_UPDATE, [Common info].user.mUserid];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> sendLoginInfo Result: %@", data);
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
        
        User *user = [[User alloc]initWithDictionary:dict error:nil];

        if ([user.mcheck isEqualToString:@"Y"]) {
            [Common info].user = user;
            return true;
        }
    }
    
    return false;
}

- (BOOL)sendLogout {
    [self clear];
    NSString *url_str = [NSString stringWithFormat:URL_USER_LOGOUT];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> sendLogout Result: %@", data);
        
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            //return FALSE; 현재는 서버의 로그아웃 처리를 무시한다. 로컬에서만 로그아웃 처리. (안드로이드도 마찬가지임)
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (NSString *)sendSearchIDInfo:(NSString *)userName Email:(NSString *)emailAddress {
    [self clear];
    NSString *url_str = [NSString stringWithFormat:URL_ID_FIND, userName, emailAddress];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> searchID Result: %@", data);
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
        
        NSLog(@">> searchPW Result: %@", data);
        
        if ([dict[@"mcheck"] isEqual: @"Y"]) {
            return dict[@"mUserid"];
        }

    }
    else return @"";
    
    NSString *return_id = _user_id;
    _user_id = @"";
    return return_id;
}

- (NSString *)sendSearchPWInfo:(NSString *)userName Email:(NSString *)emailAddress ID:(NSString *)userID {
    [self clear];
    NSString *url_str = [NSString stringWithFormat:URL_PW_FIND, userName, emailAddress, userID];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    
    if (ret_val != nil) {
        
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];

        NSLog(@">> searchPW Result: %@", data);
        
        if ([dict[@"mcheck"] isEqual: @"Y"]) {
            return dict[@"mEmail"];
        }
    }
    else return @"";
    
    NSString *return_email = _email;
    _email = @"";
    return return_email;
}

/*
<member>
 <mCheck>Y</mCheck>
 <mUserid>daypark</mUserid>
 <mUserName>박대희</mUserName>
 <mEmail>daypark@gmail.com</mEmail>
 <mCellNum>010-2221-8050</mCellNum>
 <mPostNum>423737</mPostNum>
 <mAddr1>경기 광명시 철산3동 주공아파트</mAddr1>
 <mAddr2>1318동 1303호</mAddr2>
</member>
*/
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    _parsing_element = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    if ([_parsing_element isEqualToString:@"mCheck"]) {
        _check = [value uppercaseString];
    }
    else if ([_parsing_element isEqualToString:@"mUserid"]) {
        _user_id = value;
    }
    else if ([_parsing_element isEqualToString:@"mUserName"]) {
        _user_name = value;
    }
    else if ([_parsing_element isEqualToString:@"mEmail"]) {
        _email = value;
    }
    else if ([_parsing_element isEqualToString:@"mCellNum"]) {
        _phone_num = value;
    }
    else if ([_parsing_element isEqualToString:@"mPostNum"]) {
        _post_num = value;
    }
    else if ([_parsing_element isEqualToString:@"mAddr1"]) {
        _address_basic = [NSString stringWithFormat:@"%@%@", _address_basic, value];
    }
    else if ([_parsing_element isEqualToString:@"mAddr2"]) {
        _address_detail = [NSString stringWithFormat:@"%@%@", _address_detail, value];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _parsing_element = @"";
}


@end
