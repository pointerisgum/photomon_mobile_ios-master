#import "PHAssetUtility.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation PHAssetUtility

// thread safe singleton
+ (PHAssetUtility *)info {
    static dispatch_once_t pred;
    static PHAssetUtility *phassetutility_info = nil;
    dispatch_once(&pred, ^{
        phassetutility_info = [[PHAssetUtility alloc] init];
    });
    return phassetutility_info;
}

- (id)init {
    if (self = [super init]) {
	}
    return self;
}

// HEIF Fix
- (long)getFileSize:(PHAsset *)asset {
	if(asset == nil ) return 0;

	__block long filesize = 0; 

	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
	options.synchronous = YES;

	options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

	@autoreleasepool {
		[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
			filesize = [imageData length];
		}];
	}

#ifdef PHOTOMON_TESTMODE
	NSAssert(filesize > 0, @"error : filesize <= 0");
#endif

	return filesize;
}

- (UIImageOrientation)getOrientation:(PHAsset *)asset {
	__block UIImageOrientation ph_orientation = UIImageOrientationUp;

	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
	options.synchronous = YES;

	@autoreleasepool {
		[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
			ph_orientation = orientation;
		}];
	}

	return ph_orientation;
}

- (int)getPixelWidth:(PHAsset *)asset {
	if(asset == nil ) return 0;

#ifdef PHOTOMON_TESTMODE
	NSAssert(asset.pixelWidth > 0, @"error : asset.pixelWidth <= 0");
#endif
	return (int)asset.pixelWidth;
}

- (int)getPixelHeight:(PHAsset *)asset {
	if(asset == nil ) return 0;

#ifdef PHOTOMON_TESTMODE
	NSAssert(asset.pixelHeight > 0, @"error : asset.pixelHeight <= 0");
#endif
	return (int)asset.pixelHeight;
}

- (NSURL *)getUrl:(PHAsset *)asset {
	__block NSURL* ret_url = nil;

	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
    options.synchronous = YES;

	@autoreleasepool {
		[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
			if ([info objectForKey:@"PHImageFileURLKey"]) {
				ret_url = [info objectForKey:@"PHImageFileURLKey"];
			}                                            
		}];
	}

#ifdef PHOTOMON_TESTMODE
	NSAssert(ret_url != nil && ![ret_url isEqualToString:@""], @"error : PHImageFileURLKey is empty);
#endif

	return ret_url;
}

- (NSString *)getFileName:(PHAsset *)asset {
	NSURL* url = [self getUrl:asset];

#ifdef PHOTOMON_TESTMODE
	NSAssert(url != nil && ![url isEqualToString:@""], @"error : PHImageFileURLKey is empty);
#endif

	return [url.absoluteString lastPathComponent];
}

- (NSMutableArray*)getUserAlbums {
    __block NSMutableArray *group_array = [[NSMutableArray alloc] init];

	PHFetchOptions *userAlbumsOptions = [PHFetchOptions new];
	PHFetchResult *userAlbums;

	//userAlbumsOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
	//PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:userAlbumsOptions];
	//PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:userAlbumsOptions];

	/*
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumImported options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:userAlbumsOptions]; // 나의 사진 스트림
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:userAlbumsOptions]; // X
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumGeneric options:userAlbumsOptions]; // 사진이 0 장 이상인 "나의 사진 스트림 + 쵝근 가져온 항목" 을 보여줌
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumTimelapses options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumAllHidden options:userAlbumsOptions]; // 사진이 0 장 이상인 "나의 사진 스트림 + 쵝근 가져온 항목" 을 보여줌
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSlomoVideos options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:userAlbumsOptions]; // 모든 사진
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:userAlbumsOptions];
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:userAlbumsOptions];
	*/

	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:userAlbumsOptions];
	[userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
		PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
		fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];

		// iOS 11 에서 최근 가져온 항목 보여주지 않음
		/*
		if([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 && collection.assetCollectionSubtype == 5) 
			return;
		*/
		// iOS 11 에서 Live Photo 항목 보여주지 않음
		if([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 && collection.assetCollectionSubtype == 213) 
			return;

		if([[PHAsset fetchKeyAssetsInAssetCollection:collection options:fetchOptions] count] > 0) {
			[group_array addObject:collection];
		}
		/*
		NSLog(@"-------------------------------------------------------");
		NSLog(@"collection.assetCollectionSubtype : %ld", collection.assetCollectionSubtype);
		NSLog(@"collection.localizedTitle : %@", collection.localizedTitle);
		*/
    }];

	/*
		고속 연사 촬영 : 207
		최근 추가된 항목 : 206
		즐겨찾는 사진 : 203
		스크린샷 : 211
		타임랩스 : 204
		파노라마 : 201
		모든 사진 : 209
		비디오 : 202
		최근 삭제된 항목 : 1000000201
		가져림 : 205
		셀카 : 210
		슬로 모션 : 208	
	*/
	userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:userAlbumsOptions];
	[userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
		PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
		fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
		if([[PHAsset fetchKeyAssetsInAssetCollection:collection options:fetchOptions] count] > 0) {
			if(!(collection.assetCollectionSubtype == 207 || collection.assetCollectionSubtype == 204 || collection.assetCollectionSubtype == 201 || collection.assetCollectionSubtype == 202 || collection.assetCollectionSubtype == 1000000201 || collection.assetCollectionSubtype == 205 || collection.assetCollectionSubtype == 210 || collection.assetCollectionSubtype == 208)) {
				// iOS 11 에서 최근 가져온 항목 보여주지 않음
				/*
				if([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 && collection.assetCollectionSubtype == 5) 
					return;
				*/
				// iOS 11 에서 Live Photo 항목 보여주지 않음
				if([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0 && collection.assetCollectionSubtype == 213) 
					return;

				if([[PHAsset fetchKeyAssetsInAssetCollection:collection options:fetchOptions] count] > 0) {
					if(collection.assetCollectionSubtype == 209)
						[group_array insertObject:collection atIndex:0];
					else
						[group_array addObject:collection];
				}
				/*
				NSLog(@"-------------------------------------------------------");
				NSLog(@"collection.assetCollectionSubtype : %ld", collection.assetCollectionSubtype);
				NSLog(@"collection.localizedTitle : %@", collection.localizedTitle);
				*/
			}
		}
    }];

	return(group_array);
}

