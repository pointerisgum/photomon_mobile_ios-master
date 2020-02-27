//
//  OrderDetailViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 15..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface OrderDetailViewController : BaseViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webview;

@end
