//
//  BabyEditViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 5..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "BabyEditViewController.h"
#import "SelectAlbumViewController.h"
#import "PhotobookUploadViewController.h"
#import "GuideViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"

@interface BabyEditViewController ()

@end

@implementation BabyEditViewController

static UIImageView *crtimageview;
static UITableViewCell *crtcell;

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"BabyEdit"];
    _thread = nil;

    [self registerForKeyboardNotifications];
    _activeTextField = nil;

    _v1_f1.delegate = self;
    _v1_f2.delegate = self;
    _v2_f1.delegate = self;
    _v2_f2.delegate = self;
    _v1_f3.delegate = self;
    _v2_f4.delegate = self;
    _v3_f4.delegate = self;
    _v4_f3.delegate = self;
    _v5_f3.delegate = self;

	/*
	_v1_f2
	_v1_f3
	_v2_f2
	_v2_f4
	_v3_f4
	_v4_f3
	_v5_f3
	*/
	[self makeTextViewBorder:_v1_f2];
	[self makeTextViewBorder:_v1_f3];
	[self makeTextViewBorder:_v2_f2];
	[self makeTextViewBorder:_v2_f4];
	[self makeTextViewBorder:_v3_f4];
	[self makeTextViewBorder:_v4_f3];
	[self makeTextViewBorder:_v5_f3];

	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v1_f4:)];
		tg.numberOfTapsRequired = 1;
		[_v1_f4 addGestureRecognizer:tg];
		[_v1_f4 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v1_f4:)];
		tg.numberOfTapsRequired = 1;
		[_v1_f4_1 addGestureRecognizer:tg];
		[_v1_f4_1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v2_f3:)];
		tg.numberOfTapsRequired = 1;
		[_v2_f3 addGestureRecognizer:tg];
		[_v2_f3 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v2_f3:)];
		tg.numberOfTapsRequired = 1;
		[_v2_f3_1 addGestureRecognizer:tg];
		[_v2_f3_1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v3_f1:)];
		tg.numberOfTapsRequired = 1;
		[_v3_f1 addGestureRecognizer:tg];
		[_v3_f1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v3_f1:)];
		tg.numberOfTapsRequired = 1;
		[_v3_f1_1 addGestureRecognizer:tg];
		[_v3_f1_1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v3_f3:)];
		tg.numberOfTapsRequired = 1;
		[_v3_f3 addGestureRecognizer:tg];
		[_v3_f3 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v3_f3:)];
		tg.numberOfTapsRequired = 1;
		[_v3_f3_1 addGestureRecognizer:tg];
		[_v3_f3_1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v4_f1:)];
		tg.numberOfTapsRequired = 1;
		[_v4_f1 addGestureRecognizer:tg];
		[_v4_f1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v4_f1:)];
		tg.numberOfTapsRequired = 1;
		[_v4_f1_1 addGestureRecognizer:tg];
		[_v4_f1_1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v2_f3:)];
		tg.numberOfTapsRequired = 1;
		[_v4_f2 addGestureRecognizer:tg];
		[_v4_f2 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v4_f2:)];
		tg.numberOfTapsRequired = 1;
		[_v4_f2_1 addGestureRecognizer:tg];
		[_v4_f2_1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v5_f1:)];
		tg.numberOfTapsRequired = 1;
		[_v5_f1 addGestureRecognizer:tg];
		[_v5_f1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v5_f1:)];
		tg.numberOfTapsRequired = 1;
		[_v5_f1_1 addGestureRecognizer:tg];
		[_v5_f1_1 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v5_f2:)];
		tg.numberOfTapsRequired = 1;
		[_v5_f2 addGestureRecognizer:tg];
		[_v5_f2 setUserInteractionEnabled:YES];
	}
	{
		UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click_v5_f2:)];
		tg.numberOfTapsRequired = 1;
		[_v5_f2_1 addGestureRecognizer:tg];
		[_v5_f2_1 setUserInteractionEnabled:YES];
	}

    // 이전 폴더 삭제
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *baseFolder = [NSString stringWithFormat:@"%@/baby", [[Common info] documentPath]];
    [fileManager removeItemAtPath:baseFolder error:nil];

    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

	{
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
		tapGesture.numberOfTapsRequired = 1;
		tapGesture.cancelsTouchesInView = NO;
		[tapGesture setCancelsTouchesInView:NO];
		tapGesture.delegate = self;
		[_table_view addGestureRecognizer:tapGesture];
	}
	{
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
		tapGesture.numberOfTapsRequired = 1;
		tapGesture.cancelsTouchesInView = NO;
		[self.view addGestureRecognizer:tapGesture];
	}

    _cancel_button.enabled = YES;
    _save_button.enabled = YES;

    [self clearSelectedInfo];

    if (_is_new || TRUE) {
        [Common info].photobook.delegate = self;

		[[Common info].photobook.pages removeAllObjects];
		if( [[Common info].photobook.ProductCode isEqualToString:@"366045"] || [[Common info].photobook.ProductCode isEqualToString:@"366046"] ) {
			Page *page = [[Page alloc] init];
			[[Common info].photobook.pages addObject:page];
			page.IsPage = TRUE;
			page.PageWidth = 764;
			page.PageHeight = 400;
			page.PageColorA = 255;
			page.PageColorR = 255;
			page.PageColorG = 255;
			page.PageColorB = 255;

			{
				Layer *layer = [[Layer alloc] init];
				[page.layers addObject:layer];
				layer.AreaType = 0;
				layer.PageIndex = 0;
				layer.LayerIndex = 0;
				layer.MaskX = 0;
				layer.MaskY = 48;
				layer.MaskW = 230;
				layer.MaskH = 230;
				layer.X = 0;
				layer.Y = 48;
				layer.W = 230;
				layer.H = 230;
				layer.Alpha = 255;
				layer.MaskAlpha = 255;
				layer.FrameAlpha = 255;
				layer.FrameFilename = @"";
			}
			{
				Layer *layer = [[Layer alloc] init];
				[page.layers addObject:layer];
				layer.AreaType = 0;
				layer.PageIndex = 0;
				layer.LayerIndex = 1;
				layer.MaskX = 267;
				layer.MaskY = 48;
				layer.MaskW = 230;
				layer.MaskH = 230;
				layer.X = 267;
				layer.Y = 48;
				layer.W = 230;
				layer.H = 230;
				layer.Alpha = 255;
				layer.MaskAlpha = 255;
				layer.FrameAlpha = 255;
				layer.FrameFilename = @"";
			}
			{
				Layer *layer = [[Layer alloc] init];
				[page.layers addObject:layer];
				layer.AreaType = 0;
				layer.PageIndex = 0;
				layer.LayerIndex = 2;
				layer.MaskX = 534;
				layer.MaskY = 48;
				layer.MaskW = 230;
				layer.MaskH = 230;
				layer.X = 534;
				layer.Y = 48;
				layer.W = 230;
				layer.H = 230;
				layer.Alpha = 255;
				layer.MaskAlpha = 255;
				layer.FrameAlpha = 255;
				layer.FrameFilename = @"";
			}
		}
		else {
			Page *page = [[Page alloc] init];
			[[Common info].photobook.pages addObject:page];
			page.IsPage = TRUE;
			page.PageWidth = 800;
			page.PageHeight = 400;
			page.PageColorA = 255;
			page.PageColorR = 255;
			page.PageColorG = 255;
			page.PageColorB = 255;

			Layer *layer = [[Layer alloc] init];
			[page.layers addObject:layer];
			layer.AreaType = 0;
			layer.PageIndex = 0;
			layer.LayerIndex = 0;
			layer.MaskX = 200;
			layer.MaskY = 0;
			layer.MaskW = 400;
			layer.MaskH = 400;
			layer.X = 200;
			layer.Y = 0;
			layer.W = 400;
			layer.H = 400;
			layer.Alpha = 255;
			layer.MaskAlpha = 255;
			layer.FrameAlpha = 255;
			layer.FrameFilename = @"";
		}

        [[Common info].photobook dumpLog];

        [[Common info] selectPhoto:self Singlemode:NO MinPictures:[Common info].photobook.minpictures Param:@""];
    }
    else {
        [Common info].photobook.delegate = self;
        [[Common info].photobook loadPhotobookPages];
    }

	[self clearTextField];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"BabyEdit" ScreenClass:[self.classForCoder description]];
}



