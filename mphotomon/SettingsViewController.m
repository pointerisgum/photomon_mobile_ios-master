//
//  SettingsViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SettingsViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "Instagram.h"
#import "UIView+Toast.h"
#import "ProvisionDetailViewController.h"
#import "FrameWebViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 버전 정보
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [infoDic objectForKey:@"CFBundleVersion"];
    NSLog(@"appName = %@ / %@ / %@",appName, appVersion, appBuild);
    
    NSString *newVersion = [Common info].connection.app_ver;
    if (newVersion == nil || newVersion.length < 1) {
        _latestVersion.text = @"-";
    }
    else {
        _latestVersion.text = [NSString stringWithFormat:@"v%@", newVersion];
    }
    _currentVersion.text = [NSString stringWithFormat:@"v%@", appVersion];
    
    // 사용안내
    BOOL show_book_guide1 = [[Common info] checkGuideUserDefault:GUIDE_PHOTO_SELECT];
    BOOL show_book_guide2 = [[Common info] checkGuideUserDefault:GUIDE_PHOTOBOOK_EDIT];
    BOOL show_book_guide3 = [[Common info] checkGuideUserDefault:GUIDE_CALENDAR_EDIT];
    BOOL show_book_guide4 = [[Common info] checkGuideUserDefault:GUIDE_FRAME_EDIT];
    if (show_book_guide1 && show_book_guide2 && show_book_guide3 && show_book_guide4) {
        [_guide_switch setOn:YES];
    }
    else {
        [_guide_switch setOn:NO];
    }
    [_guide_switch addTarget:self action:@selector(bookguideChanged:) forControlEvents:UIControlEventValueChanged];
    
    // 인스타그램
    //[[Instagram info] logout];
    if ([[Instagram info] isSessionValid]) {
        [_insta_switch setOn:YES];
    }
    else {
        [_insta_switch setOn:NO];
    }
    [_insta_switch addTarget:self action:@selector(instaLoginChanged:) forControlEvents:UIControlEventValueChanged];
    
    // 보관함
    _storageSize.text = @"총 사용량: 계산 중...";
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
    [_thread start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doingThread {
    NSString *docPath = [[Common info] documentPath];
    _storage_calc = [[Common info] sizeOfDirectory:docPath];

    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)doneThread {
    _storageSize.text = [NSString stringWithFormat:@"총 사용량: %@", _storage_calc];
}

- (void)instaLoginChanged: (id)sender {
    if ([sender isOn]) {
        [[Instagram info] login:self];
    }
    else {
        [[Instagram info] logout];
    }
}

- (void)bookguideChanged: (id)sender {
    NSString *show = [sender isOn] ? @"Y" : @"N";
    [[Common info] setGuideUserDefault:GUIDE_PHOTO_SELECT Value:show];
    [[Common info] setGuideUserDefault:GUIDE_PHOTOBOOK_EDIT Value:show];
    [[Common info] setGuideUserDefault:GUIDE_CALENDAR_EDIT Value:show];
    [[Common info] setGuideUserDefault:GUIDE_IDPHOTOS_CAMERA Value:show];
    [[Common info] setGuideUserDefault:GUIDE_FRAME_EDIT Value:show];
}

- (IBAction)deleteStorage:(id)sender {
    //MAcheck
    NSString *warning_msg = @"보관함에 저장되어 있는 모든 내용이 삭제되며\n이 작업은 되돌릴 수 없습니다. 삭제하시겠습니까?";
    [[Common info]alert:self Title:warning_msg Msg:@"" okCompletion:^{
        if ([[Common info] removeAllFilesInDocument]) {
            [self.view makeToast:@"삭제되었습니다."];
            
            NSString *docPath = [[Common info] documentPath];
            self.storageSize.text = [NSString stringWithFormat:@"총 사용량: %@", [[Common info] sizeOfDirectory:docPath]];
        }
        else {
            [self.view makeToast:@"삭제되지 않았습니다."];
        }

    } cancelCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];

    } okTitle:@"네" cancelTitle:@"아니오"];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - button Event
//cmh. 약관 추가
//포토몬 이용약관
- (IBAction)clickLaw:(id)sender {
    NSLog(@"포토몬 이용약관");
    
    FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
    frameWebView.webviewUrl = URL_PROVISION_LAW;
    [self presentViewController:frameWebView animated:YES completion:nil];

    
}
//개인정보 취급방침
- (IBAction)clickPrivacy:(id)sender {
    NSLog(@"개인정보 취급방침");
    FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
    frameWebView.webviewUrl = URL_PROVISION_PRIVACY;
    [self presentViewController:frameWebView animated:YES completion:nil];

}
//권한 설정 안내
- (IBAction)clickAuthority:(id)sender {
    NSLog(@"권한 설정 안내");
    
    FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
    frameWebView.webviewUrl = URL_PROVISION_AUTHORITY;
    [self presentViewController:frameWebView animated:YES completion:nil];

}



#pragma mark - oAuthDelegate methods

- (void)oAuthDone:(BOOL)result {
    [_insta_switch setOn:result];
}

@end
