//
//  IDPhotosProduct.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "IDPhotos.h"
#import "Common.h"

@implementation IDPhotos

- (id)init {
    if (self = [super init]) {
		_upload_url = @"";
        _idphotos_product = [[IDPhotosProduct alloc] init];
        [self clear];
    }
    return self;
}

- (void)dealloc {
}

- (void)clear {
}

@end
