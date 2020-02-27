//
//  ListCell.h
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainContents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListCell : UICollectionViewCell

- (void)setListCellWithContents:(Contents *)contents index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
