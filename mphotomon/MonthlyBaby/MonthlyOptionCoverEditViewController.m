//
//  MonthlyOptionCoverEditViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 7. 23..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "MonthlyOptionCoverEditViewController.h"
#import "PageEditViewController.h"
#import "PhotoCropViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "FancyProductViewController.h"
#import "CardEditTextViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"
#import "MonthlyOptionArrangementViewController.h"
#import "MonthlyUploadPopup.h"

@interface MonthlyOptionCoverEditViewController () <UITextFieldDelegate>
{
    BOOL is_selecting_nav_item;
    BOOL is_photo_done;
}
@end

@implementation MonthlyOptionCoverEditViewController



- (void)viewDidLoad {
    //NSLog(@"-- [Common info].photobook.AddVal11 : %@", [Common info].photobook.AddVal11);
    [super viewDidLoad];
    [Analysis log:@"DesignPhotoEdit"];
    _thread = nil;
    
    NSLog(@"[Common info].photobook : %@", [Common info].photobook);
    
    is_selecting_nav_item = NO;
    is_photo_done = NO;
	
	_selectedPhoto = nil;
    _selected_page = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_collection_view addGestureRecognizer:tapGesture];
    
    _cancel_button.enabled = YES;
    _save_button.enabled = YES;
    _btn_pageadd.backgroundColor = UIColor.yellowColor;
    _photo_popup.hidden = YES;
    [self clearSelectedInfo];
   
     //_photobook = [[Photobook alloc]init];
    
	int uploadCnt = [MonthlyBaby inst].currentUploadCount;
	int bookCnt = [MonthlyBaby inst].isSeperated ? 2 : 1;
	if (false == [MonthlyBaby inst].isSeperated && uploadCnt > [MonthlyBaby inst].maxUploadCountPerBook) {
		uploadCnt = [MonthlyBaby inst].maxUploadCountPerBook;
	}
	NSString *uploadInfoStr = [NSString stringWithFormat:@"%d장 / %d권", uploadCnt, bookCnt ];
	[_uploadInfoLabel setText:uploadInfoStr ];
	
	_is_new = YES;
	_imageKey = @"";
	[[PhotoContainer inst] initialize];
    
    if (YES) {
        //PRODUCT_SINGLECARD, PRODUCT_DESIGNPHOTO, PRODUCT_POLAROID
        [Common info].photobook.product_type = PRODUCT_POLAROID;
        [[Common info].photobook initPhotobookPagesLocal];
        
        Page *onePage = [[Page alloc]init];
        CGFloat x = 0.0;
        CGFloat y = 0.0;
        CGFloat w = 614.0;
        CGFloat h = 410.0;
        [Common info].photobook.page_rect = CGRectMake(x, y, w, h);
        onePage.idx = 0;
        onePage.PageFile = @"img_cover.png"; //png는 필터링해야되나?
        onePage.IsCover = onePage.IsProlog = onePage.IsEpilog = onePage.IsPage = FALSE;
        onePage.IsPage = TRUE;
        onePage.PageWidth = [Common info].photobook.page_rect.size.width;
        onePage.PageHeight = [Common info].photobook.page_rect.size.height;
        
        Layer *oneLayer = [[Layer alloc] init];
        
        oneLayer.AreaType = 0;
        oneLayer.PageIndex = 0;
        oneLayer.LayerIndex = 0;
        oneLayer.MaskX = 300;
        oneLayer.MaskY = 8;
        oneLayer.MaskW = 302;
        oneLayer.MaskH = 256;
        oneLayer.MaskR = 0;
        oneLayer.FrameFilename = @"";
        // 신규 달력 포맷 : frameinfo
        oneLayer.Frameinfo = @"";
        // 신규 달력 포맷 : FrameFilename
        if(oneLayer.FrameFilename == nil || [oneLayer.FrameFilename isEqualToString:@""])
            oneLayer.FrameFilename = oneLayer.Frameinfo;
        
        
        [onePage.layers addObject:oneLayer];
        
        [[Common info].photobook.pages addObject:onePage];
        
        [Common info].photobook.delegate = self;
        
       
        [[Common info].photobook dumpLog];
        
        /*[[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:1];*/
        
        [self selectPhotoDone:NO];
        //[_collection_view reloadData];
       
    }
    /*else {
        [Common info].photobook.delegate = self;
        [Common info].photobook.product_type = 1;
        [[Common info].photobook loadPhotobookPages];
        
        NSArray *arr1 = [[Common info].photobook.AddVal10 componentsSeparatedByString: @"^"];
        for( NSObject* obj in arr1 ) [_nav_item_cnt addObject:obj];
        
        NSLog(@"_nav_item_cnt.count : %i", _nav_item_cnt.count);
        
        
        NSArray *arr2 = [[Common info].photobook.AddVal14 componentsSeparatedByString: @"^"];
        for( NSObject* obj in arr2 ) [_nav_item_theme addObject:obj];
        
        [_nav_view reloadData];
        [_collection_view reloadData];
    }*/
    
    is_selecting_nav_item = YES;
    //    [_nav_view
    //       selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
    //                    animated:NO
    //              scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    is_selecting_nav_item = NO;
	 [self registerForKeyboardNotifications];
	
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"DesignPhotoEdit" ScreenClass:[self.classForCoder description]];
	
	if (_is_new) {
	
		
		_is_new = NO;
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)noti {
    if (self.navigationController.topViewController == self) {
        
        /*[Common info].photobook.AddVal10 = [_nav_item_cnt componentsJoinedByString:@"^"];
        [Common info].photobook.AddVal14 = [_nav_item_theme componentsJoinedByString:@"^"];*/
        
        if(!(_is_new == YES && is_photo_done == NO)) {
            [[Common info].photobook saveFile];
            NSLog(@"appWillResignActive... saved...");
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _photo_popup.hidden = YES;
}

- (void)startFillPhotoThread {
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.delegate = self;
    _HUD.labelText = @"Loading ...";
    [self.view addSubview:_HUD];
    
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
    
    //스킨파일 파일 별도 저장
    Page *onePage = [Common info].photobook.pages[0];
    NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", [Common info].photobook.base_folder, onePage.PageFile];
    [[Common info] storeImage:onePage.PageFile ToFile:localpathname];
    
    [[Common info].photo_pool removeAll];
    [[Instagram info] removeAll];
    [_collection_view reloadData];
    //[_nav_view reloadData];
    
    [_HUD hide:YES afterDelay:0.1];
    is_photo_done = YES;
}

- (void)clearSelectedInfo {
    //_selected_page = 0;
    _current_position = 0;
//    _selected_layer = nil;
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
    
    _current_position = indexPath.row;
    
    if (indexPath && state == UIGestureRecognizerStateEnded) {
        UICollectionViewCell *cell = [_collection_view cellForItemAtIndexPath:indexPath];
        UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
        
        /*
         [cell setNeedsLayout];
         [cell layoutIfNeeded];
         [cell setNeedsDisplay];
         */
        [_collection_view reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
        
        
        Layer *layer = nil;
        {
            [_collection_view reloadData];
            CGPoint point_page = [_collection_view convertPoint:location toView:bkimageview];
            //CGPoint point_page = [cell.contentView convertPoint:location toView:bkimageview];
            layer = [[Common info].photobook getLayer:indexPath.row FromPoint:point_page];
        }
        if(layer == nil) {
            [_collection_view reloadData];
            CGPoint point_page = [_collection_view convertPoint:location toView:bkimageview];
            layer = [[Common info].photobook getLayer:indexPath.row FromPoint:point_page];
        }
        if (layer != nil && layer.AreaType == 0) {
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
        else if (layer != nil && layer.AreaType == 2) {
            _selected_page = indexPath.row;
            _selected_layer = layer;
            
            _edittext_width = _selected_layer.MaskW * [Common info].photobook.edit_scale;
            _edittext_height = _selected_layer.MaskH * [Common info].photobook.edit_scale;
            
            //[self performSegueWithIdentifier:@"CardEditTextSegue" sender:self];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CardEditTextViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CardEditTextView"];
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
                
                
                [self.navigationController presentViewController:vc animated:YES completion:nil ];
            }
            
        }
        if( layer!=nil )
        {
            NSLog(@"layer.AreaType : %d", layer.AreaType);
        }
    }
}

- (IBAction)button_removepage_click:(UIButton *)btn
{
    if(_nav_item_cnt.count <= 1) {
        [self.view makeToast:@"마지막 페이지는 삭제할 수 없습니다."];
        return;
    }
    
    NSIndexPath *indexPath;
    indexPath = [self.nav_view indexPathForItemAtPoint:[self.nav_view convertPoint:btn.center fromView:btn.superview]];
    
    [self removePage:(indexPath.row+1)];
}

- (IBAction)button_increasecnt_click:(UIButton *)btn
{
    NSIndexPath *indexPath;
    indexPath = [self.nav_view indexPathForItemAtPoint:[self.nav_view convertPoint:btn.center fromView:btn.superview]];
    UICollectionViewCell *cell = [_nav_view dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];
    
    int ival = [_nav_item_cnt[indexPath.row] intValue] + 1;
    _nav_item_cnt[indexPath.row] = [NSString stringWithFormat:@"%d", ival];
    
    [_nav_view reloadData];
    [_collection_view reloadData];
}

- (IBAction)button_decreasecnt_click:(UIButton *)btn
{
    NSIndexPath *indexPath;
    indexPath = [self.nav_view indexPathForItemAtPoint:[self.nav_view convertPoint:btn.center fromView:btn.superview]];
    UICollectionViewCell *cell = [_nav_view dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];
    
    int ival = [_nav_item_cnt[indexPath.row] intValue] - 1;
    if(ival < 1 ) ival = 1;
    _nav_item_cnt[indexPath.row] = [NSString stringWithFormat:@"%d", ival];
    
    [_nav_view reloadData];
    [_collection_view reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if(collectionView == _collection_view)
        return 1;
    else
        return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //return 1;
    return [Common info].photobook.pages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if(collectionView == _collection_view) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DesignPhotoEditCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];
        if(indexPath.row == _selected_page) cell.contentView.backgroundColor = [UIColor lightGrayColor];
        else cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    
    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    //[bkimageview setImage:[UIImage imageNamed:@"img_cover.png"]];
    
    CGRect frame;
    {
        frame = bkimageview.frame;
        
        // SJYANG.2018.06 : 가로모드 이미지 겹침 문제 해결
        @try {
            for (UIView *aView in [bkimageview subviews]){
                if ([aView isKindOfClass:[UIImageView class]]){
                    [aView removeFromSuperview];
                }
            }
        }
        @catch(NSException *exception) {}
        
        CGFloat spacing = 25.0;
        
        CGFloat height = (collectionView.frame.size.height - spacing * 2);
        
        
        // SJYANG.2018.06 : 가로모드 : 여길 고쳐야 함
        //CGRect page_rect = [Common info].photobook.page_rect;
        
        Page* page = (Page*)[Common info].photobook.pages[indexPath.row];
        CGRect page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);
        
        
        CGFloat width = (height * page_rect.size.width) / page_rect.size.height;
        
        // SJYANG.2018.06 : 가로모드 : 여길 고쳐야 함
        //frame.size = CGSizeMake(width, height - 3.0f);
        /*if(width > height)
            frame.size = CGSizeMake(width * 0.5f, height * 0.5f);
        else
            //frame.size = CGSizeMake(width, height - 3.0f);
            frame.size = CGSizeMake(width, height);*/
//        frame.size = CGSizeMake(width * 1.5f, height * 1.5f);
		
        bkimageview.frame = frame;
        
        //bkimageview.backgroundColor = UIColor.redColor;
        bkimageview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        bkimageview.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
    }
	
	UILabel *plzUploadPhoto = (UILabel *)[cell viewWithTag:201];
	
	if (_selectedPhoto != nil) {
		[plzUploadPhoto setHidden:YES];
	}
	else {
		[plzUploadPhoto setHidden:NO];
	}
    
    if(collectionView == _collection_view)
        [[Common info].photobook composePage:indexPath.row ParentView:bkimageview IncludeBg:YES IsEdit:YES];
    else
        [[Common info].photobook composePage:indexPath.row ParentView:bkimageview IncludeBg:YES IsEdit:NO];
    
    if(collectionView == _collection_view) {
        UIButton *button_pageedit = (UIButton *)[cell viewWithTag:150];
        [button_pageedit addTarget:self action:@selector(button_pageedit_click:) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL bshow = NO;
        if(bshow == NO) button_pageedit.hidden = YES;
    }
    
    /*if(collectionView == _nav_view) {
        UILabel *view = (UILabel *)[cell viewWithTag:104];
        view.text = [_nav_item_cnt objectAtIndex:indexPath.row];
        
    }*/
    
    //bkimageview.backgroundColor = UIColor.redColor;
    //bkimageview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    bkimageview.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
    
    bkimageview.translatesAutoresizingMaskIntoConstraints = YES;
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat spacing = 0.0f;
    CGFloat height = (collectionView.frame.size.height - spacing * 2);
    
    // SJYANG.2018.06 : 가로모드 디버깅중 : 여길 고쳐야 함
    //CGRect page_rect = [Common info].photobook.page_rect;
    Page* page = (Page*)[Common info].photobook.pages[indexPath.row];
    CGRect page_rect;
    if(page.PageWidth > page.PageHeight)
        page_rect = CGRectMake(0, 0, page.PageWidth * 0.5f, page.PageHeight);
    else
        page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);
    
    
    CGFloat width = (height * page_rect.size.width) / page_rect.size.height;
    
    if(collectionView == _collection_view)
        return CGSizeMake(screenWidth, height);
    else
        return CGSizeMake(width, height);
     
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if(collectionView == _collection_view)
        return 0;
    else
        return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if(collectionView == _collection_view)
        return 0;
    else
        return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selected_page = indexPath.row;
    if(collectionView == _nav_view) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        [_nav_view reloadData];
        
        NSLog(@"didSelectItemAtIndexPath :: is_selecting_nav_item : %d", is_selecting_nav_item);
        if(is_selecting_nav_item == NO) {
            [_collection_view scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                             animated:YES];
        }
    }
    is_selecting_nav_item = NO;
}

#pragma mark - Navigation

/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 if(scrollView == _collection_view){ // new check
 int x = (int)(_collection_view.contentOffset.x / _collection_view.bounds.size.width) * 120; // cell width + spacing 48 + 8
 CGFloat y = 0;
 CGPoint contentOffset = CGPointMake(x, y);
 _nav_view.contentOffset = contentOffset;
 }
 }
 */

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSIndexPath *indexPath = nil;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    int current_page = -1;
    
    if(scrollView == _collection_view) {
        int n = 0;
        int page1_x = -1;
        int page2_x = -1;
        int page1_row = -1;
        int page2_row = -1;
        for (UICollectionViewCell *cell in [_collection_view visibleCells]) {
            indexPath = [_collection_view indexPathForCell:cell];
            
            CGPoint point_page = [cell.superview convertPoint:cell.frame.origin toView:nil];
            
            //NSLog(@"I've GOT IT : %d",indexPath.row);
            //NSLog(@"I've GOT IT #2 : %f",point_page.x);
            
            if(n == 0) {
                page1_x = (int)point_page.x;
                page1_row = indexPath.row;
            }
            else if(n == 1) {
                page2_x = (int)point_page.x;
                page2_row = indexPath.row;
            }
            n++;
        }
        if(n==1) {
            current_page = page1_row;
        }
        else {
            if(abs(page1_x) < abs(page2_x)) current_page = page1_row;
            else current_page = page2_row;
        }
        _selected_page = current_page;
        //NSLog(@"#4 : _selected_page : %d", _selected_page);
    }
    
    if(current_page >= 0) {
        is_selecting_nav_item = YES;
        [_nav_view
         selectItemAtIndexPath:[NSIndexPath indexPathForItem:current_page inSection:0]
         animated:YES
         scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        is_selecting_nav_item = NO;
    }
    
    [_nav_view reloadData];;
}

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
    else if ([segue.identifier isEqualToString:@"PageEditDesignPhotoSegue"]) {
        PageEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
            
            Page* tpage = [Common info].photobook.pages[_selected_page];
            vc.layouttype = @"designphoto";
            [[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:1];
            [vc updateLayouts];
        }
    }
}

