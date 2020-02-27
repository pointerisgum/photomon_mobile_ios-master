//
//  GoodsFanbookDetailViewController.m
//  PHOTOMON
//
//  Created by 안영건 on 02/05/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "GoodsFanbookDetailViewController.h"
#import "PhotobookTheme.h"
#import "Common.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "PhotobookEditTableViewController.h"

@interface GoodsFanbookDetailViewController ()

@property NSInteger sel_size_idx;
@property NSInteger sel_covertype_idx;
@property NSInteger sel_coating_idx;

@end

@implementation GoodsFanbookDetailViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [Analysis log:@"FanbookDetail"];

    _option_idx = 0; // SJYANG
    //_thumbs = nil;
    //_select_size = @"8x8";

    //cmh 2018.08.07 내지코팅 추가
    self.sel_size_idx = 0;
    self.sel_covertype_idx = 0;
    self.sel_coating_idx = 0;

    // SJYANG : 스키니북 / 카탈로그
    // cmh : 구닥북 추가
    if(_book_info == nil && [_selected_theme.book_infos count] >= 1) {
        BookInfo *tbookinfo = _selected_theme.book_infos[0];

        _book_info = _selected_theme.book_infos[0];
        _select_size = _book_info.booksize;
        _select_covertype = _book_info.covertype;
    }

    // HSJ. 초기에 전체적으로 -20 값을 해준다.
    if (_book_info && [_selected_theme.book_infos count] >= 1) {

        for (BookInfo *tbookinfo in _selected_theme.book_infos) {
            if ([tbookinfo.productcode isEqualToString:@"300221"] || [tbookinfo.productcode isEqualToString:@"300225"] || [tbookinfo.productcode isEqualToString:@"300223"]) {
                tbookinfo.productcode = [NSString stringWithFormat:@"%ld", [tbookinfo.productcode integerValue] - 20];
            }
        }

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// SJYANG
// 프리미엄북 : 형압 옵션 표시
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [Analysis firAnalyticsWithScreenName:@"FanbookDetail" ScreenClass:[self.classForCoder description]];

    // SJYANG : 2016.06.02
    _scroll_view.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    {
        _content_view.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_content_view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_content_view.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        [_content_view.superview addConstraint:constraint];
    }

    int start_y = _detail_btn.frame.origin.y + 37;
    int space = 38;
    int step = 0;

    [self setLabelTopConstraint:_booksize_title pos:start_y + space * step];
    [self setButtonTopConstraint:_booksize pos:start_y + space * step];
    [self setButtonTopConstraint:_booksize_icon pos:start_y + space * step++];

    // SJYANG : 2017.12.09 : 스키니북/카달로그 처리
    if([_book_info.productcode isEqualToString:@"120069"]) {
        _covertype_title.hidden = YES;
        _covertype.hidden = YES;
    }
    else
    {
        [self setLabelTopConstraint:_covertype_title pos:start_y + space * step];
        [self setLabelTopConstraint:_covertype pos:start_y + space * step++];
    }

    //cmh 2018.08.07 내지코팅 추가
    if (_selected_theme.sel_coatings.count > 0) {
        [self setLabelTopConstraint:_innerCorting pos:start_y + space * step];
        [self setButtonTopConstraint:_innerCorting_btn pos:start_y + space * step];
        [self setButtonTopConstraint:_innerCorting_btn_opt pos:start_y + space * step++];
    }else{
        _innerCorting.hidden = YES;
        _innerCorting_btn.hidden = YES;
        _innerCorting_btn_opt.hidden = YES;
    }

    [self setLabelTopConstraint:_price_title pos:start_y + space * step];
    [self setLabelTopConstraint:_price pos:start_y + space * step];
    [self setLabelTopConstraint:_price_strike pos:start_y + space * step + _price.frame.size.height / 2];
    [self setLabelTopConstraint:_discount pos:start_y + space * step++];

    if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] ) {
        [self setLabelTopConstraint:_coverlogo_title pos:start_y + space * step];
        [self setButtonTopConstraint:_coverlogo pos:start_y + space * step];
        [self setButtonTopConstraint:_coverlogo_dropdown pos:start_y + space * step - 2];
        [self setButtonTopConstraint:_coverlogo_help pos:start_y + space * (step++) - 2];
    } else {
        _coverlogo_title.hidden = YES;
        _coverlogo.hidden = YES;
        _coverlogo_dropdown.hidden = YES;
        _coverlogo_help.hidden = YES;
    }

    [self setLabelTopConstraint:_minpictures_title pos:start_y + space * step];
    [self setLabelTopConstraint:_minpictures pos:start_y + space * step++];

    [self setLabelTopConstraint:_pages_title pos:start_y + space * step];
    [self setLabelTopConstraint:_pages pos:start_y + space * step++];

