//
//  UploadViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "UploadViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "CartTableViewController.h"
#import "PHAssetUtility.h"
#import "UIView+Toast.h"
#import "ProgressView.h"

@interface UploadViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (strong, nonatomic) ProgressView *progressView;
@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PhotoPrintUpload"];
    
    //

    _backgroundTaskId = 0;
    _uploadPhotos = [[NSMutableArray alloc] init];
    [self initState];
    //MAcheck
    //이동통신망을 이용하면\n별도의 데이터 통화료가 발생할 수있습니다.
    NSString *msg = [NSString stringWithFormat:@"%lu개의 사진파일을 업로드합니다.\n계속하시겠습니까?", (unsigned long)[Common info].photoprint.print_items.count];

    [[Common info]alert:self Title:msg Msg:@"" okCompletion:^{
        [self startUpload];

    } cancelCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];

    } okTitle:@"업로드" cancelTitle:@"취소"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PhotoPrintUpload" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initState {
    if ([[Common info].photoprint isInclueLargeTypePrint]) { // getuploadtypephotoitem 호출 전에 처리해야 함.
        [self.view makeToast:@"대형인화(8x10, A4)가 포함된 경우,\n'유광' 옵션만 가능합니다."];
        [[Common info].photoprint resetSurfaceType];
    }
    if (_backgroundTaskId > 0) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
        _backgroundTaskId = 0;
    }
    
    _is_canceled = FALSE;
    _upload_index = -1;
    [_uploadPhotos removeAllObjects];
    
    self.progressPhoto.hidden = true;
    self.progressTotal.hidden = true;
    
//    _progressPhoto.progress = 0.0f;
//    _progressTotal.progress = 0.0f;
    self.statusLabel.hidden = true;
    
    _statusLabel.text = [NSString stringWithFormat:@"0 / %lu", (unsigned long)[Common info].photoprint.print_items.count];

//    [[PhotomonInfo sharedInfo] loadOrderInfo];
//    NSString *order_num = [PhotomonInfo sharedInfo].orderNumber;

    int idx = 0;
    for (id key in [Common info].photoprint.print_items) {
        PrintItem *temp_item = [[Common info].photoprint.print_items objectForKey:key];
        PrintItem *upload_photo = [temp_item getUploadTypePhotoItem:idx++];
        [_uploadPhotos addObject:upload_photo];
    }
    
    PrintItem *item = (PrintItem *)_uploadPhotos[0];
    if (item.thumb == nil) {
		item.thumb = [item.photoItem getThumbnail];
    }
    if (item.filename == nil || item.filename.length < 1) {
        item.filename = [item.photoItem filename];
    }
    [_thumbView setImage:item.thumb];
    
    if ([item.date_type isEqualToString:@"적용"]) {
		self.lbDate.text = [item.photoItem getCreationDate:@"yyyy.MM.dd"];

    } else {
        self.lbDate.hidden = true;
    }
}

