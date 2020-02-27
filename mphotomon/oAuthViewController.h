//
//  oAuthViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 3. 11..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol oAuthDelegate <NSObject>
@optional
- (void)oAuthDone:(BOOL)result;
@end


@interface oAuthViewController : UIViewController

@property (assign) BOOL is_success;
@property (strong, nonatomic) NSString *oauth_url;
@property (strong, nonatomic) IBOutlet UIWebView *webview;

@property (strong, nonatomic) id<oAuthDelegate> delegate;

- (IBAction)close:(id)sender;

@end
