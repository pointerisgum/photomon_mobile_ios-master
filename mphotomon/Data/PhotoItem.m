//
//  PhotoItem.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 1..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PhotoItem.h"

@implementation PhotoItem

- (id)init {
    if (self = [super init]) {
        _asset = nil;
        _url = @"";
        _filename = @"";
        _thumbname = @"";
        _thumb = nil;
//        _order_num = @"";
        _order_count = @"1";
        _size_type = @"3.5x5"; // TODO : 사진인화 3x5
        _light_type = @"유광";
        _full_type = @"이미지풀";
        _border_type = @"무테";
        _revise_type = @"밝기보정";
        _trim_info = @"null^";
        _scroll_offset = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (PhotoItem *)getUploadTypePhotoItem:(int)idx {
    PhotoItem *upload_photo = [[PhotoItem alloc] init];
    upload_photo.asset = _asset;
    upload_photo.url = _url;
    upload_photo.filename = _filename; // 속도 문제로 최대한 늦게 만든다. 업로드 직전까지만 할당하면 된다.
    upload_photo.thumb = _thumb; // 속도 문제로 최대한 늦게 만든다. 업로드 직전까지만 할당하면 된다.
    upload_photo.thumbname = [NSString stringWithFormat:@"thumbfile_%d.jpg", idx];
    upload_photo.order_count = [NSString stringWithFormat:@"%@^", _order_count];
    upload_photo.size_type = [NSString stringWithFormat:@"%@^", _size_type];
    upload_photo.light_type = [_light_type isEqualToString:@"유광"] ? @"L" : @"N";
    upload_photo.full_type = [_full_type isEqualToString:@"인화지풀"] ? @"P" : @"I";
    upload_photo.border_type = [_border_type isEqualToString:@"무테"] ? @"M" : @"B";
    upload_photo.revise_type = [_revise_type isEqualToString:@"밝기보정"] ? @"Y" : @"N";
    upload_photo.trim_info = _trim_info;
/*
    NSLog(@"> .......................................uploadfile prop.");
    NSLog(@"> filename: %@", upload_photo.filename);
    NSLog(@"> thumb: %@", upload_photo.thumb);
    NSLog(@"> thumbname: %@", upload_photo.thumbname);
    NSLog(@"> order_num: %@", upload_photo.order_num);
    NSLog(@"> order_count: %@", upload_photo.order_count);
    NSLog(@"> size_type: %@", upload_photo.size_type);
    NSLog(@"> full_type: %@", upload_photo.full_type);
    NSLog(@"> border_type: %@", upload_photo.border_type);
    NSLog(@"> light_type: %@", upload_photo.light_type);
    NSLog(@"> revise_type: %@", upload_photo.revise_type);
    NSLog(@"> trim_info: %@", upload_photo.trim_info);
*/    
    return upload_photo;
}


@end