- (void)startUpload {
    if (_uploadPhotos.count > 0) {
        
        self.progressView = [[ProgressView alloc]initWithTitle:@"사진파일 업로드중"];
        // 주문번호 얻어오기
        [[Common info].photoprint initOrderNumber];
        
        _backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@">> Backgrouund task ran out of time and was terminated");
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
            _backgroundTaskId = 0;
        }];
        
        _is_canceled = FALSE;
        _upload_index = 0;
        
        PrintItem *item = (PrintItem *)_uploadPhotos[_upload_index];
        if (item.thumb == nil) {
			item.thumb = [item.photoItem getThumbnail];
        }
        if (item.filename == nil || item.filename.length < 1) {
            item.filename = [item.photoItem filename];
        }
        
        [_thumbView setImage:item.thumb];
        
        if ([item.date_type isEqualToString:@"적용"]) {
            self.lbDate.text = [item.photoItem getCreationDate:@"yyyy.MM.dd"];
        } else {
            self.lbDate.hidden = true;
        }

        

		// 2.0.83 에서 사진인화 업로드가 안되는 버그 수정
		__block NSData *uploadData;

		PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
		options.networkAccessAllowed = YES;
		options.synchronous = YES;
		
		if (item.photoItem.positionType == PHOTO_POSITION_LOCAL) {
			LocalItem *li = (LocalItem *)item.photoItem;
			
			// HEIF Fix
			if([[PHAssetUtility info] isHEIF:li.photo.asset]) {
				// 2017.11.16 : SJYANG : @autoreleasepool 추가
					[li.photo.asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
						if (contentEditingInput.fullSizeImageURL) {
							@autoreleasepool
							{
								CIImage *ciImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
								CIContext *context = [CIContext context];
								uploadData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
	
								if (![[Common info].photoprint uploadImageWithImageData:item withImageData:uploadData UploadController:self]) {
									NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발생하였습니다.", item.filename];
									[[Common info] alert:self Msg:msg];
									[self.navigationController popViewControllerAnimated:YES];
									[self.progressView endProgress];
								}
							}
						}
						else
						{
							NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발생하였습니다.", item.filename];
							[[Common info] alert:self Msg:msg];
	
							[self.navigationController popViewControllerAnimated:YES];
							[self.progressView endProgress];
						}
					}];
			}
			else {
				@autoreleasepool {
					[[PHImageManager defaultManager] requestImageDataForAsset:li.photo.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
						uploadData = [imageData copy];
					}];
				}
	
				if (![[Common info].photoprint uploadImageWithImageData:item withImageData:uploadData UploadController:self]) {
					NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발생하였습니다.", item.filename];
					[[Common info] alert:self Msg:msg];
					[self.navigationController popViewControllerAnimated:YES];
					[self.progressView endProgress];
				}
			}
			
		} else {
			uploadData = UIImageJPEGRepresentation([item.photoItem getOriginal], 1.0f);

			if (![[Common info].photoprint uploadImageWithImageData:item withImageData:uploadData UploadController:self]) {
				NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발생하였습니다.", item.filename];
				[[Common info] alert:self Msg:msg];
				[self.navigationController popViewControllerAnimated:YES];
				[self.progressView endProgress];
			}
		}
    }
}