-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}    

- (void)makeTextViewBorder:(UITextView *)tv {
    [tv.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [tv.layer setBorderWidth:0.3];
    [tv.layer setCornerRadius:6.0f];
}

- (void)viewWillAppear:(BOOL)animated {
	_view1.hidden = YES;
	_view2.hidden = YES;
	_view3.hidden = YES;
	_view4.hidden = YES;
	_view5.hidden = YES;

	_view1.alpha = 1;
	_view2.alpha = 1;
	_view3.alpha = 1;
	_view4.alpha = 1;
	_view5.alpha = 1;

    if ([[Common info].photobook.ProductCode isEqualToString:@"366001"] || [[Common info].photobook.ProductCode isEqualToString:@"366002"] || [[Common info].photobook.ProductCode isEqualToString:@"366003"] || [[Common info].photobook.ProductCode isEqualToString:@"366004"] || [[Common info].photobook.ProductCode isEqualToString:@"366005"]) {
		_view1.hidden = NO;
	}
    else if ([[Common info].photobook.ProductCode isEqualToString:@"366022"] || [[Common info].photobook.ProductCode isEqualToString:@"366023"]) {
		_view2.hidden = NO;
	}
    else if ([[Common info].photobook.ProductCode isEqualToString:@"366021"]) {
		_view3.hidden = NO;
	}
    else if ([[Common info].photobook.ProductCode isEqualToString:@"366045"] || [[Common info].photobook.ProductCode isEqualToString:@"366046"]) {
		_view4.hidden = NO;
	}
    else if ([[Common info].photobook.ProductCode isEqualToString:@"366041"] || [[Common info].photobook.ProductCode isEqualToString:@"366042"] || [[Common info].photobook.ProductCode isEqualToString:@"366043"] || [[Common info].photobook.ProductCode isEqualToString:@"366044"]) {
		_view5.hidden = NO;
	}

	_constraint_v1_f1_width.constant = self.view.frame.size.width - 105;
	_constraint_v2_f1_width.constant = self.view.frame.size.width - 105;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    _progressView = [[ProgressView alloc]initWithTitle:@"미니스탠딩 구성중"];
//
//    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _HUD.delegate = self;
//    _HUD.labelText = @"Loading ...";
//    [self.view addSubview:_HUD];

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
}

- (void)clearSelectedInfo {
    _selected_page = -1;
    _selected_layer = nil;
    _photo_popup.hidden = YES;
}

- (void)singleTapPiece:(id)sender {
	if( _photo_popup.hidden == NO ) return;
    [self.view endEditing:YES];
    [self clearSelectedInfo];
	_table_view.userInteractionEnabled = YES;

    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    UIGestureRecognizerState state = singleTap.state;

    CGPoint location = [singleTap locationInView: _table_view];
    NSIndexPath *indexPath = [_table_view indexPathForRowAtPoint: location];

    if (indexPath && state == UIGestureRecognizerStateEnded) {
        UITableViewCell *cell = [_table_view cellForRowAtIndexPath:indexPath];
        UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];

        CGPoint point_page = [_table_view convertPoint:location toView:bkimageview];
        Layer *layer = [[Common info].photobook getLayer:indexPath.row FromPoint:point_page];
        if (layer != nil) {
			crtimageview = bkimageview;
			crtcell = cell;

            _selected_page = indexPath.row;
            _selected_layer = layer;
			[self changePhoto:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BabyEditCell" forIndexPath:indexPath];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    [[Common info].photobook composePage:indexPath.row ParentView:bkimageview IncludeBg:YES IsEdit:YES];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 320:160 = w : h(?)
    CGFloat h = (tableView.frame.size.width * 160) / 320;
    return h;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"PhotobookUploadSegue"]) {
        if ([Common info].photobook != nil) {
            [[Common info].photobook saveFile];
            if (![Common info].photobook.Edited) {
                [[Common info] alert:self Msg:@"편집이 완료되지 않았습니다."];
                return NO;
            }

			[[Common info].photobook clearAddVal];

			if ([[Common info].photobook.ProductCode isEqualToString:@"366001"] || [[Common info].photobook.ProductCode isEqualToString:@"366002"] || [[Common info].photobook.ProductCode isEqualToString:@"366003"] || [[Common info].photobook.ProductCode isEqualToString:@"366004"] || [[Common info].photobook.ProductCode isEqualToString:@"366005"]) {
				/*
				v1_f1 : 아기 이름
				v1_f2 : 말풍선 문구
				v1_f4 : 볼터치 선택
				v1_f3 : 메모
				*/
				if (_v1_f1.text.length < 1) {

                    [[Common info] alert:self Title:@"아기 이름을 입력해주세요." Msg:@"" completion:^{
                        self.activeTextField = self.v1_f1;
                        [self.v1_f1 becomeFirstResponder];

                    }];
					return NO;
				}

				if (_v1_f2.text.length < 1 || _v1_f2.textColor == [UIColor lightGrayColor]) {
					_v1_f2.textColor = [UIColor lightGrayColor];
					_v1_f2.text = @"내용을 입력해 주세요.";

                    [[Common info] alert:self Title:@"말풍선 문구를 입력해 주세요." Msg:@"" completion:^{
                        self.activeTextField = self.v1_f2;
                        [self.v1_f2 becomeFirstResponder];
                    }];
                    
					return NO;
				}

				// 2018.01.02 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				{
					NSString *text = _v1_f1.text;
					NSString *checkChar = [[Common info] checkEucKr:text];
					if(checkChar != nil) {
						[_v1_f1 resignFirstResponder];
						[_v1_f1 setBackgroundColor: [UIColor clearColor]];

						NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
                        [[Common info]alert:self Msg:errorMsg];
						return NO;
					}
				}
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				// 2018.01.02 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				{
					NSString *text = _v1_f2.text;
					NSString *checkChar = [[Common info] checkEucKr:text];
					if(checkChar != nil) {
						[_v1_f2 resignFirstResponder];
						[_v1_f2 setBackgroundColor: [UIColor clearColor]];

						NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
                        [[Common info]alert:self Msg:errorMsg];

						return NO;
					}
				}
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				if( _v1_f1.text.length > 150 ) [Common info].photobook.AddVal1 = [_v1_f1.text substringToIndex : 150];
				else [Common info].photobook.AddVal1 = _v1_f1.text;

				if( _v1_f2.text.length > 150 ) [Common info].photobook.AddVal3 = [_v1_f2.text substringToIndex : 150];
				else [Common info].photobook.AddVal3 = _v1_f2.text;

				[Common info].photobook.AddVal5 = _v1_f4.text;

				if( _v1_f3.text.length > 150 ) [Common info].photobook.AddVal7 = [_v1_f3.text substringToIndex : 150];
				else [Common info].photobook.AddVal7 = _v1_f3.text;
			}
			else if ([[Common info].photobook.ProductCode isEqualToString:@"366022"] || [[Common info].photobook.ProductCode isEqualToString:@"366023"]) {
				/*
				v2_f1 : 아기 이름
				v2_f2 : 이니셜
				v2_f3 : 볼터치 선택
				v2_f4 : 메모
				*/
				if (_v2_f1.text.length < 1) {
                    [[Common info]alert:self Title:@"아기 이름을 입력해 주세요." Msg:@"" completion:^{
                        self.activeTextField = self.v2_f1;
                        [self.v2_f1 becomeFirstResponder];
                    }];
	                return NO;
				}

				if (_v2_f2.text.length < 1 || _v2_f2.textColor == [UIColor lightGrayColor]) {
					_v2_f2.textColor = [UIColor lightGrayColor];
					_v2_f2.text = @"내용을 입력해 주세요.";

                    [[Common info]alert:self Title:@"이니셜을 입력해 주세요." Msg:@"" completion:^{
                        self.activeTextField = self.v2_f2;
                        [self.v2_f2 becomeFirstResponder];
                    }];
                    
					return NO;
				}

				// 2018.01.02 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				{
					NSString *text = _v2_f1.text;
					NSString *checkChar = [[Common info] checkEucKr:text];
					if(checkChar != nil) {
						[_v2_f1 resignFirstResponder];
						[_v2_f1 setBackgroundColor: [UIColor clearColor]];

						NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
                        [[Common info]alert:self Title:errorMsg Msg:@"" completion:nil];
						return NO;
					}
				}
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				// 2018.01.02 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				{
					NSString *text = _v2_f2.text;
					NSString *checkChar = [[Common info] checkEucKr:text];
					if(checkChar != nil) {
						[_v2_f2 resignFirstResponder];
						[_v2_f2 setBackgroundColor: [UIColor clearColor]];

						NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
                        [[Common info]alert:self Title:errorMsg Msg:@"" completion:nil];

						return NO;
					}
				}
				//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

				if( _v2_f1.text.length > 150 ) [Common info].photobook.AddVal1 = [_v2_f1.text substringToIndex : 150];
				else [Common info].photobook.AddVal1 = _v2_f1.text;

				if( _v2_f2.text.length > 150 ) [Common info].photobook.AddVal3 = [_v2_f2.text substringToIndex : 150];
				else [Common info].photobook.AddVal3 = _v2_f2.text;

				if( _v2_f3.text.length > 150 ) [Common info].photobook.AddVal5 = [_v2_f3.text substringToIndex : 150];
				else [Common info].photobook.AddVal5 = _v2_f3.text;

				if( _v2_f4.text.length > 150 ) [Common info].photobook.AddVal7 = [_v2_f4.text substringToIndex : 150];
				else [Common info].photobook.AddVal7 = _v2_f4.text;
			}
			else if ([[Common info].photobook.ProductCode isEqualToString:@"366021"]) {
				/*
				v3_f1 : 색상
				v3_f2 : 이니셜
				v3_f3 : 볼터치 선택
				v3_f4 : 메모
				*/
				if( _v3_f1.text.length > 150 ) [Common info].photobook.AddVal1 = [_v3_f1.text substringToIndex : 150];
				else [Common info].photobook.AddVal1 = _v3_f1.text;

				if( _v3_f3.text.length > 150 ) [Common info].photobook.AddVal5 = [_v3_f3.text substringToIndex : 150];
				else [Common info].photobook.AddVal5 = _v3_f3.text;

				if( _v3_f4.text.length > 150 ) [Common info].photobook.AddVal7 = [_v3_f4.text substringToIndex : 150];
				else [Common info].photobook.AddVal7 = _v3_f4.text;
			}
			else if ([[Common info].photobook.ProductCode isEqualToString:@"366045"] || [[Common info].photobook.ProductCode isEqualToString:@"366046"]) {
				/*
				v4_f1 : 볼터치
				v4_f2 : 악세사리
				v4_f3 : 메모
				*/

				if( _v4_f1.text.length > 150 ) [Common info].photobook.AddVal5 = [_v4_f1.text substringToIndex : 150];
				else [Common info].photobook.AddVal5 = _v4_f1.text;

				if( _v4_f2.text.length > 150 ) [Common info].photobook.AddVal6 = [_v4_f2.text substringToIndex : 150];
				else [Common info].photobook.AddVal6 = _v4_f2.text;

				if( _v4_f3.text.length > 150 ) [Common info].photobook.AddVal7 = [_v4_f3.text substringToIndex : 150];
				else [Common info].photobook.AddVal7 = _v4_f3.text;
			}
			else if ([[Common info].photobook.ProductCode isEqualToString:@"366041"] || [[Common info].photobook.ProductCode isEqualToString:@"366042"] || [[Common info].photobook.ProductCode isEqualToString:@"366043"] || [[Common info].photobook.ProductCode isEqualToString:@"366044"]) {
				/*
				악세사리 메세지 3줄
				v5_f1 : 볼터치
				v5_f2 : 악세사리
				v5_f3 : 메모
				*/

				if( _v5_f1.text.length > 150 ) [Common info].photobook.AddVal5 = [_v5_f1.text substringToIndex : 150];
				else [Common info].photobook.AddVal5 = _v5_f1.text;

				if( _v5_f2.text.length > 150 ) [Common info].photobook.AddVal6 = [_v5_f2.text substringToIndex : 150];
				else [Common info].photobook.AddVal6 = _v5_f2.text;

				if( _v5_f3.text.length > 150 ) [Common info].photobook.AddVal7 = [_v5_f3.text substringToIndex : 150];
				else [Common info].photobook.AddVal7 = _v5_f3.text;
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
	_table_view.userInteractionEnabled = YES;
	NSLog(@"changePhoto!!!!");
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
    NSString *progress_str = [NSString stringWithFormat:@"미니스탠딩 구성 중 (%d/%d)", count, total_count];
    NSLog(@"%@", progress_str);
    [_progressView manageProgress:(CGFloat)count/(CGFloat)total_count];
//    _HUD.progress = count/total_count;
//    _HUD.labelText = progress_str;
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
        //[self popupGuidePage:GUIDE_BABY_EDIT];

        // start thread..
        [self startFillPhotoThread];
    }
    [self clearSelectedInfo];
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIButton class]]) {
		return FALSE;
	}
	if ([touch.view.superview isKindOfClass:[UIButton class]]) {
		return FALSE;
	}
	if ([touch.view.superview.superview isKindOfClass:[UIButton class]]) {
		return FALSE;
	}
	return TRUE;
}

