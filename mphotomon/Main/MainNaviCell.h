//
//  MainNaviCell.h
//  PHOTOMON
//
//  Created by 김민아 on 14/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainNaviCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *indicatorView;

@end

NS_ASSUME_NONNULL_END
