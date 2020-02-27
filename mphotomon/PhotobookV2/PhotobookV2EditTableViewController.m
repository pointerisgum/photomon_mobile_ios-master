//
//  PhotobookV2EditTableViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 24..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "PhotobookV2EditTableViewController.h"
#import "PhotoCropViewController.h"
#import "PhotobookV2LayoutViewController.h"
#import "PhotobookV2BackgroundViewController.h"
#import "CardEditTextViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "Instagram.h"
#import "Utility.h"

@interface PhotobookV2EditTableViewController ()

@end

@implementation PhotobookV2EditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PhotobookEdit"];
    _thread = nil;
    _title_constraint.constant = 0;
    _is_warning = FALSE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    /*    // gesture
     UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCell:)];
     longPress.minimumPressDuration = 0.5f;
     [_table_view addGestureRecognizer:longPress];
     */
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
    tapGesture.numberOfTapsRequired = 1;
    [_table_view addGestureRecognizer:tapGesture];
    
    //
    _title_button.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    _title_button.layer.borderWidth = 1.0;
    
    _cancel_button.enabled = YES;
    _save_button.enabled = YES;
    
    [self clearSelectedInfo];
    
    _default_page = nil;
    //
    if (_is_new) {
        [Common info].photobook.delegate = self;
        /*if (![[Common info].photobook initPhotobookPages]) {
            [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }*/
        
        if (![[Common info].photobook initPhotobookV2CodyPages:0 paramDepth1Key:[Common info].photobook.depth1_key paramDepth2Key:[Common info].photobook.depth2_key paramProductOption1:[Common info].photobook.ProductOption1]) {
            [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
        //depth2key 예제로 강제 호출
        /*if (![[Common info].photobook initPhotobookV2CodyPages:0 paramDepth1Key:[Common info].photobook.depth1_key paramDepth2Key:@"BeginAgain" paramProductOption1:[Common info].photobook.ProductOption1]) {
            [self.view makeToast:@"페이지 정보를 받을 수 없습니다.\n잠시후 다시 시도해 보세요."];
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }*/
        // 포토북은 (cover+61p)*4장 -> 총 248장 max
        [[Common info] selectPhoto:self Singlemode:NO MinPictures:[Common info].photobook.minpictures Param:@"248"];
    }
    else {
        [Common info].photobook.delegate = self;
        [[Common info].photobook loadPhotobookPages];
        for (Page *pageItem in [Common info].photobook.pages){
            for (Layer *layerItem in pageItem.layers){
                if(layerItem.MaskX > (pageItem.PageLeftWidth + pageItem.PageMiddleWidth)){
                    layerItem.str_positionSide = @"R";
                }else if(layerItem.MaskX > pageItem.PageLeftWidth){
                    layerItem.str_positionSide = @"C";
                }else if(layerItem.MaskX < pageItem.PageLeftWidth){
                    layerItem.str_positionSide = @"L";
                }
                    
            }
        }
        
    }
    
    //[[Common info].layout_pool loadLayouts:[Common info].photobook.ProductSize Theme: [Common info].photobook.DefaultStyle ProductType:[Common info].photobook.product_type];
    //[[Common info].background_pool loadBackgrounds:[Common info].photobook.ProductSize Theme:[Common info].photobook.DefaultStyle ProductType:[Common info].photobook.product_type];
    
    //임시
    /*[[Common info].layout_pool loadPhotobookV2Layouts:[Common info].photobook.ProductSize Theme:[Common info].photobook.DefaultStyle ProductType:[Common info].photobook.product_type productOption1:[Common info].photobook.ProductOption1 layoutType:@"cover"];
    [[Common info].background_pool loadPhotobookV2Backgrounds:[Common info].photobook.ProductSize Theme:[Common info].photobook.DefaultStyle ProductType:[Common info].photobook.product_type productOption1:[Common info].photobook.ProductOption1 depth1_key:[Common info].photobook.depth1_key depth2_key:[Common info].photobook.depth2_key productType:@"designphotobook" backgroundType:@"cover"];*/
    
    // 2017.11.16 : SJYANG : 수정중 : 포토북에 에러가 없는지 확인하고 에러가 있으면 해당 사진 제거
    /*
     if (![[Common info].photobook isValid]) {
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"사진 앨범에 오류가 있습니다. 오류가 있는 사진은 앨범에서 삭제되었으니, 다른 사진으로 변경해 주세요." preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction *yes = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     [alert dismissViewControllerAnimated:YES completion:nil];
     }];
     [alert addAction:yes];
     [self presentViewController:alert animated:YES completion:nil];
     }
     */
    
    //[[Common info].layout_pool loginfo];
    //[[Common info].background_pool loginfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PhotobookEdit" ScreenClass:[self.classForCoder description]];
}

- (void)viewWillAppear:(BOOL)animated {
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

/*
 - (void)didMoveToParentViewController:(UIViewController *)parent {
 //[[Common info].photobook saveFile];
 if (![parent isEqual:self.parentViewController]) {
 if (_save_button.enabled == NO) {
 if (_thread) {
 [_thread cancel];
 _thread = nil;
 }
 }
 }
 }
 */

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

- (void)startFillPhotoThread {
    _progressView = [[ProgressView alloc]initWithTitle:@"포토북 구성 중"];
    
    //    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    //_HUD.mode = MBProgressHUDModeDeterminate;
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
    _cover_popup.hidden = YES;
    _cover_onlyLayout_popup.hidden = YES;
    _prolog_popup.hidden = YES;
    _page_popup.hidden = YES;
    _analogpage_popup.hidden = YES;
    _photo_popup.hidden = YES;
    _premiumpage_popup.hidden = YES;
    _fixed_page_popup.hidden = YES;
    _premiumfirstpage_popup.hidden = YES;
    
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
        /*UIImageView *testImageView =[[UIImageView alloc]init];
        [testImageView setImage:[UIImage imageNamed:@"ic_googlephoto.png"]];
        [testImageView setFrame:CGRectMake(point_page.x, point_page.y, 10, 10)];
        testImageView.layer.borderWidth = 1;
        [bkimageview addSubview: testImageView ];
        NSLog(@"tappiece:%d,%d", (int)location.x, (int)location.y);*/
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
                
                // 2017.11.16 : SJYANG
                NSString* filePath = [NSString stringWithFormat:@"%@/edit/%@", [Common info].photobook.base_folder, layer.ImageEditname];
                if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath] )
                    button_edit.enabled = NO;
                else
                    button_edit.enabled = YES;
            }
            else {
                button_ins.hidden = NO;
                button_del.hidden = YES;
                button_edit.enabled = NO;
            }
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
                vc.fontsize = _selected_layer.TextFontsize * [Common info].photobook.edit_scale;
                //vc.fontsize = 8;
                
                NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld", [Common info].photobook.base_folder, [Common info].photobook.ProductId, (long)_selected_page];
                vc.textcontents = [NSString stringWithContentsOfFile:tc_filepath encoding:NSUTF8StringEncoding error:nil];
                
                if ([_selected_layer.Halign isEqualToString:@"left"]) vc.alignment =  NSTextAlignmentLeft;
                else if ([_selected_layer.Halign isEqualToString:@"right"]) vc.alignment =  NSTextAlignmentRight;
                else vc.alignment =  NSTextAlignmentCenter;
                
                
                [self.navigationController presentViewController:vc animated:YES completion:nil ];
            }
            
        }
    }
}

