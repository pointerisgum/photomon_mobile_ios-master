//
//  PayWebViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 20..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WKWebViewPanelManager.h"

@interface WVCartViewController : UIViewController

@property (assign) BOOL is_innerrequest;
@property (strong, nonatomic) WKWebView *web_view;

@property (assign) int resultAction;
@property (strong, nonatomic) NSString* resultParam;

@property (strong, nonatomic) NSString* resultUrl;
@property (strong, nonatomic) NSString* osinfo;
@property (strong, nonatomic) UIViewController *callerViewController;

//@property (nonatomic, strong) void (^dismissCallBack)(void);


#define ACTION_NONE             0
#define ACTION_CLOSE            1
#define ACTION_OPENURL          3
#define ACTION_GOPAYMENT        4
#define ACTION_ORDERCOMPLETE    5
#define ACTION_ORDERLIST        6
#define ACTION_GOCART           7
#define ACTION_GOLOGIN          8

- (IBAction)cancel:(id)sender;
- (void)doAction;
- (NSData *)downloadSyncWithURL:(NSURL *)url;
- (void)loadCart;
- (void)loadOrderPay;
- (void)loadOrderComplete;
- (void)loadOrderList;

@end
