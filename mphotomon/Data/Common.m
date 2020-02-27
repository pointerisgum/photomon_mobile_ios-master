//
//  Common.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "Common.h"
#import "SelectAlbumViewController.h"
#import "PHAssetUtility.h"
#import "../Library/KeyChain/SAMKeychain.h"
#import "../Library/KeyChain/SAMKeychainQuery.h"
#import "GoodsFanbookDesignViewController.h"
#import "GoodsPaperSloganDesignViewController.h"
#import "GoodsProductViewController.h"
#import "PhotoPositionSelectController.h"

@implementation Common

// thread safe singleton
+ (Common *)info {
    static dispatch_once_t pred;
    static Common *common_info = nil;
    dispatch_once(&pred, ^{
        common_info = [[Common alloc] init];
    });
    return common_info;
}

- (id)init {
    if (self = [super init]) {
        _main_controller = nil;
        _photobook_product_root_controller = nil;
        _photobook_root_controller = nil;
        _card_product_root_controller = nil;
        _card_root_controller = nil;
        _gift_root_controller = nil;
        _baby_root_controller = nil;

        _connection = [[Connection alloc] init];
        _login_info = [[LoginUserInfo alloc] init];

        _photoprint = [[Photoprint alloc] init];

        _photo_pool = [[PhotoPool alloc] init];
        _layout_pool = [[LayoutPool alloc] init];
        _background_pool = [[BackgroundPool alloc] init];		
		_photobook = [[Photobook alloc] init];
        _photobook_product = [[PhotobookProduct alloc] init];
        _photobook_theme = [[PhotobookTheme alloc] init];

        _idphotos = [[IDPhotos alloc] init];

        _is_navi_double_back = NO;
		_device_uuid = [self getDeviceUUID];

		_conn_link_init = NO;
		_dynamic_link_init = NO;
        
        _nonMemberName = @"";
        _nonMemberEmail = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)alert:(id)sender Msg:(NSString *)msg {
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [alert dismissViewControllerAnimated:YES completion:nil];
//    }];
//    [alert addAction:ok];
//    [sender presentViewController:alert animated:YES completion:nil];
    
    [AlertView ShowAlertTitle:msg subTitle:@"" completion:nil];
}

- (void)alert:(id)sender Title:(NSString*)tle Msg:(NSString *)msg completion:(void(^)(void))completion {
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //        [alert dismissViewControllerAnimated:YES completion:nil];
    //    }];
    //    [alert addAction:ok];
    //    [sender presentViewController:alert animated:YES completion:nil];
    
    [AlertView ShowAlertTitle:tle subTitle:msg completion:completion];
}

- (void)alert:(id)sender Title:(NSString*)tle Msg:(NSString *)msg okCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))cancelCompletion okTitle:(NSString *)ok cancelTitle:(NSString *)cancel {

    [AlertView ShowAlertWithCancelTitle:tle subTitle:msg okCompletion:completion cancelCompletion:cancelCompletion okButton:ok cancelButton:cancel];
}
    

// 딥링크 관련 코드
- (UIImageView *)showDeepLinkLaunchScreen:(UIView *)refview {
	/*
	UIImage* image;
	if([Common info].inner_deeplink == YES)
		image = [UIImage imageNamed:@"transparent.png"];
	else
		image = [UIImage imageNamed:@"launch_screen.png"];
	int frame_height = refview.bounds.size.height;
	int frame_width = refview.bounds.size.height / image.size.height * image.size.width;
	UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
	imageview.frame = CGRectMake(0 - (image.size.width - frame_width) / 4, 0, frame_width, frame_height);

	[imageview setContentMode:UIViewContentModeScaleAspectFit]; // UIViewContentModeScaleToFill

	[refview addSubview:imageview];
	[refview bringSubviewToFront:imageview];

	return imageview;
	*/
	if([Common info].inner_deeplink == YES) 
		return nil;
	else {
		UIImage* image = [UIImage imageNamed:@"launch_screen.png"];
		int frame_height = refview.bounds.size.height;
		int frame_width = refview.bounds.size.height / image.size.height * image.size.width;
		UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
		imageview.frame = CGRectMake(0 - (image.size.width - frame_width) / 4, 0, frame_width, frame_height);

		[imageview setContentMode:UIViewContentModeScaleAspectFit]; // UIViewContentModeScaleToFill

		[refview addSubview:imageview];
		[refview bringSubviewToFront:imageview];

		return imageview;
	}
}

- (NSData *)downloadSyncWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:15.0f];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"** download error: %@", error);
        return nil;
    }
    return data;
}

- (void)downloadAsyncWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *imageData))completionBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   completionBlock(YES, data);
                               } else {
                                   NSLog(@"** download error: %@", error);
                                   completionBlock(NO, nil);
                               }
                           }];
}

