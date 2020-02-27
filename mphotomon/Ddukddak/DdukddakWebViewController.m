//
//  DdukddakWebViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 9. 30..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "DdukddakWebViewController.h"
#import "UIView+Toast.h"
#import "Ddukddak.h"

#import "Common.h"
#import "PhotomonInfo.h"
#import "MonthlyUploadPopup.h"
#import "MonthlyUploadDonePopup.h"
#import "SelectAlbumViewController.h"
#import "MonthlyOptionDateViewController.h"
#import "PhotoPositionSelectController.h"

#import "DdukddakProductSelectViewController.h"
#import "LoginViewController.h"
#import "DdukddakDetailViewController.h"

//#import "MonthlyAddProductPopup.h"

@interface DdukddakWebViewController ()<NSURLConnectionDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, MonthlyAfterUploadActionDelegate>

@end

@implementation DdukddakWebViewController

-(BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self dismissViewControllerAnimated:NO completion:nil];
                                                  }];
    
    [Common info].deeplink_url = nil;
    
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:@"notification"];
    
    WKPreferences *pref = [[WKPreferences alloc] init];
    [pref setJavaScriptEnabled:YES];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = contentController;
    config.preferences = pref;
    
    CGSize size = [UIScreen.mainScreen bounds].size;
    CGSize statusBar = [UIApplication sharedApplication].statusBarFrame.size;
    //    CGSize navigationBar = self.navigationController.navigationBar.frame.size;
    //
    //    self.navigationController.navigationBarHidden = YES;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"뒤로" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    //인트로인지 아닌지 판별하여 버튼을 보여주거나 안보여줌
    if(_isIntro == YES){
        _registBtn.hidden = NO;
        _mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height - _registBtn.bounds.size.height ) configuration:config];
    }
    else{
        _registBtn.hidden = YES;
        //_mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height) configuration:config];
        _mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height - _registBtn.bounds.size.height ) configuration:config];
    }
    
    
    
    //    _mainWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    
    [self.view addSubview:_mainWebView];
    
    [_mainWebView setUIDelegate:self];
    [_mainWebView setNavigationDelegate:self];
    [_mainWebView sizeToFit];
    
    [MonthlyBaby inst].mainWebView = self;
    
    
}

