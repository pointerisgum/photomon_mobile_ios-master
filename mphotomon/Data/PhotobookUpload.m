//
//  PhotobookUpload.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 14..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotobookUpload.h"
#import "PhotomonInfo.h"

@implementation PhotobookUploadItem
- (id)init {
    if (self = [super init]) {
        _type = 0;
        _pageno = @"";
        _uploadfilename = @"";
        _localpathname = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end



@implementation PhotobookUpload

- (void)clear {
    if (_items != nil && _items.count > 0) {
        [_items removeAllObjects];
    }
}

- (BOOL)prepareUploadServer {
    if (_photobook == nil) return FALSE;
    
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_UPLOAD_SERVER, _photobook.ProductCode];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *server_name = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook upload server: %@", server_name);

        if (server_name.length > 0) {
			// SJYANG.2018.05 : 이동헌 대리님 옵션 처리
			NSString *intNum = [_photobook.ProductCode substringToIndex:3];

		    if ([_photobook.ProductCode isEqualToString:@"347037"] || [_photobook.ProductCode isEqualToString:@"347036"] ||
                [_photobook.ProductCode isEqualToString:@"347063"] ||
                [_photobook.ProductCode isEqualToString:@"347064"] ||
                _photobook.product_type == PRODUCT_DIVISIONSTICKER ||
                [intNum isEqualToString:@"413"] || [intNum isEqualToString:@"414"] || [_photobook.ProductCode isEqualToString:@"347062"]) {
				_upload_url = [NSString stringWithFormat:@"http://%@.photomon.com/upload/upload_designPhoto.asp", server_name];
				int taktype = 2;
				
				if ([[Common info].photobook.tmpAddVal11 rangeOfString:@"유광"].location != NSNotFound) taktype = 1;
				else taktype = 2;
				
				NSString *strSize = [[Common info].photobook.tmpAddVal12 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSString *strTheme1 = [[Common info].photobook.tmpAddVal13 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSString *strTheme2 = [[Common info].photobook.tmpAddVal14 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				NSString *strPkgcnt = [[Common info].photobook.tmpAddVal10 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

				/*
				strurl += "?userid=" + Singleton.getInstance().getUserId() + "&cart_session=" + Singleton.getInstance().getCartSession() + "&osinfo=android";
				strurl += "&taktype=" + taktype;
				strurl += "&pkgcnt=" + strPkgcnt;
				strurl += "&size=" + strSize;
				strurl += "&theme1=" + strTheme1;
				strurl += "&theme2=" + strTheme2;
				*/

				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				// ProductID 새로 생성.
				_photobook.ProductId = [[Common info] createProductId:_photobook.ProductCode];
				
				//"http://" + reponse value + ".photomon.com/upload/upload_check.asp?product_id="+제작코드
				_check_url = [NSString stringWithFormat:URL_PRODUCT_UPLOAD_CHECK, server_name, _photobook.ProductId];
			}
			else {
				_upload_url = [NSString stringWithFormat:URL_PRODUCT_UPLOAD_PATH, server_name];
				
				// ProductID 새로 생성.
				_photobook.ProductId = [[Common info] createProductId:_photobook.ProductCode];
				
				//"http://" + reponse value + ".photomon.com/upload/upload_check.asp?product_id="+제작코드
				_check_url = [NSString stringWithFormat:URL_PRODUCT_UPLOAD_CHECK, server_name, _photobook.ProductId];
			}
            return TRUE;
        }
    }
    return FALSE;
}
/*
- (int)getUploadItemCount {
    int total_count = 0;
    total_count = (int)_photobook.pages.count * 2; // 썸네일 개수
    total_count += 1; // ctg
    total_count += [_photobook getImageLayerCount]; // 원본 이미지 개수
    total_count += 1; // txt
    return total_count;
}
*/
- (void)addItem:(int)type UploadName:(NSString *)uploadname LocalName:(NSString *)localname PageNo:(int)pageno {
    PhotobookUploadItem *item = [[PhotobookUploadItem alloc] init];
    item.type = type;
    item.pageno = [NSString stringWithFormat:@"%d", pageno];
    item.uploadfilename = uploadname;
    switch (type) {
        case 0: // thumb
            item.localpathname = [NSString stringWithFormat:@"%@/thumb/%@", _photobook.base_folder, localname];
            break;
        case 1: // orifile
            item.localpathname = [NSString stringWithFormat:@"%@/org/%@", _photobook.base_folder, localname];
            break;
        case 2: // ctg or txt
            item.localpathname = [NSString stringWithFormat:@"%@/%@", _photobook.base_folder, localname];
            break;
        default:
            break;
    }
    [_items addObject:item];
}

- (BOOL)prepareItemsFrame:(NSMutableArray *)filearray {
    NSLog(@"업로드 파일 리스트 생성..");

    if (_photobook.product_type != PRODUCT_FRAME) {
        return FALSE;
    }
    _checksum = 0;
    _items = [[NSMutableArray alloc] init];
    
    // 1. 썸네일 준비
    NSString *thumbname = [NSString stringWithFormat:@"%@_001.jpg", _photobook.ProductId];
    [self addItem:0 UploadName:thumbname LocalName:@"thumb.jpg" PageNo:1];
    
    // 2. ctg 준비
    NSString *ctgname = [NSString stringWithFormat:@"%@_777.ctg", _photobook.ProductId];
    [self addItem:2 UploadName:ctgname LocalName:@"save.ctg" PageNo:777];
    
    // 3. 사진 원본 준비
    for (int i = 0; i < filearray.count; i++) {
        NSString *filename = filearray[i];
        [self addItem:1 UploadName:filename LocalName:filename PageNo:i+1];
    }
    _checksum = (int)filearray.count + 2; // 원본개수 + ctg + txt
    NSLog(@"체크썸: %d (원본이미지개수 + 777.ctg + 888.txt)", _checksum);
    
    // 4. 텍스트 파일 준비
    NSString *txtname = [NSString stringWithFormat:@"%@_888.txt", _photobook.ProductId];
    [self addItem:2 UploadName:txtname LocalName:@"upload.txt" PageNo:888];
    
    NSLog(@"upload count: %lu", (unsigned long)_items.count);
    return TRUE;
}

- (BOOL)prepareItems {
    NSLog(@"업로드 파일 리스트 생성.. prepareItems");
    
    _checksum = 0;
    _items = [[NSMutableArray alloc] init];
    
    // 1. 썸네일 준비
    if (_photobook.product_type == PRODUCT_PHOTOBOOK) {
        // 커버 썸네일
        NSString *lname = [NSString stringWithFormat:@"THUMBL_%@_0001.jpg", _photobook.ProductId];
        NSString *rname = [NSString stringWithFormat:@"THUMBR_%@_0002.jpg", _photobook.ProductId];
        [_photobook makeThumb:0 ToFile1:lname ToFile2:rname IncludeBg:NO];
        [self addItem:0 UploadName:lname LocalName:lname PageNo:0];
        [self addItem:0 UploadName:rname LocalName:rname PageNo:1];
        
        int page_num = 1;
        
        // 프롤로그 썸네일 (왼쪽장 빼고, 오른쪽장만 추가)
        lname = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, 0];
        rname = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, 1];
        [_photobook makeThumb:1 ToFile1:lname ToFile2:rname IncludeBg:NO];
        if ([_photobook.ProductCode isEqualToString:@"300269"] || [_photobook.ProductCode isEqualToString:@"300270"]) { // 손글씨 포토북은 프롤로그가 없으므로 모두 포함.
            [self addItem:0 UploadName:lname LocalName:lname PageNo:page_num++];
            [self addItem:0 UploadName:rname LocalName:rname PageNo:page_num++];
        }
        else {
            [self addItem:0 UploadName:rname LocalName:rname PageNo:page_num++];
        }

        // 내지 썸네일
        for (int i = 2; i < _photobook.pages.count; i++) {
            lname = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, page_num];
            rname = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, page_num+1];
            [_photobook makeThumb:i ToFile1:lname ToFile2:rname IncludeBg:NO];
            [self addItem:0 UploadName:lname LocalName:lname PageNo:page_num];
			// SJYANG : 2016.06.07
			// 프리미엄 포토북일 경우에 마지막 blank 페이지 제외
			if( _photobook.pages.count-1 == i && [_photobook.ThemeName isEqualToString:@"premium"] ) {
				page_num += 1;
			} else {
				[self addItem:0 UploadName:rname LocalName:rname PageNo:page_num+1];
				page_num += 2;
			}
        }
    }
    else if (_photobook.product_type == PRODUCT_CALENDAR || _photobook.product_type == PRODUCT_POLAROID || _photobook.product_type == PRODUCT_DESIGNPHOTO || _photobook.product_type == PRODUCT_MUG || _photobook.product_type == PRODUCT_POSTCARD || _photobook.product_type == PRODUCT_PHONECASE || _photobook.product_type == PRODUCT_MAGNET /*|| _photobook.product_type == PRODUCT_SINGLECARD*/) {
        for (int i = 0; i < _photobook.pages.count; i++) {
            NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, i+1];
            [_photobook makeThumb:i ToFile:name IncludeBg:NO];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
        }
    }
    else if (_photobook.product_type == PRODUCT_SINGLECARD) {
        int thumbNum = 1;
        for (int i = 0; i < _photobook.pages.count; i = i + 2) {
            NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, thumbNum];
            [_photobook makeThumb:i ToFile:name IncludeBg:NO];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
            thumbNum++;
        }
    }
    else if (_photobook.product_type == PRODUCT_CARD) {
        for (int i = 0; i < _photobook.pages.count; i++) {
            //NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, i+1];
            NSString *name = [NSString stringWithFormat:@"thumb%02d.jpg", i];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
        }
    }
    else if (_photobook.product_type == PRODUCT_BABY) {
        for (int i = 0; i < _photobook.pages.count; i++) {
            NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, i+1];
            [_photobook makeThumb:i ToFile:name IncludeBg:NO];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
        }
    }
    else if (_photobook.product_type == PRODUCT_FRAME) {
        NSAssert(NO, @"prepareItems : Frame은 prepareItemsFrame 호출할 것.");
    }
    else if (_photobook.product_type == PRODUCT_POSTER) {
        for (int i = 0; i < _photobook.pages.count; i++) {
            NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, i+1];
            [_photobook makeThumb:i ToFile:name IncludeBg:NO];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
        }
    }
    else if (_photobook.product_type == PRODUCT_PAPERSLOGAN) {
        for (int i = 0; i < _photobook.pages.count; i += 2) {
            NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, i+1];
            [_photobook makeThumb:i ToFile:name IncludeBg:NO];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
        }
    }
    else if (_photobook.product_type == PRODUCT_TRANSPARENTCARD) {
        for (int i = 0; i < _photobook.pages.count; i++) {
            NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, i+1];
            [_photobook makeThumb:i ToFile:name IncludeBg:NO];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
        }
    }
    else if (_photobook.product_type == PRODUCT_DIVISIONSTICKER) {
        for (int i = 0; i < _photobook.pages.count; i += 2) {
            NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _photobook.ProductId, i+1];
            [_photobook makeThumb:i ToFile:name IncludeBg:NO];
            [self addItem:0 UploadName:name LocalName:name PageNo:i+1];
        }
    }
    else {
        NSAssert(NO, @"prepareItems : product type mismatch..");
    }
    
    // 2. ctg 준비
    NSString *ctgname = [NSString stringWithFormat:@"%@_777.ctg", _photobook.ProductId];
    [self addItem:2 UploadName:ctgname LocalName:@"save.ctg" PageNo:777];
    
    // 3. 사진 원본 준비
    int imagenum = 0;
    NSString *filelist = @"";
    for (Page *page in _photobook.pages) {
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0) {
				if ([Common info].photobook.product_type == PRODUCT_BABY) {
	                NSString *uploadFileName = [NSString stringWithFormat:@"%@_%03d.%@", _photobook.ProductId, (imagenum+1), [layer.ImageFilename pathExtension]];
					if( (imagenum+1)==1 ) _photobook.AddVal13 = uploadFileName;
					else if( (imagenum+1)==2 ) _photobook.AddVal14 = uploadFileName;
					else if( (imagenum+1)==3 ) _photobook.AddVal15 = uploadFileName;
					[self addItem:1 UploadName:uploadFileName LocalName:layer.ImageFilename PageNo:imagenum+1];
				}
				else {
					[self addItem:1 UploadName:layer.ImageFilename LocalName:layer.ImageFilename PageNo:imagenum+1];
				}
                filelist = [NSString stringWithFormat:@"%@%@\n", filelist, layer.ImageFilename];
                imagenum++;
            }
        }
    }
    _checksum = imagenum + 2; // 원본개수 + ctg + txt
    NSLog(@"체크썸: %d (원본이미지개수 + 777.ctg + 888.txt)", _checksum);
    
    // 4. 텍스트 파일 준비
    NSString *txtname = [NSString stringWithFormat:@"%@_888.txt", _photobook.ProductId];
    NSString *txtbody = [NSString stringWithFormat:@"%-12lu%@", (unsigned long)filelist.length, filelist];
    NSData *txtdata = [txtbody dataUsingEncoding:NSUTF8StringEncoding];
    [txtdata writeToFile:[NSString stringWithFormat:@"%@/%@", _photobook.base_folder, txtname] atomically:YES];
    [self addItem:2 UploadName:txtname LocalName:txtname PageNo:888];
    
    NSLog(@"upload count: %lu", (unsigned long)_items.count);
    return TRUE;
}