- (void)longPressCell:(id)sender {
    [self.view endEditing:YES];
    [self clearSelectedInfo];
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView: _table_view];
    NSIndexPath *indexPath = [_table_view indexPathForRowAtPoint: location];
    if (indexPath.row == 0 || indexPath.row == 1) return;
    
    static UIView      *snapshot = nil;
    static NSIndexPath *sourceIndexPath = nil;
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [_table_view cellForRowAtIndexPath:indexPath];
                
                NSLog(@"이곳에서 시간이 오래...");
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                NSLog(@"결려..");
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [_table_view addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Fade out.
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    cell.hidden = YES;
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && sourceIndexPath && ![indexPath isEqual:sourceIndexPath]) {
                // ... update data source.
                [[Common info].photobook.pages exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [_table_view moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // Clean up.
            UITableViewCell *cell = [_table_view cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo fade out.
                cell.alpha = 1.0;
            } completion:^(BOOL finished) {
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            break;
        }
    }
}

// Add this at the end of your .m file. It returns a customized snapshot of a given view.
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

// SJYANG : 2016.06.07
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger last_section_index = [_table_view numberOfSections] - 1;
    NSInteger last_row_index = [_table_view numberOfRowsInSection:last_section_index] - 1;
    if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] && indexPath.row==last_row_index )
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Common info].photobook.pages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotobookEditCell" forIndexPath:indexPath];
    //cell.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5f].CGColor;
    //cell.layer.borderWidth = 1.0;
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    UIImageView *bkimageview = (UIImageView *)[cell viewWithTag:100];
    UIButton* addpage = (UIButton *)[cell viewWithTag:101]; // SJYANG
    UILabel *pageleft = (UILabel *)[cell viewWithTag:102];
    UILabel *pageright = (UILabel *)[cell viewWithTag:103];
    UIButton* addpageLeft = (UIButton *)[cell viewWithTag:104]; // SJYANG
    UIButton* addpageRight = (UIButton *)[cell viewWithTag:105]; // SJYANG
    
    // SJYANG
    // 프리미엄북 : 커버 페이지에서 페이지 버튼을 숨김
    if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] && indexPath.row==0 )
        addpage.hidden = YES;
    else
        addpage.hidden = NO;
    
    if (indexPath.row == 0) {
        pageleft.text = @"";
        pageright.text = @"";
        
        if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) { // SJYANG : 카달로그
            pageleft.text = @"1";
            pageright.text = @"2";
        }
    }
    else {
        if ([[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"]) { // analogue photobook
            pageleft.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row*2-1];
            pageright.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row*2];
        }
        else if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) { // SJYANG : 카달로그
            pageleft.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row*2+1];
            pageright.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row*2+2];
        }
        else {
            if (indexPath.row == 1) {
                addpageLeft.hidden = YES;
                pageleft.text = @"";
                pageright.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
            }
            else {
                addpageLeft.hidden = NO;
                pageleft.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row*2-2];
                pageright.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row*2-1];
            }
        }
    }
    
    // SJYANG
    NSInteger last_section_index = [_table_view numberOfSections] - 1;
    NSInteger last_row_index = [_table_view numberOfRowsInSection:last_section_index] - 1;
    if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] && indexPath.row==last_row_index )
        pageright.text = @"";
    
    if( ![[Common info].photobook composePage:indexPath.row ParentView:bkimageview IncludeBg:YES IsEdit:YES] )
        _is_warning = TRUE;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect page_rect = [Common info].photobook.page_rect;
    CGFloat cell_w = tableView.bounds.size.width - 15*2;
    CGFloat cell_h;
    if(_is_new){
        cell_h = ((cell_w * page_rect.size.height) / (page_rect.size.width*2)) + 15*2;
    }
    else{
        cell_h = ((cell_w * page_rect.size.height) / (page_rect.size.width)) + 15*2;
    }
    return cell_h;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 양성진 수정/추가
        // 하자보수 이슈 : 카탈로그 오류에 대해서 : 카탈로그는 8, 12, 16, 20, 24 페이지 단위로 페이지 추가, 삭제가 됩니다. 아마도 오류는 초기 사진선택 후 카탈로그 편집화면으로 이동시 페이지 수 처리가 잘못되는듯 합니다.
        if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) {
            [self.view makeToast:@"카달로그는 메뉴의 페이지 삭제를 사용해 주세요."];
            return;
        }
        
        NSUInteger page_count = [Common info].photobook.pages.count*2 - 3;
        
        if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] )
            page_count--;
        
        //if (page_count > 21) {
        if (page_count > [Common info].photobook.MinPage) {
            [[Common info].photobook deletePage:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [self.view makeToast:@"페이지를 더이상 삭제할 수 없습니다."];
        }
        [self clearSelectedInfo];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 1) {
        return NO;
    }
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == 1) {
        return NO;
    }
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
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
    /*else if ([segue.identifier isEqualToString:@"PageEditSegue"]) {
        PageEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
            
            // SJYANG : 2016.06.03
            NSInteger last_section_index = [_table_view numberOfSections] - 1;
            NSInteger last_row_index = [_table_view numberOfRowsInSection:last_section_index] - 1;
            
            vc.filter = 1;
            if (_selected_page == 0) {
                vc.layouttype = @"cover";
            }
            else if (_selected_page == 1) {
                vc.layouttype = @"prolog";
                if ([[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"]) { // analogue photobook
                    vc.layouttype = @"page";
                }
            }
            // SJYANG : 2016.06.03
            else if (_selected_page == last_row_index) {
                vc.layouttype = @"page";
                if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] ) {
                    vc.layouttype = @"epilogue";
                }
            }
            else {
                vc.layouttype = @"page";
            }
            
            if ([vc.layouttype isEqualToString:@"page"]) {
                if (_selected_page >= 0) {
                    // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
                    if( [[Common info].photobook.ProductCode isEqualToString:@"300267"] || [[Common info].photobook.ProductCode isEqualToString:@"300268"] || [[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"] ) {
                        // 이미지 레이어 수만 계산
                        int nImageLayers = 0;
                        Page *page = [Common info].photobook.pages[_selected_page];
                        for (Layer *layer in page.layers) {
                            if (layer.AreaType == 0) { // 0: image
                                nImageLayers++;
                            }
                        }
                        
                        if (nImageLayers <= 2) {
                            vc.filter = 1;
                        }
                        else if (nImageLayers <= 4) {
                            vc.filter = 2;
                        }
                        else {
                            vc.filter = 3;
                        }
                    }
                    else
                    {
                        // 기존 레이어 수 계산하는 소스
                        Page *page = [Common info].photobook.pages[_selected_page];
                        if (page.layers.count <= 2) {
                            vc.filter = 1;
                        }
                        else if (page.layers.count <= 4) {
                            vc.filter = 2;
                        }
                        else {
                            vc.filter = 3;
                        }
                    }
                }
            }
            //[vc updateLayouts];
        }
    }
    else if ([segue.identifier isEqualToString:@"PageBackgroundSegue"]) {
        PageBackgroundViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delegate = self;
            if (_selected_page == 0) {
                vc.sel_pagetype = @"cover";
            }
            else if (_selected_page == 1) {
                vc.sel_pagetype = @"prolog";
            }
            else {
                vc.sel_pagetype = @"page";
            }
            //[vc updateBackgrounds];
        }
    }*/
    
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


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _cover_popup.hidden = YES;
    _cover_onlyLayout_popup.hidden = YES;
    _prolog_popup.hidden = YES;
    _page_popup.hidden = YES;
    _analogpage_popup.hidden = YES;
    _photo_popup.hidden = YES;
    // SJYANG
    _premiumpage_popup.hidden = YES;
    _fixed_page_popup.hidden = YES;
    _premiumfirstpage_popup.hidden = YES;
}
/*
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
 [_table_view reloadData];
 }
 */
