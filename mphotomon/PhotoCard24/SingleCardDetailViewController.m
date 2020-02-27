//
//  DesignPhotoDetailViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 2..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "SingleCardDetailViewController.h"
#import "SingleCardEditViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "PriceCell.h"
#import "GoodsTransparentCardEditViewController.h"

@interface SingleCardDetailViewController (){
    NSMutableArray *cells;
}

@end

@implementation SingleCardDetailViewController

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
    _option_idx2 = 0;
    _option_idx_count = 0;
    _option_idx2_count = 0;
    
//    _sel_option = [[SelectOption alloc] init];
    
    
    /*
    NSLog(@"==============");
    NSLog(@"1============== : %@",self.selected_theme.theme1_id);
    NSLog(@"2============== : %@",self.selected_theme.theme2_id);
    NSLog(@"3============== : %@",self.selected_theme.productcode);
    NSLog(@"4============== : %@",self.selected_theme.main_thumb);
    NSLog(@"5============== : %@",self.selected_theme.theme_name);
    NSLog(@"6============== : %@",self.selected_theme.openurl);
    NSLog(@"7============== : %@",self.selected_theme.webviewurl);
    
    NSLog(@"8============== : %@",self.selected_theme.preview_thumbs);
    NSLog(@"9============== : %@",self.selected_theme.cover_types);
    NSLog(@"10============== : %@",self.selected_theme.book_infos);
    
    NSLog(@"11============== : %@",self.selected_theme.sel_coatings);
    NSLog(@"12============== : %@",self.selected_theme.sel_options2);
    
    NSLog(@"***************");
    //가격
    NSLog(@"1*************** : %@",self.selected_theme.price);
    NSLog(@"2*************** : %@",self.selected_theme.discount);
    //사이즈
    NSLog(@"3*************** : %@",self.selected_theme.book_sizes);

    //구성 24장 1세트
    //하드코딩 24장 1세트
    
    //옵션 comment;price;
    NSLog(@"4*************** : %@",((SelectOption*)self.selected_theme.sel_options[0]).comment);
    NSLog(@"4*************** : %@",((SelectOption*)self.selected_theme.sel_options[0]).price);
    NSLog(@"4*************** : %@",((SelectOption*)self.selected_theme.sel_options[1]).comment);
    NSLog(@"4*************** : %@",((SelectOption*)self.selected_theme.sel_options[1]).price);

    NSLog(@"5*************** : %@",((SelectOption*)self.selected_theme.sel_options2[0]).comment);
    NSLog(@"5*************** : %@",((SelectOption*)self.selected_theme.sel_options2[0]).price);
    NSLog(@"5*************** : %@",((SelectOption*)self.selected_theme.sel_options2[1]).comment);
    NSLog(@"5*************** : %@",((SelectOption*)self.selected_theme.sel_options2[1]).price);
*/

    //배송안내
    
    //배송료
    //하드코딩 2,500(3만원 이상 무료)
    
    cells = [@[@[@"CellPrice",@"가격"],@[@"CellOption", @"타입"], @[@"CellInfo",@"사이즈"],@[@"CellInfo",@"구성"]
               ,@[@"CellOption",@"옵션1"],@[@"CellCount",@"수량"],@[@"CellOption",@"옵션2"]
               ,@[@"CellCount",@"수량"],@[@"CellInfo",@"배송안내"],@[@"CellInfo",@"배송료"]] mutableCopy];

    if (_cardType.length == 0) {
        _cardType = @"포토카드";
    }
    self.navigationItem.title = _cardType;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"DesignPhotoDetail" ScreenClass:[self.classForCoder description]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];
//    [self updateTheme];
    [self.collection_view reloadData];
}

- (void)updateTheme {
    
    if (_selected_theme != nil /*&& _booksizes.currentTitle.length <= 0*/) {
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
    // SJYANG.2018.04 : 이동헌 대리님 옵션 처리

    // 네컷인화 배열 $$$$$포토보드(+53,000원)$Blackpink$$$1$무광$6.3cm x 17.7cm$defaultdepth1$Blackpink$
    [Common info].photobook.AddVal6 = [NSString stringWithFormat:@"%@|%d_%@|%d", ((SelectOption*)self.selected_theme.sel_options[_option_idx]).comment, _option_idx_count, ((SelectOption*)self.selected_theme.sel_options2[_option_idx2]).comment, _option_idx2_count];

    NSLog(@"[Common info].photobook.AddVal6 : %@", [Common info].photobook.AddVal6);

    [Common info].photobook.AddVal11 = @"무광";
//        [Common info].photobook.AddVal12 = _booksizes.currentTitle;
    [Common info].photobook.AddVal13 = _selected_theme.theme1_id;
    [Common info].photobook.AddVal7 = _selected_theme.theme2_id;
    if ([segue.identifier isEqualToString:@""]) {
        GoodsTransparentCardEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = YES;
        }
    } else {
        SingleCardEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = YES;
        }
    }
}


