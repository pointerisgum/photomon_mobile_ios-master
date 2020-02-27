//
//  PhotoLayerView.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 13..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface PhotoLayerView : UIView

@property (strong, nonatomic) UIImageView *photoView;

- (BOOL)setLayerInfo:(Layer *)layer BaseFolder:(NSString *)base_folder IsEdit:(BOOL)is_edit;

@end