//    [self setLabelTopConstraint:_papertype_title pos:start_y + space * step];
//    [self setLabelTopConstraint:_papertype pos:start_y + space * step++];

    [self setLabelTopConstraint:_deliverymsg_title pos:start_y + space * step];
    [self setLabelTopConstraint:_deliverymsg pos:start_y + space * step++];

    /*
    {
        _coverlogo_popup_view.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_coverlogo_popup_view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_content_view attribute:NSLayoutAttributeTop multiplier:1.0f constant:80];
        [_content_view addConstraint:constraint];
    }
    */

    _content_view.hidden = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];

    // SJYANG
    // 프리미엄북 : 형압 옵션 표시
    _content_view.hidden = YES;
    _coverlogo_popup_view.hidden = YES;
    [self updateTheme];
}

- (void)updateTheme {
    if (_selected_theme != nil) {

        _book_info = _selected_theme.book_infos[self.sel_size_idx * _selected_theme.cover_types.count + self.sel_covertype_idx];

        NSString *productcode = _book_info.productcode;

        if (self.sel_coating_idx == 1) {
            productcode = [[NSString alloc] initWithFormat:@"%d", [productcode intValue] + 20];
        }
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
        [[Common info].photobook setProductCode:productcode];
        [_collection_view reloadData];

//        for (BookInfo *bookinfo in _selected_theme.book_infos) {
//            if ([bookinfo.booksize isEqualToString:_select_size]) {
//                [[Common info].photobook initPhotobookInfo:bookinfo ThemeInfo:_selected_theme];
//                _book_info = bookinfo;
//
//                [_collection_view reloadData];
//                break;
//            }
//        }

        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
//        NSString *intnum = @"";
//        NSString *seqnum = @"";
//        NSString *product_code = [Common info].photobook.ProductCode;
//        if (product_code.length == 6) {
//            intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
//            seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
//        }
//
//        if( [seqnum isEqualToString:@"267"] || [seqnum isEqualToString:@"268"] || [seqnum isEqualToString:@"269"] || [seqnum isEqualToString:@"270"] ) {
//            if( [seqnum isEqualToString:@"270"] )
//                [_done_button setTitle:@"기본형 포토북 만들기" forState:UIControlStateNormal];
//            else if( [seqnum isEqualToString:@"269"] )
//                [_done_button setTitle:@"라이트형 포토북 만들기" forState:UIControlStateNormal];
//            else if( [seqnum isEqualToString:@"268"] )
//                [_done_button setTitle:@"기본형 인스타북 만들기" forState:UIControlStateNormal];
//            else if( [seqnum isEqualToString:@"267"] )
//                [_done_button setTitle:@"라이트형 인스타북 만들기" forState:UIControlStateNormal];
//        }
//        else {
//            if ([_select_size isEqualToString:@"5.5x5.5"]) {
//                [_done_button setTitle:@"인스타북 만들기" forState:UIControlStateNormal];
//            }
//            else {
//                [_done_button setTitle:@"포토북 만들기" forState:UIControlStateNormal];
//            }
//        }
    }
}

- (NSString *)getBookSizeTitle:(NSString *)title {
    NSString *size_title = title;
    if ([size_title containsString:@"A5w"]) {
        size_title = [size_title stringByReplacingOccurrencesOfString:@"A5w" withString:@"A5"];
    }
    return size_title;
}

- (IBAction)selectBookSize:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.book_sizes.count; i++) {
        BookInfo *bi = _selected_theme.book_infos[i * _selected_theme.cover_types.count + 1];
        NSString *size_title = [NSString stringWithFormat:@"%@ (%@)", bi.booksize, bi.cm];
        size_title = [self getBookSizeTitle:size_title];

        alert_action = [UIAlertAction actionWithTitle:size_title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.sel_size_idx = i;
            _select_size = bi.booksize;
            [self updateTheme];

            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];

    [self presentViewController:vc animated:YES completion:nil];

}

