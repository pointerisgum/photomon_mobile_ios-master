//
//  ContactusItem.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 10..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "ContactusItem.h"

@implementation ContactusItem

- (id)init {
    if (self = [super init]) {
        _category = @"";
        _subject = @"";
        _content = @"";
        _security = @"";
        _userID = @"";
        _userName = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end

@implementation ContactusListItem

- (id)init {
    if (self = [super init]) {
        _idx = @"";
        _subject = @"";
        _writedate = @"";
        _security = @"";
        _userID = @"";
        _userName = @"";
        _re_step = @"";
        _body = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