- (IBAction)setBookTitle:(id)sender {
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
    [[Common info].photobook setBookTitle:_title_text.text];
    _title_constraint.constant = 0;
    [_table_view reloadData];
}

- (IBAction)clickMessage:(id)sender {
    UIView *message_view = (UIView *)[self.view viewWithTag:200];
    message_view.hidden = TRUE;
    _message_constraint.constant = 0;
}

- (IBAction)clickPageButton:(id)sender {
    [self clearSelectedInfo];
    
    if ([sender superview] != nil) {
        // iOS 7 이상은 super's super. 이전에는 그냥 super.
        if ([[sender superview] superview] != nil) {
            UITableViewCell *cell = (UITableViewCell*)[[sender superview] superview];
            if (cell != nil) {
                NSIndexPath *indexPath = [_table_view indexPathForCell:cell];
                if (indexPath) {
                    _selected_page = indexPath.row;
                    
                    // SJYANG
                    NSInteger last_section_index = [_table_view numberOfSections] - 1;
                    NSInteger last_row_index = [_table_view numberOfRowsInSection:last_section_index] - 1;
                    
                    UIButton *button = (UIButton *)sender;
                    CGRect button_rect = [cell convertRect:button.frame toView:self.view];
                    _select_popupBtnTitle = button.currentTitle;
                    UIView *popup = nil;
                    //NSLog(@"_selected_page : %ld", (long)_selected_page);
                    
                    NSLog(@"[Common info].photobook.ProductCode : %@", [Common info].photobook.ProductCode);
                    
                    if (_selected_page == 0) {
                        //cmh 구닥북일 경우에는 레이아웃 변경만 나오게 처리
                        if ([[Common info] isGudakBook:[Common info].photobook.ProductCode]) {
                            popup = _cover_onlyLayout_popup;
                        }else{
                            popup = _cover_popup;
                        }
                        popup.hidden = NO;
                    }
                    else if (_selected_page == 1) {
                        // SJYANG
                        if( [[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"] ) {
                            popup = _analogpage_popup;
                        } else {
                            // 프리미엄북 : 1 페이지의 PAGE 버튼 ~~~> 프리미엄북 1 페이지 팝업
                            if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] ) {
                                popup = _premiumfirstpage_popup;
                            } else {
                                // hsj 구닥북일 경우에는 레이아웃 변경만 나오게 처리
                                if ([[Common info] isGudakBook:[Common info].photobook.ProductCode]) {
                                    popup = _cover_onlyLayout_popup;
                                } else {
                                    popup = _prolog_popup;
                                    //popup = _page_popup;
                                }
                            }
                        }
                        
                        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
                        if( [[Common info].photobook.ProductCode isEqualToString:@"300267"] || [[Common info].photobook.ProductCode isEqualToString:@"300268"] ) {
                            popup = _premiumfirstpage_popup;
                        }
                        // SJYANG : 스키니북
                        else if( [[Common info].photobook.ProductCode isEqualToString:@"300180"] ) {
                            popup = _analogpage_popup;
                            
                            UIColor* disable_color = [UIColor colorWithWhite: 0.70 alpha:1];
                            UIButton *btn2 = (UIButton *)[popup viewWithTag:501];
                            UIButton *btn3 = (UIButton *)[popup viewWithTag:502];
                            btn2.enabled = btn3.enabled = NO;
                            [btn2 setTitleColor:disable_color forState:UIControlStateNormal];
                            [btn3 setTitleColor:disable_color forState:UIControlStateNormal];
                        }
                        // SJYANG : 카달로그
                        else if( [[Common info].photobook.ProductCode isEqualToString:@"120069"] ) {
                            popup = _page_popup;
                        }
                        
                        popup.hidden = NO;
                    }
                    else {
                        // SJYANG : 2016.05.31
                        if( [[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"] ) {
                            popup = _analogpage_popup;
                        }
                        // SJYANG : 스키니북
                        else if( [[Common info].photobook.ProductCode isEqualToString:@"300180"] ) {
                            popup = _analogpage_popup;
                            
                            UIColor* enable_color = [UIColor darkGrayColor];
                            UIButton *btn2 = (UIButton *)[popup viewWithTag:501];
                            UIButton *btn3 = (UIButton *)[popup viewWithTag:502];
                            btn2.enabled = btn3.enabled = YES;
                            [btn2 setTitleColor:enable_color forState:UIControlStateNormal];
                            [btn3 setTitleColor:enable_color forState:UIControlStateNormal];
                        }
                        // SJYANG : 카달로그
                        else if( [[Common info].photobook.ProductCode isEqualToString:@"120069"] ) {
                            popup = _page_popup;
                        }
                        else {
                            if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] ) {
                                // 프리미엄북 : 2+ 페이지의 PAGE 버튼 ~~~> 프리미엄북 공통 페이지 팝업
                                UIColor* disable_color = [UIColor colorWithWhite: 0.70 alpha:1];
                                UIColor* enable_color = [UIColor darkGrayColor];
                                
                                if( _selected_page == last_row_index ) {
                                    popup = _premiumfirstpage_popup;
                                }
                                else if( _selected_page == last_row_index - 1 ) {
                                    popup = _premiumpage_popup;
                                    
                                    UIButton *btn1 = (UIButton *)[popup viewWithTag:1001];
                                    UIButton *btn2 = (UIButton *)[popup viewWithTag:1002];
                                    UIButton *btn3 = (UIButton *)[popup viewWithTag:1003];
                                    UIButton *btn4 = (UIButton *)[popup viewWithTag:1004];
                                    UIButton *btn5 = (UIButton *)[popup viewWithTag:1005];
                                    
                                    btn1.enabled = btn2.enabled = btn3.enabled = btn4.enabled = YES;
                                    btn5.enabled = NO;
                                    [btn1 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn2 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn3 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn4 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn5 setTitleColor:disable_color forState:UIControlStateNormal];
                                }
                                else {
                                    popup = _premiumpage_popup;
                                    
                                    UIButton *btn1 = (UIButton *)[popup viewWithTag:1001];
                                    UIButton *btn2 = (UIButton *)[popup viewWithTag:1002];
                                    UIButton *btn3 = (UIButton *)[popup viewWithTag:1003];
                                    UIButton *btn4 = (UIButton *)[popup viewWithTag:1004];
                                    UIButton *btn5 = (UIButton *)[popup viewWithTag:1005];
                                    
                                    btn1.enabled = btn2.enabled = btn3.enabled = btn4.enabled = btn5.enabled = YES;
                                    [btn1 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn2 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn3 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn4 setTitleColor:enable_color forState:UIControlStateNormal];
                                    [btn5 setTitleColor:enable_color forState:UIControlStateNormal];
                                }
                            } else {
                                popup = _page_popup;
                            }
                        }
                        
                        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
                        if( [[Common info].photobook.ProductCode isEqualToString:@"300267"] || [[Common info].photobook.ProductCode isEqualToString:@"300268"] ) {
                            if( [[Common info].photobook.ProductCode isEqualToString:@"300267"] )
                                popup = _analogpage_popup;
                            else
                                popup = _premiumpage_popup;
                        }
                        if( [[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"] ||
                           [[Common info] isGudakBook:[Common info].photobook.ProductCode]) {
                            popup = _analogpage_popup;
                        }
                        
                        popup.hidden = NO;
                    }
                    
                    CGRect popup_rect = popup.frame;
                    /*popup_rect.origin.x = _table_view.frame.size.width/2 - popup.frame.size.width/2;
                    popup_rect.origin.y = button_rect.origin.y + button_rect.size.height;
                    if (popup_rect.origin.y + popup_rect.size.height > self.view.frame.size.height) {
                        popup_rect.origin.y -= (button_rect.size.height + popup_rect.size.height);
                    }*/
                    if([_select_popupBtnTitle isEqualToString:@"L"]){
                        popup_rect.origin.x = button_rect.origin.x + button_rect.size.width + 10;
                        popup_rect.origin.y = button_rect.origin.y + button_rect.size.height + 10;
                    }
                    else{
                        popup_rect.origin.x = button_rect.origin.x - popup_rect.size.width - 10;
                        popup_rect.origin.y = button_rect.origin.y + button_rect.size.height + 10;
                    }
                    
                    [popup setFrame:popup_rect];
                }
            }
        }
    }
}

- (IBAction)addPage:(id)sender {
    if (_selected_page < 1) {
        [self clearSelectedInfo];
        [self.view makeToast:@"커버와 내지 1p 위치로는\n페이지를 생성할 수 없습니다."];
    }
    else {
        // SJYANG 2016.05.31
        // 마지막 페이지에서는 위로 페이지가 추가되도록 수정
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        NSInteger last_section_index = [_table_view numberOfSections] - 1;
        NSInteger last_row_index = [_table_view numberOfRowsInSection:last_section_index] - 1;
        
        NSInteger selected_page = _selected_page;
        if (![[Common info].photobook.ProductCode isEqualToString:@"120069"]) { // SJYANG : 카달로그
            if ( selected_page==last_row_index )
                selected_page = last_row_index - 1;
        }
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        // 2018.12.20 : 인스타북 61p 제한 해제 => 굳이 이 코드가 필요없으므로, 주석 처리함
        //if ([[Common info].photobook canPageAdd] || [[Common info].photobook.ProductCode isEqualToString:@"300268"]) {
        if ([[Common info].photobook canPageAdd]) {
            int nloop = 1;
            if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) nloop++; // SJYANG : 카달로그
            
            for(int idx = 0; idx < nloop; idx++) {
                if (_default_page == nil) {
                    _default_page = [[Common info].photobook.pages[2] copy]; // 내지 첫번째 페이지 복사
                    
                    Layout *layout = [[Common info].layout_pool getDefaultLayout];
                    if (layout != nil) {
                        _default_page.layers = layout.layers;
                    }
                }
                
                if ([[Common info].photobook insertPage:selected_page FromDefaultPage:_default_page]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selected_page+1 inSection:0];
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    [indexPaths addObject:indexPath];
                    
                    [_table_view beginUpdates];
                    [_table_view insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
                    [_table_view endUpdates];
                    [_table_view scrollToRowAtIndexPath:[indexPaths objectAtIndex:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    [_table_view reloadData];
                }
            }
        }
        else {
            [self.view makeToast:@"페이지를 더이상 추가할 수 없습니다."];
        }
        [self clearSelectedInfo];
    }
    [_table_view reloadData];
}

- (IBAction)deletePage:(id)sender {
    int selected_page = (int)_selected_page;
    int check_page = selected_page;
    if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) // SJYANG : 카달로그
        check_page = check_page + 1;
    
    if (check_page < 2) {
        [self clearSelectedInfo];
        [self.view makeToast:@"커버와 내지 1p는 삭제할 수 없습니다."];
    }
    else {
        int nloop = 1;
        if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) nloop++; // SJYANG : 카달로그
        
        for(int idx = 0; idx < nloop; idx++) {
            if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) { // SJYANG : 카달로그
                if(selected_page!=1 && selected_page % 2 == 1 && idx == 1) selected_page--;
            }
            
            NSUInteger page_count = [Common info].photobook.pages.count*2 - 3;
            if ([[Common info].photobook.ProductCode isEqualToString:@"120069"]) page_count = [Common info].photobook.pages.count * 2; // SJYANG : 카달로그
            
            if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] )
                page_count--;
            
            //if (page_count > 21) {
            if (page_count > [Common info].photobook.MinPage) {
                if ([[Common info].photobook deletePage:selected_page]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selected_page inSection:0];
                    [_table_view deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    //[_table_view reloadData];
                }
                [self clearSelectedInfo];
            }
            else {
                [self.view makeToast:@"페이지를 더이상 삭제할 수 없습니다."];
                [self clearSelectedInfo];
                break;
            }
        }
    }
    [_table_view reloadData];
}