//cmh 2018.08.07 내지코팅 추가
- (IBAction)selectInnerCort:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_coatings.count; i++) {

        SelectOption *sel_item = _selected_theme.sel_coatings[i];

        alert_action = [UIAlertAction actionWithTitle:sel_item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.sel_coating_idx = i;
            if (i == 0) {
                for (BookInfo *tbookinfo in _selected_theme.book_infos) {
                    if ([tbookinfo.productcode isEqualToString:@"300221"] || [tbookinfo.productcode isEqualToString:@"300225"] || [tbookinfo.productcode isEqualToString:@"300223"]) {
                        tbookinfo.productcode = [NSString stringWithFormat:@"%ld", [tbookinfo.productcode integerValue] - 20];
                    }
                }
            } else {
                for (BookInfo *tbookinfo in _selected_theme.book_infos) {
                    if ([tbookinfo.productcode isEqualToString:@"300201"] || [tbookinfo.productcode isEqualToString:@"300205"] || [tbookinfo.productcode isEqualToString:@"300203"]) {
                        tbookinfo.productcode = [NSString stringWithFormat:@"%ld", [tbookinfo.productcode integerValue] + 20];
                    }
                }
            }
            [self updateTheme];
            [self.collection_view reloadData];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];

    [self presentViewController:vc animated:YES completion:nil];

}


- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = _select_size;
    vc.product_type = PRODUCT_PHOTOBOOK;
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

    // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    if ([seqnum isEqualToString:@"270"])
        seqnum = @"269";
    else if ([seqnum isEqualToString:@"268"])
        seqnum = @"267";

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PhotobookEditTableViewController *vc = [segue destinationViewController];
    if (vc) {
        vc.is_new = YES;

        // SJYANG
        // 프리미엄북 : 형압 옵션에 따라 photobook.AddParams (hapiness / love) 설정
        if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] ) {
            switch (_option_idx) {
                case 0: [Common info].photobook.AddParams = @"happiness"; break;
                case 1: [Common info].photobook.AddParams = @"love"; break;
                default: NSAssert(NO, @"PhotobookDetailViewController.m: 옵션에러"); break;
            }
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selected_theme) {
        _page_control.numberOfPages = _selected_theme.preview_thumbs.count / 2;
        return _selected_theme.preview_thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotobookDetailCell" forIndexPath:indexPath];

    if (_selected_theme != nil) {
        NSString *thumbname = _selected_theme.preview_thumbs[indexPath.row];
        if ([_select_size isEqualToString:@"6x8"]) {
            thumbname = [thumbname stringByReplacingOccurrencesOfString:@"preview_e_" withString:@"preview_h_"];
        }
        else if ([_select_size isEqualToString:@"8x6"]) {
            thumbname = [thumbname stringByReplacingOccurrencesOfString:@"preview_e_" withString:@"preview_w_"];
        }
        else {
            //thumbname = @"preview_e_Simple_01.jpg";
        }

        // SJYANG
        // 프리미엄북 : 커버를 보여줄 때 선택한 형압 옵션에 맞는 커버 썸네일 출력
        if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] ) {
            if( _option_idx==0 )
                thumbname = [thumbname stringByReplacingOccurrencesOfString:@"_love" withString:@"_happiness"];
            else
                thumbname = [thumbname stringByReplacingOccurrencesOfString:@"_happiness" withString:@"_love"];
        }
        NSLog(@"thumbname : %@", thumbname);

        NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
                if (imageview.image == nil) {
                    imageview.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
                }
            }
            else {
                NSLog(@"theme-detail's thumbnail_image is not downloaded.");
            }
        }];

        //
        NSString *seqnum = [_book_info.productcode substringWithRange:NSMakeRange(3,3)];

        //
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        if (page_label != nil) {
            if ([seqnum isEqualToString:@"269"] || [seqnum isEqualToString:@"270"]) {
                if (indexPath.row == 0) {
                    page_label.text = @"cover";
                }
                else if (indexPath.row == (_selected_theme.preview_thumbs.count-1)) {
                    page_label.text = @"back";
                }
                else {
                    page_label.text = [NSString stringWithFormat:@"%d-%dp", (int)indexPath.row*2-1, (int)indexPath.row*2];
                }
            }
            else {
                if (indexPath.row == 0) {
                    page_label.text = @"cover";
                }
                else if (indexPath.row == 1) {
                    page_label.text = @"1p";
                }
                else if (indexPath.row == (_selected_theme.preview_thumbs.count-1)) {
                    page_label.text = @"back";
                }
                else {
                    // SJYANG : 2016.06.14
                    NSInteger last_section_index = [_collection_view numberOfSections] - 1;
                    NSInteger last_row_index = [_collection_view numberOfItemsInSection:last_section_index] - 1;

                    if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] && indexPath.row==last_row_index-1 )
                        page_label.text = [NSString stringWithFormat:@"%ddp", (int)indexPath.row*2-2];
                    else
                        page_label.text = [NSString stringWithFormat:@"%d-%dp", (int)indexPath.row*2-2, (int)indexPath.row*2-1];
                }
            }
        }

        NSString *price = [[Common info] toCurrencyString:[_book_info.price intValue] + (self.sel_coating_idx == 0 ? 0 : 5000)];
        NSString *discount = [[Common info] toCurrencyString:[_book_info.discount intValue] + (self.sel_coating_idx == 0 ? 0 : 5000)];
        NSString *addprice = [[Common info] toCurrencyString:[_book_info.addpageprice intValue] * 2];

