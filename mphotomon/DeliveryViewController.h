//
//  DeliveryViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 17..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeliveryViewController : UIViewController

@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIView *contentview;

@property (strong, nonatomic) IBOutlet UILabel *deliveryInputLabel;
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *phoneID;
@property (strong, nonatomic) IBOutlet UITextField *phoneFrontNum;
@property (strong, nonatomic) IBOutlet UITextField *phoneRearNum;
@property (strong, nonatomic) IBOutlet UITextField *emailAddress;
@property (strong, nonatomic) IBOutlet UITextField *addressPostNum;
@property (strong, nonatomic) IBOutlet UITextField *addressBasic;
@property (strong, nonatomic) IBOutlet UITextField *addressDetail;
@property (strong, nonatomic) IBOutlet UITextField *messageDelivery;
@property (strong, nonatomic) IBOutlet UIButton *phonePaymentCheckBox;
@property (strong, nonatomic) IBOutlet UIButton *cardPaymentCheckBox;
@property (strong, nonatomic) IBOutlet UIButton *vbankPaymentCheckBox;

- (void)fillDeliveryInfo:(NSString *)selected;
- (void)loadUserDeliveryInfo;
- (void)loadRecentlyDeliveryInfo;
- (void)saveRecentlyDeliveryInfo;

- (IBAction)clickDeliveryInput:(id)sender;
- (IBAction)clickPhoneID:(id)sender;
- (IBAction)onPhonePayment:(id)sender;
- (IBAction)onCardPayment:(id)sender;
- (IBAction)onVBankPayment:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)onPayment;

@end
