//
//  DdukddakSianBoardViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 2019/10/20.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DdukddakSianBoardViewController : UIViewController

@property (strong, nonatomic) WKWebView *mainWebView;
@property (strong, nonatomic) NSString *url;
@property (assign) BOOL requestLogin;

- (void) loadURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
