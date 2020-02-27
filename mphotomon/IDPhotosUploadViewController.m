//
//  IDPhotosUploadViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 14..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosUploadViewController.h"
#import "UIView+Toast.h"

@interface IDPhotosUploadViewController ()

@end

@implementation IDPhotosUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"IDPhotosUpload"];
    
    [self initState];
    
    //MAcheck
    [[Common info]alert:self Title:@"사진을 주문전송 하시겠습니까?" Msg:@"" okCompletion:^{
        [self.wait_indicator startAnimating];
        
        self.uploader = [[IDPhotosUpload alloc] init];
        self.uploader.idphotos = [Common info].idphotos;
        self.uploader.upload_image = self.upload_image;
        
        // 중복 체크
        if ([self.uploader prepareUploadServer]) {
            [self startUpload];
        }
        else {
            [self closeMessage:@"서버와 연결할 수 없습니다."];
        }

    } cancelCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];

    } okTitle:@"네" cancelTitle:@"아니오"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosUpload" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initState {
    _backgroundTaskId = 0;
    _cancel_button.enabled = NO;
    _is_canceled = FALSE;
    _upload_index = -1;
    
    _progressPhoto.progress = 0.0f;
    _progressTotal.progress = 0.0f;
    _statusLabel.text = @"0 / 0";
    _messageLabel.text = @"미리보기 파일을 생성 중입니다..";
}

- (void)startUpload {
    _backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@">> Backgrouund task ran out of time and was terminated");
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
        _backgroundTaskId = 0;
    }];
    
    _cancel_button.enabled = YES;
    
    _is_canceled = FALSE;
    _upload_index = 0;
    if (![_uploader uploadFile:_upload_index UploadController:self]) {
        [self closeMessage:@"파일 전송 중에 오류가 발생하였습니다."];
    }
}

- (IBAction)cancel:(id)sender {
    if (_upload_index < 0) {
        [self closeMessage:@"파일 전송이 취소되었습니다."];
    }
    else {
        _is_canceled = TRUE;
    }
}

- (void)closeMessage:(NSString *)msg {
    if (_backgroundTaskId > 0) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
        _backgroundTaskId = 0;
    }

    [[Common info]alert:self Title:msg Msg:@"" completion:^{
        [self.uploader clear];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    //NSLog(@"--> %.5f complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
    
    _progressPhoto.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    if (_is_canceled) {
        [connection cancel];
        [self closeMessage:@"파일 전송이 취소되었습니다."];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_upload_index < 0) return;

    BOOL is_error = FALSE;
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (response == nil || ![response isEqualToString:@"ok"]) {
        response = [[NSString alloc] initWithData:data encoding:0x80000000 + kCFStringEncodingDOSKorean];
        NSLog(@"--> upload failure: %@", response);
        is_error = TRUE;
    }
	NSLog(@"UPLOAD_RESULT : %@", response);
    
    if (_is_canceled || is_error) {
        [connection cancel];
        NSString *msg = _is_canceled ? @"파일 전송이 취소되었습니다." : @"파일 전송에 실패했습니다.";
        [self closeMessage:msg];
    }
    else {
        if (_upload_index < 1) {
            _upload_index++;
            
            _progressTotal.progress = (CGFloat)_upload_index / 1.0f;
            _progressPhoto.progress = 0.0f;
            _statusLabel.text = [NSString stringWithFormat:@"%d / 1", _upload_index];
            _messageLabel.text = @"파일을 전송 중입니다..";
            
            if (![_uploader uploadFile:_upload_index UploadController:self]) {
                [connection cancel];
                [self closeMessage:@"파일 전송에 실패했습니다."];
            }
        }
        else {
            //if ([_uploader checkUploadResult] && [_uploader addCart]) {
            if ([_uploader addCart]) {
                [Analysis log:@"IDphotosUploadComplete"];
                if (_backgroundTaskId > 0) {
                    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
                    _backgroundTaskId = 0;
                }
                
                [_wait_indicator stopAnimating];
                
                _progressTotal.progress = 1.0f;
                _progressPhoto.progress = 1.0f;
                _statusLabel.text = [NSString stringWithFormat:@"1 / 1"];
                _messageLabel.text = @"파일 전송을 완료했습니다.";

                [[Common info]alert:self Title:@"파일 전송을 완료했습니다." Msg:@"" completion:^{
                    [self.uploader clear];
                    
                    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                    [[Common info].main_controller onCartviaExternalController];
                }];
            }
            else {
                [connection cancel];
                [self closeMessage:@"파일 전송에 실패했습니다."];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    [connection cancel];
    [self closeMessage:@"파일 전송에 실패했습니다."];
}

@end
