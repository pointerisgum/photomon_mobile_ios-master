//
//  DesignPhotoEditViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "SingleCardEditViewController.h"
#import "PageEditViewController.h"
#import "PhotoCropViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "CardEditTextViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"
#import "SCENavCollectionViewCell.h"
#import "UIColor+HexString.h"
#import "ProgressView.h"

@interface SingleCardEditViewController ()
@property (strong, nonatomic) ProgressView *progressView;
@end

@implementation SingleCardEditViewController

BOOL is_card_selecting_nav_item;
BOOL is_card_photo_done;

- (void)viewDidLoad {
    //NSLog(@"-- [Common info].photobook.AddVal11 : %@", [Common info].photobook.AddVal11);
    [super viewDidLoad];
    
    [self drawChangeDesignEditBG];
    
    //photobook log
    NSLog(@"[Common info].photobook : %@", [Common info].photobook);
    
    
    [Analysis log:@"DesignPhotoEdit"];
    _thread = nil;

    is_card_selecting_nav_item = NO;
	is_card_photo_done = NO;

    _nav_item_cnt = [[NSMutableArray alloc] init];
    _nav_item_theme = [NSMutableArray arrayWithCapacity:1];
    isFronts = [[NSMutableArray alloc] init];
	_selected_page = 0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_collection_view addGestureRecognizer:tapGesture];
    
    _cancel_button.enabled = YES;
    _save_button.enabled = YES;
//    _btn_pageadd.backgroundColor = UIColor.yellowColor;
    
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
        
        [self selectPhotoDone:NO];

        [_nav_item_cnt addObject:@"1"];
        [_nav_item_cnt addObject:@"1"];
        [_nav_item_theme addObject:[Common info].photobook.AddVal7];
        [_nav_item_theme addObject:[Common info].photobook.AddVal7];
        NSLog(@"[Common info].photobook.AddVal11 : %@", [Common info].photobook.AddVal11);
        NSLog(@"[Common info].photobook.AddVal7 : %@", [Common info].photobook.AddVal7);
        
        NSLog(@"[Common info].photobook : %@", [Common info].photobook);

        isFronts = [@[[NSNumber numberWithBool:YES]] mutableCopy];

    }
    else {
            [Common info].photobook.delegate = self;
            [[Common info].photobook loadPhotobookPages];
            
            NSLog(@"[Common info].photobook.AddVal10 : %@", [Common info].photobook.AddVal10);
            
            NSArray *arr1 = [[Common info].photobook.AddVal10 componentsSeparatedByString: @"^"];
            for( NSObject* obj in arr1 ) {
                [_nav_item_cnt addObject:obj];
                [isFronts addObject:[NSNumber numberWithBool:YES]];
            }
            NSArray *arr2 = [[Common info].photobook.AddVal14 componentsSeparatedByString: @"^"];
            for( NSObject* obj in arr2 ) [_nav_item_theme addObject:obj];
            
        dispatch_async(dispatch_get_main_queue(), ^{
            [_nav_view reloadData];
            [_collection_view reloadData];
        });

    }

    is_card_selecting_nav_item = YES;
    [_nav_view
       selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] 
                    animated:NO
              scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];   
    is_card_selecting_nav_item = NO;
     
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"DesignPhotoEdit" ScreenClass:[self.classForCoder description]];
}

- (void)drawChangeDesignEditBG {
    self.changeDesignEditBG.layer.cornerRadius = 16;
    self.changeDesignEditBG.layer.borderWidth = 1;
    self.changeDesignEditBG.layer.borderColor = [UIColor colorFromHexString:@"dddddd"].CGColor;
    self.changeDesignEditBG.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
}

