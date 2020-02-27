//
//  MonthlyConfirmOrderPopup.h
//  PHOTOMON
//
//  Created by 곽세욱 on 09/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthlyBaby.h"

NS_ASSUME_NONNULL_BEGIN

@interface MonthlyConfirmOrderPopup : UIViewController < NSURLConnectionDataDelegate >
@property (strong, nonatomic) IBOutlet UILabel *uploadCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *markDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *themeLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderingTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addProductLabel;
@property (strong, nonatomic) IBOutlet UILabel *divisionLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderBookCountLabel;

@property (strong, nonatomic) id<MonthlyConfirmOrderDelegate> delegate;

- (void) setData:(nonnull id<MonthlyConfirmOrderDelegate>) delegate;

- (IBAction)order:(id)sender;
- (IBAction)close:(id)sender;

@end

NS_ASSUME_NONNULL_END