- (IBAction)cancel:(id)sender {
    if (_upload_index < 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        _is_canceled = TRUE;
    }
}
#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    //NSLog(@"--> %.5f complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
    
    _progressPhoto.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    if (_is_canceled) {
        [connection cancel];
        [self initState];
        [[Common info] alert:self Msg:@"업로드가 취소되었습니다.."];
        [self.navigationController popViewControllerAnimated:YES];
        [self.progressView endProgress];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_upload_index < 0 || _uploadPhotos.count <= 0) return;

    BOOL is_error = FALSE;
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (response == nil) {
        response = [[NSString alloc] initWithData:data encoding:0x80000000 + kCFStringEncodingDOSKorean];
        NSLog(@"--> upload failure: %@", response);
        is_error = TRUE;
    }
    else {
        NSString *temp = [response stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"<UploadCheck>Y</UploadCheck>" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            NSLog(@"--> upload failure: %@", response);
            is_error = TRUE;
        }
    }
    
    if (_is_canceled || is_error) {
        [connection cancel];
        [self initState];
        
        NSString *msg = _is_canceled ? @"업로드가 취소되었습니다." : @"업로드를 실패했습니다.";
        [[Common info] alert:self Msg:msg];
        [self.navigationController popViewControllerAnimated:YES];
        [self.progressView endProgress];
    }
    else {
        if (_upload_index < _uploadPhotos.count - 1) {
			@autoreleasepool {
				_upload_index++;

				PrintItem *item = (PrintItem *)_uploadPhotos[_upload_index];
				if (item.thumb == nil) {
					item.thumb = [item.photoItem getThumbnail];
				}
				if (item.filename == nil || item.filename.length < 1) {
					item.filename = [item.photoItem filename];
				}
				[_thumbView setImage:item.thumb];
				
                if ([item.date_type isEqualToString:@"적용"]) {
					self.lbDate.text = [item.photoItem getCreationDate:@"yyyy.MM.dd"];
                } else {
                    self.lbDate.hidden = true;
                }

                
                [self.progressView manageProgress:(CGFloat)_upload_index / (CGFloat)_uploadPhotos.count title:[NSString stringWithFormat:@"사진파일 업로드중 %d / %lu", _upload_index, (unsigned long)_uploadPhotos.count]];
                
				_progressTotal.progress =
				_progressPhoto.progress = 0.0f;
//                _statusLabel.text = ;
				


				// 2.0.83 에서 사진인화 업로드가 안되는 버그 수정
				/*
				if (![[Common info].photoprint uploadImage:item UploadController:self]) {
					if (_backgroundTaskId > 0) {
						[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
						_backgroundTaskId = 0;
					}

					NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발행하였습니다.", item.filename];
					[[PhotomonInfo sharedInfo] alertMsg:msg];
					[self.navigationController popViewControllerAnimated:YES];
				}
				*/

				__block NSData *uploadData;
				
				if (item.photoItem.positionType == PHOTO_POSITION_LOCAL) {
					LocalItem *li = (LocalItem *)item.photoItem;
					
					PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
					options.networkAccessAllowed = YES;
					options.synchronous = YES;
	
					// HEIF Fix
					if([[PHAssetUtility info] isHEIF:li.photo.asset]) {
						[li.photo.asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
							// 2017.11.21 : SJYANG
							@synchronized(self) {
								if (contentEditingInput.fullSizeImageURL) {
									// 2017.11.21 : SJYANG
									@autoreleasepool
									{
										CIImage *ciImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
										CIContext *context = [CIContext context];
										uploadData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
	
										if (![[Common info].photoprint uploadImageWithImageData:item withImageData:uploadData UploadController:self]) {
											if (_backgroundTaskId > 0) {
												[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
												_backgroundTaskId = 0;
											}
	
											NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발행하였습니다.", item.filename];
											[[Common info] alert:self Msg:msg];
											[self.navigationController popViewControllerAnimated:YES];
	
											[self.progressView endProgress];
										}
									}
								}
								else
								{
									if (_backgroundTaskId > 0) {
										[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
										_backgroundTaskId = 0;
									}
	
									NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발행하였습니다.", item.filename];
									[[Common info] alert:self Msg:msg];
									[self.navigationController popViewControllerAnimated:YES];
									[self.progressView endProgress];
								}
							}
						}];
					}
					else {
						@autoreleasepool {
							[[PHImageManager defaultManager] requestImageDataForAsset:li.photo.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
								uploadData = [imageData copy];
							}];
						}
						if (![[Common info].photoprint uploadImageWithImageData:item withImageData:uploadData UploadController:self]) {
							if (_backgroundTaskId > 0) {
								[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
								_backgroundTaskId = 0;
							}
	
							NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발행하였습니다.", item.filename];
							[[Common info] alert:self Msg:msg];
							[self.navigationController popViewControllerAnimated:YES];
						}
					}
					
				} else {
					
					uploadData = UIImageJPEGRepresentation([item.photoItem getOriginal], 1.0f);
					
					if (![[Common info].photoprint uploadImageWithImageData:item withImageData:uploadData UploadController:self]) {
						if (_backgroundTaskId > 0) {
							[[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
							_backgroundTaskId = 0;
						}
						
						NSString *msg = [NSString stringWithFormat:@"%@ 전송 중에 오류가 발행하였습니다.", item.filename];
						[[Common info] alert:self Msg:msg];
						[self.navigationController popViewControllerAnimated:YES];
					}
				}

			}
        }
        else {
            if ([[Common info].photoprint addCart]) {
                [Analysis log:@"PhotoPrintUploadComplete"];
                if (_backgroundTaskId > 0) {
                    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
                    _backgroundTaskId = 0;
                }
                
                [self.progressView manageProgress:1.0 title:[NSString stringWithFormat:@"사진파일 업로드중 %d / %lu", _upload_index, (unsigned long)_uploadPhotos.count]];



                [[Common info]alert:self Title:@"업로드를 완료했습니다." Msg:@"" completion:^{
                    // 선택 리스트를 초기화 합니다.
                [self.progressView endProgress];
                    [[Common info].photoprint.print_items removeAllObjects];
                    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                    [[PhotomonInfo sharedInfo].mainViewController onCartviaExternalController];
                }];
            }
            else {
                [self initState];
                [[Common info] alert:self Msg:@"업로드를 실패했습니다."];
                [self.navigationController popViewControllerAnimated:YES];
                [self.progressView endProgress];
            }
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
    NSLog(@"error !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    NSLog(@"%@", error.localizedDescription);
    [self initState];
	// 2017.11.21 : SJYANG
    [[Common info] alert:self Msg:@"네트워크에 문제가 있어, 업로드를 실패했습니다."];
    [self.navigationController popViewControllerAnimated:YES];
    [self.progressView endProgress];
}

@end