- (BOOL)downloadImage:(NSURL *)url ToFile:(NSString *)pathname {
    if ([self isFileExist:pathname]) {
        return TRUE;
    }
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    if (imageData != nil) {
        return [imageData writeToFile:pathname atomically:YES];
    }
    return FALSE;
}
//로컬이미지를 기존 로직에 맞춰 별도 경로에 이미지를 저장
- (BOOL)storeImage:(NSString *)imgnamed ToFile:(NSString *)pathname {
    if ([self isFileExist:pathname]) {
        return TRUE;
    }
    UIImage *img = [UIImage imageNamed:imgnamed];
    NSData *imageData = UIImagePNGRepresentation(img);
    if (imageData != nil) {
        return [imageData writeToFile:pathname atomically:YES];
    }
    return FALSE;
}

// 신규 달력 포맷
- (BOOL)downloadFile:(NSURL *)url ToFile:(NSString *)pathname {
    if ([self isFileExist:pathname]) {
        return TRUE;
    }
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    if (imageData != nil) {
        return [imageData writeToFile:pathname atomically:YES];
    }
    return FALSE;
}

- (BOOL)isFileExist:(NSString *)pathname {
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    return [fileMgr fileExistsAtPath:pathname];
}

- (BOOL)isDirExist:(NSString *)path {
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileMgr fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        return YES;
    }
    return NO;
}

- (BOOL)removeAllFilesInDocument {
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    NSString *docPath = [[Common info] documentPath];

    BOOL result = YES;
    NSError *error = nil;
    for (NSString *content in [fileMgr contentsOfDirectoryAtPath:docPath error:&error]) {
        NSString *del_pathname = [NSString stringWithFormat:@"%@/%@", docPath, content];

        BOOL success = [fileMgr removeItemAtPath:del_pathname error:&error];
        if (!success || error) {
            result = NO;
        }
    }
    return result;
}

+ (unsigned long long)sizeOfFiles:(NSString *)pathname {

    unsigned long long int folderSize = 0;

    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathname error:nil];
    for (NSString *file in contents) {

        NSString *subpath = [pathname stringByAppendingPathComponent:file];
        //NSLog(@"subpath:%@", subpath);

        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:subpath isDirectory:&isDir];
        if (isDir) {
            folderSize += [self sizeOfFiles:subpath];
        }
        else {
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:subpath error:nil];
            folderSize += [fileAttributes fileSize];
        }
    }
    return folderSize;
}

- (NSString *)sizeOfDirectory:(NSString *)path {
    unsigned long long int folderSize = [Common sizeOfFiles:path];
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

- (NSString *)extractFilenameFromUrl:(NSURL *)url {
    return [self extractFilename:url.path];
}

- (NSString *)extractFilename:(NSString *)path {
    NSString *filename = [path lastPathComponent];
    return filename;
}

- (void)setUserDefaultKey:(NSString *)key Value:(NSString *)value {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

- (NSString *)getUserDefaultKey:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefault stringForKey:key];
    if (value != nil && value.length > 0) {
        return value;
    }
    return @"";
}

- (void)setGuideUserDefault:(NSString *)key Value:(NSString *)value {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

- (BOOL)checkGuideUserDefault:(NSString *)key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefault stringForKey:key];
    if (value == nil || [value isEqualToString:@"Y"]) {
        return YES;
    }
    return NO;
}

- (void)selectPhoto:(UIViewController *)viewController Singlemode:(BOOL)isSingleMode MinPictures:(int)minPictures Param:(NSString *)param {
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *navi = [sb instantiateViewControllerWithIdentifier:@"SelectPhotoPage"];
//    if (navi) {
//        SelectAlbumViewController *vc = (SelectAlbumViewController *)navi.topViewController;
//        vc.is_singlemode = isSingleMode;
//        vc.min_pictures = minPictures;
//        vc.param = param;
//        vc.delegate = (id<SelectPhotoDelegate>)viewController;
//        [viewController presentViewController:navi animated:YES completion:nil];
//    }
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoSelect" bundle:nil];
	UINavigationController *navi = [sb instantiateViewControllerWithIdentifier:@"PhotoSelectSequence"];
	if (navi) {
		PhotoPositionSelectController *vc = (PhotoPositionSelectController *)navi.topViewController;
		[vc setData:(id<SelectPhotoDelegate>)viewController isSinglemode:isSingleMode minPictureCount:minPictures param:param];
		vc.delegate = (id<SelectPhotoDelegate>)viewController;
		
		[viewController presentViewController:navi animated:YES completion:nil];
	}
}