//        if (_book_info.productcode.length >= 6) {
//            NSString *uvtype = seqnum;
//            if (uvtype != nil && uvtype.length > 0) {
//                BOOL isUV = ([uvtype isEqualToString:@"221"] || [uvtype isEqualToString:@"223"] || [uvtype isEqualToString:@"225"]);
//                if (isUV) {
//                    price = [[Common info] toCurrencyString:[_book_info.price intValue] + 5000];
//                    discount = [[Common info] toCurrencyString:[_book_info.discount intValue] + 5000];
//                }
//            }
//        }

        NSString *size_title = [NSString stringWithFormat:@"%@ (%@)", _book_info.booksize, _book_info.cm];
        size_title = [self getBookSizeTitle:size_title];
        [_booksize setTitle:size_title forState:UIControlStateNormal];
        [_covertype setTitle:_selected_theme.cover_types[self.sel_covertype_idx] forState:UIControlStateNormal];

        NSLog(@"_selected_theme.sel_coatings : %@", _selected_theme.sel_coatings);
        //cmh 2018.08.07 내지코팅 추가
        if (_selected_theme.sel_coatings.count > 0) {
            SelectOption *sel_item = _selected_theme.sel_coatings[self.sel_coating_idx];
            [_innerCorting_btn setTitle:sel_item.comment forState:UIControlStateNormal];
        }

        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
        if( [seqnum isEqualToString:@"267"] || [seqnum isEqualToString:@"268"] || [seqnum isEqualToString:@"269"] || [seqnum isEqualToString:@"270"] ) {
            _covertype_title.text = @"페이지수";
//            _covertype.text = _book_info.covertype;
//            if( _book_info.minpages==_book_info.maxpages ) {
//                if( [seqnum isEqualToString:@"268"] || [seqnum isEqualToString:@"270"] )
//                    _covertype.text = [NSString stringWithFormat:@"기본형 %@p", _book_info.minpages];
//                else
//                    _covertype.text = [NSString stringWithFormat:@"라이트형 %@p", _book_info.minpages];
//            }
//            else {
//                if( [seqnum isEqualToString:@"268"] || [seqnum isEqualToString:@"270"] )
//                    _covertype.text = [NSString stringWithFormat:@"기본형 (%@p~%@p)", _book_info.minpages, _book_info.maxpages];
//                else
//                    _covertype.text = [NSString stringWithFormat:@"라이트형 (%@p~%@p)", _book_info.minpages, _book_info.maxpages];
//            }
        }
        else {
            _covertype_title.text = @"커버종류";
//            _covertype.text = _book_info.covertype;
        }
        _price.text = [NSString stringWithFormat:@"%@원", price];
        _discount.text = [NSString stringWithFormat:@"%@원", discount];
        _minpictures.text = [NSString stringWithFormat:@"%@장", _book_info.minpictures];

        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
        if ([seqnum isEqualToString:@"268"] || [seqnum isEqualToString:@"267"]) {
            _pages_title.text = @"기본구성";
            if( _book_info.minpages==_book_info.maxpages )
                _pages.text = [NSString stringWithFormat:@"기본 %@p (페이지추가불가)", _book_info.minpages];
            else
                _pages.text = [NSString stringWithFormat:@"기본 %@p~%@p (2p추가시 %@원)", _book_info.minpages, _book_info.maxpages, addprice];
            _papertype.text = [NSString stringWithFormat:@"커버:%@ / 내지:%@", _book_info.coverpaper, _book_info.pagepaper];
        }
        else if ([seqnum isEqualToString:@"269"] || [seqnum isEqualToString:@"270"]) { // analogue photobook
            _pages_title.text = @"기본구성";
            _pages.text = [NSString stringWithFormat:@"표지포함 %@p (페이지추가불가)", _book_info.productoption2];
            _papertype.text = _book_info.pagepaper;
        }
        else {
            // SJYANG : 2017.12.09 : 스키니북/카달로그 처리
            if([_book_info.productcode isEqualToString:@"300180"] || [_book_info.productcode isEqualToString:@"300181"] || [_book_info.productcode isEqualToString:@"120069"]) {
                if([_book_info.productcode isEqualToString:@"300180"] || [_book_info.productcode isEqualToString:@"300181"]) {
                    _pages_title.text = @"페이지수";
                    _pages.text = @"기본 23p (커버제외)";
                }
                else if([_book_info.productcode isEqualToString:@"120069"]) {
                    _pages_title.text = @"페이지수";
                    _pages.text = [NSString stringWithFormat:@"기본%@p~최대%@p (4p씩 추가가능)", _book_info.minpages, _book_info.maxpages];
                }
                _papertype_title.text = @"제본";
                _papertype.text = _book_info.bind;
            }
            else if ([seqnum isEqualToString:@"201"] || [seqnum isEqualToString:@"203"] || [seqnum isEqualToString:@"205"]) {
                _pages_title.text = @"페이지수";
                _pages.text = [NSString stringWithFormat:@"기본%@p~최대%@p (2p추가시 %@원)", _book_info.minpages, _book_info.maxpages, @"1,000"];

                _papertype_title.text = @"용지";
                _papertype.text = [NSString stringWithFormat:@"커버:%@", _book_info.coverpaper];
            }
            else {
                _pages_title.text = @"페이지수";
                _pages.text = [NSString stringWithFormat:@"기본%@p~최대%@p (2p추가시 %@원)", _book_info.minpages, _book_info.maxpages, addprice];

                _papertype_title.text = @"용지";

                // SJYANG
                // 프리미엄북일 경우 항목에서 "커버:xx / 내지:xx" 에서 "커버:xx" 정보를 표시하지 않음
                if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] )
                    _papertype.text = [NSString stringWithFormat:@"내지:%@", _book_info.pagepaper];
                else
                    _papertype.text = [NSString stringWithFormat:@"커버:%@ / 내지:%@", _book_info.coverpaper, _book_info.pagepaper];
            }
        }

        // SJYANG : 2016.06.14
        NSString *productmsg;
        if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] )
            productmsg = [[Common info].connection productMsg:2];
        else
            productmsg = [[Common info].connection productMsg:1];
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

    _page_control.currentPage = page / 2;
}

