//
//  SubCell.h
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SubCell : UICollectionViewCell

- (void)setSubCell:(BOOL)isNewDesign thumb:(NSString *)urlString title:(NSString *)titleString subTitle:(NSString *)subTitle;

@end

NS_ASSUME_NONNULL_END
