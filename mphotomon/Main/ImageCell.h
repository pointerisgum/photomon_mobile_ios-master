//
//  ImageCell.h
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCell : UICollectionViewCell

- (void)setTitle:(NSString *)title image:(NSString *)urlString;
- (void)setImage:(NSString *)imageName;
@end

NS_ASSUME_NONNULL_END
