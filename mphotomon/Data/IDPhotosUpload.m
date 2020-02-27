//
//  PhotobookUpload.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 14..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosUpload.h"
#import "PhotomonInfo.h"
#import "Common.h"

@implementation IDPhotosUpload

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)dealloc {
}

- (void)clear {
	_orderno = @"";
	_parsing_element = @"";
}

- (BOOL)prepareUploadServer {
    if (_idphotos == nil) return FALSE;

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_UPLOAD_SERVER, _idphotos.idphotos_product.product.item_product_code];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *server_name = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook upload server: %@", server_name);

        if (server_name.length > 0) {
            //_upload_url = [NSString stringWithFormat:URL_PRODUCT_UPLOAD_PATH, server_name];
			_upload_url = [Common info].idphotos.upload_url;
	        NSLog(@">> _upload_url: %@", _upload_url);
            
            // ProductID 새로 생성.
            _idphotos.idphotos_product.product_id = [[Common info] createProductId:_idphotos.idphotos_product.product.item_product_code];
            
			// SJYANG : 필요한지???
            //"http://" + reponse value + ".photomon.com/upload/upload_check.asp?product_id="+제작코드
            _check_url = [NSString stringWithFormat:URL_PRODUCT_UPLOAD_CHECK, server_name, _idphotos.idphotos_product.product_id];

			[self initOrderNumber];
			
			return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)uploadFile:(int)index UploadController:(id)upload_controller {
	NSData *uploadData;
	if(index == 0) {
		NSString *name = [NSString stringWithFormat:@"%@_%03d.jpg", _idphotos.idphotos_product.product_id, index+1];
		[self makeThumb:0 ToFile:name];
		uploadData = _thumb_data;
	}
	else if(index == 1)
		 uploadData = UIImageJPEGRepresentation(_upload_image, 0.5);
	//uploadData = _thumb_data;
    if (uploadData == nil) return FALSE;
    
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

    [params setObject:@"1" forKey:@"PageNO"];
    [params setObject:_idphotos.idphotos_product.product_id forKey:@"Product_id"];
    [params setObject:_idphotos.idphotos_product.product.item_product_code forKey:@"Product_code"];
	
    // add params
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];

		NSLog(@"TEST-NAME : %@", [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param]);
		NSLog(@"TEST-VALUE : %@", [NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]]);
    }
    
    // add file
    if (uploadData) {
        NSString *type_name = (index == 0) ? @"thumbfile" : @"orifile";
		//type_name = @"thumbfile";
        NSString *content_type = @"image/jpeg";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", type_name, item.uploadfilename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", type_name, [NSString stringWithFormat:@"%@_%03d.jpg", _idphotos.idphotos_product.product_id, index+1]] dataUsingEncoding:NSUTF8StringEncoding]];
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

- (BOOL)addCart {
    NSString *url_str = @"";
 
    url_str = [NSString stringWithFormat:URL_CART_ADD_IDPHOTOS, [Common info].device_uuid];

	NSString *product_name = [NSString stringWithFormat:@"%@(%@매)", _idphotos.idphotos_product.product.item_product_name, _idphotos.idphotos_product.product.item_product_count];

    url_str = [NSString stringWithFormat:@"%@&userid=%@", url_str, [Common info].user.mUserid];
	url_str = [NSString stringWithFormat:@"%@&orderno=%@", url_str, _orderno];
	url_str = [NSString stringWithFormat:@"%@&cart_session=%@", url_str, [PhotomonInfo sharedInfo].cartSession];
	url_str = [NSString stringWithFormat:@"%@&Product_id=%@", url_str, _idphotos.idphotos_product.product_id];
	url_str = [NSString stringWithFormat:@"%@&ProductCode=%@", url_str, _idphotos.idphotos_product.product.item_product_code];
	url_str = [NSString stringWithFormat:@"%@&ProductName=%@", url_str, product_name];
	url_str = [NSString stringWithFormat:@"%@&price=%@", url_str, _idphotos.idphotos_product.product.item_product_price]; 
	url_str = [NSString stringWithFormat:@"%@&pkgcnt=1", url_str]; // item_product_price??
	url_str = [NSString stringWithFormat:@"%@&ordermemo=ios", url_str];
	url_str = [NSString stringWithFormat:@"%@&osinfo=ios", url_str];
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

        NSRange range = [data rangeOfString:@"<mCheck>Y</mCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            NSLog(@">> checkAddedCartItem Failed!!");
            return FALSE;
        }
        NSLog(@">> checkAddedCartItem OK!!");
    }
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