- (void)removePage:(int)pageno {
    [_nav_item_cnt removeObjectAtIndex:(pageno-1)];
    [_nav_item_theme removeObjectAtIndex:(pageno-1)];
    
    [[Common info].photobook.pages removeObjectAtIndex:(pageno-1)];
    
    [self.collection_view performBatchUpdates:^{
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(pageno-1) inSection:0];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
        [indexPaths addObject:indexPath];
        
        [_collection_view deleteItemsAtIndexPaths:indexPaths];
        [_nav_view deleteItemsAtIndexPaths:indexPaths];
        
    } completion:nil];
}

- (IBAction)addPage:(id)sender {
    NSInteger pageno = [Common info].photobook.pages.count;
    Page *default_page = [[Common info].photobook.pages[0] copy]; // 첫번째 페이지 복사
    
    
    // SJYANG.2018.06 : 가로모드 처리
    /*
     Layout *layout = [[Common info].layout_pool getDefaultLayout];
     if (layout != nil) {
     default_page.layers = layout.layers;
     }
     */
    // PTODO
    default_page.layers = default_page.layers;
    
    
    if ([[Common info].photobook insertPage:(pageno-1) FromDefaultPage:default_page]) {
        [_nav_item_cnt addObject:@"1"];
        [_nav_item_theme addObject:[_nav_item_theme objectAtIndex:0]];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageno inSection:0];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
        [indexPaths addObject:indexPath];
        
        [_collection_view insertItemsAtIndexPaths:indexPaths];
        [_nav_view insertItemsAtIndexPaths:indexPaths];
    }
}

