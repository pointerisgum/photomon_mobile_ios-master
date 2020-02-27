//
//  PhotobookUploadViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 14..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotobookUploadViewController.h"
#import "UIView+Toast.h"
#import "ProgressView.h"

@interface PhotobookUploadViewController ()
@property (strong, nonatomic) ProgressView *progressView;

@end

@implementation PhotobookUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PhotoProductUpload"];
    
    [self initState];
    _statusLabel.hidden = true;
    
    NSString *msg = @"선택한 보관함을 주문전송\n하시겠습니까?";
    
    // 포토북의 경우, 제목 입력을 확인해 본다.
    // cmh. 180822. 구닥북일 경우 제목에 관련된 메세지는 안나옴
    if ([Common info].photobook.product_type == PRODUCT_PHOTOBOOK) {
        NSLog(@"[Common info].photobook : %@", [Common info].photobook.ProductCode);

        BOOL titleLayerFound = NO;

        for (Layer *layer in [[Common info].photobook.pages[0] layers]) {
            if (layer.AreaType == 2) {
                titleLayerFound = YES;
                break;
            }
        }
        // SJYANG : 프리미엄북의 경우 책 제목 체크 PASS
        if ( [Common info].photobook.title.length < 1
            && ![[Common info].photobook.ThemeName isEqualToString:@"premium"]
            && ![[Common info] isGudakBook:[Common info].photobook.ProductCode]
                && titleLayerFound) {
            msg = @"책 제목이 편집되지 않았습니다. 그대로 주문 전송 하시겠습니까?\n편집 화면 -> 커버 메뉴 선택 -> 책 제목 입력에서 편집 가능";
        }
        [self setTitle:@"포토북 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_CALENDAR) {
        [self setTitle:@"달력 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_POLAROID) {
        [self setTitle:@"폴라로이드 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_CARD) {
        [self setTitle:@"포토카드 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_MUG) {
        [self setTitle:@"머그컵 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_PHONECASE) {
        [self setTitle:@"폰케이스 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_POSTCARD) {
        [self setTitle:@"포토엽서 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_BABY) {
        [self setTitle:@"미니스탠딩 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_MAGNET) {
        [self setTitle:@"냉장고자석 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_POSTER) {
        [self setTitle:@"포스터 업로드"];
    }
    else if ([Common info].photobook.product_type == PRODUCT_PAPERSLOGAN) {
        [self setTitle:@"종이슬로건 업로드"];
    }
    //MAcheck
    
    [[Common info]alert:self Title:msg Msg:@"" okCompletion:^{
        [self.wait_indicator startAnimating];
        
        self.uploader = [[PhotobookUpload alloc] init];
        self.uploader.photobook = [Common info].photobook;
        self.uploader.photobook.delegate = self;
        
        [self.uploader.photobook loadPhotobookPages];
        
        // 중복 체크
        if ([self.uploader.photobook checkDuplicate]) {
            if ([self.uploader prepareUploadServer]) {
                [self startUpload];
            }
            else {
                [self closeMessage:@"서버와 연결할 수 없습니다."];
            }
        }
        else {
            [self.uploader.photobook saveFile];
            [self closeMessage:@"전송할 파일에 오류가 발견되어\n일부 파일이 제거되었습니다.\n\n편집하기를 선택하여 \n편집을 다시 완료해 주세요."];
        }

    } cancelCompletion:^{
        if([Common info].photobook.product_type == PRODUCT_PHONECASE && [Common info].photobook.minpictures == 0 ) {
            BOOL has_textlayer = NO;
            for (int i = 0; i < [Common info].photobook.pages.count; i++) {
                Page *page = [Common info].photobook.pages[i];
                for (Layer *layer in page.layers) {
                    if(layer.AreaType==2) {
                        has_textlayer = YES;
                        break;
                    }
                }
            }
            if(has_textlayer == NO) {
                [Common info].is_navi_double_back = YES;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];

    } okTitle:@"네" cancelTitle:@"아니오"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PhotoProductUpload" ScreenClass:[self.classForCoder description]];
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
    
    _progressTotal.hidden = true;
    _progressView.hidden = true;
    
    _progressPhoto.progress = 0.0f;
    _progressTotal.progress = 0.0f;
    _statusLabel.text = @"0 / 0";
    _messageLabel.text = @"미리보기 파일을 생성 중입니다..";
}

- (void)startUpload {
    
    _progressView = [[ProgressView alloc]initWithTitle:@"파일 업로드 중"];

	_backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@">> Backgrouund task ran out of time and was terminated");
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
        _backgroundTaskId = 0;
    }];
    
    [_uploader prepareItems];
    if (_uploader.items.count <= 0) {
        [self closeMessage:@"미리보기 파일 생성 중에 오류가 발생하였습니다."];
        [_progressView endProgress];

    }
    _cancel_button.enabled = YES;
    
    _is_canceled = FALSE;
    _upload_index = 0;
    if (![_uploader uploadFile:_upload_index UploadController:self]) {
        [self closeMessage:@"파일 전송 중에 오류가 발생하였습니다."];
        [_progressView endProgress];

    }
}

- (IBAction)cancel:(id)sender {
    if (_upload_index < 0) {
        [self closeMessage:@"파일 전송이 취소되었습니다."];
        [_progressView endProgress];

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
        [_progressView endProgress];

        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    //NSLog(@"--> %.5f complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
    
    _progressPhoto.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    
    if (_is_canceled) {
        [connection cancel];
        //[_uploader clear];
        //[self.view makeToast:@"파일 전송이 취소되었습니다."];
        //[self.navigationController popViewControllerAnimated:YES];
        [self closeMessage:@"파일 전송이 취소되었습니다."];
        [_progressView endProgress];

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
        //[_uploader clear];
        NSString *msg = _is_canceled ? @"파일 전송이 취소되었습니다." : @"파일 전송에 실패했습니다.";
        //[self.view makeToast:msg];
        //[self.navigationController popViewControllerAnimated:YES];
        [self closeMessage:msg];
        [_progressView endProgress];

    }
    else {
        
        if (_upload_index < _uploader.items.count - 1) {
            _upload_index++;
            
            [_progressView manageProgress:(CGFloat)_upload_index/(CGFloat)_uploader.items.count];

            _progressTotal.progress = (CGFloat)_upload_index / (CGFloat)_uploader.items.count;
            _progressPhoto.progress = 0.0f;
            _statusLabel.text = [NSString stringWithFormat:@"%d / %lu", _upload_index, (unsigned long)_uploader.items.count];
            _messageLabel.text = @"파일을 전송 중입니다..";
            
            if (![_uploader uploadFile:_upload_index UploadController:self]) {
                [connection cancel];
                //[_uploader clear];
                //[self.view makeToast:@"파일 전송에 실패했습니다."];
                //[self.navigationController popViewControllerAnimated:YES];
                [self closeMessage:@"파일 전송에 실패했습니다."];
                [_progressView endProgress];

            }
            
            /*PhotobookUploadItem *item = _uploader.items[_upload_index+1];
            
            //사진이 다 차지 않았어도 보낼수 있도록 하는 테스트 코드
            if ([item.uploadfilename length] == 0 ) {
                NSLog(@"uploadfilename empty");
                _upload_index = (int)_uploader.items.count - 1;
            }*/
            
        }
        else {
            if ([_uploader checkUploadResult] && [_uploader addCart]) {
                [Analysis log:@"PhotoProductUploadComplete"];
                if (_backgroundTaskId > 0) {
                    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskId];
                    _backgroundTaskId = 0;
                }
                
                [_wait_indicator stopAnimating];
                
                [_progressView manageProgress:1.0];
                
                _progressTotal.progress = 1.0f;
                _progressPhoto.progress = 1.0f;
                _statusLabel.text = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)_uploader.items.count, (unsigned long)_uploader.items.count];
                _messageLabel.text = @"파일 전송을 완료했습니다.";
                [_progressView endProgress];

                
                [[Common info] alert:self Title:@"파일 전송을 완료했습니다." Msg:@"" completion:^{
                    [self.uploader clear];
                    
                    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                    [[Common info].main_controller onCartviaExternalController];

                }];
            }
            else {
                [connection cancel];
                //[_uploader clear];
                //[self.view makeToast:@"파일 전송에 실패했습니다."];
                //[self.navigationController popViewControllerAnimated:YES];
                [self closeMessage:@"파일 전송에 실패했습니다."];
                [_progressView endProgress];

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
    //[_uploader clear];
    //[self.view makeToast:@"파일 전송에 실패했습니다."];
    //[self.navigationController popViewControllerAnimated:YES];
    [self closeMessage:@"파일 전송에 실패했습니다."];
    [_progressView endProgress];

}

#pragma mark - PhotobookDelegate methods

- (void)photobookProcess:(int)count TotalCount:(int)total_count {
}

- (void)photobookError {
}

@end