- (void)getThumbnailInfoForCollection:(PHAssetCollection *)collection withImageView:(UIImageView *)imageview withNameLabel:(UILabel *)namelabel withCountLabel:(UILabel *)countlabel {
	PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
	fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
	fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
	PHFetchResult *fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:collection options:fetchOptions];
	PHAsset *asset = [fetchResult firstObject];

	[self getThumbnailInfoForAsset:asset withImageView:imageview];

	if(namelabel != nil)
	    namelabel.text = collection.localizedTitle;
	/*
	if(countlabel != nil) 
	    countlabel.text = [NSString stringWithFormat:@"%ld", (long)[collection estimatedAssetCount]];
	*/
	if(countlabel != nil) 
	    countlabel.text = [NSString stringWithFormat:@"%ld", (long)[[PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions] count]];
}

// iOS 11 에서 사진 선택 썸네일 이미지 리스트 로딩이 굉장히 느리고 크래시나는 문제 수정
- (void)getThumbnailInfoForAsset:(PHAsset *)asset withImageView:(UIImageView *)imageview {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact; // PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsResizeModeExact
    //options.resizeMode = PHImageRequestOptionsResizeModeFast; // PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsResizeModeExact
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; // PHImageRequestOptionsDeliveryModeFastFormat, PHImageRequestOptionsDeliveryModeOpportunistic, PHImageRequestOptionsDeliveryModeHighQualityFormat 
    //options.version = PHImageRequestOptionsVersionUnadjusted;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat dimension = 78.0f;
    CGSize size = CGSizeMake(dimension*scale, dimension*scale);
    if(asset != nil && imageview != nil) {
        @autoreleasepool {
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
#ifdef PHOTOMON_TESTMODE
                NSAssert(result != nil, @"error : result is nil");
#endif
                imageview.image = result;
            }];
        }
    }
}

- (UIImage *)getThumbnailUIImage:(PHAsset *)asset {
	__block UIImage *ret;

	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
	options.synchronous = YES;
	options.resizeMode = PHImageRequestOptionsResizeModeExact;

	CGFloat scale = [UIScreen mainScreen].scale;
	CGFloat dimension = 78.0f;
	CGSize size = CGSizeMake(dimension*scale, dimension*scale);

	@autoreleasepool {
		[[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
			ret = [result copy];
		}];
	}

#ifdef PHOTOMON_TESTMODE
	NSAssert(ret != nil, @"error : ret is nil");
#endif

	return ret;
}