- (void)selectPhoto:(UIViewController *)viewController Singlemode:(BOOL)isSingleMode MinPictures:(int)minPictures Param:(NSString *)param cancelOp:(void(^)(UIViewController *))cancelOp selectDoneOp:(void(^)(UIViewController *))selectDoneOp{
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController *navi = [sb instantiateViewControllerWithIdentifier:@"SelectPhotoPage"];
//    if (navi) {
//        SelectAlbumViewController *vc = (SelectAlbumViewController *)navi.topViewController;
//        vc.is_singlemode = isSingleMode;
//        vc.min_pictures = minPictures;
//        vc.param = param;
//        vc.delegate = (id<SelectPhotoDelegate>)viewController;
//        [viewController presentViewController:navi animated:YES completion:nil];
//    }
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoSelect" bundle:nil];
	UINavigationController *navi = [sb instantiateViewControllerWithIdentifier:@"PhotoSelectSequence"];
	if (navi) {
		PhotoPositionSelectController *vc = (PhotoPositionSelectController *)navi.topViewController;
		[vc setData:(id<SelectPhotoDelegate>)viewController isSinglemode:isSingleMode minPictureCount:minPictures param:param];
		vc.delegate = (id<SelectPhotoDelegate>)viewController;
		if (cancelOp) {
			vc.cancelOp = cancelOp;
		}
		
		if (selectDoneOp) {
			vc.selectDoneOp = selectDoneOp;
		}
		
		[viewController presentViewController:navi animated:YES completion:nil];
	}
}

// 디버그 로그 전용.. 느린 속도의 원인이 됨.
- (NSString *)logPhotoInfo:(PHAsset *)asset {
    UIImageOrientation orientation = [[PHAssetUtility info] getOrientation:asset];

    NSString* degree = @"(0도)";
    switch (orientation) {
        case UIImageOrientationLeft:  // 90도, 원본에서 90도 회전하여 보여주는 사진이므로 트림정보를 -90도 회전해야 함.
            degree = @"(90도)";
            break;
        case UIImageOrientationRight: // 270도
            degree = @"(-90도)";
            break;
        case UIImageOrientationDown:  // 180도
            degree = @"(180도)";
            break;
        default: // AL..Mirrored 계열은 그냥 무시.
            break;
    }

    CGSize dim = [self getDimensions:asset];

    int w = [[PHAssetUtility info] getPixelWidth:asset];
    int h = [[PHAssetUtility info] getPixelHeight:asset];
    CGSize sz = CGSizeMake(w, h);

    long long bytes = (long long)[[PHAssetUtility info] getFileSize:asset];
    int kbytes = (int)(bytes / 1000);

    return [NSString stringWithFormat:@"%@: %dx%d(%dx%d), %dK, %@", [[PHAssetUtility info] getFileName:asset], (int)dim.width, (int)dim.height, (int)sz.width, (int)sz.height, kbytes, degree];
}

