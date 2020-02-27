//
//  MonthlyBaby.m
//  PHOTOMON
//
//  Created by 곽세욱 on 08/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MonthlyBaby.h"
#import "Common.h"
#import "PHAssetUtility.h"

@implementation MonthlyAddProductInfo

@end

@implementation MonthlyBaby

// thread safe singleton
+ (MonthlyBaby *)inst {
	static dispatch_once_t pred;
	static MonthlyBaby *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[MonthlyBaby alloc] init];
		
		instance.addProducts = [[NSMutableArray alloc] init];
		instance.selectedAddProduct = [[NSMutableArray alloc] init];
	});
	return instance;
}

- (void) initialize {
	_isSeperated = _currentUploadCount > _maxUploadCountPerBook;
	_markDate = YES;
	[_selectedAddProduct removeAllObjects];
	_orderingType = 0;
	_designTheme = 0;
	_orderBookCount = 1;
	_coverImageKey = @"";
	_trimInfo = @"";
	_mainTitle = @"";
	_subTitle = @"";
	
	[[Common info].photo_pool removeAll]; // 선택한 사진이 없게 수정.
}

- (BOOL) loadBaseData {
	NSData *url_ret = [[Common info] downloadSyncWithURL:[NSURL URLWithString:[NSString stringWithFormat:URL_GET_UPLOAD_SERVER_BY_SVCMODE, @"monthlybaby"]]];
	if (url_ret != nil) {
		_uploadURL = [[NSString alloc] initWithData:url_ret encoding:NSUTF8StringEncoding];
	} else {
		// failed to dispatch URL
		if (_uploadURL == nil || [_uploadURL length] <= 0)
			return FALSE;
	}
	
	NSData *addProduct_ret = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_MONTHLY_ADDPRODUCT_LIST]];
	if (addProduct_ret != nil) {
		NSError *error;
		
		NSDictionary *json_data = [NSJSONSerialization
								   JSONObjectWithData:addProduct_ret
								   options:kNilOptions
								   error:&error];
		if (error) {
			NSLog(@"error : %@", error.localizedDescription);
		} else {
			[_addProducts removeAllObjects];
			
			for (NSDictionary *dics in [json_data objectForKey:@"items"]) {
				
				MonthlyAddProductInfo *info = [[MonthlyAddProductInfo alloc] init];
				info.intnum = [dics objectForKey:@"intnum"];
				info.seq = [dics objectForKey:@"seq"];
				info.price = [dics objectForKey:@"price"];
				info.pkgname = [dics objectForKey:@"pkgname"];
				info.seloption = [dics objectForKey:@"seloption"];
				info.thumb = [dics objectForKey:@"url_thumb"];
				
				[_addProducts addObject:info];
			}
		}
		
	} else {
		// failed to dispatch URL
		if([_addProducts count] <= 0)
			return FALSE;
	}
	
	return TRUE;
}

- (BOOL) loadData:(NSString *)getcode {
	
	if ([Common info].user.mUserid.length > 0) {
		NSURL *reqURL = [Common buildQueryURL:URL_GET_SUBSCRIPTION_INFO
										query:@[
												[NSURLQueryItem queryItemWithName:@"userid" value:[Common info].user.mUserid]
												,[NSURLQueryItem queryItemWithName:@"uniquekey" value:[Common info].device_uuid]
												,[NSURLQueryItem queryItemWithName:@"getcode" value:getcode]
												]];
		
		NSData *ret_val = [[Common info] downloadSyncWithURL:reqURL];
		NSError *error;
		
		if (ret_val != nil) {
			NSDictionary *json_data = [NSJSONSerialization
									   JSONObjectWithData:ret_val
									   options:kNilOptions
									   error:&error];
			if (error) {
				NSLog(@"error : %@", error.localizedDescription);
			} else {
				NSString *maxCount = [json_data objectForKey:@"maxcount"];
				NSString *uploadMaxCount = [json_data objectForKey:@"upload_maxcount"];
				NSString *uploadCount = [json_data objectForKey:@"imgcount"];
				NSString *deadline = [json_data objectForKey:@"deadline"];
				if (maxCount) {
					_maxUploadCountPerBook = [maxCount intValue];
				}
				_maxUploadCountPerBook = _maxUploadCountPerBook > 0 ? _maxUploadCountPerBook : 440;
				
				if (uploadMaxCount){
					_maxUploadCountTotal = [uploadMaxCount intValue];
				}
				_maxUploadCountTotal = _maxUploadCountTotal > 0 ? _maxUploadCountTotal : 880;
				
				if (uploadCount){
					_currentUploadCount = [uploadCount intValue];
				}
				_currentUploadCount = _currentUploadCount > 0 ? _currentUploadCount : 0;
				
				if (deadline) {
					_deadline = deadline;
				}
			}
		}
	}
	
	return TRUE;
}

