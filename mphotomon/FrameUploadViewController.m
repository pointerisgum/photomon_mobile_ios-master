//
//  FrameUploadViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 2. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "FrameUploadViewController.h"
#import "UIView+Toast.h"
#import "Analysis.h"
#import "Common.h"

@interface FrameUploadViewController ()

@end

@implementation FrameUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PhotoProductUpload"];
    
    [self initState];
    [self setTitle:@"액자 업로드"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PhotoProductUpload" ScreenClass:[self.classForCoder description]];
}
//check
- (void)viewWillAppear:(BOOL)animated {
    [[Common info]alert:self Title:@"편집된 내용을 \n주문전송 하시겠습니까?" Msg:@"" okCompletion:^{
        
        [self.wait_indicator startAnimating];
        
        self.uploader = [[PhotobookUpload alloc] init];
        self.uploader.photobook = [Common info].photobook;
        self.uploader.photobook.delegate = self;
        
        if ([self.uploader prepareUploadServer]) {
            [self startUpload];
        }
        else {
            [self closeMessage:@"서버와 연결할 수 없습니다."];
        }

    } cancelCompletion:^{
        [self dismissViewControllerAnimated:YES completion:nil];

    } okTitle:@"" cancelTitle:@""];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [_uploader prepareItemsFrame:_photofilelist];
    if (_uploader.items.count <= 0) {
        [self closeMessage:@"미리보기 파일 생성 중에 오류가 발생하였습니다."];
    }
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
        [_uploader clear];
        [self dismissViewControllerAnimated:YES completion:nil];

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
    if (_upload_index < 0 || _uploader.items.count <= 0) return;
    
    BOOL is_error = FALSE;
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (response == nil || ![response isEqualToString:@"ok"]) {
        response = [[NSString alloc] initWithData:data encoding:0x80000000 + kCFStringEncodingDOSKorean];
        NSLog(@"--> upload failure: %@", response);
        is_error = TRUE;
    }
    
    if (_is_canceled || is_error) {
        [connection cancel];
        NSString *msg = _is_canceled ? @"파일 전송이 취소되었습니다." : @"파일 전송에 실패했습니다.";
        [self closeMessage:msg];
    }
    else {
        if (_upload_index < _uploader.items.count - 1) {
            _upload_index++;
            
            _progressTotal.progress = (CGFloat)_upload_index / (CGFloat)_uploader.items.count;
            _progressPhoto.progress = 0.0f;
            _statusLabel.text = [NSString stringWithFormat:@"%d / %lu", _upload_index, (unsigned long)_uploader.items.count];
            _messageLabel.text = @"파일을 전송 중입니다..";
            
            if (![_uploader uploadFile:_upload_index UploadController:self]) {
                [connection cancel];
                [self closeMessage:@"파일 전송에 실패했습니다."];
            }
        }
        else {
            if ([_uploader checkUploadResult] && [_uploader addCart]) {
                [Analysis log:@"PhotoProductUploadComplete"];
                if (_backgroundTaskId > 0) {
                    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
                    _backgroundTaskId = 0;
                }
                
                [_wait_indicator stopAnimating];
                
                _progressTotal.progress = 1.0f;
                _progressPhoto.progress = 1.0f;
                _statusLabel.text = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)_uploader.items.count, (unsigned long)_uploader.items.count];
                _messageLabel.text = @"파일 전송을 완료했습니다.";
                
                
                [[Common info]alert:self Title:@"파일 전송을 완료했습니다." Msg:@"" completion:^{
                    [self.uploader clear];
                    
                    [self dismissViewControllerAnimated:NO completion:^{
                        [self.delegate completeUpload];
                    }];
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
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error !!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    [connection cancel];
    [self closeMessage:@"파일 전송에 실패했습니다."];
}

#pragma mark - PhotobookDelegate methods

- (void)photobookProcess:(int)count TotalCount:(int)total_count {
}

- (void)photobookError {
}

@end