#if 0
- (CGSize)getDimensions:(PHAsset *)asset {
	[Common info].dimension_type = "";

    int w = [[PHAssetUtility info] getPixelWidth:asset];
    int h = [[PHAssetUtility info] getPixelHeight:asset];

    CGSize dim_new = CGSizeZero;
    if (w > 0 && h > 0) {
		dim_new = CGSizeMake(w, h);
    }
    else {
        NSLog(@"WWWwwwwwwwwwwwwwwwwwwwwwwwwwaring!!!!!!!!!!");
#ifdef PHOTOMON_TESTMODE
        NSAssert(false, @"error : getDimensions is empty");
#endif
        return CGSizeMake(0, 0);
    }

    CGSize size = CGSizeZero;
    if (w > h) {
        size.width = MAX(w, h);
        size.height = MIN(w, h);
    }
    else {
        size.width = MIN(w, h);
        size.height = MAX(w, h);
    }

#ifdef PHOTOMON_TESTMODE
    NSAssert(size.width > 0 && size.height > 0, @"error : size is 0");
#endif

    return size;
}
#else
- (CGSize)getDimensions:(PHAsset *)asset {
	// SJYANG
	// 분명히 이 코드 내에서 문제가 있음.
	// iPhone 기종과 상황에 따라 원본 사이즈보다 커지는 경우가 발생하는데,
	// 커지는 사이즈가 대략 2가지 종류가 있다. 자세한 로그를 남겨야 할 듯.
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
	options.synchronous = YES;
	// HEIF Fix : 정확히 같은 사이즈를 가져와야 HEIF 이미지를 변환할 때와 혼동이 없을 듯
	options.resizeMode = PHImageRequestOptionsResizeModeExact;
	options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;

	// !!!!!!!!!!!!!!!!!!!!!!!
	//options.version = PHImageRequestOptionsVersionOriginal;
	//options.version = PHImageRequestOptionsVersionUnadjusted;
	options.version = PHImageRequestOptionsVersionCurrent;

    __block CIImage *fullImage = nil;
	// HEIF Fix
    if([[PHAssetUtility info] isHEIF:asset]) {
        fullImage = [CIImage imageWithData:[[PHAssetUtility info] getJpegImageDataForAsset:asset]];
    }
	else {
		[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
			fullImage = [CIImage imageWithData:imageData];
		}];
	}

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *w = [f numberFromString:[NSString stringWithFormat:@"%@", fullImage.properties[@"PixelWidth"]]];
    NSNumber *h = [f numberFromString:[NSString stringWithFormat:@"%@", fullImage.properties[@"PixelHeight"]]];
	/*
	NSLog(@"w : %@", [NSString stringWithFormat:@"%@", fullImage.properties[@"PixelWidth"]]);
	NSLog(@"h : %@", [NSString stringWithFormat:@"%@", fullImage.properties[@"PixelHeight"]]);
	*/

    CGSize dim_new = CGSizeZero;
    if (w != nil && h != nil) {
		[Common info].dimension_type = @"#1";
        dim_new = CGSizeMake([w floatValue], [h floatValue]);
    }
    else {
		[Common info].dimension_type = @"#2";
        NSLog(@"WWWwwwwwwwwwwwwwwwwwwwwwwwwwaring!!!!!!!!!!");
        int tw = [[PHAssetUtility info] getPixelWidth:asset];
        int th = [[PHAssetUtility info] getPixelHeight:asset];
        dim_new = CGSizeMake(tw, th);
    }

    CGSize size = CGSizeZero;
    CGSize dim_org;
    {
        int tw = [[PHAssetUtility info] getPixelWidth:asset];
        int th = [[PHAssetUtility info] getPixelHeight:asset];
        dim_org = CGSizeMake(tw, th);
    }
    if (dim_org.width > dim_org.height) {
        size.width = MAX(dim_new.width, dim_new.height);
        size.height = MIN(dim_new.width, dim_new.height);
    }
    else {
        size.width = MIN(dim_new.width, dim_new.height);
        size.height = MAX(dim_new.width, dim_new.height);
    }
    return size;
}
#endif

- (CGSize)getDimensionsWithImageData:(PHAsset *)asset withImageData:(NSData *)imageData {
	// SJYANG
	// 분명히 이 코드 내에서 문제가 있음.
	// iPhone 기종과 상황에 따라 원본 사이즈보다 커지는 경우가 발생하는데,
	// 커지는 사이즈가 대략 2가지 종류가 있다. 자세한 로그를 남겨야 할 듯.
	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
	options.networkAccessAllowed = YES;
	options.synchronous = YES;
	// HEIF Fix : 정확히 같은 사이즈를 가져와야 HEIF 이미지를 변환할 때와 혼동이 없을 듯
	options.resizeMode = PHImageRequestOptionsResizeModeExact;
	options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;

	// !!!!!!!!!!!!!!!!!!!!!!!
	//options.version = PHImageRequestOptionsVersionOriginal;
	//options.version = PHImageRequestOptionsVersionUnadjusted;
	options.version = PHImageRequestOptionsVersionCurrent;

    __block CIImage *fullImage = nil;

	
	// HEIF Fix
	/*
    if([[PHAssetUtility info] isHEIF:asset]) {
        fullImage = [CIImage imageWithData:[[PHAssetUtility info] getJpegImageDataForAsset:asset]];
    }
	else {
		[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
			fullImage = [CIImage imageWithData:imageData];
		}];
	}
	*/
	fullImage = [CIImage imageWithData:imageData];



    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *w = [f numberFromString:[NSString stringWithFormat:@"%@", fullImage.properties[@"PixelWidth"]]];
    NSNumber *h = [f numberFromString:[NSString stringWithFormat:@"%@", fullImage.properties[@"PixelHeight"]]];
	NSLog(@"PixelWidth : %@", [NSString stringWithFormat:@"%@", fullImage.properties[@"PixelWidth"]]);
	NSLog(@"PixelHeight : %@", [NSString stringWithFormat:@"%@", fullImage.properties[@"PixelHeight"]]);

    CGSize dim_new = CGSizeZero;
    if (w != nil && h != nil) {
		[Common info].dimension_type = @"#1";
        dim_new = CGSizeMake([w floatValue], [h floatValue]);
    }
    else {
		[Common info].dimension_type = @"#2";
        NSLog(@"WWWwwwwwwwwwwwwwwwwwwwwwwwwwaring!!!!!!!!!!");
        int tw = [[PHAssetUtility info] getPixelWidth:asset];
        int th = [[PHAssetUtility info] getPixelHeight:asset];
        dim_new = CGSizeMake(tw, th);
    }

    CGSize size = CGSizeZero;
    CGSize dim_org;
    {
        int tw = [[PHAssetUtility info] getPixelWidth:asset];
        int th = [[PHAssetUtility info] getPixelHeight:asset];
        dim_org = CGSizeMake(tw, th);
    }
    if (dim_org.width > dim_org.height) {
        size.width = MAX(dim_new.width, dim_new.height);
        size.height = MIN(dim_new.width, dim_new.height);
    }
    else {
        size.width = MIN(dim_new.width, dim_new.height);
        size.height = MAX(dim_new.width, dim_new.height);
    }
    return size;
}