- (NSData *)getImageDataForAsset:(PHAsset*)asset {
	__block NSData *org_data;

	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
	options.synchronous = YES;


    // HEIF Fix
    if([[PHAssetUtility info] isHEIF:asset]) {
        org_data = [[[PHAssetUtility info] getJpegImageDataForAsset:asset] copy];
    }
	else {
		@autoreleasepool {
			[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
				org_data = [imageData copy];
			}];
		}
	}

#ifdef PHOTOMON_TESTMODE
	NSAssert(org_data != nil, @"error : org_data is nil");
#endif

	return org_data;
}

// HEIF Fix
- (NSData *)getFastJpegImageDataForAsset:(PHAsset*)asset {
	if(asset == nil ) return nil;
	
	__block NSData *org_data;

	PHImageRequestOptions *inoptions = [[PHImageRequestOptions alloc] init];
    inoptions.networkAccessAllowed = YES;
    inoptions.synchronous = YES;
	inoptions.resizeMode = PHImageRequestOptionsResizeModeFast; // PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsResizeModeExact
    inoptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; // PHImageRequestOptionsDeliveryModeFastFormat, PHImageRequestOptionsDeliveryModeOpportunistic, PHImageRequestOptionsDeliveryModeHighQualityFormat 

	@autoreleasepool {
		[[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:inoptions resultHandler:^void(UIImage *image, NSDictionary *info) {
			org_data = [[NSData dataWithData:UIImageJPEGRepresentation(image, 1)] copy];
		}];
	}

	return org_data;
}

// HEIF Fix
- (NSData *)getFastExactJpegImageDataForAsset:(PHAsset*)asset {
	if(asset == nil ) return nil;
	
	__block NSData *org_data;

	PHImageRequestOptions *inoptions = [[PHImageRequestOptions alloc] init];
    inoptions.networkAccessAllowed = YES;
    inoptions.synchronous = YES;
	inoptions.resizeMode = PHImageRequestOptionsResizeModeExact; // PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsResizeModeExact
    inoptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; // PHImageRequestOptionsDeliveryModeFastFormat, PHImageRequestOptionsDeliveryModeOpportunistic, PHImageRequestOptionsDeliveryModeHighQualityFormat 

	@autoreleasepool {
		[[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:inoptions resultHandler:^void(UIImage *image, NSDictionary *info) {
			org_data = [[NSData dataWithData:UIImageJPEGRepresentation(image, 1)] copy];
		}];
	}

	return org_data;
}

// HEIF Fix
- (NSData *)getJpegImageDataForAsset:(PHAsset*)asset {
	if(asset == nil ) return nil;

	__block NSData *jpgData = nil;
	__block BOOL bCompleted = FALSE;   

	// 2017.11.16 : SJYANG :  @autoreleasepool 추가
	[asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
		if (contentEditingInput.fullSizeImageURL) {
			@autoreleasepool 
			{
				CIImage *ciImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
				CIContext *context = [CIContext context];
				jpgData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
			}
		}
		bCompleted = TRUE;
	}];
	while(!bCompleted) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}

	return jpgData;
}

// Failed to load image data for asset PHAsset with format 9998 관련하
// 여 해당 에러가 나오기까지 딜레이가 심해서 바로 fileSize 키를 읽어옴
// TODO : 생각해볼 것 : 사실 어느정도 getFileSize 와 맞추려면 size 에 1.10 or 1.11 을 곱해줘야 함
- (long)getFastFileSize:(PHAsset *)asset {
	if(asset == nil ) return 0;

	long size = 0;

	@try {
		NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
		size = [[(PHAssetResource*)resources[0] valueForKey:@"fileSize"] integerValue];
	}
	@catch(NSException *exception) {}

	return size;
}

- (BOOL)isHEIF:(PHAsset *)asset {
	__block BOOL result = NO;

    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) 
		return TRUE;

    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
		NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
		[resourceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			PHAssetResource *resource = obj;
			NSString *UTI = resource.uniformTypeIdentifier;
			if ([UTI isEqualToString:@"public.heif"] || [UTI isEqualToString:@"public.heic"]) {
				result = YES;
				*stop = YES;
			}
		}];
	} else {
		NSString *UTI = [asset valueForKey:@"uniformTypeIdentifier"];
		result = [UTI isEqualToString:@"public.heif"] || [UTI isEqualToString:@"public.heic"];
	}

	return result;
}

@end
