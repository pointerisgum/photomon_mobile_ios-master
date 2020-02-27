//
//  CardEditTableViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "CardEditTableViewController.h"
#import "PhotoCropViewController.h"
#import "PageEditViewController.h"
//#import "AlbumCollectionViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"

@interface CardEditTableViewController ()

@end

@implementation CardEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"CardEdit"];
    _thread = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_table_view addGestureRecognizer:tapGesture];

    _cancel_button.enabled = YES;
    _save_button.enabled = YES;

    [self clearSelectedInfo];


    if (_is_new) {
        [Common info].photobook.delegate = self;

        if (![[Common info].photobook initPhotobookPages]) {
            [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
        [[Common info].photobook dumpLog];

        //[self performSegueWithIdentifier:@"PhotoMultiSelectSegue" sender:self];

		// SJYANG : 캘린더 시작년월 변경
        //[[Common info] selectPhoto:self Singlemode:NO MinPictures:[Common info].photobook.minpictures Param:@""];
		int nImageLayers = 0;
		for (Page *page in [Common info].photobook.pages) {
			for (Layer *layer in page.layers) {
				if (layer.AreaType == 0) { // 0: image
					nImageLayers++;
				}
			}
		}

        [[Common info] selectPhoto:self Singlemode:NO MinPictures:nImageLayers Param:@""];
    }
    else {
        [Common info].photobook.delegate = self;
        [[Common info].photobook loadPhotobookPages];
    }
	//[[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:[Common info].photobook.product_type];
}

- (void)viewDidAppear:(BOOL)animated {
    [Analysis firAnalyticsWithScreenName:@"CardEdit" ScreenClass:[self.classForCoder description]];
	if([Common info].photobook.useTitleHint == NO) {
		[Common info].photobook.useTitleHint = YES;
		[_table_view reloadData];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)noti {
    if (self.navigationController.topViewController == self) {
		[Common info].photobook.useTitleHint = NO;
		[_table_view reloadData];

		[[Common info].photobook saveFile];
        NSLog(@"appWillResignActive... saved...");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _photo_popup.hidden = YES;
}

- (void)startFillPhotoThread {
    _progressView = [[ProgressView alloc]initWithTitle:@"포토카드 구성 중"];
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
//    [_HUD hide:YES afterDelay:0.1];
}

- (void)clearSelectedInfo {
    _selected_page = -1;
    _selected_layer = nil;
    _photo_popup.hidden = YES;

	_edittext_width = .0f;
	_edittext_height = .0f;
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

			/*
			Page *objselpage = [Common info].photobook.pages[_selected_page];
			if(objselpage.CardCommonLayoutType == nil || [objselpage.CardCommonLayoutType isEqualToString:@""]) {
                button_edit.enabled = NO;
				[Common info].layout_pool.cardcommonlayouttype = @"n/a";
			}
			else {
				[[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:[Common info].photobook.product_type CardCommonLayoutType:objselpage.CardCommonLayoutType];
			}
			*/
		}
		else if (layer != nil && layer.AreaType == 2) {
            _selected_page = indexPath.row;
            _selected_layer = layer;

			_edittext_width = _selected_layer.MaskW * [Common info].photobook.edit_scale;
			_edittext_height = _selected_layer.MaskH * [Common info].photobook.edit_scale;

			[self performSegueWithIdentifier:@"CardEditTextSegue" sender:self];
		}
		if( layer!=nil )
		{
			NSLog(@"layer.AreaType : %d", layer.AreaType);
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
	NSString *intnum = @"";
	@try {
		NSString *product_code = [Common info].photobook.ProductCode;
		intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
	}
	@catch(NSException *exception) {}

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardEditCell" forIndexPath:indexPath];

    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    Page *page = [Common info].photobook.pages[indexPath.row];

	float pageheight = 600.f / (float)page.PageWidth * (float)page.PageHeight;

	CGFloat multiplier_height = pageheight + ((float)page.PageWidth / 600.f) ; // 482.474 ... 453

	NSLayoutConstraint *constraint =[NSLayoutConstraint
                           constraintWithItem:bkimageview
                           attribute:NSLayoutAttributeWidth
                           relatedBy:NSLayoutRelationEqual
                           toItem:bkimageview
                           attribute:NSLayoutAttributeHeight
                           multiplier:600.0/multiplier_height
                           constant:0.0f];
	[bkimageview addConstraint:constraint];

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    UILabel *footlabel = (UILabel *)[cell viewWithTag:104];
	if(indexPath.row == 0) footlabel.text = @"앞면";
	else if(indexPath.row == 1 || indexPath.row == 2) footlabel.text = @"내지";
	else if(indexPath.row == 3) footlabel.text = @"뒷면";

	[[Common info].photobook composePage:indexPath.row ParentView:bkimageview IncludeBg:YES IsEdit:YES];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *intnum = @"";
	@try {
		NSString *product_code = [Common info].photobook.ProductCode;
		intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
	}
	@catch(NSException *exception) {}

	Page *page = [Common info].photobook.pages[indexPath.row];

	float pageheight = 600.f / (float)page.PageWidth * (float)page.PageHeight;

	// 600 * 0.53333333333333333333333333333333 = 241.xx = 241 - 7 = 234
	// 320:234 = w : h
    CGFloat h = (tableView.frame.size.width * (pageheight * 0.53333f - 7.f)) / 320;

	//CGFloat multiplier_height = pageheight + 29.47422680412371134020618556702; // 482.474 ... 453
	CGFloat multiplier_height = pageheight + 29.47422680412371134020618556702 * ((float)page.PageWidth / 600.f) ; // 482.474 ... 453

	h = (tableView.frame.size.width - 23 * 2) / 600.0 * multiplier_height + 15;
	// SJYANG : 2018 달력
    if ([intnum isEqualToString:@"369"] && indexPath.row > 0 && indexPath.row%2 == 0)
		h += 4;

    if ([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"368"] || [intnum isEqualToString:@"391"] || [intnum isEqualToString:@"392"]) { // 소형벽걸이 + 미니특가달력 + 시트달력 + 대형벽걸이
		if(indexPath.row == 0)
			h += 5;
	}
	else {
		if ((indexPath.row%2 == 0)) {
			h += 15;
		}
	}
    return h;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
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
    if ([segue.identifier isEqualToString:@"CardEditTextSegue"]) {
        CardEditTextViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
			vc.edittext_width = _edittext_width;
			vc.edittext_height = _edittext_height;
			vc.fontsize = _selected_layer.TextFontsize;

			NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page];
			vc.textcontents = [NSString stringWithContentsOfFile:tc_filepath encoding:NSUTF8StringEncoding error:nil];

			if ([_selected_layer.Halign isEqualToString:@"left"]) vc.alignment =  NSTextAlignmentLeft;				
			else if ([_selected_layer.Halign isEqualToString:@"right"]) vc.alignment =  NSTextAlignmentRight;
			else vc.alignment =  NSTextAlignmentCenter;
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
	[Common info].photobook.useTitleHint = NO;
	[_table_view reloadData];

    [[Common info].photobook saveFile];
    UIViewController *root_vc = [self.navigationController.viewControllers firstObject];
    if (root_vc == [Common info].card_root_controller)
        [[Common info].card_root_controller goStorage];
    else if (root_vc == [Common info].card_product_root_controller)
        [[Common info].card_product_root_controller goStorage];
    else if (root_vc == [Common info].photobook_root_controller) 
        [[Common info].photobook_root_controller goStorage];
    else if (root_vc == [Common info].photobook_product_root_controller) 
        [[Common info].photobook_product_root_controller goStorage];
}

- (IBAction)cancel:(id)sender {
    if (_save_button.enabled == NO) { // 취소가 잘 안되는 문제가...
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
    }
    else {
		[Common info].photobook.useTitleHint = NO;
		[_table_view reloadData];

        [[Common info].photobook saveFile];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - PhotobookDelegate methods

- (void)photobookProcess:(int)count TotalCount:(int)total_count {
    NSString *progress_str = [NSString stringWithFormat:@"포토카드 구성 중 (%d/%d)", count, total_count];
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
        //[self popupGuidePage:GUIDE_CARD_EDIT];
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

#pragma mark - PhotoEditViewControllerDelegate methods

- (void)didEditPhoto {
    [_table_view reloadData];
    [self clearSelectedInfo];
}

- (void)cancelEditPhoto {
    [self clearSelectedInfo];
}

#pragma mark - CardEditTextDelegate methods

- (void)editTextDone:(NSString *)oriText withFmtText:(NSString* )fmtText withAlignment:(int)alignment {
	NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page];
	NSLog(@"tc_filepath : %@", tc_filepath);
	[oriText writeToFile:tc_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];

	_selected_layer.TextDescription = [fmtText copy];
	if(alignment == NSTextAlignmentLeft)
	    _selected_layer.Halign = @"left";
	else if(alignment == NSTextAlignmentRight)
	    _selected_layer.Halign = @"right";
	else
	    _selected_layer.Halign = @"center";

    [_table_view reloadData];
}

- (void)viewDidUnload {
}


@end
