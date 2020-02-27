//
//  SocialLoginViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 05/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol socialAuthDelegate <NSObject>
@optional
- (void)oAuthDone:(BOOL)result snsType:(int)snsType;
@end

@interface SNSLoginViewController : UIViewController  <UIWebViewDelegate>

@property (assign) BOOL isSuccess;
@property (assign) int snsType;
@property (strong, nonatomic) IBOutlet UIWebView *webview;

@property (strong, nonatomic) id<socialAuthDelegate> delegate;

- (IBAction)close:(id)sender;
- (void)setData:(int)snsType delegate:(id<socialAuthDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
