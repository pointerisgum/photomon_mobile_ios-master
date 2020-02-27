//
//  MonthlyOrderBookCount.h
//  PHOTOMON
//
//  Created by 곽세욱 on 09/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthlyBaby.h"

NS_ASSUME_NONNULL_BEGIN

@interface MonthlyOrderBookCount : UIViewController
@property (strong, nonatomic) IBOutlet UIView *addPriceView;
@property (strong, nonatomic) IBOutlet UILabel *addPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *orderCountCollectionView;
@property (strong, nonatomic) IBOutlet UIButton *orderCountButton;
@property (strong, nonatomic) id<MonthlySelectOrderCountDoneDelegate> delegate;

@property (assign) int addedOrderCount;

- (void)setData:(nonnull id<MonthlySelectOrderCountDoneDelegate>)delegate;
- (IBAction)selectCount:(id)sender;
- (IBAction)order:(id)sender;

@end

NS_ASSUME_NONNULL_END