// SJYANG
// 프리미엄북 : 형압 옵션 선택시 처리
- (IBAction)selectOption:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options.count; i++) {
        SelectOption *item = _selected_theme.sel_options[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            _option_idx = i;
            [_collection_view reloadData];

            [_coverlogo setTitle:item.comment forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];

            [self updateTheme];
        }];
        [vc addAction:alert_action];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];

    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupCoverLogo:(id)sender {
    NSString *product_code = [Common info].photobook.ProductCode;
    NSString *intnum = @"";
    NSString *seqnum = @"";
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

    NSString* option_value = @"";
    if( _option_idx==0 )
        option_value = @"happiness";
    else if( _option_idx==1 )
        option_value = @"love";

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_OPTION_POPUP, intnum, seqnum, option_value, [Common info].device_uuid];

    _coverlogo_popup_view.hidden = NO;

    NSURL *nsurl = [[NSURL alloc] initWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nsurl];
    [_coverlogo_popup_webview loadRequest:request];
    [_coverlogo_popup_webview reload];

    /*
    LandscapeWebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LandscapeWebPage"];
    vc.url = url;
    [self.navigationController popToViewController:self animated:NO];
    [self presentViewController:vc animated:YES completion:nil];
    */
}

- (IBAction)closePopupCoverLogo:(id)sender {
    _coverlogo_popup_view.hidden = YES;
}

- (IBAction)selectCoverType:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.cover_types.count; i++) {
        BookInfo *bi = _selected_theme.book_infos[i];
        NSString *covertype_title = bi.covertype;

        alert_action = [UIAlertAction actionWithTitle:covertype_title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.sel_covertype_idx = i;
            self.select_covertype = bi.covertype;
            if ([self.select_covertype containsString:@"소프트"]) {
                self.innerCorting_btn.enabled = NO;
                self.innerCorting_btn_opt.hidden = YES;
                self.sel_coating_idx = 0;
            } else {
                self.innerCorting_btn.enabled = YES;
                self.innerCorting_btn_opt.hidden = NO;
            }
            [self updateTheme];

            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];

    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setLabelTopConstraint:(UILabel *)obj pos:(int)pos {
    obj.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_content_view attribute:NSLayoutAttributeTop multiplier:1.0f constant:pos];
    [_content_view addConstraint:constraint];
}

- (void)setButtonTopConstraint:(UIButton *)obj pos:(int)pos {
    obj.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:obj attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_content_view attribute:NSLayoutAttributeTop multiplier:1.0f constant:pos];
    [_content_view addConstraint:constraint];
}

@end
