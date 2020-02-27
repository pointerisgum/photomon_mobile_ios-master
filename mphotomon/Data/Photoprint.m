//
//  Photoprint.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 30..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "Photoprint.h"
#import "Common.h"
#import "PhotomonInfo.h"
#import "PHAssetUtility.h"

@implementation PrintItem

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
    _photoItem = nil;
    _filename = @"";
    _thumbname = @"";
    _thumb = nil;
    
    _size_type = @"3.5x5"; // TODO : 사진인화 3x5
    _light_type = @"유광";
    _full_type = @"이미지풀";
    _border_type = @"무테";
    _revise_type = @"밝기보정";
    _trim_info = @"null^";
    _order_count = @"1";
    
    _scroll_offset = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    _offset = 0;
}

- (PrintItem *)getUploadTypePhotoItem:(int)idx {
    PrintItem *upload_photo = [[PrintItem alloc] init];
    upload_photo.photoItem = _photoItem;
    upload_photo.filename = _filename; // 속도 문제로 최대한 늦게 만든다. 업로드 직전까지만 할당하면 된다.
    upload_photo.thumb = _thumb; // 속도 문제로 최대한 늦게 만든다. 업로드 직전까지만 할당하면 된다.
    upload_photo.thumbname = [NSString stringWithFormat:@"thumbfile_%d.jpg", idx];
    
    upload_photo.size_type = [NSString stringWithFormat:@"%@^", _size_type];
    upload_photo.light_type = [_light_type isEqualToString:@"유광"] ? @"L" : @"N";
    upload_photo.full_type = [_full_type isEqualToString:@"인화지풀"] ? @"P" : @"I";
    upload_photo.border_type = [_border_type isEqualToString:@"무테"] ? @"M" : @"B";
    upload_photo.revise_type = [_revise_type isEqualToString:@"밝기보정"] ? @"Y" : @"N";
    upload_photo.date_type = _date_type;
    upload_photo.trim_info = _trim_info;
    upload_photo.order_count = [NSString stringWithFormat:@"%@^", _order_count];
    
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

//
@implementation Photoprint

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
    _upload_url = @"";
    _orderno = @"";
    
    _types = [[NSMutableArray alloc] init];
    _discounts = [[NSMutableArray alloc] init];
    _prices = [[NSMutableArray alloc] init];
    _sizes = [[NSMutableArray alloc] init];
    _minResolutions = [[NSMutableArray alloc] init];
    
    _sel_type = @"";
    _print_items = [[NSMutableDictionary alloc] init];
    
    _parsing_element = @"";
}

- (BOOL)initPhotoprintInfo {
    [self clear];
    
    // 1. 업로드 url
    NSString *hostUrl = @"";
    NSString *hostAsp = @"";
    
	NSData *ret_val;
    //ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_UPLOADPATH]];
    ret_val = [[Common info].connection.info_print_upload_host dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        hostUrl = data;
    }
    else return FALSE;
    
    //ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_UPLOADNAME]];
    ret_val = [[Common info].connection.info_print_upload_host_image dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        hostAsp = data;
    }
    else return FALSE;
    
    if (hostUrl.length > 0 && hostAsp.length > 0) {
        _upload_url = [NSString stringWithFormat:@"%@%@", hostUrl, hostAsp];
        NSLog(@"사진업로드URL:%@", _upload_url);
    }
    else return FALSE;
    
    // 2. order number
#if 1
    if (![self initOrderNumber]) {
        return FALSE;
    }
#else
    NSString *ordernoUrl = @"";
    //ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_ORDERNUM]];
    ret_val = [[Common info].connection.info_print_ordernourl dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        ordernoUrl = data;
    }
    else return FALSE;
    
    ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:ordernoUrl]];
    if (ret_val != nil) {
        //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    if (_orderno.length <= 0) {
        return FALSE;
    }
