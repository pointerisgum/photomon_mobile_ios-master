//
//  LoginMenuViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 05/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "LoginMenuViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "MainContents.h"
#import "UIImageView+WebCache.h"

@interface LoginMenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPhotobolCount;
@property (weak, nonatomic) IBOutlet UILabel *lbCouponCount;
@property (weak, nonatomic) IBOutlet UILabel *lbCash;
@property (weak, nonatomic) IBOutlet UILabel *lbDelivery;
@property (weak, nonatomic) IBOutlet UIImageView *ivBanner;

@property (strong, nonatomic) Contents *content;

@end

@implementation LoginMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchCloseButton:)];
    
    gesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:gesture];
    
    NSString *url_str = @"http://www.photomon.com/wapp/xml/msidemenu_banner.asp";
    
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> bannerinfo Result: %@", data);
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    
        self.content = [[Contents alloc]initWithDictionary:dict[@"member"] error:nil];
        NSLog(@"self.content: %@", self.content);
        
        [self.ivBanner sd_setImageWithURL:[NSURL URLWithString:self.content.thumb]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[Common info].login_info updateUserInfo]) {
        
        UIFont *boldFont = [UIFont fontWithName:@"NanumSquareOTFB" size:17.5];
        UIFont *boldDefaultFont = [UIFont fontWithName:@"NanumSquareOTFR" size:17.5];
        UIFont *defaultFont = [UIFont fontWithName:@"NanumSquareOTFR" size:13.5];
        
        self.lbName.font = boldFont;
        
        NSMutableAttributedString *notifyingStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@님", [Common info].user.mUserName]];
        
        [notifyingStr addAttribute:NSFontAttributeName
                             value:boldDefaultFont
                             range:NSMakeRange(notifyingStr.length-1, 1)];
        
        self.lbName.attributedText = notifyingStr;
        
        self.lbPhotobolCount.font = boldFont;
        
        notifyingStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@볼", [Common info].user.mMileage]];
        
        [notifyingStr addAttribute:NSFontAttributeName
                             value:defaultFont
                             range:NSMakeRange(notifyingStr.length-1, 1)];
        
        
        self.lbPhotobolCount.attributedText = notifyingStr;
        
        self.lbCouponCount.font = boldFont;

        notifyingStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@개", [Common info].user.mCouponCount]];
        
        [notifyingStr addAttribute:NSFontAttributeName
                             value:defaultFont
                             range:NSMakeRange(notifyingStr.length-1, 1)];
        
        self.lbCouponCount.attributedText = notifyingStr;
        
        self.lbCash.font = boldFont;

        notifyingStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@원", [Common info].user.mBookmileage]];
        
        [notifyingStr addAttribute:NSFontAttributeName
                             value:defaultFont
                             range:NSMakeRange(notifyingStr.length-1, 1)];
        
        self.lbCash.attributedText = notifyingStr;
        
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@건의 상품이 배송중입니다", [Common info].user.mCountdelivery]];
        
        [attributeString addAttribute:NSForegroundColorAttributeName
                                value:[UIColor colorWithRed:255/255.0 green:156/255.0 blue:0/0.0 alpha:1.0]
                                range:NSMakeRange(0, [Common info].user.mCountdelivery.length+1)];
        
        [attributeString addAttribute:NSUnderlineStyleAttributeName
                                value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                range:NSMakeRange(0, [Common info].user.mCountdelivery.length+1)];
        
        self.lbDelivery.attributedText = attributeString;

    }
}

- (IBAction)didTouchBanner:(UIButton *)sender {
    
    [[Common info].main_controller didTouchCloseButton];
    [[Common info].main_controller didTouchCellWithData:self.content];
}

- (IBAction)didTouchSettingButton:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didTouchSettingButton)]) {
        [self.delegate didTouchSettingButton];
    }
}

- (IBAction)didTouchCloseButton:(UIButton *)sender {
    
    if([self.delegate respondsToSelector:@selector(didTouchCloseButton)]) {
        [self.delegate didTouchCloseButton];
    }
}


//3100~3105
- (IBAction)didTouchMenuCategoryButton:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didTouchMenuCategory:)]) {
        [self.delegate didTouchMenuCategory:sender.tag - 3100];
    }
}

- (IBAction)didTouchLogoutButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didTouchLogoutButton)]) {
        [self.delegate didTouchLogoutButton];
    }
}


@end