- (void)didReceiveMemoryWarning {
    NSLog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)noti {
    NSLog(@"appWillResignActive");
    if (self.navigationController.topViewController == self) {

        [Common info].photobook.AddVal10 = [_nav_item_cnt componentsJoinedByString:@"^"];
        [Common info].photobook.AddVal14 = [_nav_item_theme componentsJoinedByString:@"^"];

		if(!(_is_new == YES && is_card_photo_done == NO)) {
			[[Common info].photobook saveFile];
			NSLog(@"appWillResignActive... saved...");
		}
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    _photo_popup.hidden = YES;
}

- (void)startFillPhotoThread {
    NSLog(@"startFillPhotoThread");
    
    _progressView = [[ProgressView alloc]initWithTitle:@"포토카드인화 구성 중"];
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
    NSLog(@"doingThread");
    [[Common info].photobook fillPhotobookPages];
    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)doneThread {
    NSLog(@"doneThread");
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
    NSLog(@"clearSelectedInfo");
    //_selected_page = 0;
    _current_position = 0;
    _selected_layer = nil;
    _photo_popup.hidden = YES;
    
    _edittext_width = .0f;
    _edittext_height = .0f;
}

- (void)singleTapPiece:(id)sender {
	//[_collection_view reloadData];

    NSLog(@"singleTapPiece");
	[self.view endEditing:YES];
    [self clearSelectedInfo];
    
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    UIGestureRecognizerState state = singleTap.state;
    
    
    CGPoint locationCopy = [singleTap locationInView: _collection_view];
    CGPoint location = CGPointMake(locationCopy.x, locationCopy.y);
    
    NSIndexPath *indexPath = [_collection_view indexPathForItemAtPoint: location];

    _current_position = indexPath.row;
    
    if (indexPath && state == UIGestureRecognizerStateEnded) {
        UICollectionViewCell *cell = [_collection_view cellForItemAtIndexPath:indexPath];
        UIImageView *bkimageview;
        
        NSNumber *number = isFronts[indexPath.row];
        NSInteger realIndexPathCount;
        
        if ([number boolValue]) {
            bkimageview = (UIImageView *)[cell viewWithTag:100];
            realIndexPathCount = (indexPath.row * 2);
        }else{
            bkimageview = (UIImageView *)[cell viewWithTag:200];
            realIndexPathCount = (indexPath.row * 2)+1;
        }

        
        
		[_collection_view reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
        [_collection_view reloadData];
        
        CGPoint point_page = [_collection_view convertPoint:location toView:bkimageview];
        Layer *layer = [[Common info].photobook getLayer:realIndexPathCount FromPoint:point_page];
        
		if(layer == nil) {
			[_collection_view reloadData];
			CGPoint point_page = [_collection_view convertPoint:location toView:bkimageview];
			layer = [[Common info].photobook getLayer:realIndexPathCount FromPoint:point_page];
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
        } else if (layer != nil && layer.AreaType == 2) {
            _selected_page = indexPath.row;
            _selected_layer = layer;
            
            _edittext_width = _selected_layer.MaskW * [Common info].photobook.edit_scale;
            _edittext_height = _selected_layer.MaskH * [Common info].photobook.edit_scale;
            
            [self performSegueWithIdentifier:@"CardEditTextSegue" sender:self];
        }
        
    }
}

- (void)editTextDone:(NSString *)oriText withFmtText:(NSString* )fmtText withAlignment:(int)alignment {
    
    NSInteger p = 0;
    if ([isFronts[_selected_page] boolValue]) {
        
        p = _selected_page * 2;
    }else{
        p = _selected_page * 2 + 1;
    }
    
    NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)p];
    NSLog(@"tc_filepath : %@", tc_filepath);
    [oriText writeToFile:tc_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    _selected_layer.TextDescription = [fmtText copy];
    if(alignment == NSTextAlignmentLeft)
        _selected_layer.Halign = @"left";
    else if(alignment == NSTextAlignmentRight)
        _selected_layer.Halign = @"right";
    else
        _selected_layer.Halign = @"center";
    
    [_nav_view reloadData];
    [_collection_view reloadData];
}

- (IBAction)button_removepage_click:(UIButton *)btn
{
    NSLog(@"button_removepage_click");
	if(_nav_item_cnt.count <= 2) {
	    [self.view makeToast:@"마지막 페이지는 삭제할 수 없습니다."];
		return;
	}

	NSIndexPath *indexPath = [self.nav_view indexPathForItemAtPoint:[self.nav_view convertPoint:btn.center fromView:btn.superview]];

    [self removePage:(indexPath.row+1)];
    
}

- (IBAction)button_increasecnt_click:(UIButton *)btn
{
    NSLog(@"button_increasecnt_click");
    
    if ([self isCardMaxCheck]) {
        return;
    }

    
    NSIndexPath *indexPath;
    indexPath = [self.nav_view indexPathForItemAtPoint:[self.nav_view convertPoint:btn.center fromView:btn.superview]];
    UICollectionViewCell *cell = [_nav_view dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];

    int ival = [_nav_item_cnt[indexPath.row * 2] intValue] + 1;
    _nav_item_cnt[indexPath.row * 2] = [NSString stringWithFormat:@"%d", ival];
    _nav_item_cnt[indexPath.row * 2 + 1] = [NSString stringWithFormat:@"%d", ival];

    [_nav_view reloadData];
    [_collection_view reloadData];
}

- (IBAction)button_decreasecnt_click:(UIButton *)btn
{
    NSLog(@"button_decreasecnt_click");
    NSIndexPath *indexPath;
    indexPath = [self.nav_view indexPathForItemAtPoint:[self.nav_view convertPoint:btn.center fromView:btn.superview]];
    UICollectionViewCell *cell = [_nav_view dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];

    int ival = [_nav_item_cnt[indexPath.row * 2] intValue] - 1;
    if(ival < 1 ) ival = 1;
    _nav_item_cnt[indexPath.row * 2] = [NSString stringWithFormat:@"%d", ival];
    _nav_item_cnt[indexPath.row * 2 + 1] = [NSString stringWithFormat:@"%d", ival];

    [_nav_view reloadData];
    [_collection_view reloadData];
}

- (IBAction)clickChangeFront:(UIButton *)btn
{
    NSLog(@"clickChangeFront");
    
    [self clearSelectedInfo];
    NSIndexPath *indexPath = [self.nav_view indexPathForItemAtPoint:[self.nav_view convertPoint:btn.center fromView:btn.superview]];
    
//    NSNumber *number = isFronts[indexPath.row];
//    number = [NSNumber numberWithBool:![number boolValue]];
//    [isFronts replaceObjectAtIndex:indexPath.row withObject:number];

    _selected_page = indexPath.row;
    if (btn.tag == 1) {
        [isFronts replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }else{
        [isFronts replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }
    

    [self.collection_view reloadData];
    [self.nav_view reloadData];
    
    if(is_card_selecting_nav_item == NO) {
        [_collection_view scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                         animated:YES];
    }

    
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if(collectionView == _collection_view)
        return 1;
    else
        return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook.pages.count/2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if(collectionView == _collection_view) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DesignPhotoEditCell" forIndexPath:indexPath];
	} else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];
//        if(indexPath.row == _selected_page) cell.contentView.backgroundColor = [UIColor lightGrayColor];
//        else cell.contentView.backgroundColor = [UIColor whiteColor];
    }

   
    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    UIImageView *bkimageview2 = (UIImageView *)[cell viewWithTag:200];

    
    @try {
        for (UIView *aView in [bkimageview subviews]){
//            if ([aView isKindOfClass:[UIImageView class]]){
                [aView removeFromSuperview];
//            }
        }
    }
    @catch(NSException *exception) {}
    
    @try {
        for (UIView *aView in [bkimageview2 subviews]){
//            if ([aView isKindOfClass:[UIImageView class]]){
                [aView removeFromSuperview];
//            }
        }
    }
    @catch(NSException *exception) {}
    
    if(collectionView == _collection_view){
        UIView *shadowView = [cell.contentView viewWithTag:400];

        CGRect frame = bkimageview.frame;
        NSLog(@"NSStringFromCGRect(bkimageview.frame) : %@", NSStringFromCGRect(bkimageview.frame));
        CGFloat spacing = 25.0;
        CGFloat height = (collectionView.frame.size.height - spacing * 2);
        
        
        Page* page = (Page*)[Common info].photobook.pages[indexPath.row * 2];
        CGRect page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);
        CGFloat width = (height * page_rect.size.width) / page_rect.size.height;
        
        if(width > height)
            frame.size = CGSizeMake(width * 0.5f, height * 0.5f);
        else
            frame.size = CGSizeMake(width, height);
        
        bkimageview.frame = frame;
        bkimageview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        bkimageview.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
        
        bkimageview2.frame = frame;
        bkimageview2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        bkimageview2.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);