- (IBAction)Back
{
    
    [[Common info] alert:self Title:@"뚝딱서비스 주문을 취소하시겠습니까?" Msg:@"" okCompletion:^{
        
    } cancelCompletion:^{
        /*if(self.presentingViewController != nil){
            [self dismissViewControllerAnimated:YES completion:^(void){
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
            
        }else{
            [self.navigationController popToRootViewControllerAnimated:NO];
        }*/
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        if(allViewControllers.count > 2 ){
            for (UIViewController *aViewController in allViewControllers) {
                if ([aViewController isKindOfClass:[DdukddakDetailViewController class]]) {
                    [self.navigationController popToViewController:aViewController animated:YES];
                    break;
                }
            }
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } okTitle:@"계속주문" cancelTitle:@"취소"];
    //    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBarHidden = YES;
    
    if([Common info].user.mUserid .length > 0){
        _registBtn.backgroundColor = [UIColor lightGrayColor];
       }
    else{
       _registBtn.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1];
    }
    
    if([_url containsString:URL_MONTHLY_BABY_MAIN_URL]) {
        
        if ([[MonthlyBaby inst] loadBaseData]) {
        }
        [[MonthlyBaby inst] loadData:@"imgcount^deadline^maxcount^upload_maxcount"];
    }
    
    if(_isIntro == YES){
        [[Ddukddak inst]loadProduct];
        
        NSString *htmlstr = [NSString stringWithFormat:@"<html>                         <meta name='viewport' content='width=device-width, initial-scale=1'>                         <style>  .bg { position: relative;top: 0;left: 0;min-width: 100%%;max-width: 100%%;min-height: auto;}</style><body style='margin:0px 0px 0px 0px;'><div><img class ='bg' src='%@'></div></body></html>",[Ddukddak inst].mainImg];
        [_mainWebView loadHTMLString:htmlstr baseURL:nil];
    }
    else{
       [self loadURL:_url];
    }
    
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //        MonthlyOptionCoverEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionCoverEditViewController"];
    //
    //        if (vc) {
    ////            [vc setData:totalCount delegate:self];
    //
    //    //        [MonthlyBaby inst].currentUploadCount = 600;
    //            [self presentViewController:vc animated:NO completion:nil];
    //        }
    
    //    else {
    //        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"로그인 후 이용할 수 있습니다.\n로그인 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
    //
    //        [alertController addAction:[UIAlertAction actionWithTitle:@"아니오" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //            [self popoverPresentationController];
    //            [self.navigationController popViewControllerAnimated:YES];
    //        }]];
    //        [alertController addAction:[UIAlertAction actionWithTitle:@"네" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //            [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    //        }]];
    //        [self presentViewController:alertController animated:YES completion:nil];
    //    }
    if(!_isViewDidAppear){
        _isViewDidAppear = YES;
        CGSize size = [UIScreen.mainScreen bounds].size;
        CGSize statusBar = [UIApplication sharedApplication].statusBarFrame.size;
        CGSize navigationBar = self.navigationController.navigationBar.frame.size;
        
        NSString *curURL = _mainWebView.URL.absoluteString;
        //if(![curURL containsString:@"about:blank"]) {
        
        if ([curURL containsString:@"ddudak"]) {
            if ([curURL containsString:@"OrderPay"]) {
                self.navigationController.navigationBarHidden = NO;
                [_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height)];
                self.title = @"주문결제";
            } else {
                self.navigationController.navigationBarHidden = YES;
                [_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
            }
        } else if(_isIntro) {
            self.navigationController.navigationBarHidden = NO;
            [_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height - _registBtn.bounds.size.height-_registBtn.bounds.size.height)];
            
        } else {
            self.navigationController.navigationBarHidden = YES;
            [_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height)];
           
            //[_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height - navigationBar.height - _registBtn.bounds.size.height )];
            //CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height - _registBtn.bounds.size.height )
            }
    }
    
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void) loadURL:(NSString *)url {
    
        NSURL *reqURL = [Common buildQueryURL:url
                                        query:@[]];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:reqURL];
        [_mainWebView loadRequest:request];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma webView

// 콘텐츠가 웹뷰에 로드되기 시작할 때 호출 (1)
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //    NSLog(@"didStartProvisionalNavigation: %@", _mainWebView.URL);
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation: %@", navigation);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation: %@navigation, error: %@", navigation, error);
}

// 네비게이션이 요청되었을 때 (2)
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didCommitNavigation");
}

// 네비게이션이 완료 되었을 떄 (3)
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"didFinishNavigation");
    //    if (self.wkWebView.canGoBack) {
    //        [self.wkWebView goBack];
    //        NSLog(@"ASDF : CAN GO BACK");
    //    } else {
    //        NSLog(@"ASDF : CAN NOT GO BACK");
    //    }
    if(_isViewDidAppear){
        CGSize size = [UIScreen.mainScreen bounds].size;
        CGSize statusBar = [UIApplication sharedApplication].statusBarFrame.size;
        CGSize navigationBar = self.navigationController.navigationBar.frame.size;
    
        NSString *curURL = _mainWebView.URL.absoluteString;
    //if(![curURL containsString:@"about:blank"]) {
    
        if ([curURL containsString:@"ddudak"]) {
            if ([curURL containsString:@"OrderPay"]) {
                self.navigationController.navigationBarHidden = NO;
                [_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height)];
                self.title = @"주문결제";
            } else if([curURL containsString:@"ordercomplete.asp"]) {
                self.navigationController.navigationBarHidden = YES;
                [_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
                self.title = @"결제완료";
            } else {
                self.navigationController.navigationBarHidden = YES;
                [_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
            }
        } else if(_isIntro) {
            self.navigationController.navigationBarHidden = NO;
            [_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height - _registBtn.bounds.size.height-_registBtn.bounds.size.height)];
            
        } else if([curURL containsString:@"OrderList"]) {
            self.navigationController.navigationBarHidden = YES;
            [_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
        } else if([curURL containsString:@"ordercomplete"]) {
            self.navigationController.navigationBarHidden = YES;
            [_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
        }
        else {
            self.navigationController.navigationBarHidden = NO;
            [_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height)];
        //[_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height - navigationBar.height - _registBtn.bounds.size.height )];
        
        }
    }
   // }
    //    if ([curURL containsString:@"orderpay.asp"]) {
    //        self.title = @"주문결제";
    //    } else if([curURL containsString:@"ordercomplete.asp"]) {
    //        self.title = @"결제완료";
    //        self.navigationController.navigationBarHidden = NO;
    //        [_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height)];
    //    } else {
    //    }
}

