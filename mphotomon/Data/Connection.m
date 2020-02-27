//
//  Connection.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 27..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "Connection.h"
#import "Common.h"
#import "PhotomonInfo.h"

@implementation Connection

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
    _app_ver = @"";
    _appstore_url = @"";
    _update_msg = @"";
    
    _event_id = @"0";
    _event_url = @"";
    _event_show = @"N";
    
    _main_event_count = @"0";
    _main_event_url = @"";
    
    _delivery_free_cost = 0;
    _product_msg = [[NSMutableArray alloc] init];

	_printRecvInfo = @"";
	_podRecvInfo = @"";
	_premiumRecvInfo = @"";
	_calendarRecvInfo = @"";
	_cardRecvInfo = @"";
	_babyRecvInfo = @"";
	_frameFirstRecvInfo = @"";
	_frameSecondRecvInfo = @"";
	_polaroidRecvInfo = @"";
	_etcRecvInfo = @"";
    
    _tplServerInfo = @"tpl";
}

- (BOOL)isAvailable {
    if (_app_ver.length > 0) {
        return YES;
    }
    return NO;
}

/*
 - 첫번째(변화없음) : 사진인화  - 현재 앱/프로그램 사용
 - 두번째(intNum 변화) : 포토북(246,300), 달력(277 및 PC 달력) - 현재 앱/프로그램 사용
 
 - 세번째(신규) : 레이플랫북, 제니스북 및 기타 포토북(두번째 제외)
 - 네번째(신규) : 대형인화,스크린,미니/실물스탠딩
 - 다섯번째(신규) : 원목액자, 탁상/벽걸이액자,대형액자,캔버스액자
 - 여섯번째(신규) : 인피니액자,쉐도우액자,크리스탈마블
 - 일곱번째(신규) : 폴라로이드세트,초대장,카드,팬시포토,포토머그,포토텀블러 - 차후 폴라로이드(347) 사용?
 */

- (NSString *)productMsg:(int)idx {
    if (idx >= 0 && idx < _product_msg.count) {
        return _product_msg[idx];
    }
    return @"";
}

- (BOOL)needUpdate {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *curVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"[%@] curVersion:%@, newVersion:%@", appName, curVersion, _app_ver);
    if (_app_ver.length <= 0) {
        return NO;
    }
    
    NSArray *appVersionArray = [curVersion componentsSeparatedByString:@"."];
    NSArray *appVersionNewArray = [_app_ver componentsSeparatedByString:@"."];
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
    [self clear];

    // 1. 버전 정보 확인
	// SJYANG : 버전 확인시 타임스탬프 파라메터 전송
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init]; 
	[dateFormatter setDateFormat:@"yyyyMMdd"];	
	NSString *urlVersionInfo = [NSString stringWithFormat:@"%@?timestamp=%@&osinfo=ios&uniquekey=%@", URL_VERSIONINFO, [dateFormatter stringFromDate:[NSDate date]], [Common info].device_uuid];	
	NSLog(@"urlVersionInfo : %@", urlVersionInfo);

    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:urlVersionInfo]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> loadVersionInfo: %@", data);
        
        // line0: Android^2.0.43^market://details?id=com.photomon^포토몬앱이 업데이트 되었습니다|
        // line1: iOS^2.0.29^https://itunes.apple.com/kr/app/photomon/id723333895?mt=8^포토몬앱이 업데이트 되었습니다|
        // line2: 30000|
        // line3: 6^event_url
        NSArray *line_array = [data componentsSeparatedByString:@"|"];
        for (NSString *str in line_array) {
            if ([str isEqualToString:@""]) break;
            NSArray *str_array = [str componentsSeparatedByString:@"^"];
            if ([str_array[0] isEqualToString:@"iOS"]) { // 0: iOS
                _app_ver = str_array[1];                 // 1: 2.0.29
                _appstore_url = str_array[2];            // 2: url
                _update_msg = str_array[3];              // 3: 포토몬앱이 업데이트 되었습니다
            }
        }
        _delivery_free_cost = (int)[line_array[2] integerValue];
        
        // 이벤트 정보 체크
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *event_id = [userDefault stringForKey:@"eventID"];
        NSString *event_show = [userDefault stringForKey:@"eventShow"];
        //event_id = @"0"; // 리셋 테스트
        
        if (line_array.count >= 4) {
            NSArray *eventInfo = [line_array[3] componentsSeparatedByString:@"^"];
            if (eventInfo.count > 1) {
                if ([eventInfo[0] integerValue] > [event_id integerValue]) { // 새로운 이벤트는 처음엔 무조건 보여줌.
                    _event_id = eventInfo[0];
                    _event_url = eventInfo[1];
                    _event_show = @"Y";
                }
                else if ([eventInfo[0] integerValue] == [event_id integerValue]) { // 현재 이벤트는 '다시보지않기' 체크 확인 후 보여줌.
                    if ([event_show isEqualToString:@"Y"]) {
                        _event_id = eventInfo[0];
                        _event_url = eventInfo[1];
                        _event_show = @"Y";
                    }
                }
            }
        }
    }

    ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_EVENT]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> mainEventUrl: %@", data);
        
        NSArray *row_array = [data componentsSeparatedByString:@"^"];
        if (row_array.count > 0) {
            _main_event_count = row_array[0];
        }
        if (row_array.count > 1) {
            _main_event_url = row_array[1];
        }
    }
    
    ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_RECV_INFO]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSArray *temp_array = [data componentsSeparatedByString:@"\n"];
        
        for (NSString *line in temp_array) {
            if ([line isEqualToString:@""]) {
                break;
            }
            NSString *msg = line;
            msg = [msg stringByReplacingOccurrencesOfString:@" <font color=red><b>" withString:@" "];
            msg = [msg stringByReplacingOccurrencesOfString:@"</b></font>" withString:@" "];
            NSLog(@">> product_msg: %@", msg);
            [_product_msg addObject:msg];
        }
    }
   
    return TRUE;
}

