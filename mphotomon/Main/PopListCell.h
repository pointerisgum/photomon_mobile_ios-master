//
//  PopListCell.h
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainContents.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PopListCellDelegate <NSObject>

- (void)didTouchCellWithData:(Contents *)contents;

@end

@interface PopListCell : UICollectionViewCell

- (void)setPopListWithData:(Ranking *)data self:(id<PopListCellDelegate>)delegate;
- (void)moveTap:(NSInteger)tap;

@end

NS_ASSUME_NONNULL_END
