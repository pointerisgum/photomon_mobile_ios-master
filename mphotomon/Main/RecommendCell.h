//
//  RecommendCell.h
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainContents.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecommendCellDelegate <NSObject>

- (void)didTouchCellWithData:(Contents *)contents;

@end


@interface RecommendCell : UICollectionViewCell

- (void)setRecommentList:(NSArray *)list self:(id<RecommendCellDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