- (IBAction)moveupPage:(id)sender {
    int movable_pagenum = 3;
    NSString *comment = @"커버와 내지 1p 위치로는\n순서를 변경할 수 없습니다.";
    if ([[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"]) {
        movable_pagenum = 2;
        comment = @"커버 위치로는\n순서를 변경할 수 없습니다.";
    }
    
    if (_selected_page < movable_pagenum) {
        [self.view makeToast:comment];
    }
    else {
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:_selected_page inSection:0];
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:_selected_page-1 inSection:0];
        if (indexPath1 && indexPath2) {
            [[Common info].photobook.pages exchangeObjectAtIndex:indexPath1.row withObjectAtIndex:indexPath2.row];
            [_table_view moveRowAtIndexPath:indexPath1 toIndexPath:indexPath2];
        }
    }
    [self clearSelectedInfo];
    [_table_view reloadData];
}

- (IBAction)movedownPage:(id)sender {
    int nomove_pagenum = 2;
    NSString *comment = @"커버와 내지 1p 위치에서는\n순서를 변경할 수 없습니다.";
    if ([[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"]) {
        nomove_pagenum = 1;
        comment = @"커버 위치에서는\n순서를 변경할 수 없습니다.";
    }
    
    if (_selected_page < nomove_pagenum) {
        [self.view makeToast:comment];
    }
    else if (_selected_page >= [Common info].photobook.pages.count-1) {
        [self.view makeToast:@"마지막 페이지입니다."];
    }
    else {
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:_selected_page inSection:0];
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:_selected_page+1 inSection:0];
        if (indexPath1 && indexPath2) {
            [[Common info].photobook.pages exchangeObjectAtIndex:indexPath1.row withObjectAtIndex:indexPath2.row];
            [_table_view moveRowAtIndexPath:indexPath1 toIndexPath:indexPath2];
        }
    }
    [self clearSelectedInfo];
    [_table_view reloadData];
}