//        shadowView.frame = CGRectInset(frame,1,1);
        shadowView.frame = frame;
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        shadowView.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);


        [[Common info].photobook composePage:indexPath.row * 2 ParentView:bkimageview IncludeBg:YES IsEdit:YES];
        [[Common info].photobook composePage:indexPath.row * 2 + 1 ParentView:bkimageview2 IncludeBg:YES IsEdit:YES];

        
        NSNumber *number = isFronts[indexPath.row];
        [bkimageview setHidden:![number boolValue]];
        [bkimageview2 setHidden:[number boolValue]];
        
        UILabel *lbText = (UILabel *)[cell viewWithTag:300];
        lbText.text = ([number boolValue])? @"앞면":@"뒷면";

        
//        bkimageview.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
        NSLog(@"NSStringFromCGRect(cell.contentView.bounds) : %@", NSStringFromCGRect(cell.contentView.bounds));

        bkimageview.translatesAutoresizingMaskIntoConstraints = YES;
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
        
        

        bkimageview.layer.cornerRadius = 25.0;
        bkimageview.layer.masksToBounds = YES;
        bkimageview.layer.borderColor = [UIColor colorFromHexString:@"dddddd"].CGColor;
        
        bkimageview2.layer.cornerRadius = 25.0;
        bkimageview2.layer.masksToBounds = YES;
        bkimageview2.layer.borderColor = [UIColor colorFromHexString:@"dddddd"].CGColor;

        
   
        //그림자 영역
        shadowView.userInteractionEnabled = NO;
        shadowView.backgroundColor = [UIColor colorFromHexString:@"dddddd"];
        shadowView.layer.cornerRadius = 25;
        shadowView.layer.shadowColor = [UIColor colorFromHexString:@"dddddd"].CGColor;
        shadowView.layer.shadowOffset = CGSizeMake(2, 2);
        shadowView.layer.shadowRadius = 3;
        shadowView.layer.shadowOpacity = 1;
        shadowView.clipsToBounds = NO;
        
        
        
        
    }else{
        
        
        
        CGRect frame = bkimageview.frame;
        CGFloat spacing = 25.0;
        CGFloat height = (collectionView.frame.size.height - spacing * 2);
        
        
        Page* page = (Page*)[Common info].photobook.pages[indexPath.row * 2];
        CGRect page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);
        CGFloat width = (height * page_rect.size.width) / page_rect.size.height;
        
        if(width > height)
            frame.size = CGSizeMake(width * 0.5f, height * 0.5f);
        else
            frame.size = CGSizeMake(width, height);
        