- (IBAction)clickMessage:(id)sender {
    UIView *message_view = (UIView *)[self.view viewWithTag:200];
    message_view.hidden = TRUE;
    _message_constraint.constant = 0;
    
    // TODO : 체크 필요
    for(int i = 0;i < [Common info].photobook.pages.count - 1;i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_collection_view dequeueReusableCellWithReuseIdentifier:@"DesignPhotoEditCell" forIndexPath:ip];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        [cell setNeedsDisplay];
    }
    for(int i = 0;i < [Common info].photobook.pages.count - 1;i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_nav_view dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:ip];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        [cell setNeedsDisplay];
    }
}

- (IBAction)addPhoto:(id)sender {
	[[Common info].photo_pool removeAll];
	[[Instagram info] removeAll];
	[Common info].photobook.ProductCode = @"";
	[Common info].photobook.product_type = PRODUCT_MONTHLYBABY;
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:1 Param:@""];
}

- (IBAction)changePhoto:(id)sender {
	[[Common info].photo_pool removeAll];
	[[Instagram info] removeAll];
	[Common info].photobook.ProductCode = @"";
	[Common info].photobook.product_type = PRODUCT_MONTHLYBABY;
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:1 Param:@""];
}

- (IBAction)save:(id)sender {
    [Common info].photobook.AddVal10 = [_nav_item_cnt componentsJoinedByString:@"^"];
    [Common info].photobook.AddVal14 = [_nav_item_theme componentsJoinedByString:@"^"];
    
    if(_is_new == YES && is_photo_done == NO)
        return;
    
    [[Common info].photobook saveFile];
    //FancyProductViewController *root_vc =(FancyProductViewController*) [self.navigationController.viewControllers firstObject];
    /*if (root_vc == [Common info].card_root_controller)
        [[Common info].card_root_controller goStorage];
    else if (root_vc == [Common info].card_product_root_controller)
        [[Common info].card_product_root_controller goStorage];
    else if (root_vc == [Common info].photobook_root_controller)
        [[Common info].photobook_root_controller goStorage];
    else if (root_vc == [Common info].photobook_product_root_controller)
        [[Common info].photobook_product_root_controller goStorage];*/
    //[root_vc goStorage];
}