- (void) uploadImage:(PhotoItem *)item url:(NSURL *)url params:(NSDictionary *)params delegate:(nonnull id)delegate {
	@autoreleasepool
	{
		// HEIF Fix
		@autoreleasepool
		{
			__block UIImageOrientation ph_orientation = UIImageOrientationUp;
			
			__block NSData *org_data;
			
			NSMutableDictionary *newParams = [NSMutableDictionary dictionary];
			
			if (params != nil) {
				[newParams addEntriesFromDictionary:params];
			}
			
			[newParams setObject:item.creationDate forKey:@"savetime"];
			
			if (item.positionType == PHOTO_POSITION_LOCAL) {
				LocalItem *local = (LocalItem *)item;
				if([[PHAssetUtility info] isHEIF:local.photo.asset]) {
					
					[local.photo.asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
						@synchronized(self) {
							if (contentEditingInput.fullSizeImageURL) {
								// 2017.11.16 : SJYANG : @autoreleasepool 추가
								@autoreleasepool
								{
									CIImage *ciImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
									CIContext *context = [CIContext context];
									org_data = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
									
									[self sendToServer:url params:newParams imageData:org_data filename:local.filename  delegate:delegate];
								}
							}
						}
					}];
				}
				else {
					PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
					options.networkAccessAllowed = YES;
					options.synchronous = YES;
					
					[[PHImageManager defaultManager] requestImageDataForAsset:local.photo.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
						
						org_data = [imageData copy];
						
						ph_orientation = orientation;
					}];
					
					[self sendToServer:url params:newParams imageData:org_data filename:local.filename  delegate:delegate];
				}
			} else {
				SocialItem *social = (SocialItem *)item;
				
				NSData *org_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:social.mainURL]];
				
				[self sendToServer:url params:newParams imageData:org_data filename:social.filename  delegate:delegate];
			}
			
		}
	}
}

- (void) sendToServer:(NSURL *)url params:(NSDictionary *)params imageData:(nullable NSData *)imageData filename:(NSString *)filename delegate:(nonnull id)delegate {
	
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
	
	//				[params setObject:[Common info].device_uuid forKey:@"uniquekey"];
	
	// add params
	if (params != nil) {
	
		for (NSString *param in params) {
			[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		
	}
	
	//	NSString *str= [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
	//	NSLog(str);
	
	// add file
	if (imageData) {
		NSString *type_name = @"multi_file";
		NSString *content_type = @"image/jpeg";
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", type_name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", content_type] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:imageData];
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
	[request setURL:url];
	
	// start upload
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
	[connection start];
}

- (void) sendToServer:(NSURL *)url params:(NSDictionary *)params delegate:(nonnull id)delegate {
//	[self sendToServer:url params:params imageData:nil filename:@"" delegate:delegate];
	
	// make request
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPShouldHandleCookies:NO];
	[request setTimeoutInterval:60.0f];
	[request setHTTPMethod:@"POST"];
	
	NSString *body = @"";
	
	// add params
	if (params != nil) {
		
		for (NSString *param in params) {
			NSString *paramStr = [NSString stringWithFormat:@"%@=%@", param, [params objectForKey:param]];
			if (body.length > 0) {
				body = [body stringByAppendingString:@"&"];
			}
			body = [body stringByAppendingString:paramStr];
		}
	}
	
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setURL:url];
	
	// start upload
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
	[connection start];
}
@end
