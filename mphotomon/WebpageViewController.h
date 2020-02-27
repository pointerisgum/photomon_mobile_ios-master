//
//  WebpageViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 8..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface WebpageViewController : BaseViewController

@property (assign, nonatomic) int mode;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webview;

- (IBAction)close:(id)sender;

@end