- (BOOL)uploadFile:(int)index UploadController:(id)upload_controller {
    if (index >= _items.count) {
        return FALSE;
    }
    PhotobookUploadItem *item = _items[index];
   
    BOOL is_dir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:item.localpathname isDirectory:&is_dir]) {
		NSLog(@"![fileManager fileExistsAtPath:item.localpathname isDirectory:&is_dir] : %@", item.localpathname);
		return FALSE;
	}
    
    NSData *uploadData = [fileManager contentsAtPath:item.localpathname];
    if (uploadData == nil) {
		NSLog(@"uploadData == nil : %@", item.localpathname);
		return FALSE;
	}
    
    // make request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60.0f];
    [request setHTTPMethod:@"POST"];
    
    // set content-type
    NSString *boundary = @"----PHOTOMON_PHOTOBOOK_BOUNDARY----";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // make post_body
    //NSMutableData *body = [NSMutableData data];
    NSMutableData *body = [[NSMutableData alloc] init];

    // prepare params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if ([_photobook.ProductCode isEqualToString:@"347036"]) {
        if([item.pageno intValue] < 700) {
            int pno = [item.pageno intValue] - index;
            if (pno > 1) {
                [params setObject:[NSString stringWithFormat:@"%d", pno] forKey:@"PageNO"];
            } else {
                [params setObject:item.pageno forKey:@"PageNO"];
            }
        } else {
            [params setObject:item.pageno forKey:@"PageNO"];
        }
    } else {
        [params setObject:item.pageno forKey:@"PageNO"];
    }
    [params setObject:_photobook.ProductId forKey:@"Product_id"];
    [params setObject:_photobook.ProductCode forKey:@"Product_code"];
    [params setObject:item.uploadfilename forKey:@"orifilename"];

    [params setObject:[Common info].device_uuid forKey:@"uniquekey"];

	// SJYANG.2018.05 : 이동헌 대리님 옵션 처리
    NSString *intNum = [_photobook.ProductCode substringToIndex:3];

	if (([_photobook.ProductCode isEqualToString:@"347037"] || [_photobook.ProductCode isEqualToString:@"347036"] ||
         [_photobook.ProductCode isEqualToString:@"347063"] ||
         [_photobook.ProductCode isEqualToString:@"347064"] ||
         _photobook.product_type == PRODUCT_DIVISIONSTICKER ||
         [intNum isEqualToString:@"413"] || [intNum isEqualToString:@"414"] || [_photobook.ProductCode isEqualToString:@"347062"]) && _upload_url != nil && [_upload_url rangeOfString:@"upload_designPhoto.asp"].location != NSNotFound)
	{
		int taktype = 2;
		if ([[Common info].photobook.tmpAddVal11 rangeOfString:@"유광"].location != NSNotFound) taktype = 1;
		else taktype = 2;

		int pageno = [item.pageno intValue];

		NSLog(@"pageno : %d", pageno);
		
		if ([Common info].user){
			[params setObject:[Common info].user.mUserid forKey:@"userid"];
		}
		else {
			[params setObject:@"" forKey:@"userid"];
		}
	    [params setObject:[PhotomonInfo sharedInfo].cartSession forKey:@"cart_session"];
	    [params setObject:@"ios" forKey:@"osinfo"];
	    [params setObject:[NSString stringWithFormat:@"%d", taktype] forKey:@"taktype"];
		// TODO : 검증 필요
		if(pageno < 700)
		{
			@try
			{
				NSArray *arr = [_photobook.tmpAddVal10 componentsSeparatedByString: @"^"];
				[params setObject:[arr objectAtIndex:(pageno - 1)] forKey:@"pkgcnt"]; 
				NSLog(@"[arr objectAtIndex:(pageno - 1)] : %@", [arr objectAtIndex:(pageno - 1)]);
			}
			@catch(NSException *exception) 
			{
				[params setObject:@"1" forKey:@"pkgcnt"]; 
			}
		}

		@try
		{
			NSArray *arrSize = [_photobook.tmpAddVal12 componentsSeparatedByString: @" ("];
			[params setObject:arrSize[0] forKey:@"size"];
			NSLog(@"arrSize[0] : %@", arrSize[0]);
		}
		@catch(NSException *exception) 
		{
			[params setObject:@"5 x 7" forKey:@"size"];
		}

	    [params setObject:_photobook.tmpAddVal13 forKey:@"theme1"];
		// TODO : 검증 필요
		if(pageno < 700)
		{
			@try
			{
				NSArray *arr = [_photobook.tmpAddVal14 componentsSeparatedByString: @"^"];
				[params setObject:[arr objectAtIndex:(pageno - 1)] forKey:@"theme2"]; 
				NSLog(@"[arr objectAtIndex:(pageno - 1)] : %@", [arr objectAtIndex:(pageno - 1)]);
			}
			@catch(NSException *exception) 
			{
				[params setObject:@"" forKey:@"theme2"]; 
			}
		}

		NSLog(@"taktype : %d", taktype);
		NSLog(@"size : %@", _photobook.tmpAddVal12);
		NSLog(@"theme1 : %@", _photobook.tmpAddVal13);
	}

    NSLog(@">%@: %@",item.pageno, item.uploadfilename);
    //NSLog(@"> .......................................uploadfile prop. %@", params);
    
    // add params
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add file
    if (uploadData) {
        NSString *type_name = (item.type == 0) ? @"thumbfile" : @"orifile";
        NSString *content_type = (item.type == 2) ? @"text/plain" : @"image/jpeg";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", type_name, item.uploadfilename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", content_type] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:uploadData];
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
    [request setURL:[NSURL URLWithString:_upload_url]];
    
    // start upload
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:upload_controller];
    [connection start];
    
    return TRUE;
}