// 정책 제어를 통해 WKNavigationActionPolicyAllow 또는 WKNavigationActionPolicyCancel
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString* requestString = navigationAction.request.URL.absoluteString;
    requestString = [requestString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];
    NSLog(@"ASDF : [REQUEST] %@", requestString);
    if ([requestString hasPrefix:@"jscall:"]) {
        NSArray *components = [requestString componentsSeparatedByString:@"://"];
        if (components.count > 0) {
            NSString *command = [components objectAtIndex:1];
            
            if ([command isEqualToString:@"selectPhoto"]) {
                [self selectPhotos];
            }
            else if([command isEqualToString:@"login"]) {
                if ([Common info].user.mUserid.length > 0){
                    [[MonthlyBaby inst] loadData:@"imgcount^deadline^maxcount^upload_maxcount"];
                    [self loadURL:URL_MONTHLY_BABY_MAIN_URL];
                }
                else {
                    _requestLogin = YES;
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[Common info].main_controller didTouchMenuButton:nil];
                    }];
                    //                    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
                }
            }
            else if([command isEqualToString:@"close"]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else if([command isEqualToString:@"orderlist"]) {
                NSString *userid = [Common info].user.mUserid;
                
                if (userid == nil) {
                    userid = @"";
                }
                
                NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;
                
                NSURL *reqURL = [Common buildQueryURL:@"https://www.photomon.com/wapp/order/orderlistloading.asp"
                                                query:@[
                                                        [NSURLQueryItem queryItemWithName:@"userid" value:userid]
                                                        ,[NSURLQueryItem queryItemWithName:@"uniquekey" value:[Common info].device_uuid]
                                                        ,[NSURLQueryItem queryItemWithName:@"osinfo" value:@"ios"]
                                                        ,[NSURLQueryItem queryItemWithName:@"cart_session" value:cartsession
                                                          ]]];
                
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:reqURL];
                [_mainWebView loadRequest:request];
            }
            else if([command isEqualToString:@"orderNow"]) {
                [self orderNow];
            }
            //            // SJYANG : openurl 작업
            //            if ([command containsString:@"openurl"]) {
            //                _resultAction = ACTION_OPENURL;
            //
            //                NSString *workStr = [requestString copy];
            //                workStr = [workStr stringByReplacingOccurrencesOfString:@"jscall://openurl%7C" withString:@""];
            //
            //                _resultUrl = workStr;
            //                NSLog(@"_resultUrl : [%@]", _resultUrl);
            //                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_resultUrl]];
            //                [self close:self];
            //            }
        }
    }
    /*
     if ([requestString hasPrefix:@"android_photomon_app.executeAndroidapp('"]) {
     }
     */
    
    if (decisionHandler) {
        if (![requestString hasPrefix:@"http://"] && ![requestString hasPrefix:@"https://"]) {
            NSURL *url = navigationAction.request.URL;
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
                decisionHandler(WKNavigationActionPolicyCancel);
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    [[Common info] alert:self Title:message Msg:@"" completion:^{
        completionHandler();
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    [[Common info] alert:self Title:message Msg:@"" okCompletion:^{
        completionHandler(YES);
    } cancelCompletion:^{
        completionHandler(NO);
    } okTitle:@"확인" cancelTitle:@"취소"];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
}

- (void)setNeedsFocusUpdate {
}

- (void)updateFocusIfNeeded {
}

#pragma mark - Monthly Upload After Action
/*-(void) saveMidTerm {
    [self loadURL:[NSString stringWithFormat:@"%@?Type=save",URL_MONTHLY_ORDER_COMPLETE]];
}

-(void) orderNow {
    // 새로운 뷰로
    //    [self loadURL:URL_MONTHLY_ORDER_COMPLETE];
    [[MonthlyBaby inst] initialize];
    MonthlyOptionDateViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionDateViewController"];
    [self.navigationController pushViewController:vc animated:YES ];
}*/
/*
-(void) selectPhotos {
    [Common info].photobook.ProductCode = @"300502";
    [Common info].photobook.product_type = PRODUCT_MONTHLYBABY;
    //                [[Common info] selectPhoto:self Singlemode:NO MinPictures:23 Param:@"440"];
    
    int minCount = MIN(23, MAX(0, [MonthlyBaby inst].maxUploadCountTotal - [MonthlyBaby inst].currentUploadCount));
    int maxCount = MIN([MonthlyBaby inst].maxUploadCountPerBook, MAX(0, [MonthlyBaby inst].maxUploadCountTotal - [MonthlyBaby inst].currentUploadCount));
    
    [[Common info] selectPhoto:self Singlemode:NO MinPictures:minCount Param:[NSString stringWithFormat:@"%d", maxCount]
                      cancelOp:^(UIViewController *vc) {
                          [[Common info] alert:self Title:@"테스트" Msg:@"" okCompletion:^{
                          } cancelCompletion:^{
                              [vc dismissViewControllerAnimated:YES completion:nil];
                          } okTitle:@"계속 진행" cancelTitle:@"취소"];
                      }
                  selectDoneOp:^(UIViewController *vc) {
                      int totalCount = (int)[[PhotoContainer inst] selectCount];
                      NSString *msg = [NSString stringWithFormat:@"%d장의 사진을 업로드 하시겠습니까?\nWifi환경이 아니면 통신요금이 부과될 수 있습니다.", totalCount ];
                      
                      [[Common info] alert:vc Title:msg Msg:@"" okCompletion:^{
                          
                          UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MonthlyBaby" bundle:nil];
                          MonthlyUploadPopup *mupvc = [sb instantiateViewControllerWithIdentifier:@"MonthlyUploadPopup"];
                          
                          if (mupvc) {
                              [mupvc setData:totalCount svcmode:@"monthlybaby" uploadDoneOp:^(BOOL isSuccess, NSString* imageKey) {
                                  int uploadCount = (int)[[PhotoContainer inst] selectCount];
                                  
                                  [[PhotoContainer inst] removeAll];
                                  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MonthlyBaby" bundle:nil];
                                  MonthlyUploadDonePopup *mudpvc = [sb instantiateViewControllerWithIdentifier:@"MonthlyUploadDonePopup"];
                                  
                                  if (mudpvc) {
                                      [mudpvc setData:uploadCount delegate:self rootView:vc];
                                      
                                      [vc presentViewController:mudpvc animated:NO completion:nil];
                                  }
                              }];
                              [vc presentViewController:mupvc animated:NO completion:nil];
                          }
                          
                      } cancelCompletion:^{
                      } okTitle:@"네" cancelTitle:@"아니오"];
                  }
     ];
    
    //    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoSelect" bundle:nil];
    //    UINavigationController *navi = [sb instantiateViewControllerWithIdentifier:@"PhotoSelectSequence"];
    //    if (navi) {
    //        PhotoPositionSelectController *vc = (PhotoPositionSelectController *)navi.topViewController;
    //        [vc setData:self isSinglemode:NO     minPictureCount:minCount param:[NSString stringWithFormat:@"%d", maxCount]];
    //        vc.monthlyDelegate = self;
    //
    //        [self presentViewController:navi animated:YES completion:nil];
    //    }
    
    //    [[Common info] selectPhoto:self Singlemode:NO MinPictures:minCount Param:[NSString stringWithFormat:@"%d", maxCount]];
}*/

#pragma mark - Ddukddak events
-(IBAction)registDdukddak:(id)sender{
        //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"" bundle:nil];
    if([Common info].user.mUserid .length > 0){
        DdukddakProductSelectViewController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"ddukddakProductSelectViewController"];
        if (navi) {
                
            [self.navigationController pushViewController:navi animated:YES ];
        }
    }
    else{
        
        [[Common info] alert:self Title:@"로그인 후 이용할 수 있습니다.\n로그인 하시겠습니까?" Msg:@"" okCompletion:^{
            //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LoginPage"];
            [self.navigationController presentViewController:vc animated:YES completion:nil ];
        } cancelCompletion:^{
            if(self.presentingViewController != nil){
                [self dismissViewControllerAnimated:YES completion:^(void){
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }];
                
            }else{
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
            
        } okTitle:@"네" cancelTitle:@"아니오"];
    }

}
@end
