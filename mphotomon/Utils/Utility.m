//
//  Utility.m
//  PHOTOMON
//
//  Created by 안영건 on 06/05/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "Common.h"

@implementation Utility

+ (void) goStorageViaViewController:(UIViewController *) viewController {
    if (viewController == [Common info].card_root_controller)
        [[Common info].card_root_controller goStorage];
    else if (viewController == [Common info].card_product_root_controller)
        [[Common info].card_product_root_controller goStorage];
    else if (viewController == [Common info].photobook_root_controller)
        [[Common info].photobook_root_controller goStorage];
    else if (viewController == [Common info].photobook_product_root_controller)
        [[Common info].photobook_product_root_controller goStorage];
    else if (viewController == [Common info].goods_root_controller && [Common info].fanbook_root_controller == nil
            && [Common info].poster_root_controller == nil && [Common info].paperslogan_root_controller == nil) {
        [[Common info].goods_root_controller goStorage];
    }
    else {
        if ([Common info].fanbook_root_controller != nil) {
            [[Common info].fanbook_root_controller goStorage];
        } else if ([Common info].poster_root_controller != nil) {
            [[Common info].poster_root_controller goStorage];
        } else if ([Common info].paperslogan_root_controller != nil) {
            [[Common info].paperslogan_root_controller goStorage];
        }
    }
}

@end
