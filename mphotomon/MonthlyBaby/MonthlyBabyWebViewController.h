//
//  MonthlyBabyWebViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 21/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface MonthlyBabyWebViewController : UIViewController

@property (assign) BOOL requestLogin;

@property (strong, nonatomic) WKWebView *mainWebView;
@property (strong, nonatomic) NSString *url;

@end
