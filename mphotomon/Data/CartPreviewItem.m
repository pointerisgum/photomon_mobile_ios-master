//
//  CartPreviewItem.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 15..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "CartPreviewItem.h"

@implementation CartPreviewItem

- (id)init {
    if (self = [super init]) {
        _idx = @"";
        _previewImg = @"";
        _optionSTR = @"";
        _oriFileName = @"";
        _previewSize = @"";
        _previewCnt = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
