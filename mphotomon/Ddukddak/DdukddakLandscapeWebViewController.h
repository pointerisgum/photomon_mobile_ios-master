//
//  DdukddakLandscapeWebViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 02/10/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DdukddakLandscapeWebViewController : UIViewController

@property (strong, nonatomic) WKWebView *mainWebView;
@property (strong, nonatomic) NSString *url;
@property (assign) BOOL requestLogin;

- (void) loadURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
