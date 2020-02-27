//
//  PhotomonInfo.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 1..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "Define.h"
#import "MainViewController.h"
#import "CartItem.h"
#import "CartPreviewItem.h"
#import "Payment.h"
#import "SignupUser.h"
#import "LoginUserInfo.h"
#import "OrderItem.h"
#import "ContactusItem.h"
#import "NoticeItem.h"
#import "CouponItem.h"

#define NSEUCKREncoding (-2147481280)

#define PARSE_NOSTATE               0
#define PARSE_ORDERNUMBER           1
#define PARSE_CARTSESSION           2
#define PARSE_CARTLIST              3
#define PARSE_CARTOK                4
#define PARSE_CARTPREVIEWITEM       5
#define PARSE_UPDATECARTPREVIEWITEM 6
#define PARSE_SENDDELIVERYINFO      7
#define PARSE_ADDRESSINFO           8
#define PARSE_LOGINUSERINFO         9
#define PARSE_SEARCHLOGININFO       10
#define PARSE_ORDERLIST             11
#define PARSE_ORDERITEM             12
#define PARSE_ORDERDETAILLIST       13
#define PARSE_CONTACTLIST           14
#define PARSE_COUPONLIST            15

@interface PhotomonInfo : NSObject <NSXMLParserDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) NSMutableArray *orderList;
@property (strong, nonatomic) OrderItemEx *orderItemSel;
@property (strong, nonatomic) NSMutableArray *orderDetailList;

// cart info
@property (strong, nonatomic) NSString *cartSession;
@property (strong, nonatomic) CartItem *cartItem;
@property (strong, nonatomic) NSMutableArray *cartList;
@property (strong, nonatomic) NSMutableArray *cartPreviewItemList;

// pay info
@property (strong, nonatomic) NSMutableArray *payList;
@property (strong, nonatomic) Payment *payment;

// address info
@property (strong, nonatomic) NSMutableArray *postnumArray;
@property (strong, nonatomic) NSMutableArray *addressArray;
@property (strong, nonatomic) NSMutableArray *addressArray2;

// contact list
@property (strong, nonatomic) NSMutableArray *contactArray;

// notice list
@property (strong, nonatomic) NSMutableArray *noticeList;

// coupon list
@property (strong, nonatomic) NSMutableArray *couponList;
@property (assign) int parsingState;
@property (strong, nonatomic) NSString *parsingElement;

@property (strong, nonatomic) NSString *coupon_name_acc; // 쿠폰이름이 잘려서 여러번 들어옴.


+ (PhotomonInfo *)sharedInfo;

- (void)alertMsg:(NSString *)msg;
- (NSData *)downloadSyncWithURL:(NSURL *)url;
- (void)downloadAsyncWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *imageData))completionBlock;

- (BOOL)loadCartSession;
- (BOOL)loadCartList;
- (BOOL)loadCartPreviewItemList:(int)type Param:(NSString *)param;
- (BOOL)updateCartPreviewItemList:(int)type Param:(NSString *)param Idx:idx Cnt:cnt;
- (BOOL)updateCartPreviewItemListPrice:(int)type Param:(NSString *)param Price:total_price;
- (BOOL)deleteCartItem:(NSString *)cartIdx;
- (BOOL)postDeliveryInfo;
- (BOOL)postPaymentInfo:(UIWebView *)webview;
- (BOOL)loadAddressInfo:(NSString *)searchAddress;
- (BOOL)loadOrderList;
- (BOOL)loadOrderItem:(NSString *)tuid;
- (BOOL)loadOrderDetailList:(NSString *)tuid;
- (BOOL)sendContactInfo:(ContactusItem *)contactInfo;
- (BOOL)loadContactList:(NSString *)userID;
- (NSString *)loadContactPost:(NSString *)postIdx;
- (BOOL)loadNoticeList;
- (NSData *)loadNoticeItem:(NSString *)postIdx;
- (BOOL)loadCouponList:(NSString *)userID Intnum:(NSString *)intnum Seqnum:(NSString *)seqnum CartIdx:(NSString *)cartidx;
- (NSString *)registCoupon:(NSString *)couponNum ID:(NSString *)userID;

@end