- (CGSize)getDimensionsByUIImage:(UIImage *)image {
    int w = image.size.width;
    int h = image.size.height;

    CGSize dim_new = CGSizeZero;
    if (w > 0 && h > 0) {
        dim_new = CGSizeMake(w, h);
    }
    else {
        NSLog(@"WWWwwwwwwwwwwwwwwwwwwwwwwwwwaring!!!!!!!!!!");
#ifdef PHOTOMON_TESTMODE
        NSAssert(false, @"error : getDimensions is empty");
#endif
        return CGSizeMake(0, 0);
    }

    CGSize size = CGSizeZero;

    if (w > h) {
        size.width = MAX(w, h);
        size.height = MIN(w, h);
    }
    else {
        size.width = MIN(w, h);
        size.height = MAX(w, h);
    }

#ifdef PHOTOMON_TESTMODE
    NSAssert(size.width > 0 && size.height > 0, @"error : size is 0");
#endif

    return size;
}

- (BOOL)isHorzDirection:(CGSize)destSize src:(CGSize)srcSize {
    CGFloat aspectWidth = destSize.width / srcSize.width;
    CGFloat aspectHeight = destSize.height / srcSize.height;
    return (aspectWidth > aspectHeight);
}

- (CGFloat)getScale:(CGSize)destSize src:(CGSize)srcSize isInnerFit:(BOOL)isInner {
    CGFloat aspectWidth = destSize.width / srcSize.width;
    CGFloat aspectHeight = destSize.height / srcSize.height;
    CGFloat aspectRatio = isInner ? MIN(aspectWidth, aspectHeight) : MAX(aspectWidth, aspectHeight);
    return aspectRatio;
}

- (CGRect)getScaledRect:(CGSize)destSize src:(CGSize)srcSize isInnerFit:(BOOL)isInner {
    CGFloat aspectRatio = [self getScale:destSize src:srcSize isInnerFit:isInner];

    CGRect scaledRect = CGRectZero;
    scaledRect.size.width = srcSize.width * aspectRatio;
    scaledRect.size.height = srcSize.height * aspectRatio;
    scaledRect.origin.x = (destSize.width - scaledRect.size.width) / 2.0f;
    scaledRect.origin.y = (destSize.height - scaledRect.size.height) / 2.0f;
    return scaledRect;
}

- (CGSize)getRotatedSize:(CGSize)size Rotate:(int)angle {
    CGSize rotated_size = CGSizeMake(size.width, size.height);
    int value = angle / 90;
    if (value % 2) {
        rotated_size = CGSizeMake(size.height, size.width);
    }
    return rotated_size;
}

// SJYANG : CRASH 오류 수정 : imageSize 가 0, 0 이라서 크래시 발생
- (CGRect)getDefaultCropRect:(CGRect)maskRect src:(CGSize)imageSize {
	NSLog(@"maskRect.size.width : %f", maskRect.size.width);
	NSLog(@"maskRect.size.height : %f", maskRect.size.height);
	NSLog(@"imageSize.width : %f", imageSize.width);
	NSLog(@"imageSize.height : %f", imageSize.height);

    CGRect scaledImageRect = [self getScaledRect:maskRect.size src:imageSize isInnerFit:NO];

    CGFloat scale = [self getScale:maskRect.size src:imageSize isInnerFit:NO];
    CGPoint offset = CGPointMake(-scaledImageRect.origin.x, -scaledImageRect.origin.y);

    CGRect cropRect = CGRectZero;
    cropRect.origin.x = offset.x / scale;
    cropRect.origin.y = offset.y / scale;
    cropRect.size.width = maskRect.size.width / scale;
    cropRect.size.height = maskRect.size.height / scale;
    return cropRect;
}