- (void)makeThumb:(int)index ToFile:(NSString *)file {
	/*
    UIImageView *bkview = nil;
	bkview = [[UIImageView alloc] init];
	bkview.backgroundColor = [UIColor whiteColor];
    [bkview setFrame:_page_rect];
    
    //[self composePage:index ParentView:bkview IncludeBg:NO IsEdit:NO];
    
    UIGraphicsBeginImageContextWithOptions(bkview.bounds.size, NO, 0);
    [bkview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	*/

	CGFloat fsizeval = 500.0f / 660.0f;

	CGFloat width, height;
	width = 500;
	height = 333;

	//UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.0);        
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef context = UIGraphicsGetCurrentContext();       
	UIGraphicsPushContext(context);                             

    if ([[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239051"]) {
		[_upload_image drawInRect:CGRectMake(15.0f * fsizeval, 7.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(143.0f * fsizeval, 7.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(270.0f * fsizeval, 7.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(399.0f * fsizeval, 7.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(526.0f * fsizeval, 7.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];

		[_upload_image drawInRect:CGRectMake(15.0f * fsizeval, 150.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(143.0f * fsizeval, 150.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(270.0f * fsizeval, 150.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(399.0f * fsizeval, 150.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(526.0f * fsizeval, 150.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];

		[_upload_image drawInRect:CGRectMake(15.0f * fsizeval, 293.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(143.0f * fsizeval, 293.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(270.0f * fsizeval, 293.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(399.0f * fsizeval, 293.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(526.0f * fsizeval, 293.0f * fsizeval, 117.0f * fsizeval, 140.0f * fsizeval)];
	}
	else if ([[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239052"]) {
		[_upload_image drawInRect:CGRectMake(22.0f * fsizeval, 25.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(180.0f * fsizeval, 25.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(339.0f * fsizeval, 25.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(498.0f * fsizeval, 25.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];

		[_upload_image drawInRect:CGRectMake(22.0f * fsizeval, 231.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(180.0f * fsizeval, 231.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(339.0f * fsizeval, 231.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(498.0f * fsizeval, 231.0f * fsizeval, 139.0f * fsizeval, 183.0f * fsizeval)];
	}
	else if ([[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239053"]) {
		[_upload_image drawInRect:CGRectMake(38.0f * fsizeval, 12.0f * fsizeval, 161.0f * fsizeval, 205.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(249.0f * fsizeval, 12.0f * fsizeval, 161.0f * fsizeval, 205.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(459.0f * fsizeval, 12.0f * fsizeval, 161.0f * fsizeval, 205.0f * fsizeval)];

		[_upload_image drawInRect:CGRectMake(38.0f * fsizeval, 222.0f * fsizeval, 161.0f * fsizeval, 205.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(249.0f * fsizeval, 222.0f * fsizeval, 161.0f * fsizeval, 205.0f * fsizeval)];
		[_upload_image drawInRect:CGRectMake(459.0f * fsizeval, 222.0f * fsizeval, 161.0f * fsizeval, 205.0f * fsizeval)];
	}
	else if ([[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239054"]) {
        // 2018.02.28. daypark. 명함사진 2매 -> 3매 변경
//        [_upload_image drawInRect:CGRectMake(80.0f * fsizeval, 63.0f * fsizeval, 228.0f * fsizeval, 313.0f * fsizeval)];
//        [_upload_image drawInRect:CGRectMake(351.0f * fsizeval, 63.0f * fsizeval, 228.0f * fsizeval, 313.0f * fsizeval)];
        [_upload_image drawInRect:CGRectMake(38.0f * fsizeval, 83.0f * fsizeval, 160.0f * fsizeval, 224.0f * fsizeval)];
        [_upload_image drawInRect:CGRectMake(249.0f * fsizeval, 83.0f * fsizeval, 160.0f * fsizeval, 224.0f * fsizeval)];
        [_upload_image drawInRect:CGRectMake(459.0f * fsizeval, 83.0f * fsizeval, 160.0f * fsizeval, 224.0f * fsizeval)];
	}

	UIGraphicsPopContext();                             
	UIImage *thumb_image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();


    NSData *data = UIImageJPEGRepresentation(thumb_image, 1.0f);

    NSString *docPath = [[Common info] documentPath];  // 도큐먼트 폴더 찾기
    NSString *baseFolder = [NSString stringWithFormat:@"%@/idphotos", docPath];
    [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", baseFolder, file] atomically:YES];

	_thumb_data = data;
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