- (IBAction)cancel:(id)sender {
    if (_save_button.enabled == NO) { // 취소가 잘 안되는 문제가...
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
    }
    else {
        if(!(_is_new == YES && is_photo_done == NO)) {
            //[[Common info].photobook saveFile];
        }
    }
	
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - PhotoEditViewControllerDelegate methods

- (void)didEditPhoto {
    [_collection_view reloadData];
    [_nav_view reloadData];
    [self clearSelectedInfo];
}

- (void)cancelEditPhoto {
    [self clearSelectedInfo];
}

#pragma mark - PhotobookDelegate methods
//picture add process hud show
- (void)photobookProcess:(int)count TotalCount:(int)total_count {
    NSString *progress_str = [NSString stringWithFormat:@"구성 중 (%d/%d)", count, total_count];
    
    _HUD.progress = count/total_count;
    _HUD.labelText = progress_str;
}

- (void)photobookError {
    [self clearSelectedInfo];
}

#pragma mark - SelectPhotoDelegate methods

- (void)selectPhotoDone:(BOOL)is_singlemode {
    if (is_singlemode) {
//		if ([[Common info].photo_pool totalCount] > 0) {
//			_selectedPhoto = [[Common info].photobook pickPhoto:0];
//			if (_selectedPhoto != nil && _selected_layer != nil) {
//				is_photo_done = YES;
//				[[Common info].photobook addPhoto:_selectedPhoto Layer:_selected_layer PickIndex:0];
//				[_collection_view reloadData];
//				//[_nav_view reloadData];
//			}
//		}
//        else if ([[Instagram info] selectedCount] > 0) {
//            InstaPhoto *photo = [Instagram info].sel_images[0];
//            if (photo != nil && _selected_layer != nil) {
//                is_photo_done = YES;
//                //[[Common info].photobook addPhoto:photo Layer:_selected_layer PickIndex:0];
//                [_collection_view reloadData];
//                //[_nav_view reloadData];
//            }
//        }
		
		if ([[PhotoContainer inst] selectCount] > 0) {
			_selectedPhoto = [[PhotoContainer inst] getSelectedItem:0];
			
			if (_selectedPhoto != nil && _selected_layer != nil) {
				is_photo_done = YES;
				[[Common info].photobook addPhotoNew:_selectedPhoto Layer:_selected_layer PickIndex:0];
				[_collection_view reloadData];
			}
		}
		
		_imageKey = @"";
    }
    else {
        //[self popupGuidePage:GUIDE_POLAROID_EDIT];
        
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
    /*
     if ([[Common info] checkGuideUserDefault:guide_id]) {
     GuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GuidePage"];
     if (vc) {
     vc.guide_id = guide_id;
     vc.delegate = self;
     [self presentViewController:vc animated:YES completion:nil];
     }
     }
     */
}

- (void)closeGuide {
    [_collection_view reloadData];
    [_nav_view reloadData];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_HUD removeFromSuperview];
    _HUD = nil;
}

- (void)viewDidUnload {
}

#pragma mark - PageEditViewControllerDelegate methods

- (IBAction)button_pageedit_click:(UIButton *)btn
{
    //[self performSegueWithIdentifier:@"PageEditDesignPhotoSegue" sender:self];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PageEditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PageLayoutEditView"];
    if (vc) {
        vc.delegate = self;
        
        Page* tpage = [Common info].photobook.pages[_selected_page];
        vc.layouttype = @"designphoto";
        [[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:1];
        [vc updateLayouts];
        //[self.navigationController pushViewController:vc animated:YES];
        [self.navigationController presentViewController:vc animated:YES completion:nil ];
    }
	
}

- (void)changeLayout:(Layout *)layout {
    if (layout != nil && _selected_page >= 0) {
        
        [[Common info].photobook changeLayout:_selected_page From:layout];
        
        [_collection_view reloadData];
        [_nav_view reloadData];
        
        [_nav_view
         selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selected_page inSection:0]
         animated:YES
         scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        
        //UICollectionViewCell *cell = [_collection_view cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selected_page inSection:0]];
        [_collection_view reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForItem:_selected_page inSection:0], nil]];
    }
    [self clearSelectedInfo];
}
- (IBAction)goCropPhoto:(id)sender {
    //[[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
    //NSLog(@"go cropphoto");
    //non segue view control
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotoCropViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PhotoCropView"];
    if (vc) {
        vc.delegate = self;
        if (_selected_layer && _selected_layer.ImageFilename.length > 0) {
            [vc loadCropInfo:[Common info].photobook SelectedLayer:_selected_layer];
        }
        [self.navigationController presentViewController:vc animated:YES completion:nil ];
    }

}
#pragma mark - CardEditTextDelegate methods