#endif
    
    // 3. 사진인화상품
    //ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_SIZEINFO]];
    ret_val = [[Common info].connection.info_print_sizeinfo dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSArray *row_array = [data componentsSeparatedByString:@"|"];
        for (NSString *line in row_array) {
            if ([line isEqualToString:@""]) {
                break;
            }
            NSLog(@">> 사진인화상품: %@", line);
            NSArray *col_array = [line componentsSeparatedByString:@":"];
            [_types addObject:col_array[0]];
            [_discounts addObject:col_array[1]];
            [_prices addObject:col_array[2]];
            [_sizes addObject:[NSString stringWithFormat:@"%@cm x %@cm", col_array[4], col_array[3]]];
            [_minResolutions addObject:[NSString stringWithFormat:@"%@x%@", col_array[5], col_array[6]]];
        }
    }
    else return FALSE;
    
    return TRUE;
}

- (BOOL)initOrderNumber {
    NSString *ordernoUrl = @"";
    //NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_PRINT_ORDERNUM]];
    NSData *ret_val = [[Common info].connection.info_print_ordernourl dataUsingEncoding:NSUTF8StringEncoding];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        ordernoUrl = data;
    }
    else return FALSE;
    
    ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:ordernoUrl]];
    if (ret_val != nil) {
        //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            return FALSE;
        }
    }
    else return FALSE;
    
    if (_orderno.length <= 0) {
        return FALSE;
    }
    return TRUE;
}

- (BOOL)uploadImage:(PrintItem *)upload_photo UploadController:(id)upload_controller {
    NSAssert(_orderno.length > 0, @"order_number is not valid..");
    
    // make request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60.0f];
    [request setHTTPMethod:@"POST"];
    
    // set content-type
    NSString *boundary = @"----PHOTOMON_PHOTOPRINT_BOUNDARY----";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // make post_body
    NSMutableData *body = [NSMutableData data];
    // 검증 1: 원본 이미지의 크기와 트리밍 연산에 사용된 크기를 검증한다. 크기가 다르면 trim정보 null^처리.
	
	NSData *imageData = UIImageJPEGRepresentation([upload_photo.photoItem getOriginal], 1.0f);
    
    CGSize imageSize = [upload_photo.photoItem getPixelSize]; // 원본 이미지 크기
    CGSize imageDim = [upload_photo.photoItem getDimension]; // 기존 트리밍 연산에 사용된 크기
    
    NSString *trim_check = @"";
    if (MAX(imageSize.width, imageSize.height) != MAX(imageDim.width, imageDim.height)
        || MIN(imageSize.width, imageSize.height) != MIN(imageDim.width, imageDim.height)) {
        trim_check = @"x";
        upload_photo.trim_info = @"null^";
    }
    
    // 검증 2: 인화 에러의 1차 식별을 위해 파일 이름에 디버깅 정보를 표시해 둠. (웹페이지 미리보기에서 확인 가능)
	UIImageOrientation orientation = [upload_photo.photoItem getOrientation];
	NSString *degree = @"";
    switch (orientation) {
        case UIImageOrientationUp:    degree = @"0"; break;    // 0도, 기본값.
        case UIImageOrientationLeft:  degree = @"90"; break;   // 90도
        case UIImageOrientationRight: degree = @"270"; break;  // -90도, 원본이 -90도 상태. 트림정보를 -90도로 회전변환한다.
        case UIImageOrientationDown:  degree = @"180"; break;  // 180도
        default: degree = @""; break; // AL..Mirrored 계열은 그냥 무시. 기본값 처리.
    }
    NSString *filename_for_test = [NSString stringWithFormat:@"%@%@_%ldx%ld_%@_%@_%@", trim_check, upload_photo.light_type, (long)imageDim.width, (long)imageDim.height, upload_photo.trim_info, degree, upload_photo.filename];
    //NSLog(@">>filename:%@", filename_for_test);

	// 트리밍 오류 관련
	/*
    NSString *logstr = [NSString stringWithFormat:@"[UPLOAD] orderno : %@ / filename : %@ / platform : %@", _orderno, filename_for_test, [[Common info] getPlatformType]];
	[[Common info] logToDevServer:logstr];
	*/
    
    // prepare params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:filename_for_test forKey:@"sFile"];
    //[params setObject:upload_photo.filename forKey:@"sFile"];
    [params setObject:_orderno forKey:@"sOrderNO"];
    [params setObject:upload_photo.order_count forKey:@"sCnt"];
    [params setObject:upload_photo.size_type forKey:@"sSize"];
    [params setObject:upload_photo.full_type forKey:@"sFullType"];
    [params setObject:upload_photo.light_type forKey:@"sLightType"];
    [params setObject:upload_photo.border_type forKey:@"sBorderType"];
    [params setObject:upload_photo.revise_type forKey:@"sReviseType"];
    [params setObject:upload_photo.trim_info forKey:@"sTrimInfo"];
    [params setObject:@"N" forKey:@"sDateType"];
    NSLog(@"> .......................................uploadfile prop. %@", params);
    NSLog(@"sTrimInfo : %@", upload_photo.trim_info);
    NSLog(@"filename_for_test : %@", filename_for_test);
    
    // add params
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image (original)
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"orifile\"; filename=\"%@\"\r\n", filename_for_test] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image (thumbnail)
    NSData *thumbData = UIImageJPEGRepresentation(upload_photo.thumb, 1.0f);
    if (thumbData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"thumbfile\"; filename=\"%@\"\r\n", upload_photo.thumbname] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:thumbData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // end of body. (마지막에 붙은 --는 body의 끝을 표시함.)
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set body
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)body.length];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    NSString *postUrl = _upload_url;
    NSLog(@">> uploadUrl(%@): %@", postLength, postUrl);
    [request setURL:[NSURL URLWithString:postUrl]];
    
    // start upload
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:upload_controller];
    [connection start];
    
    // or synchronous type..
    //NSData *ret_val = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
    //NSLog(@"post response..%@", data);
    
    return TRUE;
}