#pragma mark -
#pragma mark TableView
//테이블뷰 행수 처리
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kPhotoCardTotal;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == kPhotoCardOPCount1)
        if (_option_idx_count <= 0) return 0;
    
    if (indexPath.row == kPhotoCardOPCount2)
        if (_option_idx2_count <= 0) return 0;

    return 38;
//    return UITableViewAutomaticDimension;
}


//내부 셀 처리
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;

    NSString *CellIdentifier = cells[indexPath.row][0];
    NSString *title = cells[indexPath.row][1];
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UILabel *lblTitle = [cell.contentView viewWithTag:1];
    [lblTitle setText:title];


    
    if (indexPath.row == kPhotoCardPrice) {

        PriceCell *priceCell = (PriceCell *) cell;

        NSLog(@"1*************** : %@", self.selected_theme.price);
        NSLog(@"2*************** : %@", self.selected_theme.discount);

        NSString *sPrice = [[Common info] toCurrencyString:[self.selected_theme.price intValue]];
        NSString *sDiscount = [[Common info] toCurrencyString:[self.selected_theme.discount intValue]];
//        NSString *sPrice = [NSString stringWithFormat:@"%@원", self.selected_theme.price];
//        NSString *sDiscount = [NSString stringWithFormat:@"%@원", self.selected_theme.discount];

        UILabel *lblPrice = [cell.contentView viewWithTag:2];
        [lblPrice setText:[NSString stringWithFormat:@"%@원", sPrice]];
        UILabel *lblDiscount = [cell.contentView viewWithTag:3];
        [lblDiscount setText:[NSString stringWithFormat:@"%@원", sDiscount]];

        if ([self.selected_theme.price isEqualToString:self.selected_theme.discount]) {
            [lblPrice setText:@""];
            priceCell.dicountLCLeft.constant = 0;
        }

    } else if (indexPath.row == kPhotoCardType) {
        UIButton *btn = [cell.contentView viewWithTag:2];
        NSString *title = _cardType;
        [btn setTitle:title forState:UIControlStateNormal];
    }else if (indexPath.row == kPhotoCardSize){
        UILabel *lblTitle = [cell.contentView viewWithTag:2];
        [lblTitle setText:[self.selected_theme.book_infos[0] booksize]];
    }else if (indexPath.row == kPhotoCardForm){
        UILabel *lblTitle = [cell.contentView viewWithTag:2];

        for (BookInfo *bi in _selected_theme.book_infos) {
            if ([bi.cardType isEqualToString:_cardType]) {
                NSUInteger startIndex = [bi.cm rangeOfString:@"("].location;
                NSUInteger endIndex = [bi.cm rangeOfString:@")"].location;

                lblTitle.text = [bi.cm substringWithRange:NSMakeRange(startIndex + 1, endIndex - startIndex - 1)];
                break;
            }
        }
    }else if (indexPath.row == kPhotoCardOption1){
        UIButton *btn = [cell.contentView viewWithTag:2];
        NSString *title = ((SelectOption*)self.selected_theme.sel_options[_option_idx]).comment;
        [btn setTitle:title forState:UIControlStateNormal];
    }else if (indexPath.row == kPhotoCardOPCount1){
        
        UILabel *lbCount = [cell.contentView viewWithTag:2];
        [lbCount setText:[NSString stringWithFormat:@"%i",self.option_idx_count]];
        
    }else if (indexPath.row == kPhotoCardOption2){
        UIButton *btn = [cell.contentView viewWithTag:2];
        NSString *title = ((SelectOption*)self.selected_theme.sel_options2[_option_idx2]).comment;
        [btn setTitle:title forState:UIControlStateNormal];
    }else if (indexPath.row == kPhotoCardOPCount2){

        UILabel *lbCount = [cell.contentView viewWithTag:2];
        [lbCount setText:[NSString stringWithFormat:@"%i",self.option_idx2_count]];

        
    }else if (indexPath.row == kPhotoCardMeg){
        UILabel *lblTitle = [cell.contentView viewWithTag:2];
//        [lblTitle setText:@"오늘 주문시 00월 00일 출고/배송 \n(토,일 제외)"];

        
        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:6];
        if (productmsg.length > 0) {
            NSString *temp_msg = [NSString stringWithFormat:@"D+3(토,일 제외)(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
            productmsg = [productmsg stringByReplacingOccurrencesOfString:@"입니다." withString:@"."];
            productmsg = [NSString stringWithFormat:@"%@%@", productmsg, temp_msg];
            [lblTitle setText:productmsg];
        }

        
        
    }else if (indexPath.row == kPhotoCardCharge){
        UILabel *lblTitle = [cell.contentView viewWithTag:2];
        [lblTitle setText:@"2,500원(3만원 이상 무료)"];
    }else{
    }
    
    return cell;
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

    // 페이지라벨
    UILabel *page_label = (UILabel *)[cell viewWithTag:500];
    page_label.text = @"";

    
    
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
					if(imageview.image != nil)
	                    [_thumbs addObject:imageview.image];
                    //_thumbs[idx] = imageview.image;
                }
                else {
                    NSLog(@"theme-detail's thumbnail_image is not downloaded.");
                }
            }];
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