//        bkimageview.frame = frame;
//        bkimageview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//        bkimageview.center = CGPointMake(cell.contentView.bounds.size.width/3,cell.contentView.bounds.size.height/2);
        
//        bkimageview2.frame = frame;
//        bkimageview2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//        bkimageview2.center = CGPointMake(cell.contentView.bounds.size.width/3*2,cell.contentView.bounds.size.height/2);

        
        
        [[Common info].photobook composePage:indexPath.row * 2 ParentView:bkimageview IncludeBg:YES IsEdit:NO];
        [[Common info].photobook composePage:indexPath.row * 2 + 1 ParentView:bkimageview2 IncludeBg:YES IsEdit:NO];
        
        for (UIView *v in [bkimageview viewWithTag:5001].subviews) {
            NSLog(@"%@", [v class]);
            [v removeFromSuperview];
        }
        
        for (UIView *v in [bkimageview2 viewWithTag:5001].subviews) {
            NSLog(@"%@", [v class]);
            [v removeFromSuperview];
        }
        
        
        UIView *lv = [cell.contentView viewWithTag:500];
        UIView *rv = [cell.contentView viewWithTag:501];

//        bkimageview.center = CGPointMake(lv.frame.size.width/2 + 2,lv.frame.size.height/2);
//        bkimageview2.center = CGPointMake(rv.frame.size.width/2 - 2,rv.frame.size.height/2);

        bkimageview.translatesAutoresizingMaskIntoConstraints = YES;
        bkimageview2.translatesAutoresizingMaskIntoConstraints = YES;
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];


        //254 140 28
        bkimageview.layer.cornerRadius = 6.0;
        bkimageview.layer.masksToBounds = YES;
        
        bkimageview2.layer.cornerRadius = 6.0;
        bkimageview2.layer.masksToBounds = YES;
        
        UILabel *lblItemCnt = (UILabel *)[cell viewWithTag:104];
        lblItemCnt.text = [_nav_item_cnt objectAtIndex:indexPath.row * 2];
        
        if ( _selected_page == indexPath.row) {
            if ([isFronts[indexPath.row] boolValue] ) {
                bkimageview.layer.borderWidth = 2.0;
                bkimageview2.layer.borderWidth = 1.0;
                bkimageview.layer.borderColor = [UIColor colorFromHexString:@"ff8d1d"].CGColor;
                bkimageview2.layer.borderColor = [UIColor colorFromHexString:@"cccccc"].CGColor;
            }else{
                bkimageview.layer.borderWidth = 1.0;
                bkimageview2.layer.borderWidth = 2.0;
                bkimageview.layer.borderColor = [UIColor colorFromHexString:@"cccccc"].CGColor;
                bkimageview2.layer.borderColor = [UIColor colorFromHexString:@"ff8d1d"].CGColor;
            }
            [lblItemCnt setTextColor:[UIColor colorWithRed:255/255.0 green:141/255.0 blue:29/255.0 alpha:1.0]];
        }else{
            bkimageview.layer.borderWidth = 1.0;
            bkimageview2.layer.borderWidth = 1.0;
            bkimageview.layer.borderColor = [UIColor colorFromHexString:@"cccccc"].CGColor;
            bkimageview2.layer.borderColor = [UIColor colorFromHexString:@"cccccc"].CGColor;
            [lblItemCnt setTextColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]];
        }
        


    }



    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat spacing = 0.0f;
    CGFloat height = (collectionView.frame.size.height - spacing * 2);

	
	// SJYANG.2018.06 : 가로모드 디버깅중 : 여길 고쳐야 함
	Page* page = (Page*)[Common info].photobook.pages[indexPath.row];
	CGRect page_rect;
	if(page.PageWidth > page.PageHeight)
		page_rect = CGRectMake(0, 0, page.PageWidth * 0.5f, page.PageHeight);
	else
		page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);


    CGFloat width = ((height - 50) * page_rect.size.width) / page_rect.size.height * 2 + 20;

    
    
    if(collectionView == _collection_view)
        return CGSizeMake(screenWidth, height);
    else
        return CGSizeMake(137, 128);
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
/*        _photo_popup.hidden = YES;
        
//        SCENavCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NavCell" forIndexPath:indexPath];
        SCENavCollectionViewCell *cell = (SCENavCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        if (cell.frame.size.width/2 > cell.clickedLocation.x) {
            //뒤쪽
            [isFronts replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        }else{
            //앞쪽
           [isFronts replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        }
        
//        cell.contentView.backgroundColor = [UIColor lightGrayColor];
		[_nav_view reloadData];
        [_collection_view reloadData];

		NSLog(@"didSelectItemAtIndexPath :: is_selecting_nav_item : %d", is_card_selecting_nav_item);
        if(is_card_selecting_nav_item == NO) {
			[_collection_view scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]
													   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
													   animated:YES];
        }
*/
    } 
    is_card_selecting_nav_item = NO;
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
    NSLog(@"scrollViewDidEndDecelerating");
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
        is_card_selecting_nav_item = YES;
        [_nav_view
           selectItemAtIndexPath:[NSIndexPath indexPathForItem:current_page inSection:0] 
                        animated:YES
                  scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];   
		is_card_selecting_nav_item = NO;
    }

	[_nav_view reloadData];;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSLog(@"shouldPerformSegueWithIdentifier");
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue");
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

            
            NSInteger p = 0;
            if ([isFronts[_selected_page] boolValue]) {
                
                p = _selected_page * 2;
            }else{
                p = _selected_page * 2 + 1;
            }
            NSLog(@"page : %i", p);
         
            
            Page* tpage = [Common info].photobook.pages[p];
            vc.layouttype = @"designphoto";
            [[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme:@"" ProductType:PRODUCT_SINGLECARD];
            [vc updateLayouts];
        }
    }
    
    if ([segue.identifier isEqualToString:@"CardEditTextSegue"]) {
        CardEditTextViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
            vc.edittext_width = _edittext_width;
            vc.edittext_height = _edittext_height;
            vc.fontsize = _selected_layer.TextFontsize;
            
            NSInteger p = 0;
            if ([isFronts[_selected_page] boolValue]) {
                
                p = _selected_page * 2;
            }else{
                p = _selected_page * 2 + 1;
            }
            NSLog(@"page : %i", p);
            
            NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)p];