- (BOOL)isLowResolution:(Layer *)layer {
    NSAssert(_photobook != nil, @"photobook is null..");

    CGFloat SCALE_FACTOR = 1.0f;
    switch (_photobook.product_type) {
        case PRODUCT_PHOTOBOOK:
            // 권장dpi(300) -> 8x8 -> (8x300)x(8x300) -> 2400(pixel)x2400(pixel)
            // 최소dpi(150) -> 8x8 -> 1200(pixel)x1200(pixel)
            // 레이플랫: 2400x1200 ~~~~~~~~~~~~~~~~~~~~~~~~~~> 다시말해, 페이지에 꽉찬 사진의 최소 크기는 2400x1200

            // 레이플랫: 2400x1200, 스크린축소판: 800x400 ~~~~~~> 레이아웃 scale_factor = 3
            // 마스크크기x3(scale_factor) -> 최소 픽셀 수. (2000x1000수준으로 조금 낮추면 2.5)
            SCALE_FACTOR = 2.5f;

            if ([_photobook.ProductSize isEqualToString:@"5.5x5.5"]) {
                // 최소dpi(150) -> 5.5x5.5 -> 825(pixel)x825(pixel)
                // 레이플랫: 1650x825, 스크린축소판: 800x400 ~~~~~~> 레이아웃 scale_factor = 약 2.0
                SCALE_FACTOR = 1.7f;
            }
            break;
        case PRODUCT_CALENDAR:
            // 권장dpi(300) -> 20x15cm(7.8x5.9inch)
            // 최소dpi(150) -> 7.8x5.9 -> 1170(pixel)x885(pixel)
            // 최소크기: 1170x885

            // 최소크기: 1170x885, 스크린축소판: 600x453 ~~~~~~> 레이아웃 scale_factor = 1.95
            // 마스크크기x1.95(scale_factor) -> 최소 픽셀 수. (1000x756수준으로 조금 낮추면 1.6)
            SCALE_FACTOR = 1.6f;
            break;
        case PRODUCT_POLAROID:
            // 권장dpi(300) -> 8.9x8.9cm(3.5x3.5inch)
            // 최소dpi(150) -> 3.5x3.5 -> 525(pixel)x525(pixel)
            // 최소크기: 525x525

            // 최소크기: 525x525, 스크린축소판: 660x660 ~~~~~~> 레이아웃 scale_factor = 0.79
            // 마스크크기x0.79(scale_factor) -> 최소 픽셀 수. (그냥 1.0f로..)
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_DESIGNPHOTO:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_SINGLECARD:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_CARD:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_MUG:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_PHONECASE:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_POSTCARD:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_MAGNET:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_BABY:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_POSTER:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_PAPERSLOGAN:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_TRANSPARENTCARD:
            SCALE_FACTOR = 1.0f;
            break;
        case PRODUCT_DIVISIONSTICKER:
            SCALE_FACTOR = 1.0f;
            break;
		case PRODUCT_MONTHLYBABY:
			SCALE_FACTOR = 1.0f;
			break;
        default:
            NSAssert(NO, @"isLowResolution: type mismatch..");
            break;
    }

    // 원본크롭크기 = 현재크롭크기 x 원본이미지장축/편집이미지장축
    // if (원본크롭크기 < 마스크크기x3) -> 최소 픽셀 수 부족으로 판단!

    CGFloat cur_crop = (CGFloat)MIN(layer.ImageCropW, layer.ImageCropH); // 단축기준으로 크롭영역 계산
    CGFloat image_scale = (CGFloat)MAX(layer.ImageOriWidth, layer.ImageOriHeight) / layer.EditImageMaxSize; // 장축 기준으로 사진 스케일 계산.
    CGFloat ori_crop = cur_crop * image_scale;
    CGFloat ori_mask = (CGFloat)MIN(layer.MaskW, layer.MaskH) * SCALE_FACTOR; // 단축기준으로 마스크영역 계산

    if (ori_crop < ori_mask) {/*
        NSLog(@"저해상도 경고!!");
        NSLog(@"원본이미지:%dx%d, 편집용이미지장축:%d", layer.ImageOriWidth, layer.ImageOriHeight, layer.EditImageMaxSize);
        NSLog(@"원본마스크:%dx%d, 편집용마스크(%dx%d)", layer.MaskW*3, layer.MaskH*3, layer.MaskW, layer.MaskH);
        NSLog(@"원본크롭 :%.0fx%.0f, 편집용크롭(%dx%d)", layer.ImageCropW*image_scale, layer.ImageCropH*image_scale, layer.ImageCropW, layer.ImageCropH);*/
        return YES;
    }
    return NO;
}

- (BOOL)isDigit:(NSString *)num_string {
    NSString *expr = @"[^0-9]";
    NSRegularExpression *reg_expr = [NSRegularExpression regularExpressionWithPattern:expr options:0 error:nil];
    NSUInteger match_count = [reg_expr numberOfMatchesInString:num_string options:0 range:NSMakeRange(0, num_string.length)];
    if (match_count > 0) {
        return NO;
    }
    return YES;
}

- (NSString *)timeString {
    NSDateFormatter *today = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [today setLocale:locale];
    [today setDateFormat:@"yyMMddHHmmss"];
    NSString *time_str = [today stringFromDate:[NSDate date]];
    return time_str;
}

