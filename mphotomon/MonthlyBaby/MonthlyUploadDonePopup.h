//
//  MonthlyUploadDonePopup.h
//  PHOTOMON
//
//  Created by 곽세욱 on 07/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthlyBaby.h"

NS_ASSUME_NONNULL_BEGIN

@interface MonthlyUploadDonePopup : UIViewController

@property (assign) int uploadCount;
@property (strong, nonatomic) id<MonthlyAfterUploadActionDelegate> delegate;
@property (weak, nonatomic) UIViewController *rootView;

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *makeButton;
@property (strong, nonatomic) IBOutlet UILabel *totalUploadCountLabel;;
@property (strong, nonatomic) IBOutlet UILabel *dueDateYearLabel;
@property (strong, nonatomic) IBOutlet UILabel *dueDateMonthLabel;
@property (strong, nonatomic) IBOutlet UILabel *dueDateDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentUploadCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *diffCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *diffDiscriptionLabel;

@property (strong, nonatomic) IBOutlet UIView *popupView;

- (void)setData:(int)uploadCount delegate:(nonnull id<MonthlyAfterUploadActionDelegate>)delegate rootView:(UIViewController *)rootView;

- (IBAction)upload:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)order:(id)sender;
- (IBAction)close:(id)sender;

@end

NS_ASSUME_NONNULL_END
