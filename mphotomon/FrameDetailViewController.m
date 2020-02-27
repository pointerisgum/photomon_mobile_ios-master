//
//  FrameDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 25..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "FrameDetailViewController.h"
#import "WebpageViewController.h"
#import "CollageEditViewController.h"
#import "ZoomViewController.h"

@interface FrameDetailViewController ()

@end

@implementation FrameDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [Analysis log:@"FrameDetail"];

    _option_str = @"";
    _book_info = nil;
    
    if (_selected_theme != nil )
    {
        if (_selected_theme.sel_options2.count > 0)
        {
            SelectOption *opt = [_selected_theme.sel_options2 objectAtIndex:0];
            _surface_str = opt.comment;
            _option_idx = 0;
            _frame_idx = 0;
            _surface.hidden = NO;
            _surface_button.hidden = NO;
            _surface_arrowButton.hidden = NO;
            _material.hidden = YES;
            _materialLabel.hidden = YES;
        }
        else {
            _surface_str = @"";
            _option_idx = 0;
            _frame_idx = -1;
            _surface.hidden = YES;
            _surface_button.hidden = YES;
            _surface_arrowButton.hidden = YES;
            _material.hidden = NO;
            _materialLabel.hidden = NO;
        }
        
        if ([[Common info].deeplink_url containsString:@"mobile_metalframe"]) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
            
            [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification"
                object:nil
                queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *note) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }];
        }
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"FrameDetail" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];
    [self updateTheme];
}

- (NSString *)getProductSizeString:(NSString *)full_str {
    NSArray *tempArray = [full_str componentsSeparatedByString:@"("];
    NSString *tempKey = tempArray[0];
    return tempKey;
}

- (void)updateTheme {
    if (_selected_theme != nil) {
        NSAssert(_selected_theme.book_infos.count > 0, @"frame's book_info is not founded");

        if (_option_str.length <= 0) {
            BookInfo *info = _selected_theme.book_infos[0];
            NSString *temp_str = [self getProductSizeString:info.cm];
            if (temp_str.length >= 3) {
                _option_str = temp_str;
            }
        }
        
        for (BookInfo *info in _selected_theme.book_infos) {
            NSRange range = [info.cm rangeOfString:_option_str];
            if (range.location != NSNotFound) {
                _book_info = info;
                _useLabel.text = info.use;
                _materialLabel.text = info.material;
                break;
            }
        }
        
        for (SelectOption *opt in _selected_theme.sel_options) {
            NSRange range = [opt.comment rangeOfString:_option_str];
            if (range.location != NSNotFound) {

                NSString *price = [[Common info] toCurrencyString:[_book_info.price intValue]];
                _price.text = [NSString stringWithFormat:@"%@원", price];
                
                _discount.text = [NSString stringWithFormat:@"%@원", opt.price];
                [_product_size setTitle:opt.comment forState:UIControlStateNormal];
                break;
            }
        }
        
        [_surface_button setTitle:_surface_str forState:UIControlStateNormal];
        
        // 액자도 기존 포토북의 업로드 및 장바구니 정보 전달 모듈을 그대로 사용하기 위해 기본 정보값을 세팅한다.
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
        Photobook *photobook = [Common info].photobook;
        photobook.ProductOption1 = @"";
        photobook.ProductOption2 = @"";
        photobook.ProductSize = _option_str;

        
        if ([photobook.ProductCode isEqualToString:@"436001"]) {
            if (_frame_idx == 0) {
                photobook.AddParams = [NSString stringWithFormat:@"%@_white", _option_str];
            }
            else {
                photobook.AddParams = [NSString stringWithFormat:@"%@_silver", _option_str];
            }
        }else {
            photobook.AddParams = _option_str;
        }
        photobook.TotalPageCount = 1;

        [_collection_view reloadData];
    }
}