- (BOOL)uploadImageWithImageData:(PrintItem *)upload_photo withImageData:(NSData*)imageData UploadController:(id)upload_controller {
    NSAssert(_orderno.length > 0, @"order_number is not valid..");
    
    // make request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60.0f];
    [request setHTTPMethod:@"POST"];
    
    // set content-type
    NSString *boundary = @"----PHOTOMON_PHOTOPRINT_BOUNDARY----";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // make post_body
    NSMutableData *body = [NSMutableData data];
    
    
    
    // 검증 1: 원본 이미지의 크기와 트리밍 연산에 사용된 크기를 검증한다. 크기가 다르면 trim정보 null^처리.
	//NSData *imageData = [[PHAssetUtility info] getImageDataForAsset:upload_photo.asset];
    
    CGSize imageSize = [upload_photo.photoItem getPixelSize]; // 원본 이미지 크기
    //CGSize imageDim = [[Common info] getDimensions:upload_photo.asset]; // 기존 트리밍 연산에 사용된 크기
//    CGSize imageDim = [upload_photo.photoItem getDimension]; // 기존 트리밍 연산에 사용된 크기
	CGSize imageDim = CGSizeMake(0, 0);
	if (upload_photo.photoItem.positionType == PHOTO_POSITION_LOCAL) {
		LocalItem *li = (LocalItem *)upload_photo.photoItem;
		imageDim = [[Common info] getDimensionsWithImageData:li.photo.asset withImageData:imageData];
	} else {
		imageDim = [upload_photo.photoItem getDimension];
	}
    
    NSString *trim_check = @"";
    if (MAX(imageSize.width, imageSize.height) != MAX(imageDim.width, imageDim.height)
        || MIN(imageSize.width, imageSize.height) != MIN(imageDim.width, imageDim.height)) {
        trim_check = @"x";
        upload_photo.trim_info = @"null^";
    }
    
    // 검증 2: 인화 에러의 1차 식별을 위해 파일 이름에 디버깅 정보를 표시해 둠. (웹페이지 미리보기에서 확인 가능)
	UIImageOrientation orientation = [upload_photo.photoItem getOrientation];
	NSString *degree = @"";
    switch (orientation) {
        case UIImageOrientationUp:    degree = @"0"; break;    // 0도, 기본값.
        case UIImageOrientationLeft:  degree = @"90"; break;   // 90도
        case UIImageOrientationRight: degree = @"270"; break;  // -90도, 원본이 -90도 상태. 트림정보를 -90도로 회전변환한다.
        case UIImageOrientationDown:  degree = @"180"; break;  // 180도
        default: degree = @""; break; // AL..Mirrored 계열은 그냥 무시. 기본값 처리.
    }
    NSString *filename_for_test = [NSString stringWithFormat:@"%@%@_%ldx%ld_%@_%@_%@", trim_check, upload_photo.light_type, (long)imageDim.width, (long)imageDim.height, upload_photo.trim_info, degree, upload_photo.filename];
    //NSLog(@">>filename:%@", filename_for_test);

	// 트리밍 오류 관련
	/*
    NSString *logstr = [NSString stringWithFormat:@"[UPLOAD] orderno : %@ / filename : %@ / platform : %@", _orderno, filename_for_test, [[Common info] getPlatformType]];
	[[Common info] logToDevServer:logstr];
	*/
    
    // prepare params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:filename_for_test forKey:@"sFile"];
    //[params setObject:upload_photo.filename forKey:@"sFile"];
    [params setObject:_orderno forKey:@"sOrderNO"];
    [params setObject:upload_photo.order_count forKey:@"sCnt"];
    [params setObject:upload_photo.size_type forKey:@"sSize"];
    [params setObject:upload_photo.full_type forKey:@"sFullType"];
    [params setObject:upload_photo.light_type forKey:@"sLightType"];
    [params setObject:upload_photo.border_type forKey:@"sBorderType"];
    [params setObject:upload_photo.revise_type forKey:@"sReviseType"];
    [params setObject:upload_photo.trim_info forKey:@"sTrimInfo"];
    [params setObject:[upload_photo.date_type isEqual:@"적용"] ? @"W" : @"N" forKey:@"sDateType"];
    
    NSLog(@"> .......................................uploadfile prop. %@", params);
    NSLog(@"sTrimInfo : %@", upload_photo.trim_info);
    NSLog(@"filename_for_test : %@", filename_for_test);
    
    // add params
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image (original)
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"orifile\"; filename=\"%@\"\r\n", filename_for_test] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image (thumbnail)
    NSData *thumbData = UIImageJPEGRepresentation(upload_photo.thumb, 1.0f);
    if (thumbData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"thumbfile\"; filename=\"%@\"\r\n", upload_photo.thumbname] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:thumbData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // end of body. (마지막에 붙은 --는 body의 끝을 표시함.)
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set body
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)body.length];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    NSString *postUrl = _upload_url;
    NSLog(@">> uploadUrl(%@): %@", postLength, postUrl);
    [request setURL:[NSURL URLWithString:postUrl]];
    
    // start upload
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:upload_controller];
    [connection start];
    
    // or synchronous type..
    //NSData *ret_val = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
    //NSLog(@"post response..%@", data);
    
    return TRUE;
}