//            vc.textcontents = [NSString stringWithContentsOfFile:tc_filepath encoding:NSUTF8StringEncoding error:nil];
            vc.textcontents = _selected_layer.TextDescription;
            
            if ([_selected_layer.Halign isEqualToString:@"left"]) vc.alignment =  NSTextAlignmentLeft;
            else if ([_selected_layer.Halign isEqualToString:@"right"]) vc.alignment =  NSTextAlignmentRight;
            else vc.alignment =  NSTextAlignmentCenter;
        }
    }
}

- (void)removePage:(int)pageno {
    NSLog(@"removePage : %i", pageno);
    [_nav_item_cnt removeObjectAtIndex:(pageno-1) * 2];
    [_nav_item_cnt removeObjectAtIndex:(pageno-1) * 2];
    [_nav_item_theme removeObjectAtIndex:(pageno-1) * 2];
    [_nav_item_theme removeObjectAtIndex:(pageno-1) * 2];
    [isFronts removeObjectAtIndex:(pageno-1)];

    
    [[Common info].photobook.pages removeObjectAtIndex:(pageno-1)*2];
    [[Common info].photobook.pages removeObjectAtIndex:(pageno-1)*2];

    [self.collection_view performBatchUpdates:^{

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(pageno-1) inSection:0];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
        [indexPaths addObject:indexPath];

        [self.collection_view deleteItemsAtIndexPaths:indexPaths];
        [self.nav_view deleteItemsAtIndexPaths:indexPaths];
        

    } completion:^(BOOL finished) {
        NSLog(@"selected_page : %i", self.selected_page );
        NSLog(@"_nav_item_cnt : %i", _nav_item_cnt.count );

        if(self.selected_page + 1 >  _nav_item_cnt.count / 2){
            self.selected_page--;
            NSLog(@"줄인다.");
        }
        
        [self.collection_view reloadData];
        [self.nav_view reloadData];
    }];
}

