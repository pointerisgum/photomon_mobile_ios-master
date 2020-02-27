//
//  PhotomonInfo.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 1..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PhotomonInfo.h"
#import "Common.h"

@implementation PhotomonInfo

// thread safe singleton
+ (PhotomonInfo *)sharedInfo {
    static dispatch_once_t pred;
    static PhotomonInfo *info = nil;
    dispatch_once(&pred, ^{
        info = [[PhotomonInfo alloc] init];
    });
    return info;
}

- (void)alertMsg:(NSString *)msg {
    [[Common info]alert:nil Msg:msg];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
//                                                    message:nil
//                                                   delegate:self
//                                          cancelButtonTitle:@"닫기"
//                                          otherButtonTitles:nil];
//    [alert show];
}

- (NSData *)downloadSyncWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5.0f];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"** download error: %@", error);
        //[self alertMsg: NSLocalizedString(@"errorNetworkConnection", nil)];
        return nil;
    }
    return data;
}

- (void)downloadAsyncWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *imageData))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   completionBlock(YES, data);
                               } else {
                                   NSLog(@"** download error: %@", error);
                                   completionBlock(NO, nil);
                               }
                           }];
}
/*
- (BOOL)needUpdate {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"[%@] appVersion:%@, updateVersion:%@", appName, appVersion, _appVersionNew);
    
    NSArray *appVersionArray = [appVersion componentsSeparatedByString:@"."];
    NSArray *appVersionNewArray = [_appVersionNew componentsSeparatedByString:@"."];
    NSInteger app_1 = [appVersionArray[0] integerValue];
    NSInteger app_2 = [appVersionArray[1] integerValue];
    NSInteger app_3 = [appVersionArray[2] integerValue];
    NSInteger new_1 = [appVersionNewArray[0] integerValue];
    NSInteger new_2 = [appVersionNewArray[1] integerValue];
    NSInteger new_3 = [appVersionNewArray[2] integerValue];
    
    if (app_1 >= new_1) {
        if (app_2 >= new_2) {
            if (app_3 >= new_3) {
                return NO;
            }
            return YES;
        }
        return YES;
    }
    return YES;
}

- (BOOL)loadVersionInfo {
    
    // 로그인 정보 확인
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDefault stringForKey:@"userID"];
    NSString *password = [userDefault stringForKey:@"userPassword"];
    if (user_id.length > 0 && password.length > 0) {
        NSLog(@"loginID: %@", user_id);
        [self sendLoginInfo:user_id PW:password];
    }
    
    // 버전 정보 확인
	// SJYANG : 버전 확인시 타임스탬프 파라메터 전송
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init]; 
	[dateFormatter setDateFormat:@"yyyyMMdd"];	
	NSString *urlVersionInfo = [NSString stringWithFormat:@"%@?timestamp=%@", URL_VERSIONINFO, [dateFormatter stringFromDate:[NSDate date]]];	

	NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:urlVersionInfo]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> loadVersionInfo: %@", data);
        
        // line0: Android^2.0.43^market://details?id=com.photomon^포토몬앱이 업데이트 되었습니다|
        // line1: iOS^2.0.29^https://itunes.apple.com/kr/app/photomon/id723333895?mt=8^포토몬앱이 업데이트 되었습니다|
        // line2: 30000|
        // line3: 6^
        NSArray *line_array = [data componentsSeparatedByString:@"|"];
        for (NSString *str in line_array) {
            if ([str isEqualToString:@""]) break;
            NSArray *str_array = [str componentsSeparatedByString:@"^"];
            if ([str_array[0] isEqualToString:@"iOS"]) {     // 0: iOS
                _appVersionNew = str_array[1];               // 1: 2.0.29
                _appUrl = str_array[2];                      // 2: url
                //.......................................... // 3: 포토몬앱이 업데이트 되었습니다
            }
        }
        _deliveryfreeCost = (int)[line_array[2] integerValue];
        
        // 이벤트 정보 체크
        NSString *event_id = [userDefault stringForKey:@"eventID"];
        NSString *event_show = [userDefault stringForKey:@"eventShow"];
        //event_id = @"0"; // 리셋 테스트
        
        _eventID = @"0";
        _eventUrl = @"";
        _eventShow = @"N";
        if (line_array.count >= 4) {
            NSArray *eventInfo = [line_array[3] componentsSeparatedByString:@"^"];
            if (eventInfo.count > 1) {
                if ([eventInfo[0] integerValue] > [event_id integerValue]) {
                    _eventID = eventInfo[0];
                    _eventUrl = eventInfo[1];
                    _eventShow = @"Y";
                }
                else if ([eventInfo[0] integerValue] == [event_id integerValue]) {
                    if ([event_show isEqualToString:@"Y"]) {
                        _eventID = eventInfo[0];
                        _eventUrl = eventInfo[1];
                        _eventShow = @"Y";
                    }
                }
            }
        }
        return TRUE;
    }
    return FALSE;
}
*/
#if 0
- (BOOL)loadProductInfo {
    NSLog(@".");
    NSLog(@">> product_info <<");
    NSData *ret_val;
	//ret_val = [self downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_UPLOADPATH]];
    ret_val = [[Common info].connection.info_print_upload_host dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> uploadHostUrl: %@", data);
        _hostUrl = data;
    }
    else return FALSE;

    //ret_val = [self downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_UPLOADNAME]];
    ret_val = [[Common info].connection.info_print_upload_host_image dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> uploadHostAsp: %@", data);
        _hostAsp = data;
    }
    else return FALSE;

	//ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_SIZEINFO]];
    ret_val = [[Common info].connection.info_print_sizeinfo dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        [_productTypes removeAllObjects];
        [_productDiscounts removeAllObjects];
        [_productPrices removeAllObjects];
        [_productSizes removeAllObjects];
        [_productMinResolutions removeAllObjects];
        
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSArray *row_array = [data componentsSeparatedByString:@"|"];
        for (NSString *line in row_array) {
            if ([line isEqualToString:@""]) {
                break;
            }
            NSLog(@">> product_item: %@", line);
            NSArray *col_array = [line componentsSeparatedByString:@":"];
            [_productTypes addObject:col_array[0]];
            [_productDiscounts addObject:col_array[1]];
            [_productPrices addObject:col_array[2]];
            [_productSizes addObject:[NSString stringWithFormat:@"%@cm x %@cm", col_array[4], col_array[3]]];
            [_productMinResolutions addObject:[NSString stringWithFormat:@"%@x%@", col_array[5], col_array[6]]];
        }
    }
    else return FALSE;
    NSLog(@">> end of product_info <<");

    return TRUE;
}
#endif