- (IBAction)changePageLayout:(id)sender {
    //[self performSegueWithIdentifier:@"PageEditSegue" sender:self];
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotobookV2LayoutViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LayoutViewController"];
    if (vc) {
        vc.delegate = self;
        
        // SJYANG : 2016.06.03
        NSInteger last_section_index = [_table_view numberOfSections] - 1;
        NSInteger last_row_index = [_table_view numberOfRowsInSection:last_section_index] - 1;
        
        vc.filter = 1;
        if (_selected_page == 0) {
            vc.layouttype = @"cover";
        }
        else if (_selected_page == 1) {
            /*vc.layouttype = @"prolog";
            if ([[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"]) { // analogue photobook
                vc.layouttype = @"page";
             
            }*/
            vc.layouttype = @"page";
        }
        // SJYANG : 2016.06.03
        else if (_selected_page == last_row_index) {
            vc.layouttype = @"page";
            if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] ) {
                vc.layouttype = @"epilogue";
            }
        }
        else {
            vc.layouttype = @"page";
        }
        [[Common info].layout_pool loadPhotobookV2Layouts:[Common info].photobook.ProductSize Theme:[Common info].photobook.DefaultStyle ProductType:[Common info].photobook.product_type productOption1:[Common info].photobook.ProductOption1 layoutType:vc.layouttype];
        if ([vc.layouttype isEqualToString:@"page"]) {
            if (_selected_page >= 0) {
                // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
                if( [[Common info].photobook.ProductCode isEqualToString:@"300267"] || [[Common info].photobook.ProductCode isEqualToString:@"300268"] || [[Common info].photobook.ProductCode isEqualToString:@"300269"] || [[Common info].photobook.ProductCode isEqualToString:@"300270"] ) {
                    // 이미지 레이어 수만 계산
                    int nImageLayers = 0;
                    Page *page = [Common info].photobook.pages[_selected_page];
                    for (Layer *layer in page.layers) {
                        if (layer.AreaType == 0) { // 0: image
                            nImageLayers++;
                        }
                    }
                    
                    if (nImageLayers <= 2) {
                        vc.filter = 1;
                    }
                    else if (nImageLayers <= 4) {
                        vc.filter = 2;
                    }
                    else {
                        vc.filter = 3;
                    }
                }
                else
                {
                    // 기존 레이어 수 계산하는 소스
                    Page *page = [Common info].photobook.pages[_selected_page];
                    if (page.layers.count <= 2) {
                        vc.filter = 1;
                    }
                    else if (page.layers.count <= 4) {
                        vc.filter = 2;
                    }
                    else {
                        vc.filter = 3;
                    }
                }
            }
        }
        //[vc updateLayouts];
    
        [self.navigationController presentViewController:vc animated:YES completion:nil ];
    }
}