- (IBAction)addPage:(id)sender {
    NSLog(@"addPage");
    
    if ([self isCardMaxCheck]) {
        return;
    }
    
    
    NSInteger pageno = [Common info].photobook.pages.count;
    Page *default_page = [[Common info].photobook.pages[0] copy]; // 첫번째 페이지 복사
    Page *default_page1 = [[Common info].photobook.pages[1] copy]; // 두번째 페이지 복사

	default_page.layers = default_page.layers;


    if ([[Common info].photobook insertPage:(pageno-1) FromDefaultPage:default_page]) {
        if ([[Common info].photobook insertPage:(pageno) FromDefaultPage:default_page1]) {
            
            [_nav_item_cnt addObject:@"1"];
            [_nav_item_cnt addObject:@"1"];
            [_nav_item_theme addObject:[_nav_item_theme objectAtIndex:0]];
            [_nav_item_theme addObject:[_nav_item_theme objectAtIndex:1]];
            
            [isFronts addObject:[NSNumber numberWithBool:YES]];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageno/2 inSection:0];
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
            [indexPaths addObject:indexPath];
            
            [_collection_view insertItemsAtIndexPaths:indexPaths];
            [_nav_view insertItemsAtIndexPaths:indexPaths];
        }
    }

}

- (IBAction)clickMessage:(id)sender {
    NSLog(@"clickMessage");
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
    NSLog(@"addPhoto");
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)changePhoto:(id)sender {
    NSLog(@"changePhoto");
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)save:(id)sender {
    NSLog(@"save");
    [Common info].photobook.AddVal10 = [_nav_item_cnt componentsJoinedByString:@"^"];
    [Common info].photobook.AddVal14 = [_nav_item_theme componentsJoinedByString:@"^"];

    NSLog(@"[Common info].photobook.AddVal10 : %@", [Common info].photobook.AddVal10);
    NSLog(@"_nav_item_cnt : %@", _nav_item_cnt);

	if(_is_new == YES && is_card_photo_done == NO)
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
    else if (root_vc == [Common info].goods_root_controller) {
        [[Common info].goods_root_controller goStorage];
    }
}