- (BOOL)loadCartSession {
    NSLog(@".");
    NSLog(@">> cart_session <<");
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:[NSString stringWithFormat:URL_CART_SESSION, [Common info].device_uuid]]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> cartSessionXml: %@", data);
        
        NSXMLParser *cartParser = [[NSXMLParser alloc] initWithData:ret_val];
        cartParser.delegate = self;
        _parsingState = PARSE_CARTSESSION;
        if (![cartParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)loadCartList {
    if (_cartSession.length < 1) {
        NSLog(@">> Error : CartSession is not found.");
        return FALSE;
    }
    //NSString *url_str = [NSString stringWithFormat:URL_CART_LIST, _loginInfo.userID, _cartSession];
    NSString *url_str = [NSString stringWithFormat:URL_CART_LIST, [Common info].user.mUserid, _cartSession, [Common info].device_uuid];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        [_cartList removeAllObjects];
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> cartListXml (id:%@, cartSession:%@): %@", [Common info].user.mUserid, _cartSession, data);
        
        NSXMLParser *cartParser = [[NSXMLParser alloc] initWithData:ret_val];
        cartParser.delegate = self;
        _parsingState = PARSE_CARTLIST;
        if (![cartParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)loadCartPreviewItemList:(int)type Param:(NSString *)param {
    if( type==239 ) {
        // SJYANG : 증명사진인화
        [_cartPreviewItemList removeAllObjects];
        CartPreviewItem *previewItem = [[CartPreviewItem alloc] init];
        [_cartPreviewItemList addObject:previewItem];
        previewItem.idx = @"1";
        previewItem.previewImg = [PhotomonInfo sharedInfo].cartItem.thumb_url;
        previewItem.optionSTR = [NSString stringWithFormat:@"%@ / 수량: %@장",[PhotomonInfo sharedInfo].cartItem.cart_print, [PhotomonInfo sharedInfo].cartItem.pkgcnt];
        previewItem.oriFileName = @"";
        previewItem.previewSize = @"";
        previewItem.previewCnt = [NSString stringWithFormat:@"%@", [PhotomonInfo sharedInfo].cartItem.totalCnt];
        return TRUE;
    }
    else if( type==360 || type==363 ) {
        [_cartPreviewItemList removeAllObjects];
        CartPreviewItem *previewItem = [[CartPreviewItem alloc] init];
        [_cartPreviewItemList addObject:previewItem];
        previewItem.idx = @"1";
        previewItem.previewImg = [PhotomonInfo sharedInfo].cartItem.thumb_url;
        previewItem.optionSTR = [NSString stringWithFormat:@"%@ / 수량: %@개",[PhotomonInfo sharedInfo].cartItem.cart_print, [PhotomonInfo sharedInfo].cartItem.pkgcnt];
        previewItem.oriFileName = @"";
        previewItem.previewSize = @"";
        previewItem.previewCnt = [NSString stringWithFormat:@"%@", [PhotomonInfo sharedInfo].cartItem.totalCnt];
        return TRUE;
    }
    else if( type==366 ) {
        [_cartPreviewItemList removeAllObjects];
        CartPreviewItem *previewItem = [[CartPreviewItem alloc] init];
        [_cartPreviewItemList addObject:previewItem];
        previewItem.idx = @"1";
        previewItem.previewImg = [PhotomonInfo sharedInfo].cartItem.thumb_url;
        previewItem.optionSTR = [NSString stringWithFormat:@"%@ / 수량: %@개",[PhotomonInfo sharedInfo].cartItem.cart_print, [PhotomonInfo sharedInfo].cartItem.pkgcnt];
        previewItem.oriFileName = @"";
        previewItem.previewSize = @"";
        previewItem.previewCnt = [NSString stringWithFormat:@"%@", [PhotomonInfo sharedInfo].cartItem.totalCnt];
        return TRUE;
    }
    else {
        NSString *url_str = @"";
        if (type == 0) {
            url_str = [NSString stringWithFormat:URL_CART_PREVIEW_PRINT, param];
        }
        else {
            url_str = [NSString stringWithFormat:URL_CART_PREVIEW_BOOK, param];
        }
        
        NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
        if (ret_val != nil) {
            [_cartPreviewItemList removeAllObjects];
            NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
            NSLog(@">> cartPreviewItem(%@): %@", param, data);
            
            NSXMLParser *cartParser = [[NSXMLParser alloc] initWithData:ret_val];
            cartParser.delegate = self;
            _parsingState = PARSE_CARTPREVIEWITEM;
            if (![cartParser parse]) {
                return FALSE;
            }
        }
        else return FALSE;

        return TRUE;
    }
}

- (BOOL)updateCartPreviewItemList:(int)type Param:(NSString *)param Idx:idx Cnt:cnt {
    NSString *url_str = @"";
    if (type == 0) {
        url_str = [NSString stringWithFormat:URL_CART_QUANTITY_PRINT, param, idx, cnt];
    }
    else {
        url_str = [NSString stringWithFormat:URL_CART_QUANTITY_BOOK, param, idx, cnt];
    }
    
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> updateCartPreviewItemList(param:%@, idx:%@, cnt:%@): %@", param, idx, cnt, data);
        
        NSXMLParser *cartParser = [[NSXMLParser alloc] initWithData:ret_val];
        cartParser.delegate = self;
        _parsingState = PARSE_UPDATECARTPREVIEWITEM; // no op
        if (![cartParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)updateCartPreviewItemListPrice:(int)type Param:(NSString *)param Price:total_price {
    NSString *url_str = @"";
    if (type == 0) {
        url_str = [NSString stringWithFormat:URL_CART_PRICE_PRINT, param, total_price];
    }
    else if (type == 300 || type == 277 || type == 367 || type == 368 || type == 369 || type == 391 || type == 392) {
        url_str = [NSString stringWithFormat:URL_CART_PRICE_PRINT, param, total_price]; // 사진인화와 동일
    }
    else {
        return FALSE;
    }
    
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> updateCartPreviewItemListPrice(param:%@, total_price:%@): %@", param, total_price, data);
        
        NSXMLParser *cartParser = [[NSXMLParser alloc] initWithData:ret_val];
        cartParser.delegate = self;
        _parsingState = PARSE_UPDATECARTPREVIEWITEM; // no op
        if (![cartParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
    
}

- (BOOL)deleteCartItem:(NSString *)cartIdx {
    NSString *url_str = [NSString stringWithFormat:URL_CART_DELETE, cartIdx];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> delete cartItem(%@): %@", cartIdx, data);
        
        NSXMLParser *cartParser = [[NSXMLParser alloc] initWithData:ret_val];
        cartParser.delegate = self;
        _parsingState = PARSE_CARTLIST;
        if (![cartParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;

    return TRUE;
}
/*
- (BOOL)sendDeliveryInfo {
     //"SendDeliveryInfo"="https://www.photomon.com/xml/mP_OID.asp?EmailAddr=%@&UserName=%@&telnum=%@&cellnum=%@&ArrCart_idx=%@&sumPrice=%@&recvAmt=%@&deliveryNo=3&postnum=%@&addr1=%@&addr2=%@&userid=%@&Couponstr=%@&recvmemo=%@";

    NSString *url_str = [NSString stringWithFormat:NSLocalizedString(@"SendDeliveryInfo", nil), _payment.email, _payment.user_name, _payment.phone_num, _payment.phone_num, _payment.cart_indices, _payment.total_price, _payment.delivery_cost, _payment.post_num, _payment.addr1, _payment.addr2, _payment.user_id, _payment.coupon_vals, _payment.delivery_msg];
    NSLog(@">> send_deliveryURL: %@", url_str);
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> send_deliveryInfo: %@", data);
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:ret_val];
        parser.delegate = self;
        _parsingState = PARSE_SENDDELIVERYINFO;
        if (![parser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}
*/
- (BOOL)postDeliveryInfo {
    // prepare params
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject: [NSString stringWithFormat:@"EmailAddr=%@", _payment.email]];
    [params addObject: [NSString stringWithFormat:@"UserName=%@", _payment.user_name]];
    [params addObject: [NSString stringWithFormat:@"telnum=%@", _payment.phone_num]];
    [params addObject: [NSString stringWithFormat:@"cellnum=%@", _payment.phone_num]];
    [params addObject: [NSString stringWithFormat:@"ArrCart_idx=%@", _payment.cart_indices]];
    [params addObject: [NSString stringWithFormat:@"sumPrice=%@", _payment.total_price]];
    [params addObject: [NSString stringWithFormat:@"recvAmt=%@", _payment.delivery_cost]];
    [params addObject: [NSString stringWithFormat:@"deliveryNo=%@", @"3"]];
    [params addObject: [NSString stringWithFormat:@"postnum=%@", _payment.post_num]];
    [params addObject: [NSString stringWithFormat:@"addr1=%@", _payment.addr1]];
    [params addObject: [NSString stringWithFormat:@"addr2=%@", _payment.addr2]];
    [params addObject: [NSString stringWithFormat:@"userid=%@", _payment.user_id]];
    [params addObject: [NSString stringWithFormat:@"Couponstr=%@", _payment.coupon_vals]];
    [params addObject: [NSString stringWithFormat:@"Couponamt=%@", _payment.coupon_amts]];
    [params addObject: [NSString stringWithFormat:@"CouponIdx=%@", _payment.coupon_idxs]];
    [params addObject: [NSString stringWithFormat:@"recvmemo=%@", _payment.delivery_msg]];

    NSString *result_params = [params componentsJoinedByString:@"&"];
    NSString *encoded_params = [result_params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [encoded_params dataUsingEncoding:NSUTF8StringEncoding];
    //NSData *data = [[params componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];

    NSString *data_len = [NSString stringWithFormat:@"%lu", (unsigned long)data.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60.0f];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setValue:data_len forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    [request setURL:[NSURL URLWithString:URL_DELIVERY_POST]];

    NSData *ret_val = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> post_deliveryInfo: %@", data);
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:ret_val];
        parser.delegate = self;
        _parsingState = PARSE_SENDDELIVERYINFO;
        if (![parser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)postPaymentInfo:(UIWebView *)webview {
    NSString *coupon_vals = _payment.coupon_vals;
    if ([coupon_vals isEqualToString:@""]) {
        coupon_vals = @"couponVal";
    }
    NSString *noti_str = [NSString stringWithFormat:@"^%d^mileageVal^%@^%@^%@", (int)_payList.count, coupon_vals, _payment.p_oid, _payment.cart_indices];
    
    // prepare params
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject: [NSString stringWithFormat:@"P_MID=%@", @"photomon03"]];
    [params addObject: [NSString stringWithFormat:@"P_OID=%@", _payment.p_oid]];
    [params addObject: [NSString stringWithFormat:@"P_AMT=%d", [_payment.total_price intValue] + [_payment.delivery_cost intValue]]];
    [params addObject: [NSString stringWithFormat:@"P_UNAME=%@", _payment.user_name]];
    [params addObject: [NSString stringWithFormat:@"P_NOTI=%@", noti_str]];
    [params addObject: [NSString stringWithFormat:@"P_NEXT_URL=%@", URL_PAYMENT_NEXT]];
    [params addObject: [NSString stringWithFormat:@"P_NOTI_URL=%@", URL_PAYMENT_NOTI]];
    [params addObject: [NSString stringWithFormat:@"P_RETURN_URL=%@", URL_PAYMENT_RETURN]];
    [params addObject: [NSString stringWithFormat:@"P_GOODS=%@", _payment.goods]];
    [params addObject: [NSString stringWithFormat:@"P_MOBILE=%@", _payment.phone_num]];
    [params addObject: [NSString stringWithFormat:@"P_EMAIL=%@", _payment.email]];
    [params addObject: [NSString stringWithFormat:@"P_HPP_METHOD=%@", @"2"]];
    [params addObject: [NSString stringWithFormat:@"inipaymobile_type=%@", @"app"]];
    [params addObject: [NSString stringWithFormat:@"tuid=%@", _payment.p_oid]];
    //[params addObject: [NSString stringWithFormat:@"P_RESERVED=%@", @""]];
    [params addObject: [NSString stringWithFormat:@"P_RESERVED=%@", @"block_isp=Y%26twotrs_isp=Y%26twotrs_isp_noti=N%26apprun_check=Y%26app_scheme=photomonapp://"]];    

    NSData *data = nil;
    NSString *url_str = @"";
    
    if ([_payment.pay_type isEqualToString:@"휴대폰"]) {
        NSString *temp_str = URL_PAYMENT_MOBILE;
        url_str = [temp_str stringByAddingPercentEscapesUsingEncoding:NSEUCKREncoding];
        data = [[params componentsJoinedByString:@"&"] dataUsingEncoding:NSEUCKREncoding];
    }
    else if ([_payment.pay_type isEqualToString:@"카드"]) {
        NSString *temp_str = URL_PAYMENT_CARD;
        url_str = [temp_str stringByAddingPercentEscapesUsingEncoding:NSEUCKREncoding];
        data = [[params componentsJoinedByString:@"&"] dataUsingEncoding:NSEUCKREncoding];
    }
    else if ([_payment.pay_type isEqualToString:@"무통장"]) {
        NSString *temp_str = URL_PAYMENT_VBANK;
        url_str = [temp_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        data = [[params componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
    }
    else return FALSE;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60.0f];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setURL:[NSURL URLWithString:url_str]];
    
    [webview loadRequest:request];
    
    return TRUE;
}
/*
- (BOOL)loadPaymentWebView:(UIWebView *)webview {
    NSString *couponVal = _payment.coupon_vals;
    if ([couponVal isEqualToString:@""]) {
        couponVal = @"couponVal";
    }
    
    NSString *pNotiStr = [NSString stringWithFormat:NSLocalizedString(@"PaymentNotiStr", nil), _payList.count, couponVal, _payment.p_oid, _payment.cart_indices];
    NSString *pAmt = [NSString stringWithFormat:NSLocalizedString(@"%d", nil), [_payment.total_price intValue] + [_payment.delivery_cost intValue]];
    
    NSString *nextUrl = [NSString stringWithFormat:NSLocalizedString(@"PaymentNextUrl", nil)];
    NSString *notiUrl = [NSString stringWithFormat:NSLocalizedString(@"PaymentNotiUrl", nil)];
    NSString *orderPayUrl = [NSString stringWithFormat:NSLocalizedString(@"PaymentOrderPayUrl", nil)];

    NSString *param = [NSString stringWithFormat:NSLocalizedString(@"PaymentParam", nil), _payment.p_oid, pAmt, _payment.user_name, pNotiStr, nextUrl, notiUrl, orderPayUrl, _payment.goods, _payment.phone_num, _payment.email];
    NSLog(@"%@", param);
    
    //# EUC-KR 값을 Data 형식으로 넘길때
    //NSString* encodedStr1 = [NSString stringWithCString:param.UTF8String encoding:NSEUCKREncoding];
    NSData *postData = nil;
    
    NSString *urlStr = @"";
    if ([_payment.pay_type isEqualToString:@"휴대폰"]) {
        urlStr = [NSString stringWithFormat:NSLocalizedString(@"InicisSmart", nil), @"mobile"];
        postData = [param dataUsingEncoding:NSEUCKREncoding allowLossyConversion:YES];
    }
    else if ([_payment.pay_type isEqualToString:@"카드"]) {
        urlStr = [NSString stringWithFormat:NSLocalizedString(@"InicisSmart", nil), @"wcard"];
        postData = [param dataUsingEncoding:NSEUCKREncoding allowLossyConversion:YES];
    }
    else if ([_payment.pay_type isEqualToString:@"무통장"]) {
        urlStr = [NSString stringWithFormat:NSLocalizedString(@"PaymentVBank", nil)];
        postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    }
    else return FALSE;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if (![_payment.pay_type isEqualToString:@"무통장"])
        [request setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSEUCKREncoding]]];
    else
        [request setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [webview loadRequest:request];
    
    NSLog(@"%@",urlStr);
    return TRUE;
}
*/

- (BOOL)loadCouponList:(NSString *)userID Intnum:(NSString *)intnum Seqnum:(NSString *)seqnum CartIdx:(NSString *)cartidx {
    if (intnum == nil) {
        intnum = @"";
    }
    if (seqnum == nil) {
        seqnum = @"";
    }
    NSString *url_str = [NSString stringWithFormat:URL_COUPON_LIST, userID, intnum, seqnum, cartidx, [Common info].device_uuid];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadCouponList (%@) %@", userID, data);
        
        [_couponList removeAllObjects];
        
        _coupon_name_acc = @"";
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_COUPONLIST;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (NSString *)registCoupon:(NSString *)couponNum ID:(NSString *)userID {
    NSString *url_str = [NSString stringWithFormat:URL_COUPON_ADD, couponNum, userID];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> registCoupon Result: %@", data);
        return data;
    }
    return @"";
}

- (BOOL)loadAddressInfo:(NSString *)searchAddress {
    NSString *url_str = [NSString stringWithFormat:NSLocalizedString(URL_DELIVERY_ADDRESS, nil), searchAddress];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        [_postnumArray removeAllObjects];
        [_addressArray removeAllObjects];
        [_addressArray2 removeAllObjects];
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> searchAddress Result: %@", data);
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_ADDRESSINFO;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}
/*
- (BOOL)sendIDCheck:(NSString *)userID {
    NSString *url_str = [NSString stringWithFormat:URL_ID_CHECK, userID];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
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

- (BOOL)sendEmailCheck:(NSString *)email {
    NSString *url_str = [NSString stringWithFormat:URL_EMAIL_CHECK, email];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
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

- (BOOL)sendSignupUserInfo:(SignupUser *)user {
    NSString *url_str = [NSString stringWithFormat:URL_USER_SIGNUP, user.userName, user.userID, user.password, user.cell1, user.cell2, user.cell3, user.emailAddress, user.recvEmail, user.recvSMS];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> signupUser Result: %@", data);
        
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        NSLog(@">> signupUser OK!!");
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)sendLoginInfo:(NSString *)userID PW:(NSString *)password {
    NSString *url_str = [NSString stringWithFormat:URL_USER_LOGIN, userID, password];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> sendLoginInfo Result: %@", data);
        
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        NSLog(@">> sendLoginInfo OK!!");
        
        _loginInfo = [_loginInfo init];
        _loginInfo.userID = userID;
        _loginInfo.password = password;
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_LOGINUSERINFO;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)sendLogout {
    NSString *url_str = [NSString stringWithFormat:URL_USER_LOGOUT];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
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
        _loginInfo = [_loginInfo init]; // 로그인 정보를 리셋하는 것으로 로그아웃 처리 대체.
        NSLog(@">> sendLogout OK!!");
    }
    else return FALSE;

    return TRUE;
    
#if 0
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:@"https://www.photomon.com/member/mlogout_ok.asp"];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSURLSessionDataTask * dataTask = [delegateFreeSession dataTaskWithRequest:urlRequest];
    [dataTask resume];
#endif
}

- (BOOL)sendSearchIDInfo:(NSString *)userName Email:(NSString *)emailAddress {
    NSString *url_str = [NSString stringWithFormat:URL_ID_FIND, userName, emailAddress];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> searchID Result: %@", data);
        
        _loginInfo.searchUserID = @"";
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_SEARCHLOGININFO;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)sendSearchPWInfo:(NSString *)userName Email:(NSString *)emailAddress ID:(NSString *)userID {
    NSString *url_str = [NSString stringWithFormat:URL_PW_FIND, userName, emailAddress, userID];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> searchPW Result: %@", data);
        
        _loginInfo.searchEmailForPW = @"";
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_SEARCHLOGININFO;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}
*/
- (BOOL)loadOrderList {
    if ([Common info].user.mUserid.length < 1 && _cartSession.length < 1) {
        return FALSE;
    }
    NSString *url_str = [NSString stringWithFormat:URL_ORDER_LIST, [Common info].user.mUserid, _cartSession];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadOrderList (%@) %@", [Common info].user.mUserid, data);
        
        [_orderList removeAllObjects];
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_ORDERLIST;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)loadOrderItem:(NSString *)tuid {
    NSString *url_str = [NSString stringWithFormat:URL_ORDER_VIEW, tuid];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> selectedOrderItem (%@) %@", tuid, data);

        _orderItemSel = [_orderItemSel init];
        _orderItemSel.tuid = tuid;
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_ORDERITEM;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)loadOrderDetailList:(NSString *)tuid {
    NSString *url_str = [NSString stringWithFormat:URL_ORDER_DETAIL, tuid];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadOrderDetailList (%@) %@", tuid, data);

        [_orderDetailList removeAllObjects];
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_ORDERDETAILLIST;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)loadContactList:(NSString *)userID {
    NSString *url_str = [NSString stringWithFormat:URL_QNA_LIST, userID];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadContactList (%@) %@", userID, data);
        
        [_contactArray removeAllObjects];
        
        NSXMLParser *adressParser = [[NSXMLParser alloc] initWithData:ret_val];
        adressParser.delegate = self;
        _parsingState = PARSE_CONTACTLIST;
        if (![adressParser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (NSString *)loadContactPost:(NSString *)postIdx {
    NSString *url_str = [NSString stringWithFormat:URL_QNA_VIEW, postIdx];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadContactPost Result: %@", data);
        return data;
/* data는 그냥 문자열, 에러처리 없음.
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        NSLog(@">> loadContactPost OK!!");*/
    }
    return @"";
}

- (BOOL)sendContactInfo:(ContactusItem *)ci {
    NSString *url_str = [NSString stringWithFormat:URL_QNA_WRITE, ci.subject, ci.category, ci.content, ci.userID, ci.userName, ci.security, [Common info].device_uuid];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> sendContactus Result: %@", data);
        
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        NSLog(@">> sendContactus OK!!");
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)loadNoticeList {
    NSString *url_str = [NSString stringWithFormat:URL_NOTICE_LIST];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadNoticeList %@", data);
        
        [_noticeList removeAllObjects];
        NSArray *lineArray = [data componentsSeparatedByString:@"|"];
        for (NSString *lineStr in lineArray) {
            if (lineStr.length < 1) break;

            NoticeItem *item = [[NoticeItem alloc] init];
            [_noticeList addObject:item];

            NSArray *colArray = [lineStr componentsSeparatedByString:@"^"];
            item.idx = colArray[0];
            item.title = colArray[1];
            item.readnum = colArray[2];
            item.category = colArray[3];
            item.date = colArray[4];
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (NSData *)loadNoticeItem:(NSString *)postIdx {
    NSString *url_str = [NSString stringWithFormat:URL_NOTICE_VIEW, postIdx];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [self downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadNoticeItem Result: %@", data);
    }
    return ret_val;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    _parsingElement = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    switch (_parsingState) {
        case PARSE_CARTSESSION:
            if ([_parsingElement isEqualToString:@"cartSession"]) {
                _cartSession = value;
            }
            break;
        case PARSE_CARTLIST:
            if ([_parsingElement isEqualToString:@"order"]) {
                CartItem *cartItem = [[CartItem alloc] init];
                [_cartList addObject:cartItem];
            }
            else {
                if (_cartList.count > 0) {
                    CartItem *cartItem = [_cartList objectAtIndex: _cartList.count-1];
                    if ([_parsingElement isEqualToString:@"totalCnt"]) {
                        cartItem.totalCnt = value;
                    }
                    else if ([_parsingElement isEqualToString:@"cart_idx"]) {
                        cartItem.cart_index = value;
                    }
                    else if ([_parsingElement isEqualToString:@"cart_print"]) {
                        //NSArray *type_strings = [value componentsSeparatedByString:@" "];
                        //cartItem.cart_print = type_strings[0];
                        cartItem.cart_print = [NSString stringWithFormat:@"%@%@", cartItem.cart_print, value];
                    }
                    else if ([_parsingElement isEqualToString:@"TotalSizeCnt"]) {
                        NSArray *row_array = [value componentsSeparatedByString:@"|"];
                        for (NSString *line in row_array) {
                            if ([line isEqualToString:@""]) {
                                break;
                            }
                            NSArray *col_array = [line componentsSeparatedByString:@":"];
                            if (col_array.count > 0) [cartItem.unit_types addObject:col_array[0]];
                            if (col_array.count > 1) [cartItem.unit_counts addObject:col_array[1]];
                            if (col_array.count > 2) [cartItem.price_old addObject:col_array[2]];
                            if (col_array.count > 3) [cartItem.price_base addObject:col_array[3]];
                            if (col_array.count > 4) [cartItem.price_org addObject:col_array[4]];
                        }
                    }
                    else if ([_parsingElement isEqualToString:@"price"]) {
                        cartItem.price = value; // 경우에 따라 다시 계산해야 함. (폴라로이드는 그대로 사용가능)
                    }
                    else if ([_parsingElement isEqualToString:@"pkgcnt"]) {
                        cartItem.pkgcnt = value;
                    }
                    else if ([_parsingElement isEqualToString:@"thumb"]) {
                        cartItem.thumb_url = value;
                    }
                    else if ([_parsingElement isEqualToString:@"printingChk"]) {
                        cartItem.printingChk = value;
                    }
                    else if ([_parsingElement isEqualToString:@"orderno"]) {
                        cartItem.orderno = value;
                    }
                    else if ([_parsingElement isEqualToString:@"intnum"]) {
                        cartItem.intnum = value;
                    }
                    else if ([_parsingElement isEqualToString:@"seq"]) {
                        cartItem.seq = value;
                    }
                    else if ([_parsingElement isEqualToString:@"g_size"]) {
                        //cartItem.g_size = value;
                        cartItem.g_size = [NSString stringWithFormat:@"%@%@", cartItem.g_size, value];
                    }
                    else if ([_parsingElement isEqualToString:@"g_class"]) {
                        cartItem.g_class = value;
                    }
                    else if ([_parsingElement isEqualToString:@"basketName"]) {
                        cartItem.basketname = value;
                    }
                    else if ([_parsingElement isEqualToString:@"recvname"]) {
                        cartItem.recvname = value;
                    }
                    else if ([_parsingElement isEqualToString:@"recvamt"]) {
                        cartItem.recvamt = value;
                    }
                    else {
                        //assert
                    }
                }
                else {
                    //assert
                }
            }
            break;
        case PARSE_CARTOK:
            //NSLog(@">> parsed cartOk: %@", value);
            break;
        case PARSE_CARTPREVIEWITEM:
            if ([_parsingElement isEqualToString:@"order"]) {
                CartPreviewItem *previewItem = [[CartPreviewItem alloc] init];
                [_cartPreviewItemList addObject:previewItem];
            }
            else {
                if (_cartPreviewItemList.count > 0) {
                    CartPreviewItem *previewItem = [_cartPreviewItemList objectAtIndex: _cartPreviewItemList.count-1];
                    if ([_parsingElement isEqualToString:@"idx"]) {
                        previewItem.idx = value;
                    }
                    else if ([_parsingElement isEqualToString:@"preivewImg"]) {
                        previewItem.previewImg = value;
                    }
                    else if ([_parsingElement isEqualToString:@"optionSTR"]) {
                        previewItem.optionSTR = value;
                    }
                    else if ([_parsingElement isEqualToString:@"oriFileName"]) {
                        previewItem.oriFileName = value;
                    }
                    else if ([_parsingElement isEqualToString:@"previewSize"]) {
                        previewItem.previewSize = value;
                    }
                    else if ([_parsingElement isEqualToString:@"previewCnt"]) {
                        previewItem.previewCnt = value;
                    }
                    else {
                        //assert
                    }
                }
                else {
                    //assert
                }
            }
            break;
        case PARSE_UPDATECARTPREVIEWITEM:
            break;
        case PARSE_SENDDELIVERYINFO:
            if ([_parsingElement isEqualToString:@"P_OID"]) {
                _payment.p_oid = value;
            }
            break;
        case PARSE_ADDRESSINFO:
            if ([_parsingElement isEqualToString:@"address"]) {
                NSString *item = [[NSString alloc] initWithString:value];
                [_postnumArray addObject:item];
            }
            else if ([_parsingElement isEqualToString:@"address2"]) {
                NSString *item = [[NSString alloc] initWithString:value];
                [_addressArray addObject:item];
            }
            else if ([_parsingElement isEqualToString:@"address3"]) {
                NSString *item = [[NSString alloc] initWithString:value];
                [_addressArray2 addObject:item];
            }
            
            break;
/*
        case PARSE_LOGINUSERINFO:
            if ([_parsingElement isEqualToString:@"mUserid"]) {
                _loginInfo.userID = value;
            }
            else if ([_parsingElement isEqualToString:@"mUserName"]) {
                _loginInfo.userName = value;
            }
            else if ([_parsingElement isEqualToString:@"mEmail"]) {
                _loginInfo.emailAddress = value;
            }
            else if ([_parsingElement isEqualToString:@"mCellNum"]) {
                _loginInfo.phoneNum = value;
            }
            else if ([_parsingElement isEqualToString:@"mPostNum"]) {
                _loginInfo.postNum = value;
            }
            else if ([_parsingElement isEqualToString:@"mAddr1"]) {
                _loginInfo.addressBasic = [NSString stringWithFormat:@"%@%@", _loginInfo.addressBasic, value];
            }
            else if ([_parsingElement isEqualToString:@"mAddr2"]) {
                _loginInfo.addressDetail = [NSString stringWithFormat:@"%@%@", _loginInfo.addressDetail, value];
            }
            break;
        case PARSE_SEARCHLOGININFO:
            if ([_parsingElement isEqualToString:@"mEmail"]) {
                _loginInfo.searchEmailForPW = value;
            }
            else if ([_parsingElement isEqualToString:@"mUserid"]) {
                _loginInfo.searchUserID = value;
            }
            break;
*/
        case PARSE_ORDERLIST:
            if ([_parsingElement isEqualToString:@"order"]) {
                OrderItem *orderItem = [[OrderItem alloc] init];
                [_orderList addObject:orderItem];
            }
            else {
                if (_orderList.count > 0) {
                    OrderItem *orderItem = [_orderList objectAtIndex: _orderList.count-1];
                    if ([_parsingElement isEqualToString:@"senddate"]) {
                        orderItem.senddate = [NSString stringWithFormat:@"%@%@", orderItem.senddate, value];
                    }
                    else if ([_parsingElement isEqualToString:@"orderno"]) {
                        orderItem.orderno = value;
                    }
                    else if ([_parsingElement isEqualToString:@"orderstr"]) {
                        orderItem.orderstr = [NSString stringWithFormat:@"%@%@", orderItem.orderstr, value];
                    }
                    else if ([_parsingElement isEqualToString:@"totamt"]) {
                        orderItem.total_price = value;
                    }
                    else if ([_parsingElement isEqualToString:@"WorkStr"]) {
                        orderItem.state = value;
                    }
                    else if ([_parsingElement isEqualToString:@"tuid"]) {
                        orderItem.tuid = value;
                    }
                    else {
                        //assert
                    }
                }
                else {
                    //assert
                }
            }
            break;
        case PARSE_ORDERITEM:
            if ([_parsingElement isEqualToString:@"tuid"]) {
                //원래것으로 세팅. t자붙은거 말고.
                //_orderItemSel.tuid = value;
            }
            else if ([_parsingElement isEqualToString:@"senddate"]) {
                _orderItemSel.senddate = value;
            }
            else if ([_parsingElement isEqualToString:@"orderstate"]) {
                _orderItemSel.state = value;
            }
            else if ([_parsingElement isEqualToString:@"username"]) {
                _orderItemSel.username = value;
            }
            else if ([_parsingElement isEqualToString:@"AllTotamt"]) {
                _orderItemSel.total_price = value;
            }
            else if ([_parsingElement isEqualToString:@"AllTotOriamt"]) {
                _orderItemSel.orginal_price = value;
            }
            else if ([_parsingElement isEqualToString:@"deliveryinfo"]) {
                _orderItemSel.delivery_info = value;
            }
            else if ([_parsingElement isEqualToString:@"Accinfo"]) {
                _orderItemSel.acc_info = value;
            }
            else if ([_parsingElement isEqualToString:@"RegistpostNo"]) {
                _orderItemSel.postnum = value;
            }
            else if ([_parsingElement isEqualToString:@"useraddr1"]) {
                //_orderItemSel.address1 = value;
                _orderItemSel.address1 = [NSString stringWithFormat:@"%@%@", _orderItemSel.address1, value];
            }
            else if ([_parsingElement isEqualToString:@"useraddr2"]) {
                //_orderItemSel.address2 = value;
                _orderItemSel.address2 = [NSString stringWithFormat:@"%@%@", _orderItemSel.address2, value];
            }
            else if ([_parsingElement isEqualToString:@"usermemo"]) {
                _orderItemSel.user_memo = value;
            }
            else if ([_parsingElement isEqualToString:@"shipInfo"]) {
                _orderItemSel.ship_info = value;
            }
            break;
        case PARSE_ORDERDETAILLIST:
            if ([_parsingElement isEqualToString:@"Orderfile"]) {
                OrderDetailItem *orderItem = [[OrderDetailItem alloc] init];
                [_orderDetailList addObject:orderItem];
            }
            else {
                if (_orderDetailList.count > 0) {
                    OrderDetailItem *orderItem = [_orderDetailList objectAtIndex: _orderDetailList.count-1];
                    if ([_parsingElement isEqualToString:@"orderno"]) {
                        orderItem.orderno = value;
                    }
                    else if ([_parsingElement isEqualToString:@"orderstr"]) {
                        orderItem.orderstr = [NSString stringWithFormat:@"%@%@", orderItem.orderstr, value];
                    }
                    else if ([_parsingElement isEqualToString:@"totamt"]) {
                        orderItem.total_price = value;
                    }
                    else if ([_parsingElement isEqualToString:@"filecnt"]) {
                        orderItem.file_count = value;
                    }
                    else if ([_parsingElement isEqualToString:@"uploadcnt"]) {
                        orderItem.upload_count = value;
                    }
                    else if ([_parsingElement isEqualToString:@"recvamt"]) {
                        orderItem.delivery_cost = value;
                    }
                    else if ([_parsingElement isEqualToString:@"imgurl"]) {
                        orderItem.thumb_url = value;
                    }
                    else {
                        //assert
                    }
                }
                else {
                    //assert
                }
            }
            break;
        case PARSE_CONTACTLIST:
            if ([_parsingElement isEqualToString:@"idx"]) {
                ContactusListItem *contactItem = [[ContactusListItem alloc] init];
                [_contactArray addObject:contactItem];
                
                contactItem.idx = value;
            }
            else {
                if (_contactArray.count > 0) {
                    ContactusListItem *contactItem = [_contactArray objectAtIndex: _contactArray.count-1];
                    if ([_parsingElement isEqualToString:@"subject"]) {
                        contactItem.subject = value;
                    }
                    else if ([_parsingElement isEqualToString:@"writer"]) {
                        contactItem.userName = value;
                    }
                    else if ([_parsingElement isEqualToString:@"writedate"]) {
                        contactItem.writedate = [NSString stringWithFormat:@"%@%@", contactItem.writedate, value];
                    }
                    else if ([_parsingElement isEqualToString:@"userid"]) {
                        contactItem.userID = value;
                    }
                    else if ([_parsingElement isEqualToString:@"scrid"]) {
                        contactItem.security = value;
                    }
                    else if ([_parsingElement isEqualToString:@"re_step"]) {
                        contactItem.re_step = value;
                    }
                    else {
                        //assert
                    }
                }
                else {
                    //assert
                }
            }
            break;
        case PARSE_COUPONLIST:
            if ([_parsingElement isEqualToString:@"couponname"]) {
                if (_coupon_name_acc.length <= 0) {
                    CouponItem *item = [[CouponItem alloc] init];
                    [_couponList addObject:item];
                }
                
                CouponItem *couponItem = [_couponList objectAtIndex: _couponList.count-1];
                couponItem.couponname = [NSString stringWithFormat:@"%@%@", couponItem.couponname, value];
                _coupon_name_acc = couponItem.couponname;
            }
            else {
                _coupon_name_acc = @"";
                if (_couponList.count > 0) {
                    CouponItem *couponItem = [_couponList objectAtIndex: _couponList.count-1];
                    if ([_parsingElement isEqualToString:@"enddate"]) {
                        couponItem.enddate = value;
                    }
                    else if ([_parsingElement isEqualToString:@"code"]) {
                        couponItem.code = value;
                    }
                    else if ([_parsingElement isEqualToString:@"intnum"]) {
                        couponItem.intnum = value;
                        //NSLog(@"intnum:%@", value);
                    }
                    else if ([_parsingElement isEqualToString:@"discount"]) {
                        couponItem.discount = value;
                    }
                    else if ([_parsingElement isEqualToString:@"coupontype"]) {
                        couponItem.coupontype = value;
                    }
                    else {
                        //assert
                    }
                }
                else {
                    //assert
                }
            }
            break;
        default:
            break;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@">> parse complete!!");
    _parsingElement = @"";
}



- (id)init {
    if (self = [super init]) {
        _parsingState = PARSE_NOSTATE;
        _cartList = [[NSMutableArray alloc] init];
        _cartPreviewItemList = [[NSMutableArray alloc] init];
        _orderList = [[NSMutableArray alloc] init];
        _orderItemSel = [[OrderItemEx alloc] init];
        _orderDetailList = [[NSMutableArray alloc] init];
        _payList = [[NSMutableArray alloc] init];
        _payment = [[Payment alloc] init];
        
        _postnumArray = [[NSMutableArray alloc] init];
        _addressArray = [[NSMutableArray alloc] init];
        _addressArray2 = [[NSMutableArray alloc] init];
        _contactArray = [[NSMutableArray alloc] init];
        _noticeList = [[NSMutableArray alloc] init];
        _couponList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
/*
- (int)getOriginalPrice:(NSString *)productType {
    if (_productTypes.count < 1) {
        [self loadProductInfo];
    }
    for (int i = 0; i < _productTypes.count; i++) {
        NSString *type = _productTypes[i];
        if ([type isEqualToString:productType]) {
            return [_productPrices[i] intValue];
        }
    }
    return 0;
}

- (int)getDiscountPrice:(NSString *)productType {
    if (_productTypes.count < 1) {
        [self loadProductInfo];
    }
    for (int i = 0; i < _productTypes.count; i++) {
        NSString *type = _productTypes[i];
        if ([type isEqualToString:productType]) {
            return [_productDiscounts[i] intValue];
        }
    }
    return 0;
}
*/
#if 0
// 카메라에 필터를 적용한 사진의 경우는 representation.dimensions에 원본사진의 해상도가 전달된다. (실제는 작은 해상도)
// 정확한 해상도를 얻기 위해서는 getDimensions를 통해 얻어야 한다. (트리밍 정보 계산시에는 getDimension 사용)
// 그러나, 전체 선택시 속도의 차이가 너무 커서 그냥 사용한다.
- (BOOL)isPrintablePhoto:(PHAsset *)asset {
	int width = [[PHAssetUtility info] getPixelWidth:asset];
	int height = [[PHAssetUtility info] getPixelHeight:asset];
	long size = [[PHAssetUtility info] getFileSize:asset];
    
    if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
        return TRUE;
        /* 메모리를 너무 사용하여 일단 제외.
        NSString *color_model = [representation.metadata objectForKey:@"ColorModel"];
        if ([color_model isEqualToString:@"RGB"]) {
            return TRUE;
        }*/
    }
    return FALSE;
}

- (BOOL)isSelectedPhoto:(PHAsset *)asset {
    return ([_selectedPhotos objectForKey:asset.localIdentifier] != nil) ? TRUE : FALSE;
}

- (void)addPhoto:(PHAsset *)asset {
    PhotoItem *photo_item = [[PhotoItem alloc] init];
    photo_item.asset = asset;
    photo_item.url = asset.localIdentifier;
    photo_item.filename = nil; // 나중에 할당.. (속도문제로 이동) 
    photo_item.thumb = nil; // 나중에 할당.. (속도문제로 이동)
    photo_item.size_type = [Common info].photoprint.selected_type;
    
    [_selectedPhotos setObject:photo_item forKey:photo_item.url];
}

- (void)removePhoto:(PHAsset *)asset {
    [_selectedPhotos removeObjectForKey:asset.localIdentifier];
}

- (NSUInteger)countPhoto {
    return _selectedPhotos.count;
}
#endif

@end