- (BOOL)addCart {
    NSString *url_str = [NSString stringWithFormat:URL_CART_ADD, [Common info].user.mUserid, _orderno, [PhotomonInfo sharedInfo].cartSession, [Common info].device_uuid];

    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
	url_str = [NSString stringWithFormat:@"%@&app_version=ios_%@", url_str, curVersion]; 

	url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSRange range = [temp rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            return FALSE;
        }
        NSLog(@">> checkAddedCartItem OK!!");
    }
    else return FALSE;
    
    return TRUE;
}

- (int)getOriginalPrice:(NSString *)productType {
    if (_types.count < 1) {
        [self initPhotoprintInfo];
    }
    for (int i = 0; i < _types.count; i++) {
        NSString *type = _types[i];
        if ([type isEqualToString:productType]) {
            return [_prices[i] intValue];
        }
    }
    return 0;
}

- (int)getDiscountPrice:(NSString *)productType {
    if (_types.count < 1) {
        [self initPhotoprintInfo];
    }
    for (int i = 0; i < _types.count; i++) {
        NSString *type = _types[i];
        if ([type isEqualToString:productType]) {
            return [_discounts[i] intValue];
        }
    }
    return 0;
}

- (CGSize)getPaperSize:(NSString *)size_type PhotoSize:(CGSize)imageSize {
#if 1
    CGSize paperSize = CGSizeZero;
	// 사진인화 3x5
    if ([size_type isEqualToString:@"3.5x5"] || [size_type isEqualToString:@"3x5"]) {
        paperSize = CGSizeMake(12.7, 8.9);
    }
    else if ([size_type isEqualToString:@"D4"]) {
        paperSize = CGSizeMake(13.5, 10.2);
    }
    else if ([size_type isEqualToString:@"4x6"]) {
        paperSize = CGSizeMake(15.2, 10.2);
    }
    else if ([size_type isEqualToString:@"5x7"]) {
        paperSize = CGSizeMake(17.8, 12.7);
    }
    else if ([size_type isEqualToString:@"8x10"]) {
        paperSize = CGSizeMake(25.4, 20.3);
    }
    else if ([size_type isEqualToString:@"A4"]) {
        paperSize = CGSizeMake(29.7, 21.0);
    }
    
    if (imageSize.width < imageSize.height) { // 인화지의 가로/세로 스왑.
        CGFloat temp;
        temp = paperSize.width;
        paperSize.width = paperSize.height;
        paperSize.height = temp;
    }
#else
    CGSize paperSize = CGSizeZero;
	// 사진인화 3x5
    if ([size_type isEqualToString:@"3.5x5"] || [size_type isEqualToString:@"3x5"]) {
        paperSize = CGSizeMake(8.9, 12.7);
    }
    else if ([size_type isEqualToString:@"D4"]) {
        paperSize = CGSizeMake(10.2, 13.5);
    }
    else if ([size_type isEqualToString:@"4x6"]) {
        paperSize = CGSizeMake(10.2, 15.2);
    }
    else if ([size_type isEqualToString:@"5x7"]) {
        paperSize = CGSizeMake(12.7, 17.8);
    }
    else if ([size_type isEqualToString:@"8x10"]) {
        paperSize = CGSizeMake(20.3, 25.4);
    }
    else if ([size_type isEqualToString:@"A4"]) {
        paperSize = CGSizeMake(21.0, 29.7);
    }
    
    if (imageSize.width > imageSize.height) { // 인화지의 가로/세로 스왑.
        CGFloat temp;
        temp = paperSize.width;
        paperSize.width = paperSize.height;
        paperSize.height = temp;
    }
#endif
    return paperSize;
}

