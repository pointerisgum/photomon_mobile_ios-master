//
//  MainTapBar.h
//  PHOTOMON
//
//  Created by 김민아 on 14/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MainTabBarDelegate <NSObject>

- (void)didTouchTabBarWithNaviIndex:(int)index;

@end

@interface MainTabBar : UIView

- (instancetype)initWithTargetFrame:(CGRect)frame naviIndex:(int)index delegate:(id<MainTabBarDelegate>)delegate;
- (instancetype)initWithTargetFrame:(CGRect)frame naviIndex:(int)index delegate:(id<MainTabBarDelegate>)delegate naviComments:(NSMutableArray *)comments;
- (void)updateCollectionViewOffset;
- (CGPoint)collectionViewOffset;

@end

NS_ASSUME_NONNULL_END