- (NSString *)timeStringEx {
    NSDateFormatter *today = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [today setLocale:locale];
    [today setDateFormat:@"yyMMddHHmmssSSS"];
    NSString *time_str = [today stringFromDate:[NSDate date]];
    return time_str;
}

- (NSString *)timeStringForTitle {
    NSDateFormatter *today = [[NSDateFormatter alloc] init];
    [today setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time_str = [today stringFromDate:[NSDate date]];
    return time_str;
}

- (NSString *)documentPath {
    NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPathArray objectAtIndex:0];
    return docPath;
}

- (NSString *)toCurrencyString:(int)number {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSString *result = [formatter stringFromNumber:[NSNumber numberWithInt:number]];
    return result;
    //return [result substringFromIndex:1];
}

- (NSString *)createProductId:(NSString *)product_code {
    NSString *time_string = [self timeString];
    if (time_string.length != 12 || ![self isDigit:time_string]) { // 간혹 중간에 오후/오전 등과 같은 문자가 추가되는 오류 보완 (2016.04.20)
        NSDateFormatter *today = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [today setLocale:locale];
        [today setDateFormat:@"yyMMdd99mmss"];
        time_string = [today stringFromDate:[NSDate date]];
    }
    int randnum = arc4random() % 100;
    return [NSString stringWithFormat:@"%@-%03d%@", time_string, randnum, product_code];
}


- (void)appendLengthOnly:(int)length to:(NSMutableData *)data {
    NSString *len = [NSString stringWithFormat:@"%-12d", length];
    NSData *sub_len = [len dataUsingEncoding:NSEUCKREncoding];
    [data appendData:sub_len];
}

- (void)appendInteger:(int)variable to:(NSMutableData *)data {
    NSString *val = [NSString stringWithFormat:@"%d", variable];
    [self appendString:val to:data];
}

- (void)appendFloat:(float)variable to:(NSMutableData *)data {
    NSString *val = [NSString stringWithFormat:@"%.2f", variable];
    [self appendString:val to:data];
}

- (void)appendBoolean:(BOOL)variable to:(NSMutableData *)data {
    NSString *val = variable ? @"true" : @"false";
    [self appendString:val to:data];
}

// 2017.12.14 : SJYANG : PTODO : EUCKR 로 저장하여 '뜽'과 같은 글자가 입력이 안 됨
- (void)appendString:(NSString *)variable to:(NSMutableData *)data {
    NSLog(@"SEOJIN : %@", variable);
    NSString *val = variable;
    NSData *sub_data = [val dataUsingEncoding:NSEUCKREncoding];

    NSString *len = [NSString stringWithFormat:@"%-12lu", (unsigned long)sub_data.length];
    NSData *sub_len = [len dataUsingEncoding:NSEUCKREncoding];

    [data appendData:sub_len];
    [data appendData:sub_data];
}

//2019-09-08 ctg file cgrect append
- (void)appendCGRect:(CGRect)variable to:(NSMutableData *)data {
    //NSLog(@"appendCGRect : %@", variable);
    
    
    NSValue *value = [NSValue valueWithCGRect:variable];
    NSData *archivedata = [NSKeyedArchiver archivedDataWithRootObject:value];
    NSString *base64String = [archivedata base64EncodedStringWithOptions:0];
    NSLog(@"appendCGRect base64string : %@", base64String);
    
    NSData *sub_data = [base64String dataUsingEncoding:NSEUCKREncoding];
    NSString *len = [NSString stringWithFormat:@"%-12lu", (unsigned long)base64String.length];
    NSData *sub_len = [len dataUsingEncoding:NSEUCKREncoding];
    
   
    [data appendData:sub_len];
    [data appendData:sub_data];
}