- (IBAction)click_v1_f4:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"있음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v1_f4.text = @"있음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"없음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v1_f4.text = @"없음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)click_v2_f3:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"있음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v2_f3.text = @"있음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"없음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v2_f3.text = @"없음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)click_v3_f1:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"블루" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v3_f1.text = @"블루";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"핑크" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v3_f1.text = @"핑크";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)click_v3_f3:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"있음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v3_f3.text = @"있음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"없음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v3_f3.text = @"없음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)click_v4_f1:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"있음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v4_f1.text = @"있음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"없음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v4_f1.text = @"없음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)click_v4_f2:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"사용" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v4_f2.text = @"사용";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"미사용" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v4_f2.text = @"미사용";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)click_v5_f1:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"있음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v5_f1.text = @"있음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"없음" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v5_f1.text = @"없음";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)click_v5_f2:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"사용" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v5_f2.text = @"사용";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"미사용" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _v5_f2.text = @"미사용";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSLog(@"shouldChangeCharactersInRange");
	/*
	_v1_f2
	_v1_f3
	_v2_f2
	_v2_f4
	_v3_f4
	_v4_f3
	_v5_f3
	*/

	if( textField == _v1_f1 || textField == _v2_f1 )
	    return textField.text.length + (string.length - range.length) <= 40;
	else {
		/*
		int MAXLENGTH = 150;

		NSUInteger oldLength = [textField.text length];
		NSUInteger replacementLength = [string length];
		NSUInteger rangeLength = range.length;

		NSUInteger newLength = oldLength - rangeLength + replacementLength;

		BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;

		return newLength <= MAXLENGTH || returnKey;
		*/
	    return textField.text.length + (string.length - range.length) <= 150;
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if(textView == _v1_f2 || textView == _v1_f3 || textView == _v2_f2 || textView == _v2_f4 || textView == _v3_f4 || textView == _v4_f3 || textView == _v4_f3 || textView == _v5_f3)
		return textView.text.length + (text.length - range.length) <= 150;
	else
		return textView.text.length + (text.length - range.length) <= 150;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	NSLog(@"textFieldDidBeginEditing");
    _activeTextField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSLog(@"textFieldDidEndEditing");
    _activeTextField = nil;
	[self.view endEditing:YES];
}
/*
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        [_contentText becomeFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
*/
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesBegan");
    [self.view endEditing:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textField {
	NSLog(@"textViewDidBeginEditing");
    _activeTextField = textField;
}
- (void)textViewDidEndEditing:(UITextView *)textField {
	NSLog(@"textViewDidEndEditing");
    _activeTextField = nil;
    [self.view endEditing:YES];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	NSLog(@"textViewShouldBeginEditing");
	/*
	_v1_f2
	_v1_f3
	_v2_f2
	_v2_f4
	_v3_f4
	_v4_f3
	_v5_f3
	*/

	if(_v1_f2 == textView) {
		if (_v1_f2.text.length > 0 && _v1_f2.textColor == [UIColor blackColor]) {
			return YES;
		}
		_v1_f2.text = @"";
		_v1_f2.textColor = [UIColor blackColor];
	}
	if(_v1_f3 == textView) {
		if (_v1_f3.text.length > 0 && _v1_f3.textColor == [UIColor blackColor]) {
			return YES;
		}
		_v1_f3.text = @"";
		_v1_f3.textColor = [UIColor blackColor];
	}
	if(_v2_f2 == textView) {
		if (_v2_f2.text.length > 0 && _v2_f2.textColor == [UIColor blackColor]) {
			return YES;
		}
		_v2_f2.text = @"";
		_v2_f2.textColor = [UIColor blackColor];
	}
	if(_v2_f4 == textView) {
		if (_v2_f4.text.length > 0 && _v2_f4.textColor == [UIColor blackColor]) {
			return YES;
		}
		_v2_f4.text = @"";
		_v2_f4.textColor = [UIColor blackColor];
	}
	if(_v3_f4 == textView) {
		if (_v3_f4.text.length > 0 && _v3_f4.textColor == [UIColor blackColor]) {
			return YES;
		}
		_v3_f4.text = @"";
		_v3_f4.textColor = [UIColor blackColor];
	}
	if(_v4_f3 == textView) {
		if (_v4_f3.text.length > 0 && _v4_f3.textColor == [UIColor blackColor]) {
			return YES;
		}
		_v4_f3.text = @"";
		_v4_f3.textColor = [UIColor blackColor];
	}
	if(_v5_f3 == textView) {
		if (_v5_f3.text.length > 0 && _v5_f3.textColor == [UIColor blackColor]) {
			return YES;
		}
		_v5_f3.text = @"";
		_v5_f3.textColor = [UIColor blackColor];
	}

	return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
	NSLog(@"textViewDidChange");
	[self resetTextField];
}

- (void)registerForKeyboardNotifications {
	NSLog(@"registerForKeyboardNotifications");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
	NSLog(@"keyboardWillShow");
}

- (void)keyboardDidShow:(NSNotification*)aNotification {
	NSLog(@"keyboardDidShow");
    if (_activeTextField == nil) {
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;

	if(_activeTextField == _v1_f1) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v1_f1.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v1_f2) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v1_f2.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v2_f1) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v2_f1.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v2_f2) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v2_f2.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v1_f3) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v1_f3.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v2_f4) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v2_f4.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v3_f4) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v3_f4.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v4_f3) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v4_f3.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
	if(_activeTextField == _v5_f3) {
		_scrollview.contentOffset = CGPointMake(0,0);
		CGPoint point = CGPointMake(0,_v5_f3.frame.origin.y);
		_scrollview.contentOffset = point;
		[_scrollview setContentOffset:point animated:YES];
	}
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
	NSLog(@"keyboardWillHide");
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
	NSLog(@"keyboardDidHide");
	[self resetTextField];
}

