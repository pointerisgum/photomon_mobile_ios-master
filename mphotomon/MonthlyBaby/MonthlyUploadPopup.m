//
//  MonthlyUploadPopup.m
//  PHOTOMON
//
//  Created by 곽세욱 on 07/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MonthlyUploadPopup.h"
#import "Common.h"
#import "PHAssetUtility.h"

@interface MonthlyUploadPopup ()

@end

@implementation MonthlyUploadPopup

- (void) setData:(int)totalCount svcmode:(NSString *)svcmode uploadDoneOp:(void(^)(BOOL, NSString*))uploadDoneOp {
	_totalCount = totalCount;
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
		if ([_svcmode isEqualToString:@"monthlybaby"]) {
			float per_one = 1 / (float)_totalCount;
			
			float progress = (float)_uploadCount / (float)_totalCount + per_one * _cur_upload_per;
			//		NSLog(@"%f", progress);
			
			_progress.progress = progress;
			_uploadCountLabel.text = [NSString stringWithFormat:@"%d번째의 사진을 업로드 중", _uploadCount + 1];
		} else if ([_svcmode isEqualToString:@"monthlycover"]) {
			_progress.progress = _cur_upload_per;
			_uploadCountLabel.text = [NSString stringWithFormat:@"커버 사진을 업로드 중", _uploadCount + 1];
		}
	}

}

- (void)startUpload {
	_backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		NSLog(@">> Background task ran out of time and was terminated");
		[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
		_backgroundTaskId = 0;
	}];
	
//	Photo *photo = [[Common info].photo_pool.sel_photos objectAtIndex:0];
	PhotoItem *photo = [[PhotoContainer inst] getSelectedItem:0];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	[params setObject:[Common info].user.mUserid forKey:@"userid"];
	[params setObject:_svcmode forKey:@"svcmode"];
	
	[[MonthlyBaby inst] uploadImage:photo url:[Common buildQueryURL:[MonthlyBaby inst].uploadURL query:@[]] params:params delegate:self];
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
			
			[[MonthlyBaby inst] uploadImage:photo url:[Common buildQueryURL:[MonthlyBaby inst].uploadURL query:@[]] params:params delegate:self];
		}
		else {
			// 업로드 끝
			if (_backgroundTaskId > 0) {
				[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
				_backgroundTaskId = 0;
			}
			
			NSArray *retData = [response componentsSeparatedByString:@"|"];

			[self dismissViewControllerAnimated:YES completion:^{
				if(_uploadDoneOp) {
					_uploadDoneOp(YES, retData[0]);
				}
			}];
//			[_delegate uploadPhotoDone:YES imageKey:retData[0]];
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
//	[_delegate uploadPhotoDone:NO];
	[self dismissViewControllerAnimated:YES completion:^{
		if(_uploadDoneOp) {
			_uploadDoneOp(NO, @"");
		}
	}];
//	[_delegate uploadPhotoDone:NO imageKey:@""];
}

@end
