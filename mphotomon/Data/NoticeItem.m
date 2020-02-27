//
//  NoticeItem.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "NoticeItem.h"

@implementation NoticeItem

- (id)init {
    if (self = [super init]) {
        _idx = @"";
        _title = @"";
        _readnum = @"";
        _category = @"";
        _date = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
