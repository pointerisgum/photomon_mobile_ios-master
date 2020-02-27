//
//  DesignPhotoEditViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "DesignPhotoEditViewController.h"
#import "PageEditViewController.h"
#import "PhotoCropViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"

@interface DesignPhotoEditViewController ()

@end

@implementation DesignPhotoEditViewController

BOOL is_selecting_nav_item;
BOOL is_photo_done;

- (void)viewDidLoad {
    //NSLog(@"-- [Common info].photobook.AddVal11 : %@", [Common info].photobook.AddVal11);
    [super viewDidLoad];
    [Analysis log:@"DesignPhotoEdit"];
    _thread = nil;

    NSLog(@"[Common info].photobook : %@", [Common info].photobook);

    is_selecting_nav_item = NO;
	is_photo_done = NO;

    _nav_item_cnt = [NSMutableArray arrayWithCapacity:1];
    _nav_item_theme = [NSMutableArray arrayWithCapacity:1];
	_selected_page = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_collection_view addGestureRecognizer:tapGesture];
    
    _cancel_button.enabled = YES;
    _save_button.enabled = YES;
    _btn_pageadd.backgroundColor = UIColor.yellowColor; 
    
    [self clearSelectedInfo];

    [_nav_item_cnt removeAllObjects];
    [_nav_item_theme removeAllObjects];
    
    if (_is_new) {
        [Common info].photobook.delegate = self;
        
        if (![[Common info].photobook initPhotobookPages]) {
            [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
        [[Common info].photobook dumpLog];
        
        [[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:PRODUCT_DESIGNPHOTO];
        Layout *defaultLayout = [[Common info].layout_pool getDefaultLayout];
        [[Common info].photobook changeLayout:_selected_page From:defaultLayout];
        
        [self selectPhotoDone:NO];

        [_nav_item_cnt addObject:@"1"];
        [_nav_item_theme addObject:[Common info].photobook.AddVal7];
        //NSLog(@"[Common info].photobook.AddVal11 : %@", [Common info].photobook.AddVal11);
        //NSLog(@"[Common info].photobook.AddVal7 : %@", [Common info].photobook.AddVal7);
    }
    else {
        [Common info].photobook.delegate = self;
        [[Common info].photobook loadPhotobookPages];

        NSArray *arr1 = [[Common info].photobook.AddVal10 componentsSeparatedByString: @"^"];
        for( NSObject* obj in arr1 ) [_nav_item_cnt addObject:obj];

        NSLog(@"_nav_item_cnt.count : %i", _nav_item_cnt.count);

        
        NSArray *arr2 = [[Common info].photobook.AddVal14 componentsSeparatedByString: @"^"];
        for( NSObject* obj in arr2 ) [_nav_item_theme addObject:obj];

        [_nav_view reloadData];
        [_collection_view reloadData];
    }

    is_selecting_nav_item = YES;
//    [_nav_view
//       selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
//                    animated:NO
//              scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];   
	is_selecting_nav_item = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"DesignPhotoEdit" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)noti {
    if (self.navigationController.topViewController == self) {

        [Common info].photobook.AddVal10 = [_nav_item_cnt componentsJoinedByString:@"^"];
        [Common info].photobook.AddVal14 = [_nav_item_theme componentsJoinedByString:@"^"];

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
    _progressView = [[ProgressView alloc]initWithTitle:@""];
    
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
    [_nav_view reloadData];
    
    [_progressView endProgress];
//    [_HUD hide:YES afterDelay:0.1];
}

- (void)clearSelectedInfo {
    //_selected_page = 0;
    _current_position = 0;
    _selected_layer = nil;
    _photo_popup.hidden = YES;
    
    _edittext_width = .0f;
    _edittext_height = .0f;
}

- (void)singleTapPiece:(id)sender {
	//[_collection_view reloadData];

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
        }else if (layer != nil && layer.AreaType == 2) {
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
                
//                NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page];
				NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld.%d%d%d%d%d", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page, _selected_layer.MaskX, _selected_layer.MaskY, _selected_layer.MaskW, _selected_layer.MaskH, _selected_layer.MaskR];
                vc.textcontents = [NSString stringWithContentsOfFile:tc_filepath encoding:NSUTF8StringEncoding error:nil];
                
                if ([_selected_layer.Halign isEqualToString:@"left"]) vc.alignment =  NSTextAlignmentLeft;
                else if ([_selected_layer.Halign isEqualToString:@"right"]) vc.alignment =  NSTextAlignmentRight;
                else vc.alignment =  NSTextAlignmentCenter;
                
                
                [self.navigationController presentViewController:vc animated:YES completion:nil ];
            }
            
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

    for (UIView* subviewItem in bkimageview.subviews)
    {
        [subviewItem removeFromSuperview];
    }
    
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
		if(width > height)
	        frame.size = CGSizeMake(width * 0.5f, height * 0.5f);
		else
			//frame.size = CGSizeMake(width, height - 3.0f);
			frame.size = CGSizeMake(width, height);

        bkimageview.frame = frame;

        //bkimageview.backgroundColor = UIColor.redColor;
        bkimageview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        bkimageview.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
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

    if(collectionView == _nav_view) {
        UILabel *view = (UILabel *)[cell viewWithTag:104];
        view.text = [_nav_item_cnt objectAtIndex:indexPath.row];
    }

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
            [[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:PRODUCT_DESIGNPHOTO];
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
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)changePhoto:(id)sender {
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)save:(id)sender {
    [Common info].photobook.AddVal10 = [_nav_item_cnt componentsJoinedByString:@"^"];
    [Common info].photobook.AddVal14 = [_nav_item_theme componentsJoinedByString:@"^"];

	if(_is_new == YES && is_photo_done == NO) 
		return;

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
		if(!(_is_new == YES && is_photo_done == NO)) {
		    [[Common info].photobook saveFile];
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

- (void)photobookProcess:(int)count TotalCount:(int)total_count {
    NSString *progress_str = [NSString stringWithFormat:@"네컷인화 구성 중 (%d/%d)", count, total_count];
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
//				is_photo_done = YES;
//                [[Common info].photobook addPhoto:photo Layer:_selected_layer PickIndex:0];
//                [_collection_view reloadData];
//                [_nav_view reloadData];
//            }
//        }
//        else if ([[Instagram info] selectedCount] > 0) {
//            InstaPhoto *photo = [Instagram info].sel_images[0];
//            if (photo != nil && _selected_layer != nil) {
//				is_photo_done = YES;
//                //[[Common info].photobook addPhoto:photo Layer:_selected_layer PickIndex:0];
//                [_collection_view reloadData];
//                [_nav_view reloadData];
//            }
//        }
//        [[Common info].photo_pool removeAll];
//        [[Instagram info] removeAll];
		if ([[PhotoContainer inst] selectCount] > 0){
			PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:0];
			[[Common info].photobook addPhotoNew:photoItem Layer:_selected_layer PickIndex:0];
			is_photo_done = YES;
			[_collection_view reloadData];
			[_nav_view reloadData];
		}
		
		[[PhotoContainer inst] initialize];
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
    [self performSegueWithIdentifier:@"PageEditDesignPhotoSegue" sender:self];
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
#pragma mark - CardEditTextDelegate methods

- (void)editTextDone:(NSString *)oriText withFmtText:(NSString* )fmtText withAlignment:(int)alignment {
//    NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page];
	NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld.%d%d%d%d%d", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page, _selected_layer.MaskX, _selected_layer.MaskY, _selected_layer.MaskW, _selected_layer.MaskH, _selected_layer.MaskR];
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

@end
