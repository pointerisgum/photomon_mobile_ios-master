//
//  InviteViewController.m
//  
//
//  Created by photoMac on 2015. 8. 10..
//
//

#import "InviteViewController.h"
#import <Social/Social.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "PhotomonInfo.h"

@interface InviteViewController ()

@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)InviteViaKakaoTalk:(id)sender {
//	if ([KOAppCall canOpenKakaoTalkAppLink]) {
//        NSMutableArray *linkArray = [NSMutableArray array];
//
//        // 초대 문구.
//        NSString *invite_msg = @"포토몬앱에서 쉽고 재미있게 사진과 소품들을 만들어 보세요.";
//        KakaoTalkLinkObject *invite_label = [KakaoTalkLinkObject createLabel:invite_msg];
//        [linkArray addObject:invite_label];
//
//        // 앱 이동 url.
//        KakaoTalkLinkAction *android_action
//        = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
//                                    devicetype:KakaoTalkLinkActionDeviceTypePhone
//                                     execparam:nil];
//
//        KakaoTalkLinkAction *iphone_action
//        = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
//                                    devicetype:KakaoTalkLinkActionDeviceTypePhone
//                                     execparam:nil];
//
//        KakaoTalkLinkObject *invite_button
//        = [KakaoTalkLinkObject createAppButton:@"포토몬 앱으로 이동"
//                                     actions:@[android_action, iphone_action]];
//
//        [KOAppCall openKakaoTalkAppLink:@[invite_label, invite_button]];
//    }
//    else {
//        // 카카오톡 설치
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_KAKAO_INSTALL]];
//    }
}

- (IBAction)InviteViaFacebook:(id)sender {
    SLComposeViewController *invite_vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [invite_vc setInitialText:NSLocalizedString(@"InviteMessage", nil)];
    [self presentViewController:invite_vc animated:YES completion:nil];
}

- (IBAction)InviteViaTwitter:(id)sender {
    SLComposeViewController *invite_vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [invite_vc setInitialText:NSLocalizedString(@"InviteMessage", nil)];
    [self presentViewController:invite_vc animated:YES completion:nil];
}

- (IBAction)InviteViaSMS:(id)sender {
    if (![MFMessageComposeViewController canSendText]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"SMS를 보낼 수 없습니다."];
        return;
    }

    MFMessageComposeViewController *sms_vc = [[MFMessageComposeViewController alloc] init];
    [sms_vc setBody:NSLocalizedString(@"InviteMessage", nil)];
    //[sms_vc setRecipients:recipents];
    
    sms_vc.messageComposeDelegate = self;
    [self presentViewController:sms_vc animated:YES completion:nil];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MessageComposeResultSent) {
        [[PhotomonInfo sharedInfo] alertMsg:@"SMS가 전송되었습니다."];
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"SMS 전송 실패."];
    }
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}





#if 0


#pragma mark - 카카오톡
- (void) kakaoWithText:(NSString *)text image:(UIImage *)image imageURLString:(NSString *)imageurl url:(NSURL *)url {
    // 카카오톡
    KakaoTalkLinkAction *androidAppAction
    = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
                                devicetype:KakaoTalkLinkActionDeviceTypePhone
                               marketparam:nil
                                 execparam:@{@"kakaoFromData":[NSString stringWithFormat:@"{seq:\"%@\", type:\"%@\"}", self.dataInfo[@"contentsSeq"], self.dataInfo[@"contentsType"]]}];
    
    KakaoTalkLinkAction *iphoneAppAction
    = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
                                devicetype:KakaoTalkLinkActionDeviceTypePhone
                               marketparam:nil
                                 execparam:@{@"kakaoFromData":[NSString stringWithFormat:@"{seq:\"%@\", type:\"%@\"}", self.dataInfo[@"contentsSeq"], self.dataInfo[@"contentsType"]]}];
    
    NSString *buttonTitle = @"앱으로 이동";
    
    
    NSMutableArray *linkArray = [NSMutableArray array];
    
    KakaoTalkLinkObject *button
    = [KakaoTalkLinkObject createAppButton:buttonTitle
                                   actions:@[androidAppAction, iphoneAppAction]];
    [linkArray addObject:button];
    
    /*[NSString stringWithFormat:@"%@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], LOC(@"msg_invite_kakao", @"경영전문대학원 MBA 모바일 주소록 앱")]*/
    if (text) {
        KakaoTalkLinkObject *label;
        label = [KakaoTalkLinkObject createLabel:text];
        [linkArray addObject:text];
    }
    
    if (imageurl && image) {
        KakaoTalkLinkObject *kimage
        = [KakaoTalkLinkObject createImage:imageurl/*self.dataInfo[@"thumbnail1"]*/
                                     width:image.size.width
                                    height:image.size.height];
        [linkArray addObject:kimage];
    }
    
    
    [KOAppCall openKakaoTalkAppLink:linkArray];
}
- (void) openInstallKakaoAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"카카오톡이 설치되어 있지 않습니다."
                                                    message:@"카카오톡을 설치하겠습니까?"// @"Do you want to install the KakaoTalk?"
                                                   delegate:self
                                          cancelButtonTitle:@"취소"
                                          otherButtonTitles:@"확인", nil];
    alert.tag = 141;
    [alert show];
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==141) {
        if (buttonIndex==[alertView cancelButtonIndex]) {
            // cancel
        } else {
            // 카카오톡 링크로 이동
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_KAKAO_INSTALL]];
        }
    }
    
}
#endif

@end
