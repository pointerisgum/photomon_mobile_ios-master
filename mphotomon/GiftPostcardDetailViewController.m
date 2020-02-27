//
//  GiftPostcardDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "GiftPostcardDetailViewController.h"
#import "GiftPostcardEditViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"

@interface GiftPostcardDetailViewController ()

@end

@implementation GiftPostcardDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"GiftPostcardDetail"];
    _thumbs = nil;
    
    _pagecount_idx = 0;
    _includebox_idx = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"GiftPostcardDetail" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];
    [self updateTheme];
}

- (void)resetPageCount {
    NSAssert(_pagecount_idx >= 0, @"postcard pagecount is not valid.");
    
    SelectOption *opt = _selected_theme.sel_coatings[_pagecount_idx];
    NSString *page_count = opt.comment;
    NSString *price = opt.price;
    if (page_count.length < 2 || price.length < 1) return;
    
    NSString *temp = [page_count substringToIndex:page_count.length-1];
    int temp_value = [temp intValue];
    NSLog(@"postcard page_count: %@ -> %@ -> %d", page_count, temp, temp_value);
    [Common info].photobook.MinPage = temp_value;
    [Common info].photobook.MaxPage = temp_value;
    [Common info].photobook.ProductOption2 = temp;
    
    [Common info].photobook.DefaultProductPrice = [price intValue];
}

- (void)updateTheme {
    if (_selected_theme != nil && _booksize.text.length <= 0) {
        NSAssert(_selected_theme.book_infos.count > 0, @"postcard's book_info is not founded");
        _book_info = _selected_theme.book_infos[0]; // 1개 only.
        
        _book_info.minpages = @"8";
        _book_info.maxpages = @"8";
        _book_info.productoption2 = @"8";
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GiftPostcardEditViewController *vc = [segue destinationViewController];
    if (vc) {
        switch (_includebox_idx) {
            case 0: [Common info].photobook.AddParams = @"옵션없음"; break;
            case 1: [Common info].photobook.AddParams = @"선물용박스_데코세트"; break;
            default: NSAssert(NO, @"PostcardDetailViewController.m: 선물용박스에러"); break;
        }
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostcardDetailCell" forIndexPath:indexPath];
    
    if (_selected_theme != nil) {
        if (_thumbs == nil) {
            _thumbs = [[NSMutableArray alloc] init];
        }
        
        if (indexPath.row < _thumbs.count && _thumbs[indexPath.row] != nil) {
            UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
            imageview.image = _thumbs[indexPath.row];
        }
        else {
            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, _selected_theme.preview_thumbs[indexPath.row]];
            
            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                if (succeeded) {
                    UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                    imageview.image = [UIImage imageWithData:imageData];
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
        
        SelectOption *sel_pagecount = (SelectOption *)_selected_theme.sel_coatings[_pagecount_idx];
        SelectOption *sel_includebox = (SelectOption *)_selected_theme.sel_options[_includebox_idx];
        [_pagecount_button setTitle:sel_pagecount.comment forState:UIControlStateNormal];
        [_includebox_button setTitle:sel_includebox.comment forState:UIControlStateNormal];
        
        // 가격 표시
        int total_price = [_book_info.discount intValue];
        if (sel_pagecount.price.length > 0) {
            total_price = [sel_pagecount.price intValue];
        }
        if (sel_includebox.price.length > 0) {
            total_price += [sel_includebox.price intValue];
        }
        NSString *price_str = [[Common info] toCurrencyString:total_price];
        _discount.text = [NSString stringWithFormat:@"%@원", price_str];
        
        // 사이즈
        _booksize.text = _book_info.cm;
        
        // 재질
        _material.text = _book_info.material;
        
        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:6];
        if (productmsg.length > 0) {
            NSString *temp_msg = [NSString stringWithFormat:@"(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
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
    vc.option_str = @"";
    vc.product_type = PRODUCT_POLAROID;
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

- (IBAction)selectPagecount:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_coatings.count; i++) {
        SelectOption *item = _selected_theme.sel_coatings[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _pagecount_idx = i;
            [self resetPageCount];
            
            [_collection_view reloadData];
            
            [_pagecount_button setTitle:item.comment forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)selectIncludebox:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options.count; i++) {
        SelectOption *item = _selected_theme.sel_options[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _includebox_idx = i;
            [_collection_view reloadData];
            
            [_includebox_button setTitle:item.comment forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}


@end
