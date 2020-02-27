//
//  DdukddakWebViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 9. 30..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface DdukddakWebViewController : UIViewController

@property (assign) BOOL requestLogin;
@property (assign) BOOL isIntro;
@property (assign) BOOL isViewDidAppear;

@property (strong, nonatomic) WKWebView *mainWebView;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) IBOutlet UIView *registBtn;

-(IBAction)registDdukddak:(id)sender;

@end /* DdukddakWebViewController_h */