- (void)editTextDone:(NSString *)oriText withFmtText:(NSString* )fmtText withAlignment:(int)alignment {
    NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page];
    NSLog(@"tc_filepath : %@", tc_filepath);
    [oriText writeToFile:tc_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    if(![_selected_layer.Grouping isEqualToString:@"1"]){
        _selected_layer.TextDescription = [fmtText copy];
        if(alignment == NSTextAlignmentLeft)
            _selected_layer.Halign = @"left";
        else if(alignment == NSTextAlignmentRight)
            _selected_layer.Halign = @"right";
        else
            _selected_layer.Halign = @"center";
    }
    else{
        //[_collection_view.la ];
        //CGPoint point_page = [cell.contentView convertPoint:location toView:bkimageview];
        //layer = [[Common info].photobook getLayer:indexPath.row FromPoint:point_page];
        
        _selected_layer.TextDescription = [fmtText copy];
        
        if(alignment == NSTextAlignmentLeft)
            _selected_layer.Halign = @"left";
        else if(alignment == NSTextAlignmentRight)
            _selected_layer.Halign = @"right";
        else
            _selected_layer.Halign = @"center";
        
        Page *selectpage = [Common info].photobook.pages[_selected_page];
        
        for (Layer *item in selectpage.layers){
            if(item.AreaType == 2 && [item.Grouping isEqualToString:_selected_layer.Grouping]){
                item.TextDescription = [fmtText copy];
                if(alignment == NSTextAlignmentLeft)
                    item.Halign = @"left";
                else if(alignment == NSTextAlignmentRight)
                    item.Halign = @"right";
                else
                    item.Halign = @"center";
            }
        }
    
    }
    
    
    [_collection_view reloadData];
    [_nav_view reloadData];
}