#pragma mark - Button Event


- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ZoomPage"];
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
    WebpageViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebPage"];
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
            
//            [_booksizes setTitle:info.cm forState:UIControlStateNormal];
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

    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UIButton *btnOption = (UIButton*)sender;
    
    UIAlertAction *alert_action = nil;
    if (indexPath.row == kPhotoCardType) {
        for (NSString *cardType in _selected_theme.sel_types) {
            alert_action = [UIAlertAction actionWithTitle:cardType style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.cardType = cardType;
                self.navigationItem.title = cardType;
                for (BookInfo *bi in _selected_theme.book_infos) {
                    if ([bi.cardType isEqualToString:_cardType]) {
                        [[Common info].photobook initPhotobookInfo:bi ThemeInfo:_selected_theme];
                        _selected_theme.productcode = bi.productcode;
                        _selected_theme.price = bi.price;
                        _selected_theme.discount = bi.discount;
                        break;
                    }
                }
                [self.tableView reloadData];
                [btnOption setTitle:cardType forState:UIControlStateNormal];
                [vc dismissViewControllerAnimated:YES completion:nil];
            }];
            [vc addAction:alert_action];
        }
    } else {
        for (int i = 0; i < _selected_theme.sel_options.count; i++) {
            SelectOption *item =  (indexPath.row == kPhotoCardOption1) ? _selected_theme.sel_options[i] : _selected_theme.sel_options2[i] ;
            alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

                if (indexPath.row == kPhotoCardOption1) {
                    _option_idx = i;
                    if (i == 0) {
                        _option_idx_count = 0;
                    }else{
                        _option_idx_count = 1;
                    }
                }else{
                    _option_idx2 = i;
                    if (i == 0) {
                        _option_idx2_count = 0;
                    }else{
                        _option_idx2_count = 1;
                    }
                }

                NSLog(@"i : %i", i);

//            [_collection_view reloadData];
                [self.tableView reloadData];

                [btnOption setTitle:item.comment forState:UIControlStateNormal];
                [vc dismissViewControllerAnimated:YES completion:nil];
            }];
            [vc addAction:alert_action];
        }
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {}];
    
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goEdit:(id)sender {
	NSLog(@"performSegueWithIdentifier");
    for (BookInfo *bi in _selected_theme.book_infos) {
        if ([bi.cardType isEqualToString:_cardType]) {
            if ([bi.productcode isEqualToString:@"347036"]) {
                [self performSegueWithIdentifier:@"DesignPhotoEditSegue" sender:self];
            } else {
                [self performSegueWithIdentifier:@"DesignTransparentPhotoEditSegue" sender:self];
            }
            break;
        }
    }
}


- (IBAction)clickOptionUp:(id)sender {
    NSLog(@"clickOptionUp");
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath.row == kPhotoCardOPCount1) {
        _option_idx_count++;
    }else if(indexPath.row == kPhotoCardOPCount2){
        _option_idx2_count++;
    }
    
    [self.tableView reloadData];
    
}

- (IBAction)clickOptionDown:(id)sender {
    NSLog(@"clickOptionDown");
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath.row == kPhotoCardOPCount1) {
        _option_idx_count--;
    }else if(indexPath.row == kPhotoCardOPCount2){
        _option_idx2_count--;
    }
    
    [self.tableView reloadData];

}



@end