- (NSString *)getDefaultTrimInfo:(PrintItem *)item {
    CGSize photoSize = [item.photoItem getDimension];
    CGSize paperSize = [self getPaperSize:item.size_type PhotoSize:photoSize];
    
    CGRect scaledImageRect = [[Common info] getScaledRect:photoSize src:paperSize isInnerFit:YES];
    CGFloat scaleFactor = [[Common info] getScale:photoSize src:paperSize isInnerFit:YES];
    
    NSString *trim_info = @"null^";
    if ([[Common info] isHorzDirection:photoSize src:paperSize]) { //photoSize.width > photoSize.height) {
        int offset = (int)scaledImageRect.origin.x;
        int length = (int)(paperSize.width * scaleFactor);
        trim_info = [self makeTrimString:@"L" Size:photoSize Offset:offset Length:length Orientation:[item.photoItem getOrientation]];
    }
    else {
        int offset = (int)scaledImageRect.origin.y;
        int length = (int)(paperSize.height * scaleFactor);
        trim_info = [self makeTrimString:@"T" Size:photoSize Offset:offset Length:length Orientation:[item.photoItem getOrientation]];
    }
    //NSLog(@"trim: %@ (paper:%dx%d, photo:%dx%d)", trim_info, (int)paperSize.width, (int)paperSize.height, (int)photoSize.width, (int)photoSize.height);
    return trim_info;
}

- (NSString *)makeTrimString:(NSString *)direction Size:(CGSize)photoSize Offset:(int)offset Length:(int)length Orientation:(UIImageOrientation)orientation {
    int max = [direction isEqualToString:@"L"] ? photoSize.width : photoSize.height;
    
    NSString *trim_info = @"";
    switch (orientation) {
        case UIImageOrientationUp:    // 0도, 기본값.
        case UIImageOrientationUpMirrored:
            break;
        case UIImageOrientationDown:  // 180도
        case UIImageOrientationDownMirrored:
            if ([direction isEqualToString:@"L"]) {
                offset = photoSize.width - (offset + length);
            }
            else {
                offset = photoSize.height - (offset + length);
            }
            break;
        case UIImageOrientationLeft:  // 90도
        case UIImageOrientationLeftMirrored:
            if ([direction isEqualToString:@"L"]) {
                direction = @"T";
            }
            else {
                direction = @"L";
                offset = photoSize.height - (offset + length);
            }
            break;
        case UIImageOrientationRight: // -90도, 원본이 -90도 상태. 트림정보를 -90도로 회전변환한다.
        case UIImageOrientationRightMirrored:
            if ([direction isEqualToString:@"L"]) {
                direction = @"T";
                offset = photoSize.width - (offset + length);
            }
            else {
                direction = @"L";
            }
            break;
    }
    if (offset < 0) { // 2015.10.2 정방형 180도 회전 사진에서 -1 값 발생.
        offset = 0;
    }
    offset += [self checkValidateOffset:offset Length:length MaxSize:max];
    
    trim_info = [NSString stringWithFormat:@"%@_%d,%d", direction, offset, length];
    return trim_info;
}