- (IBAction)moveNext:(id)sender
{
	if (_selectedPhoto != nil) {
		
		if ([_mainTitleTextField.text length] <= 0)
		{
			[[Common info] alert:self Title:@"제목이 입력되지 않았습니다.\n제목없이 만드시겠습니까?" Msg:@"" okCompletion:^{
				[self uploadImage];
//				NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//				[params setObject:[Common info].user.mUserid forKey:@"userid"];
//				[params setObject:@"monthlybaby" forKey:@"monthlycover"];
//
//				[[MonthlyBaby inst] uploadImage:_selectedPhoto url:[Common buildQueryURL:[MonthlyBaby inst].uploadURL query:@[]] params:params delegate:self];
				
			} cancelCompletion:^{
//				[self dismissViewControllerAnimated:YES completion:^{
//					[[Common info].main_controller didTouchMenuButton:nil];
//				}];
				
				//                        decisionHandler(WKNavigationActionPolicyCancel);
				
			} okTitle:@"네" cancelTitle:@"아니오"];
		} else {
			
			[self uploadImage];
			
//			NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//			[params setObject:[Common info].user.mUserid forKey:@"userid"];
//			[params setObject:@"monthlybaby" forKey:@"monthlycover"];
//
//			[[MonthlyBaby inst] uploadImage:_selectedPhoto url:[Common buildQueryURL:[MonthlyBaby inst].uploadURL query:@[]] params:params delegate:self];
		}
	}
	else {
//		[self.view makeToast:@"커버 이미지를 선택해 주세요."];
		
		[[Common info] alert:self Msg:@"커버에 들어갈 사진을 올려주세요."];
	}
//	[[MonthlyBaby inst] uploadImage:photo url:[Common buildQueryURL:[MonthlyBaby inst].uploadURL, nil] params:params delegate:self];
	
//	MonthlyOptionArrangementViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionArrangementViewController"];
//	[self.navigationController pushViewController:vc animated:YES ];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
	
	if(textField.textInputMode != nil && textField.textInputMode.primaryLanguage != nil && [textField.textInputMode.primaryLanguage isEqualToString:@"emoji"] ) {
		[[Common info]alert:self Msg:@"이모지는 입력하실 수 없습니다."];
		return FALSE;
	}

	NSString *checkChar = [[Common info] checkEucKr:string];
	if(checkChar != nil) {
		NSString *errorMsg = [NSString stringWithFormat:@"다음 글자는 입력하실 수 없는 글자입니다.\n[%@]", checkChar];
//		[self.view makeToast:errorMsg];
		[[Common info]alert:self Msg:errorMsg];
		return FALSE;
	}
	
	if (textField == _mainTitleTextField) {
		NSString *resultText = [textField.text stringByReplacingCharactersInRange:range
																	   withString:string];
		if (resultText.length > 25){
			
			[_mainScrollView makeToast:@"제목은 최대 25글자 입니다."];
		}
		return resultText.length <= 25;
	}
	else if (textField == _subTitleTextField) {
		NSString *resultText = [textField.text stringByReplacingCharactersInRange:range
																	   withString:string];
		if (resultText.length > 25){
			[_mainScrollView makeToast:@"부제목은 최대 25글자 입니다."];
		}
		return resultText.length <= 25;
	}
	
	return TRUE;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	//	NSLog(@"--> %.5f complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if (response == nil || [response isEqualToString:@"err"]) {
		response = [[NSString alloc] initWithData:data encoding:0x80000000 + kCFStringEncodingDOSKorean];
		NSLog(@"--> upload failure: %@", response);
		
	} else {
		// 업로드 종료
		NSArray * ret_data = [response componentsSeparatedByString:@"|"];
		if ([ret_data count] == 2) {
			
			// 0 : CoverImageKey
			[MonthlyBaby inst].coverImageKey = [ret_data objectAtIndex:0];
			
			Page *page = [Common info].photobook.pages[0];
			Layer *layer = page.layers[0];
			
			[MonthlyBaby inst].trimInfo = [NSString stringWithFormat:@"%d^%d^%d^%d^%d", layer.ImageCropY, layer.ImageCropX, layer.ImageCropW, layer.ImageCropH, layer.ImageR];
			
			[MonthlyBaby inst].mainTitle = _mainTitleTextField.text;
			[MonthlyBaby inst].subTitle = _subTitleTextField.text;
			
			MonthlyOptionArrangementViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionArrangementViewController"];
			[self.navigationController pushViewController:vc animated:YES ];
			
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
	[self dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark - Notify Keyboard is Showing / Hiding
- (void)registerForKeyboardNotifications
{
	// Call this method somewhere in your view controller setup code.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
	
}

#pragma mark - Handle Keyboard Notification

- (void)keyboardWillShown:(NSNotification*)aNotification
{
	// Called when the UIKeyboardDidShowNotification is sent.
	//Create Animation Block for UIView
	
	NSDictionary* info = [aNotification userInfo];
//	CGRect beginFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect endFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	if (@available(iOS 11.0, *)) {
		_nextButtonYPositionConstraint.constant = endFrame.size.height - self.view.safeAreaInsets.bottom;
	} else {
		// Fallback on earlier versions
		_nextButtonYPositionConstraint.constant = endFrame.size.height;
	}
	_scrollViewYOffset.constant = endFrame.size.height + 40;
	
	//DebugLog(@"beginFrame %f",beginFrame.size.height);
	//DebugLog(@"endFrame %f",endFrame.size.height);
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
	// Called when the UIKeyboardDidShowNotification is sent.
	
	[_mainScrollView scrollRectToVisible:CGRectMake(_mainScrollView.contentSize.width - 1,_mainScrollView.contentSize.height - 1, 1, 1) animated:YES];
//	[_mainScrollView scrollRectToVisible:CGRectMake(0, 500, 1, 1) animated:TRUE];
	
	//DebugLog(@"beginFrame %f",beginFrame.size.height);
	//DebugLog(@"endFrame %f",endFrame.size.height);
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	// Called when the UIKeyboardWillHideNotification is sent
	
	_nextButtonYPositionConstraint.constant = 0;
	_scrollViewYOffset.constant =  0;
}

- (void) uploadImage {
	if ( _imageKey.length == 0 ){
	
		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MonthlyBaby" bundle:nil];
		MonthlyUploadPopup *vc = [sb instantiateViewControllerWithIdentifier:@"MonthlyUploadPopup"];
		
		if (vc) {
//			[vc setData:1 svcmode:@"monthlycover" delegate:self];
			[vc setData:1 svcmode:@"monthlycover" uploadDoneOp:^(BOOL isSuccess, NSString *imageKey) {
				if (isSuccess) {
					_imageKey = imageKey;
					[MonthlyBaby inst].coverImageKey = imageKey;
					
					Page *page = [Common info].photobook.pages[0];
					Layer *layer = page.layers[0];
					CGSize oriImageSize = [[Common info] getRotatedSize:CGSizeMake(layer.ImageOriWidth, layer.ImageOriHeight) Rotate:layer.ImageR];
					CGFloat scale = MIN(oriImageSize.width / layer.ImageCropW, oriImageSize.height / layer.ImageCropH);
					
					CGRect crop_rect = CGRectMake(layer.ImageCropX * scale, layer.ImageCropY * scale, layer.ImageCropW * scale, layer.ImageCropH * scale);
					int x = (int)crop_rect.origin.x;
					int y = (int)crop_rect.origin.y;
					int w = (int)crop_rect.size.width;
					int h = (int)crop_rect.size.height;
					
					[MonthlyBaby inst].trimInfo = [NSString stringWithFormat:@"%d^%d^%d^%d^%d", y, x, w, h, layer.ImageR];
					
					[MonthlyBaby inst].mainTitle = _mainTitleTextField.text;
					[MonthlyBaby inst].subTitle = _subTitleTextField.text;
					
					MonthlyOptionArrangementViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionArrangementViewController"];
					[self.navigationController pushViewController:vc animated:YES ];
				} else {
					[[Common info] alert:self Msg:@"커버 전송중 오류가 발생하였습니다."];
				}
			}];
			[self presentViewController:vc animated:NO completion:nil];
		}
	} else {
		[self uploadPhotoDone:YES imageKey:_imageKey];
	}
}

- (void) uploadPhotoDone:(BOOL)isSuccess imageKey:(NSString *)imageKey{
	
	if (isSuccess) {
		_imageKey = imageKey;
		[MonthlyBaby inst].coverImageKey = imageKey;
		
		Page *page = [Common info].photobook.pages[0];
		Layer *layer = page.layers[0];
		CGSize oriImageSize = [[Common info] getRotatedSize:CGSizeMake(layer.ImageOriWidth, layer.ImageOriHeight) Rotate:layer.ImageR];
		CGFloat scale = MIN(oriImageSize.width / layer.ImageCropW, oriImageSize.height / layer.ImageCropH);
		
		CGRect crop_rect = CGRectMake(layer.ImageCropX * scale, layer.ImageCropY * scale, layer.ImageCropW * scale, layer.ImageCropH * scale);
		int x = (int)crop_rect.origin.x;
		int y = (int)crop_rect.origin.y;
		int w = (int)crop_rect.size.width;
		int h = (int)crop_rect.size.height;
		
		[MonthlyBaby inst].trimInfo = [NSString stringWithFormat:@"%d^%d^%d^%d^%d", y, x, w, h, layer.ImageR];
		
		[MonthlyBaby inst].mainTitle = _mainTitleTextField.text;
		[MonthlyBaby inst].subTitle = _subTitleTextField.text;
		
		MonthlyOptionArrangementViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionArrangementViewController"];
		[self.navigationController pushViewController:vc animated:YES ];
	} else {
		[[Common info] alert:self Msg:@"커버 전송중 오류가 발생하였습니다."];
	}
}
@end