- (IBAction)selectSize:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options.count; i++) {
        SelectOption *item = _selected_theme.sel_options[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            NSString *temp_str = [self getProductSizeString:item.comment];
            if (temp_str.length >= 3 && ![temp_str isEqualToString:_option_str]) {
                _option_idx = i;
                _option_str = temp_str;
                [self updateTheme];
            }

            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)selectSurface:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options2.count; i++) {
        SelectOption *item = _selected_theme.sel_options2[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _frame_idx = i;
            _surface_str = item.comment;
            
            [self updateTheme];
            
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selected_theme) {
        _page_control.numberOfPages = _selected_theme.preview_thumbs.count;
        return _selected_theme.preview_thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FrameDetailCell" forIndexPath:indexPath];
    
    if (_selected_theme != nil) {
        Photobook *photobook = [Common info].photobook;
        NSString *host = [Common info].photobook_theme.thumb_url;
        if ([photobook.ProductCode isEqualToString:@"436001"]) {
            host = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
        }
        
        if (indexPath.row == 0) {
            NSString *thumbname = [NSString stringWithFormat:@"preview_%@_%@_full_%02d.jpg", _selected_theme.theme2_id, _option_str, (int)indexPath.row+1];
            NSString *url = [Common makeURLString:thumbname host:host];
            NSString *orithumbname = _selected_theme.preview_thumbs[indexPath.row];
            if ([orithumbname hasPrefix:@"http://"] || [orithumbname hasPrefix:@"https://"]) {
                url = orithumbname;
            }
//            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
//            //NSLog(@"thumb0:%@", fullpath);
//
//            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *imageData = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url]];
            if (imageData != nil) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"theme-detail's thumbnail_image is not downloaded.");
            }
        }
        else {
            NSString *thumbname = _selected_theme.preview_thumbs[indexPath.row];
            
//            NSString *fullpath = [NSString stringWithFormat:@"%@%@", URL_SINGLESTORE_SKIN_PATH, thumbname];
            //NSLog(@"thumb~:%@", fullpath);
            
//            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *url = [Common makeURLString:thumbname host:host];
            [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                if (succeeded) {
                    UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                    imageview.image = [UIImage imageWithData:imageData];
                }
                else {
                    NSLog(@"theme-detail's thumbnail_image is not downloaded.");
                }
            }];
        }
        
        // 페이지라벨
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        page_label.text = @"";
        
        // 배송 메시지
        NSString *productmsg = @"";
        if ([_book_info.productcode hasPrefix:@"351"]) { // 캔버스아트
            productmsg = [[Common info].connection productMsg:4];
        }
        else { // 350(인피니에코), 356(크리스탈마블)
            productmsg = [[Common info].connection productMsg:5];
        }

        if (productmsg.length > 0) {
            NSString *temp_msg = [NSString stringWithFormat:@"D+3(토,일 제외)(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
            productmsg = [productmsg stringByReplacingOccurrencesOfString:@"입니다." withString:@"."];
            productmsg = [NSString stringWithFormat:@"%@%@", productmsg, temp_msg];
            _deliverymsg.text = productmsg;
            _deliverymsg.numberOfLines = 0;
            [_deliverymsg sizeToFit];
            
            UILabel *deliverytitle = (UILabel *)[cell viewWithTag:222];
            deliverytitle.numberOfLines = 0;
            [deliverytitle sizeToFit];
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 0.0f;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 2.0f + 16;
    
    return CGSizeMake(width, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _collection_view.frame.size.width;
    int page = floor((_collection_view.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    
    _page_control.currentPage = page;
}


- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = _option_str;
    vc.product_type = PRODUCT_FRAME;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupMore:(id)sender {
    NSString *intnum = @"";
    NSString *seqnum = @"";
    NSString *product_code = [Common info].photobook.ProductCode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }
    
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupFullFrame:(id)sender {
    CollageEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CollagePage"];
    vc.is_collage = NO;
    vc.book_info = _book_info;
    vc.delegate = self;
    NSString *product_code = [Common info].photobook.ProductCode;
    NSString *host = [Common info].photobook_theme.thumb_url;
    if ([product_code isEqualToString:@"436001"]) {
        host = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
    
        SelectOption *item = _selected_theme.sel_options[_option_idx];
        if (_frame_idx == 1) {
            vc.guideImage = [Common makeURLString:item.guideinfo_silver host:host];
        }
    }
    else {
        vc.guideImage = @"";
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupCollageFrame:(id)sender {
    CollageEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CollagePage"];
    vc.is_collage = YES;
    vc.book_info = _book_info;
    vc.delegate = self;
    
    NSString *product_code = [Common info].photobook.ProductCode;
    NSString *host = [Common info].photobook_theme.thumb_url;
    if ([product_code isEqualToString:@"436001"]) {
        host = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
        
        SelectOption *item = _selected_theme.sel_options[_option_idx];
        if (_frame_idx == 1) {
            vc.guideImage = [Common makeURLString:item.guideinfo_silver host:host];
        }
    }
    else {
        vc.guideImage = @"";
    }
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - CollageEditDelegate methods

- (void)completeEdit {
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        [[Common info].main_controller onCartviaExternalController];
    }];
}

@end
