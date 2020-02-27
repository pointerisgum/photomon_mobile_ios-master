//
//  MonthlyAddProductPopup.h
//  PHOTOMON
//
//  Created by 곽세욱 on 09/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthlyBaby.h"

NS_ASSUME_NONNULL_BEGIN

@interface MonthlyAddProductPopup : UIViewController
@property (strong, nonatomic) id<MonthlySelectAddProductDoneDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *noThanksButton;
@property (strong, nonatomic) IBOutlet UICollectionView *thumbnailListView;
@property (strong, nonatomic) IBOutlet UICollectionView *optionListView;


@property (strong, nonatomic) UIImage *checkOnImage;
@property (strong, nonatomic) UIImage *checkOffImage;
@property (strong, nonatomic) NSMutableArray *selectedList;

@property (assign) int thumbIndex;

- (IBAction)noThanks:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)close:(id)sender;
- (IBAction)onPrev:(id)sender;
- (IBAction)onNext:(id)sender;

- (void)setData:(id<MonthlySelectAddProductDoneDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
