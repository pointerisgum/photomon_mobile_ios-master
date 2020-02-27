//
//  InviteViewController.h
//  
//
//  Created by photoMac on 2015. 8. 10..
//
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
@interface InviteViewController : UIViewController <MFMessageComposeViewControllerDelegate>

- (IBAction)InviteViaKakaoTalk:(id)sender;
- (IBAction)InviteViaFacebook:(id)sender;
- (IBAction)InviteViaTwitter:(id)sender;
- (IBAction)InviteViaSMS:(id)sender;
- (IBAction)close:(id)sender;

@end