- (BOOL)loadVersionInfo_v2 {
    [self clear];

	_info_os_version = @"";
	_info_os_url = @"";
	_info_os_updatemsg = @"";
	_info_delivery_price = @"";
	_info_eventpopup_version = @"";
	_info_eventpopup_url = @"";
	_info_eventpopup_enable = @"";
	_info_eventpage_count = @"0";
	_info_eventpage_url = @"";
    _info_eventui_deeplink = [[NSMutableArray alloc] init];
	_info_eventui_mainthumburl = [[NSMutableArray alloc] init];
	_info_eventui_enable = [[NSMutableArray alloc] init];
	_info_eventui_weburl = [[NSMutableArray alloc] init];
	_info_user_session = @"";
	_info_print_sizeinfo = @"";
	_info_print_ordernourl = @"";
	_info_print_upload_host = @"";
	_info_print_upload_host_image = @"";
	_info_cart_count = @"0";

	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init]; 
	[dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *userId = [Common info].user.mUserid;
    
    if (userId == nil) {
        userId = @"";
    }
    
	NSString *urlVersionInfo = [NSString stringWithFormat:@"%@?timestamp=%@&osinfo=ios&uniquekey=%@&userid=%@&cart_session=%@", 
		URL_VERSIONINFO_V2, 
		[dateFormatter stringFromDate:[NSDate date]], 
		[Common info].device_uuid, 
		userId,
		[PhotomonInfo sharedInfo].cartSession];
	NSLog(@"urlVersionInfo : %@", urlVersionInfo);

    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:urlVersionInfo]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> urlVersionInfo data : %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {

			_app_ver = _info_os_version;
			_appstore_url = _info_os_url;
			_update_msg = _info_os_updatemsg;

			if ([_info_eventpopup_enable isEqualToString:@"true"]) {
				// 이벤트 정보 체크
				NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
				NSString *event_id = [userDefault stringForKey:@"eventID"];
				NSString *event_show = [userDefault stringForKey:@"eventShow"];
				//event_id = @"0"; // 리셋 테스트
				
		        @try {
					if([_info_eventpopup_version integerValue] > 0) {
						if ([_info_eventpopup_version integerValue] > [event_id integerValue]) { // 새로운 이벤트는 처음엔 무조건 보여줌.
							_event_id = _info_eventpopup_version;
							_event_url = _info_eventpopup_url;
							_event_show = @"Y";
						}
						else if ([_info_eventpopup_version integerValue] == [event_id integerValue]) { // 현재 이벤트는 '다시보지않기' 체크 확인 후 보여줌.
							if ([event_show isEqualToString:@"Y"]) {
								_event_id = _info_eventpopup_version;
								_event_url = _info_eventpopup_url;
								_event_show = @"Y";
							}
						}
					}
				}
				@catch(NSException *exception) {}
			}

			_main_event_count = _info_eventpage_count;
			_main_event_url = _info_eventpage_url;
		}
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"ASDF %@", elementName);
    if ([elementName isEqualToString:@"os"]) {
        _info_os_version = [attributeDict objectForKey:@"version"];
        _info_os_url = [attributeDict objectForKey:@"url"];
        _info_os_updatemsg = [attributeDict objectForKey:@"updatemsg"];
    }
    else if ([elementName isEqualToString:@"delivery"]) {
        _info_delivery_price = [attributeDict objectForKey:@"price"];

        _printRecvInfo = [attributeDict objectForKey:@"photo1"];
        _podRecvInfo = [attributeDict objectForKey:@"book1"];
        _premiumRecvInfo = [attributeDict objectForKey:@"book2"];
        _calendarRecvInfo = [attributeDict objectForKey:@"cal1"];
        _cardRecvInfo = [attributeDict objectForKey:@"card1"];
        _babyRecvInfo = [attributeDict objectForKey:@"print1"];
        _frameFirstRecvInfo = [attributeDict objectForKey:@"frame1"];
        _frameSecondRecvInfo = [attributeDict objectForKey:@"frame2"];
        _polaroidRecvInfo = [attributeDict objectForKey:@"gift1"];
        _etcRecvInfo = [attributeDict objectForKey:@"gift3"];
    }
    else if ([elementName isEqualToString:@"eventpopup"]) {
        _info_eventpopup_version = [attributeDict objectForKey:@"version"];
        _info_eventpopup_url = [attributeDict objectForKey:@"url"];
        _info_eventpopup_enable = [attributeDict objectForKey:@"enable"];
    }
    else if ([elementName isEqualToString:@"eventpage"]) {
        _info_eventpage_count = [attributeDict objectForKey:@"count"];
        _info_eventpage_url = [attributeDict objectForKey:@"url"];
    }
    else if ([elementName isEqualToString:@"eventui"]) {
        NSString *enableString = [attributeDict objectForKey:@"enable"];
        
        BOOL enable = ([enableString isEqualToString:@"true"]) ? YES : NO;
        if (enable) {
            [_info_eventui_enable addObject:[attributeDict objectForKey:@"enable"]];
            [_info_eventui_deeplink addObject:[attributeDict objectForKey:@"deeplink"]];
            [_info_eventui_mainthumburl addObject:[attributeDict objectForKey:@"mainthumburl"]];
            if (attributeDict[@"weburl"] != nil) {
                [_info_eventui_weburl addObject:attributeDict[@"weburl"]];
            } else {
                [_info_eventui_weburl addObject:@""];
            }
        }
        
        
		// 디버그
		//_info_eventui_enable = @"true";
    }
    else if ([elementName isEqualToString:@"user"]) {
        _info_user_session = [attributeDict objectForKey:@"session"];
    }
    else if ([elementName isEqualToString:@"print"]) {
        _info_print_sizeinfo = [attributeDict objectForKey:@"sizeinfo"];
        _info_print_ordernourl = [attributeDict objectForKey:@"ordernourl"];
        _info_print_upload_host = [attributeDict objectForKey:@"upload_host"];
        _info_print_upload_host_image = [attributeDict objectForKey:@"upload_host_image"];
    }
    else if ([elementName isEqualToString:@"cart"]) {
        _info_cart_count = [attributeDict objectForKey:@"count"];
    }
    else if ([elementName isEqualToString:@"tpl"]) {
        _tplServerInfo = [attributeDict objectForKey:@"server"];
        if (_tplServerInfo.length < 3) {
            _tplServerInfo = @"tpl";
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    //    if ([_parsingElement isEqualToString:@"cartSession"]) {
    //    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //    _parsingElement = @"";
}

@end