- (IBAction)viewTapped:(id)sender {
    [self.view endEditing:YES];
}

-(void)resetTextField {
	/*
	_v1_f2
	_v1_f3
	_v2_f2
	_v2_f4
	_v3_f4
	_v4_f3
	_v5_f3
	*/

	if (_v1_f2.text.length < 1) {
        _v1_f2.textColor = [UIColor lightGrayColor];
        _v1_f2.text = @"내용을 입력해 주세요.";
        [_v1_f2 resignFirstResponder];
    }
	if (_v1_f3.text.length < 1) {
        _v1_f3.textColor = [UIColor lightGrayColor];
        _v1_f3.text = @"내용을 입력해 주세요.";
        [_v1_f3 resignFirstResponder];
    }
	if (_v2_f2.text.length < 1) {
        _v2_f2.textColor = [UIColor lightGrayColor];
        _v2_f2.text = @"내용을 입력해 주세요.";
        [_v2_f2 resignFirstResponder];
    }
	if (_v2_f4.text.length < 1) {
        _v2_f4.textColor = [UIColor lightGrayColor];
        _v2_f4.text = @"내용을 입력해 주세요.";
        [_v2_f4 resignFirstResponder];
    }
	if (_v3_f4.text.length < 1) {
        _v3_f4.textColor = [UIColor lightGrayColor];
        _v3_f4.text = @"내용을 입력해 주세요.";
        [_v3_f4 resignFirstResponder];
    }
	if (_v4_f3.text.length < 1) {
        _v4_f3.textColor = [UIColor lightGrayColor];
        _v4_f3.text = @"내용을 입력해 주세요.";
        [_v4_f3 resignFirstResponder];
    }
	if (_v5_f3.text.length < 1) {
        _v5_f3.textColor = [UIColor lightGrayColor];
        _v5_f3.text = @"내용을 입력해 주세요.";
        [_v5_f3 resignFirstResponder];
    }
}

-(void)clearTextField {
	/*
	_v1_f2
	_v1_f3
	_v2_f2
	_v2_f4
	_v3_f4
	_v4_f3
	_v5_f3
	*/

	_v1_f2.textColor = [UIColor lightGrayColor];
	_v1_f2.text = @"내용을 입력해 주세요.";

	_v1_f3.textColor = [UIColor lightGrayColor];
	_v1_f3.text = @"내용을 입력해 주세요.";

	_v2_f2.textColor = [UIColor lightGrayColor];
	_v2_f2.text = @"내용을 입력해 주세요.";

	_v2_f4.textColor = [UIColor lightGrayColor];
	_v2_f4.text = @"내용을 입력해 주세요.";

	_v3_f4.textColor = [UIColor lightGrayColor];
	_v3_f4.text = @"내용을 입력해 주세요.";

	_v4_f3.textColor = [UIColor lightGrayColor];
	_v4_f3.text = @"내용을 입력해 주세요.";

	_v5_f3.textColor = [UIColor lightGrayColor];
	_v5_f3.text = @"내용을 입력해 주세요.";
}

@end
