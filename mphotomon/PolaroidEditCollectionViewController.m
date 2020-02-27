//
//  PolaroidEditCollectionViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PolaroidEditCollectionViewController.h"
#import "PhotoCropViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"
#import "PageEditPolaroidViewController.h"

@interface PolaroidEditCollectionViewController ()

@end

@implementation PolaroidEditCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PolaroidEdit"];
    _thread = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_collection_view addGestureRecognizer:tapGesture];

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
        
        [[Common info] selectPhoto:self Singlemode:NO MinPictures:[Common info].photobook.minpictures Param:@""];
    }
    else {
        [Common info].photobook.delegate = self;
        [[Common info].photobook loadPhotobookPages];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PolaroidEdit" ScreenClass:[self.classForCoder description]];
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
/*
- (void)fillPhoto {
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    _HUD.labelText = @"Loading ...";
    [self.view addSubview:_HUD];
    
    [[Common info].photobook fillPhotobookPages];
    
    [[Common info].photo_pool removeAll];
    [_collection_view reloadData];
    
    [_HUD hide:YES afterDelay:0.1];
}
*/
- (void)startFillPhotoThread {
    _progressView = [[ProgressView alloc]initWithTitle:@"폴라로이드 구성 중"];

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
    [_collection_view reloadData];
    
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
   
    CGPoint location = [singleTap locationInView: _collection_view];
    NSIndexPath *indexPath = [_collection_view indexPathForItemAtPoint: location];
    
    if (indexPath && state == UIGestureRecognizerStateEnded) {
        UICollectionViewCell *cell = [_collection_view cellForItemAtIndexPath:indexPath];
        UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];

		BOOL checked = NO;
		{
	        CGPoint point_page = [_collection_view convertPoint:location toView:bkimageview];
			
			Layer *layer = [[Common info].photobook getLayerOfPolaroidTextArea:indexPath.row FromPoint:point_page];
			if (layer != nil && layer.AreaType == 2) {
				checked = YES;
				_selected_page = indexPath.row;
				_selected_layer = layer;

				_edittext_width = _selected_layer.MaskW * [Common info].photobook.edit_scale;
				_edittext_height = _selected_layer.MaskH * [Common info].photobook.edit_scale;

				[self performSegueWithIdentifier:@"PolaroidEditTextSegue" sender:self];
				return;
			}
		}
		if(checked == NO)
		{
	        CGPoint point_page = [_collection_view convertPoint:location toView:bkimageview];
	        //NSLog(@"tap:%d,%d", (int)point.x, (int)point.y);
			Layer *layer = [[Common info].photobook getLayer:indexPath.row FromPoint:point_page];
			if (layer != nil && layer.AreaType == 0) {
				checked = YES;
				CGPoint point_popup = [_collection_view convertPoint:location toView:[_collection_view superview]];
				
				CGRect popup_rect = _photo_popup.frame;
				popup_rect.origin.x = point_popup.x;
				popup_rect.origin.y = point_popup.y;
				
				if (popup_rect.origin.x + popup_rect.size.width > _collection_view.frame.size.width) {
					CGFloat diff_x = _collection_view.frame.size.width - (popup_rect.origin.x + popup_rect.size.width);
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
				return;
			}
		}
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook.pages.count;
}

- (IBAction)button_pageedit_click:(UIButton *)btn
{
	NSIndexPath *indexPath;
	indexPath = [self.collection_view indexPathForItemAtPoint:[self.collection_view convertPoint:btn.center fromView:btn.superview]];

	_selected_page = indexPath.row;
	[self performSegueWithIdentifier:@"PageEditPolaroidSegue" sender:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PolaroidEditCell" forIndexPath:indexPath];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    [[Common info].photobook composePage:indexPath.row ParentView:bkimageview IncludeBg:YES IsEdit:YES];

	UIButton *button_pageedit = (UIButton *)[cell viewWithTag:150];
	[button_pageedit addTarget:self action:@selector(button_pageedit_click:) forControlEvents:UIControlEventTouchUpInside];

	BOOL bshow = NO;
	{
		if([[Common info].photobook.ProductCode isEqualToString:@"347055"]) {
			bshow = YES;
		}
		if([[Common info].photobook.ProductCode isEqualToString:@"347056"]) {
			bshow = YES;
		}
		if([[Common info].photobook.ProductCode isEqualToString:@"347057"]) {
			bshow = YES;
		}
	}
	
	if(bshow == NO) {
		button_pageedit.hidden = YES;
	}
	
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 10.0;
    CGFloat width = (collectionView.bounds.size.width - spacing*3) / 2;
    
    CGRect page_rect = [Common info].photobook.page_rect;
    
    // page_width : page_height = width : h(?)
    CGFloat height = (width * page_rect.size.height) / page_rect.size.width;
    
    return CGSizeMake(width, height);
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
    else if ([segue.identifier isEqualToString:@"PolaroidEditTextSegue"]) {
        PolaroidEditTextViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
			vc.edittext_width = _edittext_width;
			vc.edittext_height = _edittext_height;
			vc.fontsize = _selected_layer.TextFontsize;

			NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld.%d%d%d%d%d", [Common info].photobook.base_folder, [Common info].photobook.BasketName, (long)_selected_page, _selected_layer.MaskX, _selected_layer.MaskY, _selected_layer.MaskW, _selected_layer.MaskH, _selected_layer.MaskR];
			vc.textcontents = [NSString stringWithContentsOfFile:tc_filepath encoding:NSUTF8StringEncoding error:nil];

			if ([_selected_layer.Halign isEqualToString:@"left"]) vc.alignment =  NSTextAlignmentLeft;				
			else if ([_selected_layer.Halign isEqualToString:@"right"]) vc.alignment =  NSTextAlignmentRight;
			else vc.alignment =  NSTextAlignmentCenter;
        }
    }
    else if ([segue.identifier isEqualToString:@"PageEditPolaroidSegue"]) {
        PageEditPolaroidViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;

			Page* tpage = [Common info].photobook.pages[_selected_page];
            vc.layouttype = tpage.CalendarCommonLayoutType;
            [vc updateLayouts];
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
    //[self performSegueWithIdentifier:@"PhotoSelectSegue" sender:self];
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)save:(id)sender {
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
        [[Common info].photobook saveFile];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - PhotoEditViewControllerDelegate methods

- (void)didEditPhoto {
    [_collection_view reloadData];
    [self clearSelectedInfo];
}

- (void)cancelEditPhoto {
    [self clearSelectedInfo];
}

#pragma mark - PolaroidEditTextDelegate methods

- (void)editTextDone:(NSString *)oriText withFmtText:(NSString* )fmtText withAlignment:(int)alignment {
	fmtText = [fmtText stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

	NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld.%d%d%d%d%d", [Common info].photobook.base_folder, [Common info].photobook.BasketName, (long)_selected_page, _selected_layer.MaskX, _selected_layer.MaskY, _selected_layer.MaskW, _selected_layer.MaskH, _selected_layer.MaskR];
	[oriText writeToFile:tc_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"oriText : %@", oriText);
	NSLog(@"fmtText : %@", fmtText);
	_selected_layer.TextDescription = fmtText;
	if(alignment == NSTextAlignmentLeft)
	    _selected_layer.Halign = @"left";
	else if(alignment == NSTextAlignmentRight)
	    _selected_layer.Halign = @"right";
	else
	    _selected_layer.Halign = @"center";

    [_collection_view reloadData];
}

#pragma mark - PhotobookDelegate methods

- (void)photobookProcess:(int)count TotalCount:(int)total_count {
    NSString *progress_str = [NSString stringWithFormat:@"폴라로이드 구성 중 (%d/%d)", count, total_count];
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
//                [_collection_view reloadData];
//            }
//        }
//        else if ([[Instagram info] selectedCount] > 0) {
//            InstaPhoto *photo = [Instagram info].sel_images[0];
//            if (photo != nil && _selected_layer != nil) {
//                //[[Common info].photobook addPhoto:photo Layer:_selected_layer PickIndex:0];
//                [_collection_view reloadData];
//            }
//        }
//        [[Common info].photo_pool removeAll];
//        [[Instagram info] removeAll];
		if ([[PhotoContainer inst] selectCount] > 0){
			PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:0];
			[[Common info].photobook addPhotoNew:photoItem Layer:_selected_layer PickIndex:0];
			[_collection_view reloadData];
		}
		
		[[PhotoContainer inst] initialize];
    }
    else {
        [self popupGuidePage:GUIDE_POLAROID_EDIT];

        // start thread..
        [self startFillPhotoThread];
        //[self fillPhoto];
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
    [_collection_view reloadData];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_HUD removeFromSuperview];
    _HUD = nil;
}

- (void)viewDidUnload {
}

#pragma mark - PageEditPolaroidViewControllerDelegate methods

- (void)changeLayout:(Layout *)layout {
    if (layout != nil && _selected_page >= 0) {
        [[Common info].photobook changeLayout:_selected_page From:layout];
        [_collection_view reloadData];
    }
    [self clearSelectedInfo];
}

@end
