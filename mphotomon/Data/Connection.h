//
//  Connection.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 27..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connection : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSString *app_ver;
@property (strong, nonatomic) NSString *appstore_url;
@property (strong, nonatomic) NSString *update_msg;

@property (strong, nonatomic) NSString *event_id;         // 1. 앱시작시 뜨는 이벤트 페이지
@property (strong, nonatomic) NSString *event_url;
@property (strong, nonatomic) NSString *event_show;

@property (strong, nonatomic) NSString *main_event_count; // 2. 메인화면의 이벤트버튼을 통한 이벤트 페이지
@property (strong, nonatomic) NSString *main_event_url;

@property (assign) int delivery_free_cost;
@property (strong, nonatomic) NSMutableArray *product_msg;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@property (strong, nonatomic) NSString *info_os_version;
@property (strong, nonatomic) NSString *info_os_url;
@property (strong, nonatomic) NSString *info_os_updatemsg;
@property (strong, nonatomic) NSString *info_delivery_price;
@property (strong, nonatomic) NSString *info_eventpopup_version;
@property (strong, nonatomic) NSString *info_eventpopup_url;
@property (strong, nonatomic) NSString *info_eventpopup_enable;
@property (strong, nonatomic) NSString *info_eventpage_count;
@property (strong, nonatomic) NSString *info_eventpage_url;
@property (strong, nonatomic) NSMutableArray *info_eventui_deeplink;
@property (strong, nonatomic) NSMutableArray *info_eventui_mainthumburl;
@property (strong, nonatomic) NSMutableArray *info_eventui_enable;
@property (strong, nonatomic) NSMutableArray *info_eventui_weburl;
@property (strong, nonatomic) NSString *info_user_session;
@property (strong, nonatomic) NSString *info_print_sizeinfo;
@property (strong, nonatomic) NSString *info_print_ordernourl;
@property (strong, nonatomic) NSString *info_print_upload_host;
@property (strong, nonatomic) NSString *info_print_upload_host_image;
@property (strong, nonatomic) NSString *info_cart_count;
@property (strong, nonatomic) NSString *tplServerInfo;

@property (strong, nonatomic) NSString *printRecvInfo;
@property (strong, nonatomic) NSString *podRecvInfo;
@property (strong, nonatomic) NSString *premiumRecvInfo;
@property (strong, nonatomic) NSString *calendarRecvInfo;
@property (strong, nonatomic) NSString *cardRecvInfo;
@property (strong, nonatomic) NSString *babyRecvInfo;
@property (strong, nonatomic) NSString *frameFirstRecvInfo;
@property (strong, nonatomic) NSString *frameSecondRecvInfo;
@property (strong, nonatomic) NSString *polaroidRecvInfo;
@property (strong, nonatomic) NSString *etcRecvInfo;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)clear;
- (BOOL)isAvailable;
- (NSString *)productMsg:(int)idx;
- (BOOL)needUpdate;
- (BOOL)loadVersionInfo;
- (BOOL)loadVersionInfo_v2;

@end