- (NSString *)readString:(NSData *)data From:(int *)offset {
    NSString *val = @"";
    const int chunk_size = 12;
    if (data.length >= (*offset + chunk_size)) {
        NSData *len_data = [data subdataWithRange:NSMakeRange(*offset, chunk_size)];
        int len = [[[NSString alloc] initWithData:len_data encoding:NSEUCKREncoding] intValue];
        *offset += chunk_size;

        if (data.length >= (*offset + len) && len > 0) {
            NSData *val_data = [data subdataWithRange:NSMakeRange(*offset, len)];
            val = [[NSString alloc] initWithData:val_data encoding:NSEUCKREncoding];
            *offset += len;
        }
    }
    //NSLog(@"value:%@.", val);
    return val;
}
- (CGRect)readCGRect:(NSData *)data From:(int *)offset {
    CGRect val;
    const int chunk_size = 12;
    if (data.length >= (*offset + chunk_size)) {
        NSData *len_data = [data subdataWithRange:NSMakeRange(*offset, chunk_size)];
        int len = [[[NSString alloc] initWithData:len_data encoding:NSEUCKREncoding] intValue];
        *offset += chunk_size;
        
        if (data.length >= (*offset + len) && len > 0) {
            NSData *val_data = [[NSData alloc] initWithBase64Encoding:[data subdataWithRange:NSMakeRange(*offset, len)]];
            NSValue *valueBack = (NSValue *)[NSKeyedUnarchiver unarchiveObjectWithData:val_data];
            CGRect rectValue = (CGRect)[valueBack CGRectValue];
            val = rectValue;
            *offset += len;
        }
    }
    //NSLog(@"value:%@.", val);
    return val;
}
/*
- (NSString *)readString2:(NSString *)data From:(int *)offset {
    const int chunk_size = 12;
    int len = [[data substringWithRange:NSMakeRange(*offset, chunk_size)] intValue];
    *offset += chunk_size;

    NSString *val = @"";
    if (len > 0) {
        val = [data substringWithRange:NSMakeRange(*offset, len)];
        *offset += len;
    }
    //NSLog(@"value:%@.", val);
    return val;
}
*/

- (NSString *)getPlatformType
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];

    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

// 트리밍 오류 관련 : 개발 서버에 로그 남기기
- (NSString *)logToDevServer:(NSString *)logdata {
	/*
	NSString* strurl = [NSString stringWithFormat:@"http://www.minesolution.co.kr/clients/photomon/log.php?data=%@", [logdata stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
	NSURL *url = [NSURL URLWithString:strurl];
	NSData *data = [NSData dataWithContentsOfURL:url];
	NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	return(ret);
	*/
	return(@"");
}

// 2017.12.30 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
- (NSString *)checkEucKr:(NSString *)text {
	for (int i=0; i < [text length]; i++) {
		NSString *charStr = [text substringWithRange:NSMakeRange(i, 1)];
		const char *euckr_text = [charStr cStringUsingEncoding:-2147481280];
		if(euckr_text == nil) {
			return(charStr);
		}
	}
	return(nil);
}

- (NSString *)getDeviceUUID {
	NSError *error = nil;

	SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
	query.service = @"PHOTOMON";
	query.account = @"deviceUUID";
	[query fetch:&error];

	if ([error code] == errSecItemNotFound) {
		NSLog(@"UUID not found, and save.");

        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        NSString *uuidString = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
		CFRelease(uuidStringRef);

		query.service = @"PHOTOMON";
		query.account = @"deviceUUID";
		query.password = uuidString;
		[query save:&error];

		return uuidString;
	} 
	else if (error != nil) {
		//NSLog(@"Some other error occurred: %@", [error localizedDescription]);
		NSLog(@"Some other error occurred");
		return(nil);
	}
	else {
		NSLog(@"UUID found, and return.");

		query.service = @"PHOTOMON";
		query.account = @"deviceUUID";
		[query fetch:&error];
		return query.password;
		
		//return([keychain passwordForService:@"PHOTOMON" account:@"deviceUUID"]);
		//return(@"uuid");
	}
}

- (BOOL)isGudakBook:(NSString *)productCode {
    if ([productCode isEqualToString:@"300478"] || [productCode isEqualToString:@"300479"]) {
        return YES;
    } else {
        return NO;
    }
}

// 신규 달력 포맷
- (NSString *)makeMD5Hash:(NSString *)src {

    const char * pointer = src.UTF8String;
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);

    NSMutableString * string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [string appendFormat:@"%02x", md5Buffer[i]];
    }

    return string;
}

// URL maker
+ (NSString *)makeURLString:(NSString *)fileName host:(NSString *)host {
    
    if ([fileName hasPrefix:@"http://"] || [fileName hasPrefix:@"https://"]) {
        return [fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *fullpath = [NSString stringWithFormat:@"%@%@", host, fileName];
    return [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSURL *)buildQueryURL:(NSString *)baseURL query:(NSArray *)query {
	
	NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:baseURL];
//	NSMutableArray *queryItems = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *queryItems = [[NSMutableDictionary alloc] init];
	
	for (NSURLQueryItem *item in [urlComponents queryItems] ) {
		[queryItems setObject:item forKey:item.name];
	}
	
	for(NSURLQueryItem *item in query) {
		[queryItems setObject:item forKey:item.name];
	}
	
	if (queryItems.count > 0) {
		[urlComponents setQueryItems:[queryItems allValues]];
	}
	
	return [urlComponents URL];
 }

+ (NSString *)extractFileNameFromUrlString:(NSString *)urlString {
	return [[NSURL URLWithString:urlString].path lastPathComponent];
}

+ (NSString *)extractExtensionFromFilename:(NSString *)filename {
	return [filename pathExtension];
}

@end