- (BOOL)checkUploadResult {
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:_check_url]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> checkUploadResult xml: %@, (checksum value:%d)", data, _checksum);
        
        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        //if (_checksum == _checksum) { // 임시
        if (_checksum == [temp intValue]) {
            NSLog(@">> checkUploadResult OK!!!! (%lu)", (unsigned long)_items.count);
            return TRUE;
        }
        return FALSE;
    }
    return TRUE; // 2015-11-03 이재봉차장 의견. 서버상황에 따라 응답을 못받은 경우도 그냥 통과.
}

- (BOOL)addCart {
    NSString *url_str = @"";
    if (_photobook.product_type == PRODUCT_PHOTOBOOK) {
	    url_str = [NSString stringWithFormat:URL_CART_ADD_PHOTOBOOK, [Common info].device_uuid];
        NSString *appendUV = [_photobook isUV] ? @"UV" : @"";
        url_str = [NSString stringWithFormat:@"%@ProductName=%@%@", url_str, _photobook.ProductSize, appendUV];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@%@", url_str, _photobook.ProductSize, appendUV];
        // SJYANG : 2016.05.30
        // 프리미엄 포토북 장바구니 호출시 "^^0^로그인 고객ID 또는 비로그인은 공백^상품가격^테마2depth 명으로 소문자 치환 값_선택 형압 정보"
        if( [_photobook.ThemeName isEqualToString:@"premium"] ) {
            url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=^^0^%@^%d^%@_%@", url_str, [Common info].user.mUserid, _photobook.ProductPrice, [_photobook.DefaultStyle lowercaseString], _photobook.AddParams];
        } else {
            url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, @""];
        }
    }
    else if (_photobook.product_type == PRODUCT_CALENDAR) {
	    url_str = [NSString stringWithFormat:URL_CART_ADD_PHOTOBOOK, [Common info].device_uuid]; // 포토북과 동일
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];

		NSString *intnum = @"";
		@try {
			NSString *product_code = _photobook.ProductCode;
			intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
		}
		@catch(NSException *exception) {}