- (IBAction)changePageBackground:(id)sender {
    //[self performSegueWithIdentifier:@"PageBackgroundSegue" sender:self];
    //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PhotobookV2BackgroundViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BackgroundViewController"];
    
        if (vc) {
            vc.delegate = self;
            if (_selected_page == 0) {
                vc.sel_pagetype = @"cover";
            }
            else if (_selected_page == 1) {
                //vc.sel_pagetype = @"prolog";
                vc.sel_pagetype = @"page";
            }
            else {
                vc.sel_pagetype = @"page";
            }
            [[Common info].background_pool loadPhotobookV2Backgrounds:[Common info].photobook.ProductSize Theme:[Common info].photobook.DefaultStyle ProductType:[Common info].photobook.product_type productOption1:[Common info].photobook.ProductOption1 depth1_key:[Common info].photobook.depth1_key depth2_key:[Common info].photobook.depth2_key productType:@"designphotobook" backgroundType:vc.sel_pagetype];
            
            //[vc updateBackgrounds];
        }
        [self.navigationController presentViewController:vc animated:YES completion:nil ];
    
}

- (IBAction)resetTitle:(id)sender {
    [self clearSelectedInfo];
    _title_constraint.constant = 50;
    [_table_view reloadData];
}


- (IBAction)addPhoto:(id)sender {
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)deletePhoto:(id)sender {
    [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

- (IBAction)save:(id)sender {
    // 2017.11.16 : SJYANG
    /*
     if (_is_warning) {
     //UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"사진 앨범에 오류가 있는 사진이나 인쇄 해상도가 낮은 사진이 있습니다.\n문제가 있는 사진은 빨간색 느낌표로 표시되니, 확인하셔서 다른 사진으로 변경해 주세요." preferredStyle:UIAlertControllerStyleAlert];
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"사진 앨범에 오류가 있는 사진이 있습니다.\n문제가 있는 사진은 빨간색 느낌표로 표시되니, 확인하셔서 다른 사진으로 변경해 주세요." preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction *yes = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     [alert dismissViewControllerAnimated:YES completion:nil];
     }];
     [alert addAction:yes];
     [self presentViewController:alert animated:YES completion:nil];
     return;
     }
     */
    
    
    [[Common info].photobook saveFile];
    // SJYANG : 2016.06.02
    // 포토북은 제품선택이 추가되어서, navigationController.viewControllers firstObject 가 photobook_root_controller 가 아닌 경우가 생김
    // 현재 편집 프로세스의 상태는 포토북 프로세스이므로 바로 photobook_root_controller 의 goStorage 를 호출하도록 처리
    /*
     UIViewController *root_vc = [self.navigationController.viewControllers firstObject];
     if (root_vc == [Common info].photobook_root_controller) {
     [[Common info].photobook_root_controller goStorage];
     }
     else {
     [[Common info].gift_root_controller goStorage];
     }
     */
    if ([[Common info].photobook.ProductCode isEqualToString:@"300480"] ||
        [[Common info].photobook.ProductCode isEqualToString:@"300481"] ||
        [[Common info].photobook.ProductCode isEqualToString:@"300482"] ||
        [[Common info].photobook.ProductCode isEqualToString:@"300483"] ||
        [[Common info].photobook.ProductCode isEqualToString:@"300500"] ||
        [[Common info].photobook.ProductCode isEqualToString:@"300501"] ||
        [[Common info].photobook.ProductCode isEqualToString:@"300502"] ||
        [[Common info].photobook.ProductCode isEqualToString:@"300503"]) {
        [Utility goStorageViaViewController:[self.navigationController.viewControllers firstObject]];
    } else if( [Common info].photobook_root_controller!=nil ) {
        [[Common info].photobook_root_controller goStorage];
    } else {
        [[Common info].photobook_product_root_controller goStorage];;
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


#pragma mark - PageEditViewControllerDelegate methods

- (void)changeLayout:(Layout *)layout {
    if (layout != nil && _selected_page >= 0) {
        [[Common info].photobook changeLayout:_selected_page From:layout SelectLR:_select_popupBtnTitle];
        [_table_view reloadData];
    }
    [self clearSelectedInfo];
}

- (void)changeBackground:(Background *)background {
    if (background != nil && _selected_page >= 0) {
        [[Common info].photobook changeBackground:_selected_page From:background SelectLR:_select_popupBtnTitle];
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
    NSString *progress_str = [NSString stringWithFormat:@"포토북 구성 중 (%d/%d)", count, total_count];
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
        //                [[Common info].photobook addPhotoFromInstagram:photo Layer:_selected_layer PickIndex:0];
        //                [_table_view reloadData];
        //            }
        //        }
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
        [self popupGuidePage:GUIDE_PHOTOBOOK_EDIT];
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
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GuideViewController *vc = [sb instantiateViewControllerWithIdentifier:@"GuidePage"];
       
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
    
    
    [_table_view reloadData];
    //[_nav_view reloadData];
}

@end
