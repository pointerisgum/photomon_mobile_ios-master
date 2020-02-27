//
//  CalendarEditTableViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "CalendarEditTableViewController.h"
#import "PhotoCropViewController.h"
#import "PageEditViewController.h"
//#import "AlbumCollectionViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"

@implementation MemorialDay
- (id)init {
    if (self = [super init]) {
        _type = @"";
        _date = @"";
        _title = @"";
        _lunar = @"";
        _data = @"";
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end

@interface CalendarEditTableViewController ()

@end

@implementation CalendarEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"CalendarEdit"];
    _thread = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_table_view addGestureRecognizer:tapGesture];

    _cancel_button.enabled = YES;
    _save_button.enabled = YES;

    [self clearSelectedInfo];
	
	NSString *intnum = @"";
	@try {
		intnum = [[Common info].photobook.ProductCode substringWithRange:NSMakeRange(0, 3)];
	}
	@catch(NSException *exception) {}

    if (_is_new) {
        [Common info].photobook.delegate = self;
        [Common info].photobook.start_year = _start_year;
        [Common info].photobook.start_month = _start_month;
		
		int monthCount = [Common info].photobook.monthCount;
		// 일단 예외처리 1로 셋팅 해 달라고 요청 필요
		if ([intnum isEqualToString:@"393"])
			monthCount = 1;
        
        if ([intnum isEqualToString:@"369"])
            [Common info].photobook.AddVal14 = [NSString stringWithFormat:@"%@",_selectOptionIdx == 0 ? @"roundX" : @"roundO"];
        
		[Common info].photobook.AddVal15 = [NSString stringWithFormat:@"%d-%@-%@", monthCount, [Common info].photobook.isDouble ? @"true" : @"false", [Common info].photobook.showSpring ? @"true" : @"false"];
		
        
        _progressView = [[ProgressView alloc]initWithTitle:@"Loading"];
        [_progressView manageProgress:(CGFloat)0.99];
            _cancel_button.enabled = NO;
            _save_button.enabled = NO;

            if (_thread) {
                [_thread cancel];
                _thread = nil;
            }

            _thread = [[NSThread alloc] initWithTarget:self selector:@selector(initInfoStartThread) object:nil];
            [_thread start];
        
        /*
        //goto initInfoStartThread
        if (![[Common info].photobook initPhotobookPages]) {
            [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
         */
        
        /*
         
         //goto initInfoEndThread
         
         if ([intnum isEqualToString:@"369"])
            [Common info].photobook.DefaultProductPrice = [_discount intValue];
        
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
         */
    }
    else {
        [Common info].photobook.delegate = self;
        [[Common info].photobook loadPhotobookPages];
		bool isParsed = NO;
		if (![[Common info].photobook.AddVal15 isEqualToString:@""]) {
			NSArray *params = [[Common info].photobook.AddVal15 componentsSeparatedByString:@"-"];
			if ([params count] == 3) {
				[Common info].photobook.monthCount = [params[0] intValue];
				[Common info].photobook.isDouble = [params[1] boolValue];
				[Common info].photobook.showSpring = [params[2] boolValue];
				isParsed = YES;
			}
		}
		
		if(!isParsed) {
			
			// 하드코딩으로 셋팅
			// monthCount
			
			if ([intnum isEqualToString:@"277"]) [Common info].photobook.monthCount =  14;
			else if ([intnum isEqualToString:@"367"]) [Common info].photobook.monthCount =  12;
			else if ([intnum isEqualToString:@"368"]) [Common info].photobook.monthCount =  14;
			else if ([intnum isEqualToString:@"369"]) [Common info].photobook.monthCount =  15;
			// SJYANG : 2018 달력
			else if ([intnum isEqualToString:@"391"]) [Common info].photobook.monthCount =  14;
			else if ([intnum isEqualToString:@"392"]) [Common info].photobook.monthCount =  12;
			else if ([intnum isEqualToString:@"393"]) [Common info].photobook.monthCount =  1;
			else [Common info].photobook.monthCount =  CALENDAR_PAGE_MAX;
			
			// isDouble
			[Common info].photobook.isDouble = [intnum isEqualToString:@"277"] || [intnum isEqualToString:@"369"];
			
			// showSpring
			[Common info].photobook.showSpring = [intnum isEqualToString:@"367"] || [intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"];
			
		}
    }
    //[[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:[Common info].photobook.product_type];
}
-(void)initInfoStartThread{
    
    if (![[Common info].photobook initPhotobookPages]) {
       [self performSelectorOnMainThread:@selector(notFoundToastThread) withObject:nil waitUntilDone:NO];
        return;
    }
    //    [[Common info].photobook fillPhotobookPages];
        [self performSelectorOnMainThread:@selector(initInfoEndThread) withObject:nil waitUntilDone:NO];
     //[_progressView manageProgress:(CGFloat)1];
    

}
-(void)notFoundToastThread{
    [_progressView endProgress];
    [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
    [self.navigationController popViewControllerAnimated:NO];
    
}
-(void)initInfoEndThread{
    NSString *intnum = @"";
    @try {
        intnum = [[Common info].photobook.ProductCode substringWithRange:NSMakeRange(0, 3)];
    }
    @catch(NSException *exception) {}
    
    if ([intnum isEqualToString:@"369"])
        [Common info].photobook.DefaultProductPrice = [_discount intValue];
    
    [[Common info].photobook dumpLog];

    //[self performSegueWithIdentifier:@"PhotoMultiSelectSegue" sender:self];

    // SJYANG : 캘린더 시작년월 변경
    //[[Common info] selectPhoto:self Singlemode:NO MinPictures:[Common info].photobook.minpictures Param:@""];
    int nPages = 0;
    int nImageLayers = 0;
    for (Page *page in [Common info].photobook.pages) {
        nPages++;
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0) { // 0: image
                nImageLayers++;
                
            }
        }
        
    }
    //[_progressView endProgress];
    
    [[Common info] selectPhoto:self Singlemode:NO MinPictures:nImageLayers Param:@""];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [Analysis firAnalyticsWithScreenName:@"CalendarEdit" ScreenClass:[self.classForCoder description]];
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
    //_progressView = [[ProgressView alloc]initWithTitle:@"달력 구성 중"];
    [_progressView changeProgressTitle:@"달력 구성 중"];
    
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

            Page *objselpage = [Common info].photobook.pages[_selected_page];
            if(objselpage.CalendarCommonLayoutType == nil || [objselpage.CalendarCommonLayoutType isEqualToString:@""]) {
                button_edit.enabled = NO;
                [Common info].layout_pool.calendarcommonlayouttype = @"n/a";
            }
            else {
                [[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:[Common info].photobook.product_type CalendarCommonLayoutType:objselpage.CalendarCommonLayoutType];
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
    NSString *intnum = @"";
    @try {
        NSString *product_code = [Common info].photobook.ProductCode;
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
    }
    @catch(NSException *exception) {}

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarEditCell" forIndexPath:indexPath];

    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    Page *page = [Common info].photobook.pages[indexPath.row];

    float pageheight = 600.f / (float)page.PageWidth * (float)page.PageHeight;

    // multiplier:291.0 x 234.0
    // 600 / 453 * 234 = 482.474...
    CGFloat multiplier_height = pageheight + 29.47422680412371134020618556702 * ((float)page.PageWidth / 600.f) ; // 482.474 ... 453

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
	// 포스터 달력 관련 코드 추가
	if([intnum isEqualToString:@"393"]) {
		footlabel.text = [NSString stringWithFormat:@"%d년", page.CalendarYear];
	}
	else {
		if (indexPath.row == 0) {
			footlabel.text = @"커버";
		}
		else if (indexPath.row == [Common info].photobook.pages.count-1 && ![intnum isEqualToString:@"369"]) {
			footlabel.text = @"에필로그";
		}
		else {
			if ([Common info].photobook.isDouble) {
				NSString *temp = ((indexPath.row % 2) == 1) ? @"앞" : @"뒤";
				// SJYANG : 2018 달력
				footlabel.text = [NSString stringWithFormat:@"%d년 %d월 (%@)", page.CalendarYear, page.CalendarMonth, temp];
			} else {
				footlabel.text = [NSString stringWithFormat:@"%d년 %d월", page.CalendarYear, page.CalendarMonth];
			}
		}
	}

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
    if ([intnum isEqualToString:@"369"] && indexPath.row > 0 && indexPath.row%2 == 0) // 우드스탠드
        h += 4;

    if ([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"368"] || [intnum isEqualToString:@"391"] || [intnum isEqualToString:@"392"]) { // 소형벽걸이 + 미니특가달력 + 시트달력 + 대형벽걸이
        if(indexPath.row == 0)
            h += 5;
    }
    else {
        if ((indexPath.row % 2 == 0)) {
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
    else if ([segue.identifier isEqualToString:@"PageEditCalendarSegue"]) {
        PageEditCalendarViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
            if (_selected_page == 0) {
                vc.layouttype = @"cover";
            }
            else {
                vc.layouttype = @"page";
            }
            [vc updateLayouts];
        }
    }
/*
    else if ([segue.identifier isEqualToString:@"PhotoMultiSelectSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        AlbumCollectionViewController *vc = (AlbumCollectionViewController *)navi.topViewController;
        vc.is_singlemode = NO;
        vc.count_max = [Common info].photobook.minpictures;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"PhotoSelectSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        AlbumCollectionViewController *vc = (AlbumCollectionViewController *)navi.topViewController;
        vc.is_singlemode = YES;
        vc.count_max = 0;
        vc.delegate = self;
    }
*/
/*    else if ([segue.identifier isEqualToString:@"PhotobookGuideEditSegue"]) {
        PhotobookGuideViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.guide_id = @"PhotobookGuide2";
            vc.delegate = self;
        }
    }*/
}

- (IBAction)clickMessage:(id)sender {
    UIView *message_view = (UIView *)[self.view viewWithTag:200];
    message_view.hidden = TRUE;
    _message_constraint.constant = 0;
}

- (IBAction)addPhoto:(id)sender {
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

/*
- (IBAction)deletePhoto:(id)sender {
}
*/

- (IBAction)changePhoto:(id)sender {
    //[self performSegueWithIdentifier:@"PhotoSelectSegue" sender:self];
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)save:(id)sender {
    [[Common info].photobook saveFile];
    UIViewController *root_vc = [self.navigationController.viewControllers firstObject];
    if (root_vc == [Common info].photobook_root_controller) {
        [[Common info].photobook_root_controller goStorage];
    }
    else {
        [[Common info].photobook_product_root_controller goStorage];
    }
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

#pragma mark - PageEditCalendarViewControllerDelegate methods

- (void)changeLayout:(Layout *)layout {
    if (layout != nil && _selected_page >= 0) {
        [[Common info].photobook changeLayout:_selected_page From:layout];
        [_table_view reloadData];
    }
    [self clearSelectedInfo];
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
    NSString *progress_str = [NSString stringWithFormat:@"달력 구성 중 (%d/%d)", count, total_count];
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
        [self popupGuidePage:GUIDE_CALENDAR_EDIT];
/*        // check guide
        if ([[Common info] checkGuideUserDefault:@"PhotobookGuide2"]) {
            [self performSegueWithIdentifier:@"PhotobookGuideEditSegue" sender:self];
            return;
        }
  */
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

@end
