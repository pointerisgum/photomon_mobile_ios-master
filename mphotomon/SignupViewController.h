//
//  SignupViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 5..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SignupViewController : BaseViewController

@property (strong, nonatomic) NSString *userIDConfirm;
@property (strong, nonatomic) NSString *emailConfirm;

@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *userID;
@property (strong, nonatomic) IBOutlet UITextField *emailAddress;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *passwordConfirm;
@property (strong, nonatomic) IBOutlet UITextField *phoneID;
@property (strong, nonatomic) IBOutlet UITextField *phoneFrontNum;
@property (strong, nonatomic) IBOutlet UITextField *phoneRearNum;
@property (strong, nonatomic) IBOutlet UIButton *checkEmail;
@property (strong, nonatomic) IBOutlet UIButton *checkPhone;
//cmh. 약관분리
@property (strong, nonatomic) IBOutlet UIButton *checkProvision;
@property (strong, nonatomic) IBOutlet UIButton *checkPrivacy;


- (IBAction)clickIDCheck:(id)sender;
- (IBAction)clickEmailCheck:(id)sender;
- (IBAction)clickPhoneID:(id)sender;
- (IBAction)clickRecvEmail:(id)sender;
- (IBAction)clickRecvPhone:(id)sender;
//cmh. 약관분리
- (IBAction)clickAgreeProvision:(id)sender;
- (IBAction)clickAgreePrivacy:(id)sender;
- (IBAction)signup:(id)sender;
- (IBAction)cancel:(id)sender;

@end
