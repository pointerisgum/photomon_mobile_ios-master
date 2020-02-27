//
//  EventViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <WebKit/WebKit.h>

#define ACTION_NONE     0
#define ACTION_SIGNUP   1
#define ACTION_LOGIN    2
#define ACTION_OPENURL  3

@interface EventViewController : BaseViewController

@property (assign) int eventType;
@property (assign) int resultAction;
@property (assign) NSString* resultUrl;

//@property (strong, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) IBOutlet UIButton *checkDontShow;
@property (strong, nonatomic) IBOutlet UILabel *labelDontShow;

- (IBAction)clickDontShow:(id)sender;
- (IBAction)close:(id)sender;
- (NSData *)downloadSyncWithURL:(NSURL *)url;
@end
