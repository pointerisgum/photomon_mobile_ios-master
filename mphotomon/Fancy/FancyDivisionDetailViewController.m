//
//  FancyDivisionStickerDetailViewController.m
//  PHOTOMON
//
//  Created by kim kihwan on 2019. 7. 11..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "FancyDivisionDetailViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "PhotomonInfo.h"
#import "DesignPhotoEditViewController.h"


@interface FancyDivisionDetailViewController ()

@end

@implementation FancyDivisionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"_mobile_designphoto"].location != NSNotFound || [[Common info].deeplink_url rangeOfString:@"mobile_designphoto"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
        }
    }
    
    [Analysis log:@"DesignPhotoDetail"];
    _thumbs = nil;
    
    _option_idx = 0;
    
    // option ui line hidden miniwallet or division
    if([_selected_theme.theme1_id isEqualToString:@"divisionsticker"]){
        _option_label.hidden = true;
        _option_button.hidden = true;
        _option_button_opt.hidden = true;
        _design_label.hidden = true;
        _design_button.hidden = true;
        _design_button_opt.hidden = true;
        
        /*_option_label.frame = CGRectMake(_option_label.frame.origin.x,_option_label.frame.origin.y,_option_label.frame.size.width,0);
         _option_button.frame = CGRectMake(_option_button.frame.origin.x,_option_button.frame.origin.y,_option_button.frame.size.width,0);*/
        _constraints_delivery_optionlabel_top.active = false;
        _constraints_delivery_nonoptionlabel_top.active = true;
        _constraints_delivery_optionbuton_top.active = false;
        _constraints_delivery_nonoptionbutton_top.active = true;
        
    }else{
        _constraints_delivery_nonoptionlabel_top.active = false;
        _constraints_delivery_nonoptionbutton_top.active = false;
    }
    
    _design_idx = 0;
    //    _sel_option = [[SelectOption alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[Analysis firAnalyticsWithScreenName:@"DesignPhotoDetail" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];
    [self updateTheme];
}

- (void)updateTheme {
    if (_selected_theme != nil && _booksizes.currentTitle.length <= 0) {
        NSAssert(_selected_theme.book_infos.count > 0, @"designphoto's book_info is not founded");
        _book_info = _selected_theme.book_infos[0];
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
        
        if (_selected_theme.sel_options.count <= 0) {
            SelectOption *sel_item = [[SelectOption alloc] init];
            [_selected_theme.sel_options addObject:sel_item];
            sel_item.comment = @"선택없음";
            sel_item.price = @"0";
        }
    }
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DesignPhotoEditViewController *vc = [segue destinationViewController];
    if (vc) {
        // SJYANG.2018.04 : 이동헌 대리님 옵션 처리
        SelectOption *sel_option = (SelectOption *)_selected_theme.sel_options[_option_idx];
        
        if(_selected_theme.sel_options2.count > 0)
        {
            SelectOption *sel_design = (SelectOption *)_selected_theme.sel_options2[_design_idx];
            [Common info].photobook.AddVal8 = sel_design.comment;
            [Common info].photobook.AddVal9 = sel_design.price;
        }
        
        [Common info].photobook.AddVal6 = sel_option.comment;
        [Common info].photobook.AddVal11 = @"무광";
        [Common info].photobook.AddVal12 = _booksizes.currentTitle;
        [Common info].photobook.AddVal13 = _selected_theme.theme1_id;
        [Common info].photobook.AddVal7 = _selected_theme.theme2_id;
        
        vc.is_new = YES;
    }
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DesignPhotoDetailCell" forIndexPath:indexPath];
    
    if (_selected_theme != nil) {
        if (_thumbs == nil) {
            _thumbs = [[NSMutableArray alloc] init];
        }
        
        if (indexPath.row < _thumbs.count && _thumbs[indexPath.row] != nil) {
            UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
            imageview.image = _thumbs[indexPath.row];
        }
        else {
//            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, _selected_theme.preview_thumbs[indexPath.row]];
            
//            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *url = [Common makeURLString:_selected_theme.preview_thumbs[indexPath.row] host:[Common info].photobook_theme.thumb_url];
            
            [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                if (succeeded) {
                    UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                    imageview.image = [UIImage imageWithData:imageData];
                    if(imageview.image != nil)
                        [_thumbs addObject:imageview.image];
                    //_thumbs[idx] = imageview.image;
                }
                else {
                    NSLog(@"theme-detail's thumbnail_image is not downloaded.");
                }
            }];
        }
        
        // 페이지라벨
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        page_label.text = @"";
        
        SelectOption *sel_option = (SelectOption *)_selected_theme.sel_options[_option_idx];
        
        // 가격 표시
        int total_price = [_book_info.discount intValue];
        if (sel_option.price.length > 0) {
            total_price += [sel_option.price intValue];
        }
        NSString *price_str = [[Common info] toCurrencyString:total_price];
        _discount.text = [NSString stringWithFormat:@"%@원", price_str];
        
        //사이즈 표시
        
        [_booksizes setTitle:_book_info.booksize forState:UIControlStateNormal];
        
        // 디자인(프레임, 3컷 4컷)
        if(_selected_theme.sel_options2.count > 0){
            SelectOption *sel_design = (SelectOption *)_selected_theme.sel_options2[_design_idx];
            [_design_button setTitle:sel_design.comment forState:UIControlStateNormal];
        }
        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:6];
        if (productmsg.length > 0) {
            NSString *temp_msg = [NSString stringWithFormat:@"(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
            productmsg = [productmsg stringByReplacingOccurrencesOfString:@"입니다." withString:@"."];
            productmsg = [NSString stringWithFormat:@"%@%@", productmsg, temp_msg];
            _deliverymsg.text = [productmsg stringByReplacingOccurrencesOfString:@"출고" withString:@"출\n고"];;
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
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZoomViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = @"";
    vc.product_type = PRODUCT_DESIGNPHOTO;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupMore:(id)sender {
    NSString *seqnum = @"";
    NSString *product_code = [Common info].photobook.ProductCode;
    if (product_code.length == 6) {
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }
    
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, @"347", seqnum];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebpageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)selectBookSize:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.book_infos.count; i++) {
        BookInfo *info = _selected_theme.book_infos[i];
        alert_action = [UIAlertAction actionWithTitle:info.cm style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _book_info = _selected_theme.book_infos[i];
            
            [_collection_view reloadData];
            
            [_booksizes setTitle:info.cm forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)selectOption:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options.count; i++) {
        SelectOption *item = _selected_theme.sel_options[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _option_idx = i;
            [_collection_view reloadData];
            
            [_option_button setTitle:item.comment forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)selectDesign:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options2.count; i++) {
        SelectOption *item = _selected_theme.sel_options2[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _design_idx = i;
            [_collection_view reloadData];
            
            [_design_button setTitle:item.comment forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goEdit:(id)sender {
    NSLog(@"performSegueWithIdentifier");
    [self performSegueWithIdentifier:@"FancyDivisionEditSegue" sender:self];
}

@end
