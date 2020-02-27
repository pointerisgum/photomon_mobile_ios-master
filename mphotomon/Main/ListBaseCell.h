//
//  ListBaseCell.h
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainContents.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ListBaseCellDelegate <NSObject>

- (void)didTouchCellWithData:(Contents *)contents;

@end

@interface ListBaseCell : UICollectionViewCell

- (void)setListBaseCellWithDataList:(NSArray *)dataList self:(id<ListBaseCellDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