//        if ([intnum isEqualToString:@"277"])
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=14", url_str];
//        else if ([intnum isEqualToString:@"367"])
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=12", url_str];
//        else if ([intnum isEqualToString:@"368"])
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=14", url_str];
//        else if ([intnum isEqualToString:@"369"])
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=15", url_str];
//		// SJYANG : 2018 달력
//        else if ([intnum isEqualToString:@"391"])
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=14", url_str];
//        else if ([intnum isEqualToString:@"392"])
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=12", url_str];
//        else if ([intnum isEqualToString:@"393"])
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=1", url_str];
//		else
//	        url_str = [NSString stringWithFormat:@"%@&monthcount=14", url_str];

		url_str = [NSString stringWithFormat:@"%@&monthcount=%d", url_str, _photobook.monthCount];

		// 포스터 달력 : AddParams
        if ([intnum isEqualToString:@"393"]) 
			url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddParams];
		else
			url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, @""];
		
		if ([intnum isEqualToString:@"369"])
			url_str = [NSString stringWithFormat:@"%@&PrdOpt=%@", url_str, _photobook.AddVal14];
		else
			url_str = [NSString stringWithFormat:@"%@&PrdOpt=%@", url_str, @""];
    }
    else if (_photobook.product_type == PRODUCT_POLAROID || _photobook.product_type == PRODUCT_POSTCARD) {
		url_str = [NSString stringWithFormat:URL_CART_ADD_POLAROID, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddParams];
    }
	// 마그넷
    else if (_photobook.product_type == PRODUCT_MAGNET) {
		url_str = [NSString stringWithFormat:COMMON_URL_CART_ADD_WITH_EDIT, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddParams];
    }
	// SJYANG.2018.05 : 이동헌 대리님 옵션 처리
    else if (_photobook.product_type == PRODUCT_DESIGNPHOTO) {
		url_str = [NSString stringWithFormat:URL_CART_ADD_POLAROID, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddVal6];
    }
    else if (_photobook.product_type == PRODUCT_SINGLECARD || _photobook.product_type == PRODUCT_POSTER || _photobook.product_type == PRODUCT_PAPERSLOGAN
            || _photobook.product_type == PRODUCT_TRANSPARENTCARD) {
        url_str = [NSString stringWithFormat:URL_CART_ADD_POLAROID, [Common info].device_uuid];
        if (_photobook.product_type == PRODUCT_POSTER) {
            url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ProductSize];
            url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ProductSize];
        } else {
            url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
            url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        }
        switch (_photobook.product_type) {
            case PRODUCT_POSTER:
                url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.ProductSize];
                break;
            case PRODUCT_PAPERSLOGAN:
                url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, @""];
                break;
            default:
                url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddVal6];
                break;
        }
    }
    else if (_photobook.product_type == PRODUCT_CARD) {
		NSString* tAddParams = @"";
		NSString* tScodix = @"";

		NSString *params_filepath = [NSString stringWithFormat:@"%@/edit/params.%@", _photobook.base_folder, _photobook.ProductId];
		NSString* tContent = [NSString stringWithContentsOfFile:params_filepath encoding:NSUTF8StringEncoding error:nil];

		NSArray *tArray = [tContent componentsSeparatedByString:@":"];
		tScodix = tArray[0];
		tAddParams = tArray[1];
		if( tScodix == nil ) tScodix = @"";
		if( tAddParams == nil ) tAddParams = @"";

		url_str = [NSString stringWithFormat:COMMON_URL_CART_ADD_WITH_EDIT, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@&scodix=%@", url_str, tAddParams, tScodix];
    }
    else if (_photobook.product_type == PRODUCT_FRAME || _photobook.product_type == PRODUCT_MUG) {
		url_str = [NSString stringWithFormat:URL_CART_ADD_FRAME, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddParams];
    }
    else if (_photobook.product_type == PRODUCT_PHONECASE) {
		url_str = [NSString stringWithFormat:COMMON_URL_CART_ADD_WITH_EDIT, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddParams];
    }
    else if (_photobook.product_type == PRODUCT_BABY) {
		url_str = [NSString stringWithFormat:URL_CART_ADD_BABY, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddParams];

        url_str = [NSString stringWithFormat:@"%@&preorderid=%@", url_str, _photobook.ProductId];
        url_str = [NSString stringWithFormat:@"%@&orderNo=", url_str];
        url_str = [NSString stringWithFormat:@"%@&fileUrl=", url_str];
        url_str = [NSString stringWithFormat:@"%@&file01=%@", url_str, _photobook.AddVal13];
        url_str = [NSString stringWithFormat:@"%@&file02=%@", url_str, _photobook.AddVal14];
        url_str = [NSString stringWithFormat:@"%@&file03=%@", url_str, _photobook.AddVal15];
        url_str = [NSString stringWithFormat:@"%@&file04=", url_str];
        url_str = [NSString stringWithFormat:@"%@&file05=", url_str];
        url_str = [NSString stringWithFormat:@"%@&name01=%@", url_str, _photobook.AddVal1];
        url_str = [NSString stringWithFormat:@"%@&name02=%@", url_str, _photobook.AddVal2];
        url_str = [NSString stringWithFormat:@"%@&memo01=%@", url_str, _photobook.AddVal3];
        url_str = [NSString stringWithFormat:@"%@&memo02=%@", url_str, _photobook.AddVal4];
        url_str = [NSString stringWithFormat:@"%@&option01=%@", url_str, _photobook.AddVal5];
        url_str = [NSString stringWithFormat:@"%@&option02=%@", url_str, _photobook.AddVal6];
        url_str = [NSString stringWithFormat:@"%@&etc01=%@", url_str, _photobook.AddVal7];
        url_str = [NSString stringWithFormat:@"%@&etc02=%@", url_str, _photobook.AddVal8];
    }
    else if (_photobook.product_type == PRODUCT_DIVISIONSTICKER ) {
        url_str = [NSString stringWithFormat:URL_CART_ADD_PHOTOBOOK, [Common info].device_uuid];
        url_str = [NSString stringWithFormat:@"%@ProductName=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&Product_Name=%@", url_str, _photobook.ThemeHangulName];
        url_str = [NSString stringWithFormat:@"%@&ordercount=1&AddParam=%@", url_str, _photobook.AddVal6];
        
    }
    else {
        NSAssert(NO, @"PhotobookUpload.m(addCart): product_type mismatch");
    }
    
    // 양성진 수정/추가
    // 하자보수 이슈 : 보관함에서 주문전송시 페이지 수 연동 오류가 간혹 나오고 있습니다. 근래 오류 주문건은 -> [모바일폴라로이드]인스타포토 세트이며, 페이지수가 0 으로 들어왔습니다.
    if(_photobook.TotalPageCount == 0) {
        _photobook.TotalPageCount = [_photobook getTotalPageCount];
    }

    url_str = [NSString stringWithFormat:@"%@&userid=%@", url_str, [Common info].user.mUserid];
    url_str = [NSString stringWithFormat:@"%@&cart_session=%@", url_str, [PhotomonInfo sharedInfo].cartSession];
    url_str = [NSString stringWithFormat:@"%@&Product_id=%@", url_str, _photobook.ProductId];
    url_str = [NSString stringWithFormat:@"%@&Product_code=%@", url_str, _photobook.ProductCode];
    url_str = [NSString stringWithFormat:@"%@&Product_sel1=%@", url_str, _photobook.ProductOption1];
    url_str = [NSString stringWithFormat:@"%@&Product_sel2=%@", url_str, _photobook.ProductOption2];
    url_str = [NSString stringWithFormat:@"%@&TotalPage=%d", url_str, _photobook.TotalPageCount];
    url_str = [NSString stringWithFormat:@"%@&TotalPrice=%d", url_str, [_photobook getTotalPrice]];
    url_str = [NSString stringWithFormat:@"%@&OrderPage=%d", url_str, _photobook.TotalPageCount];
    url_str = [NSString stringWithFormat:@"%@&SessionID=%@", url_str, [PhotomonInfo sharedInfo].cartSession];
    url_str = [NSString stringWithFormat:@"%@&BasketName=%@", url_str, _photobook.BasketName];
    url_str = [NSString stringWithFormat:@"%@&ordermemo=%@", url_str, @"ios"];
    url_str = [NSString stringWithFormat:@"%@&osinfo=%@", url_str, @"ios"];
	url_str = [NSString stringWithFormat:@"%@&uniquekey=%@", url_str, [Common info].device_uuid];

    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
	url_str = [NSString stringWithFormat:@"%@&app_version=ios_%@", url_str, curVersion]; 
	
	NSLog(@"addCart: %@", url_str);
    
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> checkAddedCartItem xml: %@", data);

        NSString *temp = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (![temp isEqualToString:@"ok"]) {
            NSLog(@">> checkAddedCartItem Failed!!");
            return FALSE;
        }
        NSLog(@">> checkAddedCartItem OK!!");
    }
    return TRUE;
}

@end
