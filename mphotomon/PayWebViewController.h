//
//  PayWebViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 20..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayWebViewController : UIViewController

@property (assign) BOOL is_paycomplete;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIWebView *web_view;

- (IBAction)cancel:(id)sender;

@end
