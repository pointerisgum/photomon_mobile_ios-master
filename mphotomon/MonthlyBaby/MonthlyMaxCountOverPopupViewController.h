//
//  MonthlyMaxCountOverPopupViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 08/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthlyBaby.h"

NS_ASSUME_NONNULL_BEGIN

@interface MonthlyMaxCountOverPopupViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *totalUploadCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *maxUploadCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *optionMainLabel;
@property (strong, nonatomic) IBOutlet UILabel *optionSubLabel;
@property (strong, nonatomic) IBOutlet UIButton *optionButton;

@property (assign) int selectOptionIdx;

- (void)updateOptionStr;

- (IBAction)selectOption:(id)sender;
- (IBAction)confirm:(id)sender;
- (IBAction)close:(id)sender;
@end

NS_ASSUME_NONNULL_END
