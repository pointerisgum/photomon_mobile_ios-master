//
//  DdukddakUploadPopupViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 2019/10/12.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "DdukddakUploadPopupViewController.h"
#import "Common.h"

@interface DdukddakUploadPopupViewController ()

@end

@implementation DdukddakUploadPopupViewController

- (void) setData:(int)totalCount uploadURL:(NSString *)url svcmode:(NSString *)svcmode uploadDoneOp:(void(^)(BOOL, NSString*))uploadDoneOp {
	_totalCount = totalCount;
	_uploadURL = url;
	_svcmode = svcmode;
	_uploadDoneOp = uploadDoneOp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_backgroundTaskId = 0;
	
	_totalCountLabel.text = [NSString stringWithFormat:@"%d장의 사진", _totalCount];
	
	_uploadCount = 0;
	
	if (_totalCount < 1) {
		//얼러트 후 뒤로가기
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	
	[self updateUI:FALSE];
}

- (void) viewDidAppear:(BOOL)animated {
	// 업로드 시작
	[self startUpload];
}

-(void) updateUI:(BOOL)isDone {
	if (isDone) {
		_progress.progress = 1.0f;
		_uploadCountLabel.text = [NSString stringWithFormat:@"업로드 완료"];
	}
	else {
		float per_one = 1 / (float)_totalCount;
		
		float progress = (float)_uploadCount / (float)_totalCount + per_one * _cur_upload_per;
		
		_progress.progress = progress;
		_uploadCountLabel.text = [NSString stringWithFormat:@"%d번째의 사진을 업로드 중", _uploadCount + 1];
	}

}

- (void)startUpload {
	_backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		NSLog(@">> Background task ran out of time and was terminated");
		[[UIApplication sharedApplication] endBackgroundTask:self->_backgroundTaskId];
		self->_backgroundTaskId = 0;
	}];
	
	PhotoItem *photo = [[PhotoContainer inst] getSelectedItem:0];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	[params setObject:[Common info].user.mUserid forKey:@"userid"];
	[params setObject:_svcmode forKey:@"svcmode"];
	
	[self uploadImage:photo url:[Common buildQueryURL:_uploadURL query:@[]] params:params delegate:self];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//	NSLog(@"--> %.5f complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
	
	_cur_upload_per = (float)((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
	[self updateUI:FALSE];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//	if (_upload_index < 0 || _uploader.items.count <= 0) return;
	
	BOOL is_error = FALSE;
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (response == nil || [response isEqualToString:@"err"]) {
		response = [[NSString alloc] initWithData:data encoding:0x80000000 + kCFStringEncodingDOSKorean];
		NSLog(@"--> upload failure: %@", response);
		is_error = TRUE;
	} else {
		_uploadCount++;
		if (_uploadCount < _totalCount){
//			Photo *photo = [[Common info].photo_pool.sel_photos objectAtIndex:_uploadCount];
			PhotoItem *photo = [[PhotoContainer inst] getSelectedItem:_uploadCount];
			
			NSMutableDictionary *params = [NSMutableDictionary dictionary];
			
			[params setObject:[Common info].user.mUserid forKey:@"userid"];
			[params setObject:_svcmode forKey:@"svcmode"];
			
			[self uploadImage:photo url:[Common buildQueryURL:_uploadURL query:@[]] params:params delegate:self];
		}
		else {
			// 업로드 끝
			if (_backgroundTaskId > 0) {
				[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
				_backgroundTaskId = 0;
			}
			
			NSArray *retData = [response componentsSeparatedByString:@"|"];

			[self dismissViewControllerAnimated:YES completion:^{
				if(self->_uploadDoneOp) {
					self->_uploadDoneOp(YES, retData[0]);
				}
			}];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// A response has been received, this is where we initialize the instance var you created
	// so that we can append data to it in the didReceiveData method
	// Furthermore, this method is called each time there is a redirect so reinitializing it
	// also serves to clear it
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[connection cancel];
	//에러처리 필요
	[self dismissViewControllerAnimated:YES completion:^{
		if(self->_uploadDoneOp) {
			self->_uploadDoneOp(NO, @"");
		}
	}];
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