- (IBAction)cancel:(id)sender {
    NSLog(@"cancel");
    if (_save_button.enabled == NO) { // 취소가 잘 안되는 문제가...
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
    }
    else {
        [Common info].photobook.AddVal10 = [_nav_item_cnt componentsJoinedByString:@"^"];
        [Common info].photobook.AddVal14 = [_nav_item_theme componentsJoinedByString:@"^"];

        if(!(_is_new == YES && is_card_photo_done == NO)) {
		    [[Common info].photobook saveFile];
        }
    }
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - PhotoEditViewControllerDelegate methods

- (void)didEditPhoto {
    NSLog(@"didEditPhoto");
    [_collection_view reloadData];
    [_nav_view reloadData];
    [self clearSelectedInfo];
}

- (void)cancelEditPhoto {
    NSLog(@"cancelEditPhoto");
    [self clearSelectedInfo];
}

#pragma mark - PhotobookDelegate methods

- (void)photobookProcess:(int)count TotalCount:(int)total_count {
    NSLog(@"photobookProcess");
    NSString *progress_str = [NSString stringWithFormat:@"포토카드인화 구성 중 (%d/%d)", count, total_count];

    [_progressView manageProgress:(CGFloat)count/(CGFloat)total_count];
//    _HUD.progress = count/total_count;
//    _HUD.labelText = progress_str;
}

- (void)photobookError {
    NSLog(@"photobookError");
    [self clearSelectedInfo];
}

#pragma mark - SelectPhotoDelegate methods

- (void)selectPhotoDone:(BOOL)is_singlemode {
    NSLog(@"selectPhotoDone");
    
    if (is_singlemode) {
//        if ([[Common info].photo_pool totalCount] > 0) {
//            Photo *photo = [[Common info].photobook pickPhoto:0];
//            if (photo != nil && _selected_layer != nil) {
//				is_card_photo_done = YES;
//                [[Common info].photobook addPhoto:photo Layer:_selected_layer PickIndex:0];
//                [_collection_view reloadData];
//                [_nav_view reloadData];
//            }
//        }
//        else if ([[Instagram info] selectedCount] > 0) {
//            InstaPhoto *photo = [Instagram info].sel_images[0];
//            if (photo != nil && _selected_layer != nil) {
//				is_card_photo_done = YES;
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
			is_card_photo_done = YES;
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
    NSLog(@"selectPhotoCancel");
    if (is_singlemode) {
    }
    else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self clearSelectedInfo];
}

#pragma mark - GuideDelegate methods

- (void)popupGuidePage:(NSString *)guide_id {
    NSLog(@"popupGuidePage");
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
    NSLog(@"closeGuide");
    [_collection_view reloadData];
    [_nav_view reloadData];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    NSLog(@"hudWasHidden");
    // Remove HUD from screen when the HUD was hidded
    [_HUD removeFromSuperview];
    _HUD = nil;
}

- (void)viewDidUnload {
}

#pragma mark - PageEditViewControllerDelegate methods

- (IBAction)button_pageedit_click:(UIButton *)btn
{
    NSLog(@"button_pageedit_click");
    [self performSegueWithIdentifier:@"PageEditDesignPhotoSegue" sender:self];
}

- (void)changeLayout:(Layout *)layout {
    NSLog(@"changeLayout : %i", _selected_page);
    if (layout != nil && _selected_page >= 0) {

        
        NSInteger p = 0;
        if ([isFronts[_selected_page] boolValue]) {
            
            p = _selected_page * 2;
        }else{
            p = _selected_page * 2 + 1;
        }

        
        
        
        [[Common info].photobook changeLayout:p From:layout];

		[_collection_view reloadData];
        [_nav_view reloadData];

		[_nav_view selectItemAtIndexPath:[NSIndexPath indexPathForItem:_selected_page inSection:0]
						animated:YES
				  scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];   

		//UICollectionViewCell *cell = [_collection_view cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selected_page inSection:0]];
		[_collection_view reloadItemsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForItem:_selected_page inSection:0], nil]];
    }
    [self clearSelectedInfo];
}

#pragma mark - Local Function

-(Boolean)isCardMaxCheck{
    
    NSInteger total = 0;
    
    for (int i = 0; i < _nav_item_cnt.count; i = i + 2) {
        NSInteger c = [_nav_item_cnt[i] integerValue];
        total = total + c;
    }
    
    if (total >= 24) {
        
        [[Common info]alert:self Msg:@"더 이상 카드를 추가할 수 없습니다. (24장 1세트)"];
        return YES;
    }
    
    return NO;

}


@end