- (int)checkValidateOffset:(int)offset Length:(int)length MaxSize:(int)max {
    int check = max - (offset + length);
    if (check < 0) {
        NSLog(@"오프셋오차보정:%d", check);
        return check;
    }
    return 0;
}


// 대형인화는 유광만 가능. 대형인화가 포함된 경우에는 전체 유광으로 변경한다.
- (BOOL)isInclueLargeTypePrint {
    BOOL is_include = FALSE;
    for (id key in _print_items) {
        PrintItem *item = [_print_items objectForKey:key];
        if ([item.size_type isEqualToString:@"8x10"] || [item.size_type isEqualToString:@"A4"]) {
            is_include = TRUE;
            break;
        }
    }
    return is_include;
}
- (void)resetSurfaceType {
    for (id key in _print_items) {
        PrintItem *item = [_print_items objectForKey:key];
        item.light_type = @"유광";
    }
}

// 카메라에 필터를 적용한 사진의 경우는 representation.dimensions에 원본사진의 해상도가 전달된다. (실제는 작은 해상도)
// 정확한 해상도를 얻기 위해서는 getDimensions를 통해 얻어야 한다. (트리밍 정보 계산시에는 getDimension 사용)
// 그러나, 전체 선택시 속도의 차이가 너무 커서 그냥 사용한다.
- (BOOL)isPrintablePhoto:(PHAsset *)asset {
	// SJYANG : 2017.11.07 : 일반사진인화 상품에서 사진선택시 라이브 포토 및 비디오가 선택되는 버그 수정
	if(asset == nil) return FALSE;	
	if(asset.mediaType != PHAssetMediaTypeImage) return FALSE;
	//if(asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return FALSE;
	if(asset.mediaSubtypes == PHAssetMediaSubtypeVideoTimelapse) return FALSE;
	

	int width = [[PHAssetUtility info] getPixelWidth:asset];
	int height = [[PHAssetUtility info] getPixelHeight:asset];
	// SJYANG : 2017.11.07 : 일반사진인화 상품에서 아이클라우드 사진이 포함된 수백장의 사진을 전체선택하면 무척 느려지는 문제 수정
	//long size = [[PHAssetUtility info] getFileSize:asset];
	long size = [[PHAssetUtility info] getFastFileSize:asset];

    if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
        return TRUE;
        /* 메모리를 너무 사용하여 일단 제외.
         NSString *color_model = [representation.metadata objectForKey:@"ColorModel"];
         if ([color_model isEqualToString:@"RGB"]) {
         return TRUE;
         }*/
    }
    return FALSE;
}

- (BOOL)isSelectedPhoto:(PHAsset *)asset {
    return ([_print_items objectForKey:asset.localIdentifier] != nil) ? TRUE : FALSE;
}

- (void)addPhoto:(PhotoItem *)item {
    PrintItem *photo_item = [[PrintItem alloc] init];
    photo_item.photoItem = item;
    photo_item.filename = nil; // 나중에 할당.. (속도문제로 이동) 
    photo_item.thumb = nil; // 나중에 할당.. (속도문제로 이동)
    
    photo_item.size_type = _sel_type;
    
    [_print_items setObject:photo_item forKey:item.key];
}

- (void)removePhoto:(PhotoItem *)item {
    [_print_items removeObjectForKey:item.key];
}



// parse..
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    _parsing_element = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    if ([_parsing_element isEqualToString:@"orderno"]) {
        _orderno = value;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _parsing_element = @"";
}

@end
