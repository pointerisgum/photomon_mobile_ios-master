//
//  PhotoPool.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PhotoPool.h"
#import "Common.h"
#import "PHAssetUtility.h"

@implementation PrintOption

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)clear {
    _size_type = @"";
    _full_type = @"";
    _border_type = @"";
    _light_type = @"";
    _revise_type = @"";
    _trim_info = @"";
    _order_count = @"";
}

@end


@implementation Photo

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)dealloc {
}

- (void)clear {
    _asset = nil;
    _print_option = nil;
}

@end


@implementation PhotoPool

- (id)init {
    if (self = [super init]) {
        _sel_photos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
}

- (Photo *)getPhoto:(PHAsset *)asset {
    for (Photo *photo in _sel_photos) {
        if ([photo.asset isEqual:asset]) {
            return photo;
        }
    }
    return nil;
}

- (BOOL)isSelected:(PHAsset *)asset {
    Photo *photo = [self getPhoto:asset];
    return (photo != nil);
}

// 카메라에 필터를 적용한 사진의 경우는 representation.dimensions에 원본사진의 해상도가 전달된다. (실제는 작은 해상도)
// 정확한 해상도를 얻기 위해서는 getDimensions를 통해 얻어야 한다. (트리밍 정보 계산시에는 getDimension 사용)
// 그러나, 전체 선택시 속도의 차이가 너무 커서 그냥 사용한다.
- (BOOL)isPrintable:(PHAsset *)asset {
	if(asset == nil) return FALSE;	
	if(asset.mediaType != PHAssetMediaTypeImage) return FALSE;
	//if(asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return FALSE;
	if(asset.mediaSubtypes == PHAssetMediaSubtypeVideoTimelapse) return FALSE;
	

    if(![[PHAssetUtility info] isHEIF:asset]) {
		int width = [[PHAssetUtility info] getPixelWidth:asset];
		int height = [[PHAssetUtility info] getPixelHeight:asset];
		NSURL* url = [[PHAssetUtility info] getUrl:asset];
		long size = [[PHAssetUtility info] getFastFileSize:asset];

		NSLog(@"width : %d / height : %d / size : %ld", width, height, size);

		// TODO : 테스트 필요
		if ([Common info].photobook.product_type == PRODUCT_BABY) {
			if (MAX(width, height) >= 1000 && MIN(width, height) >= 1000 && size <= 10000000) {

				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_CARD) {
			if (MAX(width, height) >= 740 && MIN(width, height) >= 740 && size <= 10000000) {

				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		// 마그넷 : 400px 이상되는 사진만 처리하도록 수정
		else if ([Common info].photobook.product_type == PRODUCT_MAGNET) {
			if (MAX(width, height) >= 400 && MIN(width, height) >= 400 && size <= 10000000) {

				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else {
			if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
				if ([Common info].photobook.product_type == PRODUCT_MONTHLYBABY) {
					return TRUE;
				}
				
				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		return FALSE;
	}
	else {
		if(asset == nil)
			return FALSE;

		// iOS 11 에서 사진 선택 썸네일 이미지 리스트 로딩이 굉장히 느리고 크래시나는 문제 수정
		int width = [[PHAssetUtility info] getPixelWidth:asset];
		int height = [[PHAssetUtility info] getPixelHeight:asset];

		NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
		NSString *filename = ((PHAssetResource*)resources[0]).originalFilename;
		// Failed to load image data for asset PHAsset with format 9998 관련하
		// 여 해당 에러가 나오기까지 딜레이가 심해서 바로 fileSize 키를 읽어옴
		//long size = [[PHAssetUtility info] getFileSize:asset];
		long size = [[PHAssetUtility info] getFastFileSize:asset];

		NSLog(@"width : %d / height : %d / size : %ld", width, height, size);

		// TODO : 테스트 필요
		if ([Common info].photobook.product_type == PRODUCT_BABY) {
			if (MAX(width, height) >= 1000 && MIN(width, height) >= 1000 && size <= 10000000) {

				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_CARD) {
			if (MAX(width, height) >= 740 && MIN(width, height) >= 740 && size <= 10000000) {

				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else {
			if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
				if ([Common info].photobook.product_type == PRODUCT_MONTHLYBABY) {
					return TRUE;
				}
				
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		return FALSE;
	}
}

- (void)add:(PHAsset *)asset Param:(NSString *)param {
    Photo *photo= [[Photo alloc] init];
    photo.asset = asset;
    [_sel_photos addObject:photo];
}

- (void)remove:(PHAsset *)asset {
    Photo *photo = [self getPhoto:asset];
    if (photo) {
        photo.print_option = nil;
        [_sel_photos removeObject:photo];
    }
}

- (void)removeAtIndex:(NSUInteger)index {
    if (index < _sel_photos.count) {
        [_sel_photos removeObjectAtIndex:index];
    }
}

- (void)removeAll {
    [_sel_photos removeAllObjects];
}

- (NSUInteger)totalCount {
    return _sel_photos.count;
}

@end
