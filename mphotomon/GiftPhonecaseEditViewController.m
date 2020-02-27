//
//  GiftPhonecaseEditViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 5..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "GiftPhonecaseEditViewController.h"
#import "SelectAlbumViewController.h"
#import "PhotobookUploadViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"

@interface GiftPhonecaseEditViewController ()

@end

@implementation GiftPhonecaseEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"GiftPhonecaseEdit"];
    _thread = nil;

    _activeTextField = nil;
    _title_text.delegate = self;


    // 이전 폴더 삭제
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *baseFolder = [NSString stringWithFormat:@"%@/phonecase", [[Common info] documentPath]];
    [fileManager removeItemAtPath:baseFolder error:nil];

	_table_view.hidden = YES;
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_table_view addGestureRecognizer:tapGesture];

    _title_button.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    _title_button.layer.borderWidth = 1.0;

    _cancel_button.enabled = YES;
    _save_button.enabled = YES;

    [self clearSelectedInfo];
    
	_title_view.hidden = NO;

	[Common info].photobook.pageViewWidth = self.view.frame.size.width;
	[Common info].photobook.pageViewHeight = self.view.frame.size.height;

    if (_is_new) {
        [Common info].photobook.delegate = self;
        
        if (![[Common info].photobook initPhotobookPages]) {
            [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
        [[Common info].photobook dumpLog];

		_has_textlayer = NO;
		for (int i = 0; i < [Common info].photobook.pages.count; i++) {
			Page *page = [Common info].photobook.pages[i];
			for (Layer *layer in page.layers) {
				if(layer.AreaType==2) {
					_has_textlayer = YES;
					break;
				}
			}
		}

		if(_has_textlayer == NO) {
			_title_view.hidden = YES;
		}

		if( [Common info].photobook.minpictures == 0 ) {
			[self startFillPhotoThread];
			_table_view.hidden = NO;

			if(_has_textlayer == NO) {
				[self performSegueWithIdentifier:@"PhotobookUploadSegue" sender:nil];
			}
		}
		else {
	        [[Common info] selectPhoto:self Singlemode:NO MinPictures:[Common info].photobook.minpictures Param:@""];
		}
    }
    else {
        [Common info].photobook.delegate = self;
        [[Common info].photobook loadPhotobookPages];
    }

	//[[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:[Common info].photobook.product_type];
}

- (void)viewDidAppear:(BOOL)animated {
    [Analysis firAnalyticsWithScreenName:@"GiftPhonecaseEdit" ScreenClass:[self.classForCoder description]];
	if([Common info].photobook.useTitleHint == NO) {
		[Common info].photobook.useTitleHint = YES;
		[_table_view reloadData];
	}
	isForceProgress = NO;

	if([Common info].is_navi_double_back == YES) {
		[Common info].is_navi_double_back = NO;
        [self.navigationController popViewControllerAnimated:YES];
		return;
	} 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)noti {
    if (self.navigationController.topViewController == self) {
        [[Common info].photobook saveFile];
        NSLog(@"appWillResignActive... saved...");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _photo_popup.hidden = YES;
}

- (void)startFillPhotoThread {
    _progressView = [[ProgressView alloc]initWithTitle:@""];
//
//    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _HUD.delegate = self;
//    _HUD.labelText = @"Loading ...";
//    [self.view addSubview:_HUD];
//
    _cancel_button.enabled = NO;
    _save_button.enabled = NO;
    
    if (_thread) {
        [_thread cancel];
        _thread = nil;
    }
    
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
    [_thread start];
}

- (void)doingThread {
    [[Common info].photobook fillPhotobookPages];
    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)doneThread {
    _cancel_button.enabled = YES;
    _save_button.enabled = YES;
    
//    [[Common info].photo_pool removeAll];
//    [[Instagram info] removeAll];

	[[PhotoContainer inst] initialize];
    [_table_view reloadData];
    
    [_progressView endProgress];
//    [_HUD hide:YES afterDelay:0.1];
}

- (void)clearSelectedInfo {
    _selected_page = -1;
    _selected_layer = nil;
    _photo_popup.hidden = YES;
}

- (void)singleTapPiece:(id)sender {
    [self.view endEditing:YES];
    [self clearSelectedInfo];
    
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    UIGestureRecognizerState state = singleTap.state;
    
    CGPoint location = [singleTap locationInView: _table_view];
    NSIndexPath *indexPath = [_table_view indexPathForRowAtPoint: location];
    
    if (indexPath && state == UIGestureRecognizerStateEnded) {
        UITableViewCell *cell = [_table_view cellForRowAtIndexPath:indexPath];
        UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
        
        CGPoint point_page = [_table_view convertPoint:location toView:bkimageview];
        Layer *layer = [[Common info].photobook getLayer:indexPath.row FromPoint:point_page];
        if (layer != nil && layer.AreaType == 0) {
            CGPoint point_popup = [_table_view convertPoint:location toView:[_table_view superview]];
            
            CGRect popup_rect = _photo_popup.frame;
            popup_rect.origin.x = point_popup.x;
            popup_rect.origin.y = point_popup.y;
            
            if (popup_rect.origin.x + popup_rect.size.width > _table_view.frame.size.width) {
                CGFloat diff_x = _table_view.frame.size.width - (popup_rect.origin.x + popup_rect.size.width);
                popup_rect.origin.x += diff_x;
            }
            if (popup_rect.origin.y + popup_rect.size.height > self.view.frame.size.height) {
                popup_rect.origin.y -= popup_rect.size.height;
            }
            [_photo_popup setFrame:popup_rect];
            
            _selected_page = indexPath.row;
            _selected_layer = layer;
            _photo_popup.hidden = NO;
            
            UIButton *button_ins = (UIButton *)[_photo_popup viewWithTag:300];
            UIButton *button_del = (UIButton *)[_photo_popup viewWithTag:301];
            UIButton *button_edit = (UIButton *)[_photo_popup viewWithTag:302];
            if (layer.ImageEditname.length > 0) {
                button_ins.hidden = YES;
                button_del.hidden = NO;
                button_edit.enabled = YES;
            }
            else {
                button_ins.hidden = NO;
                button_del.hidden = YES;
                button_edit.enabled = NO;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Common info].photobook.pages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhonecaseEditCell" forIndexPath:indexPath];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    [[Common info].photobook composePage:indexPath.row ParentView:bkimageview IncludeBg:YES IsEdit:YES];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 320:160 = w : h
    CGFloat h = (tableView.frame.size.width * 444) / 320;
    return h;
}

#pragma mark - Navigation

static BOOL isForceProgress = NO;

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"PhotobookUploadSegue"]) {
        if ([Common info].photobook != nil) {
			[Common info].photobook.ProductOption2 = @"1";
			[Common info].photobook.ProductOption1 = [Common info].photobook.Color;
			[Common info].photobook.AddParams = [Common info].photobook.Size;

			[[Common info].photobook saveFile];
            if (![Common info].photobook.Edited) {
                [[Common info] alert:self Msg:@"편집이 완료되지 않았습니다."];
                return NO;
            }

			if ([Common info].photobook.title != nil && [Common info].photobook.title.length < 1 && _has_textlayer && isForceProgress == NO) {
				isForceProgress = NO;
				NSString *msg = @"텍스트 편집이 완료되지 않았습니다. 그대로 주문전송 하시겠습니까?";
                //MAcheck
                [[Common info]alert:self Title:msg Msg:@"" okCompletion:^{
                    isForceProgress = YES;
                    [Common info].photobook.useTitleHint = NO;
                    [_table_view reloadData];
                    [self performSegueWithIdentifier:@"PhotobookUploadSegue" sender:self];

                } cancelCompletion:^{
                    
                } okTitle:@"네" cancelTitle:@"아니오"];
				return NO;
			}
		}
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PhotoEditSegue"]) {
        PhotoCropViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
            if (_selected_layer && _selected_layer.ImageFilename.length > 0) {
                [vc loadCropInfo:[Common info].photobook SelectedLayer:_selected_layer];
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"PhotobookUploadSegue"]) {
        PhotobookUploadViewController *vc = [segue destinationViewController];
        if (vc) {
        }
    }
}

- (IBAction)clickMessage:(id)sender {
    UIView *message_view = (UIView *)[self.view viewWithTag:200];
    message_view.hidden = TRUE;
    _message_constraint.constant = 0;
}

- (IBAction)addPhoto:(id)sender {
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)changePhoto:(id)sender {
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)save:(id)sender {
}

- (IBAction)cancel:(id)sender {
    if (_save_button.enabled == NO) { // 취소가 잘 안되는 문제가...
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
    }
    else {
        [[Common info].photobook saveFile];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - PhotoEditViewControllerDelegate methods

- (void)didEditPhoto {
    [_table_view reloadData];
    [self clearSelectedInfo];
}

- (void)cancelEditPhoto {
    [self clearSelectedInfo];
}

#pragma mark - PhotobookDelegate methods

- (void)photobookProcess:(int)count TotalCount:(int)total_count {
    NSString *progress_str = [NSString stringWithFormat:@"폰케이스 구성 중 (%d/%d)", count, total_count];
    NSLog(@"%@", progress_str);
////    [_progressView ]
//    _HUD.progress = count/total_count;
//    _HUD.labelText = progress_str;
    [_progressView manageProgress:(CGFloat)count/(CGFloat)total_count];
}

- (void)photobookError {
    [self clearSelectedInfo];
}

#pragma mark - SelectPhotoDelegate methods

- (void)selectPhotoDone:(BOOL)is_singlemode {
    if (is_singlemode) {
//        if ([[Common info].photo_pool totalCount] > 0) {
//            Photo *photo = [[Common info].photobook pickPhoto:0];
//            if (photo != nil && _selected_layer != nil) {
//                [[Common info].photobook addPhoto:photo Layer:_selected_layer PickIndex:0];
//                [_table_view reloadData];
//            }
//        }
//        else if ([[Instagram info] selectedCount] > 0) {
//            InstaPhoto *photo = [Instagram info].sel_images[0];
//            if (photo != nil && _selected_layer != nil) {
//                //[[Common info].photobook addPhoto:photo Layer:_selected_layer PickIndex:0];
//                [_table_view reloadData];
//            }
//        }
//
//        [[Common info].photo_pool removeAll];
//        [[Instagram info] removeAll];
		if ([[PhotoContainer inst] selectCount] > 0){
			PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:0];
			[[Common info].photobook addPhotoNew:photoItem Layer:_selected_layer PickIndex:0];
			[_table_view reloadData];
		}
		
		[[PhotoContainer inst] initialize];
    }
    else {
        //[self popupGuidePage:GUIDE_PHONECASE_EDIT];

        // start thread..
        [self startFillPhotoThread];
    }
    [self clearSelectedInfo];
	_table_view.hidden = NO;
}

- (void)selectPhotoCancel:(BOOL)is_singlemode {
    if (is_singlemode) {
    }
    else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self clearSelectedInfo];
}

#pragma mark - GuideDelegate methods

- (void)popupGuidePage:(NSString *)guide_id {
    if ([[Common info] checkGuideUserDefault:guide_id]) {
        GuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GuidePage"];
        if (vc) {
            vc.guide_id = guide_id;
            vc.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)closeGuide {
    [_table_view reloadData];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_HUD removeFromSuperview];
    _HUD = nil;
}

- (void)viewDidUnload {
}

- (IBAction)setPhonecaseTitle:(id)sender {
	// 2018.01.02 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NSString *text = _title_text.text;
	NSString *checkChar = [[Common info] checkEucKr:text];
	if(checkChar != nil) {
		[_title_text resignFirstResponder];
		[_title_text setBackgroundColor: [UIColor clearColor]];

		NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
        
        [[Common info]alert:self Msg:errorMsg];
		return;
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	[self.view endEditing:YES];

	NSString* title = _title_text.text;
	title = [title stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [[Common info].photobook setBookTitle:title];
    //_title_constraint.constant = 0;
    [_table_view reloadData];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (replacedString.length > 10) { // 10글자 제한
        return NO;
    }
    if (replacedString.length > 0 && [replacedString characterAtIndex:0] == ' ') { // 맨 앞 공백 금지
        return NO;
    }
    NSLog(@"text log: %@", replacedString);

    // ^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\u318D\u119E\u11A2\u2022\u2025a\u00B7\uFE55]+$
    NSString *expr = @"[^ a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\u119E\u11A2\u2022\u2025a\uFE55\u00B7\u318D]"; //
    NSRegularExpression *reg_expr = [NSRegularExpression regularExpressionWithPattern:expr options:0 error:nil];
    NSUInteger match_count = [reg_expr numberOfMatchesInString:replacedString options:0 range:NSMakeRange(0, replacedString.length)];
    if (match_count > 0) {
        return NO;
    }
    //NSLog(@"in > %@(%d) - 매치(%d)", replacedString, replacedString.length, match_count);
    return YES;
}

@end
