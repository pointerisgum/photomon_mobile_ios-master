//
//  PolaroidDetailViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 2..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PolaroidDetailViewController.h"
#import "PolaroidEditCollectionViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"

@interface PolaroidDetailViewController ()

@end

@implementation PolaroidDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"_mobile_squaresetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_squaresetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"_mobile_woodpolaroid"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_woodpolaroid"].location != NSNotFound ) {
            
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
        }
    }

    [Analysis log:@"PolaroidDetail"];
    _thumbs = nil;
    
    _coating_idx = 0;
    _option_idx = 0;
//    _sel_coating = [[SelectOption alloc] init];
//    _sel_option = [[SelectOption alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PolaroidDetail" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];
    [self updateTheme];

	if ([_book_info.productcode isEqualToString:@"347055"] || [_book_info.productcode isEqualToString:@"347056"] || [_book_info.productcode isEqualToString:@"347057"]) {
		UILabel *obj1 = (UILabel *)[self.view viewWithTag:201];
		[obj1 setText:@"스타일"];
		{
			SelectOption *item = _selected_theme.sel_coatings[0];
			_coating_idx = 0;
			[_coating_button setTitle:item.comment forState:UIControlStateNormal];
		}
		/*		
		UIButton *obj2 = (UIButton *)[self.view viewWithTag:202];
		[obj2 setTitle:@"선택안함" forState:UIControlStateNormal];
		*/

		UILabel *obj3 = (UILabel *)[self.view viewWithTag:301];
		obj3.hidden  = YES;
		UIButton *obj5 = (UIButton *)[self.view viewWithTag:303];
		obj5.hidden  = YES;

		UIButton *obj4 = (UIButton *)[self.view viewWithTag:302];
		obj4.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
		obj4.titleLabel.numberOfLines = 2;
		[obj4 setTitle:[@"편집화면에서 레이아웃을 변경하시면 사진형, 문구형 선택이 가능합니다." stringByReplacingOccurrencesOfString:@"변경하시면 사진형" withString:@"변경하시면\n사진형"] forState:UIControlStateNormal];		
		[obj4 setTitleColor:[UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1.0] forState:UIControlStateNormal];
		_constraints_optionbtn_width.constant = [[UIScreen mainScreen] bounds].size.width - 110;
		_constraints_optionbtn_height.constant = 30;
	}
}

- (void)updateTheme {
    [self updateTheme:0];
}

- (void)updateTheme:(int)idx {
    if (_selected_theme != nil && _booksizes.currentTitle.length <= 0) {
        NSAssert(_selected_theme.book_infos.count > 0, @"polaroid's book_info is not founded");
        NSAssert(_selected_theme.book_infos.count > idx, @"idx is over polaroid's book_info count");
        _book_info = _selected_theme.book_infos[idx]; // 폴라로이드는 1개 only.
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
        
        if (_selected_theme.sel_coatings.count <= 0) {
            SelectOption *sel_item = [[SelectOption alloc] init];
            [_selected_theme.sel_coatings addObject:sel_item];
            if ([_book_info.productcode isEqualToString:@"347055"] || [_book_info.productcode isEqualToString:@"347056"] || [_book_info.productcode isEqualToString:@"347057"])
                sel_item.comment = @"선택안함";
            else
                sel_item.comment = @"코팅없음";
            sel_item.price = @"0";
        }
        if (_selected_theme.sel_options.count <= 0) {
            SelectOption *sel_item = [[SelectOption alloc] init];
            [_selected_theme.sel_options addObject:sel_item];
            sel_item.comment = @"선택없음";
            sel_item.price = @"0";
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PolaroidEditCollectionViewController *vc = [segue destinationViewController];
    if (vc) {
        // 코팅 옵션 반영
        if (_coating_idx >= 0) {
            NSString *product_code = [Common info].photobook.ProductCode;
            if (product_code.length == 6) {
                //[Common info].photobook.ProductCode = [product_code stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"1"];
                //NSLog(@"폴라로이드 상품코드: %@ -> %@", product_code, [Common info].photobook.ProductCode);
                
                Photobook *pbook = [Common info].photobook;
                if (_coating_idx == 0) { // 일반
                    if ([pbook.DefaultStyle isEqualToString:@"Polaroid"]) {
                        [Common info].photobook.ProductCode = _book_info.productcode;
//                        [Common info].photobook.ProductCode = @"347031";
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"MiniPolaroid"]) {
//                        [Common info].photobook.ProductCode = @"347032";
						[Common info].photobook.ProductCode = _book_info.productcode;
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"SquarePhoto"]) {
                        //[Common info].photobook.ProductCode = @"347033"; or 347039
                        [Common info].photobook.ProductCode = _book_info.productcode;
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"WoodPolaroid"]) {
                        [Common info].photobook.ProductCode = @"347034";
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"StandingPola"]) {
                        [Common info].photobook.ProductCode = @"347055";
                    }
                }
                else if (_coating_idx == 1) { // UV코팅
                    if ([pbook.DefaultStyle isEqualToString:@"Polaroid"]) {
//                        [Common info].photobook.ProductCode = _book_info.productcode;
						if ([_book_info.productcode isEqualToString:@"347031"]) {
							[Common info].photobook.ProductCode = @"347041";
						} else {
							[Common info].photobook.ProductCode = @"347042";
						}
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"MiniPolaroid"]) {
//                        [Common info].photobook.ProductCode = @"347042";
						if ([_book_info.productcode isEqualToString:@"347031"]) {
							[Common info].photobook.ProductCode = @"347041";
						} else {
							[Common info].photobook.ProductCode = @"347042";
						}
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"SquarePhoto"]) {
                        //[Common info].photobook.ProductCode = @"347043";
                        if ([_book_info.productcode isEqualToString:@"347033"]) {
                            [Common info].photobook.ProductCode = @"347043";
                        }
                        else if ([_book_info.productcode isEqualToString:@"347039"]) {
                            [Common info].photobook.ProductCode = @"347049";
                        }
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"WoodPolaroid"]) {
                        [Common info].photobook.ProductCode = @"347054"; // 우드는 UV없고, 반짝블록만 존재함.
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"StandingPola"]) {
                        [Common info].photobook.ProductCode = @"347056";
                    }
                }
                else if (_coating_idx == 2) { // 반짝블록
                    if ([pbook.DefaultStyle isEqualToString:@"Polaroid"]) {
//                        [Common info].photobook.ProductCode = _book_info.productcode;
//                        [Common info].photobook.ProductCode = @"347051";
						if ([_book_info.productcode isEqualToString:@"347031"]) {
							[Common info].photobook.ProductCode = @"347051";
						} else {
							[Common info].photobook.ProductCode = @"347052";
						}
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"MiniPolaroid"]) {
//                        [Common info].photobook.ProductCode = @"347052";
						if ([_book_info.productcode isEqualToString:@"347031"]) {
							[Common info].photobook.ProductCode = @"347051";
						} else {
							[Common info].photobook.ProductCode = @"347052";
						}
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"SquarePhoto"]) {
                        //[Common info].photobook.ProductCode = @"347053";
                        if ([_book_info.productcode isEqualToString:@"347033"]) {
                            [Common info].photobook.ProductCode = @"347053";
                        }
                        else if ([_book_info.productcode isEqualToString:@"347039"]) {
                            [Common info].photobook.ProductCode = @"347059";
                        }
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"WoodPolaroid"]) {
                        NSAssert(NO, @"PolaroidDetailViewController.m: 코팅에러1"); // 우드는 UV없고, 반짝블록만 존재함.
                    }
                    else if ([pbook.DefaultStyle isEqualToString:@"StandingPola"]) {
                        [Common info].photobook.ProductCode = @"347057";
                    }
                }
            }
            else {
                NSAssert(NO, @"PolaroidDetailViewController.m: 코팅에러2");
            }
        }
        NSLog(@"폴라로이드 코드값: %@", [Common info].photobook.ProductCode);

        // 마끈 옵션 반영
        switch (_option_idx) {
            case 0: [Common info].photobook.AddParams = @"선택없음"; break;
            case 1: [Common info].photobook.AddParams = @"마끈 집게1EA"; break;
            case 2: [Common info].photobook.AddParams = @"마끈 집게2EA"; break;
            case 3: [Common info].photobook.AddParams = @"마끈 집게3EA"; break;
            default: NSAssert(NO, @"PolaroidDetailViewController.m: 마끈에러"); break;
        }
        NSLog(@"폴라로이드 옵션: %@", [Common info].photobook.AddParams);

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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PolaroidDetailCell" forIndexPath:indexPath];

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

        // 페이지라벨
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        page_label.text = @"";

        SelectOption *sel_coating = (SelectOption *)_selected_theme.sel_coatings[_coating_idx];
        SelectOption *sel_option = (SelectOption *)_selected_theme.sel_options[_option_idx];

        // 가격 표시
        int total_price = [_book_info.discount intValue];
        if (sel_coating.price.length > 0) {
            total_price += [sel_coating.price intValue];
        }
        if (sel_option.price.length > 0) {
            total_price += [sel_option.price intValue];
        }
        NSString *price_str = [[Common info] toCurrencyString:total_price];
        _discount.text = [NSString stringWithFormat:@"%@원", price_str];

        // 사이즈
        if ([[Common info].photobook.DefaultStyle isEqualToString:@"WoodPolaroid"]) {
            if (_coating_idx == 0) {
                [_booksizes setTitle:@"89mm X 102mm" forState:UIControlStateNormal];
                [_minphotocountmsg setText:@"18장 1세트"];
            }
            else {
                [_booksizes setTitle:@"89mm X 102mm" forState:UIControlStateNormal];
                [_minphotocountmsg setText:@"17장 1세트"];
            }
        } else {
            NSString *sizeStr = [NSString stringWithFormat:@"%@", _book_info.cm];
            NSError *error = nil;
            NSString *pattern = @"(.+)[ ]*\\((.*)\\)";
            NSRegularExpression *sizeExpression = [NSRegularExpression regularExpressionWithPattern:@"(.+)[ ]*\\((.*)\\)" options:NSRegularExpressionCaseInsensitive error:&error];
            if (error != nil) {
                [_booksizes setTitle:sizeStr forState:UIControlStateNormal];
                [_minphotocountmsg setText:@""];
            } else {
                NSTextCheckingResult *match = [sizeExpression firstMatchInString:sizeStr options:0 range:NSMakeRange(0, [sizeStr length])];
                if ([match numberOfRanges] == 3){
                    NSRange sizeRange = [match rangeAtIndex:1];
                    NSRange photoCountRange = [match rangeAtIndex:2];
                    
                    NSString *size = [sizeStr substringWithRange:sizeRange];
                    NSString *photoCount = [sizeStr substringWithRange:photoCountRange];
                    [_booksizes setTitle:size forState:UIControlStateNormal];
                    [_minphotocountmsg setText:photoCount];
                } else {
                    [_booksizes setTitle:sizeStr forState:UIControlStateNormal];
                    [_minphotocountmsg setText:@""];
                }
            }
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
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = @"";
    vc.product_type = PRODUCT_POLAROID;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupMore:(id)sender {
    NSString *seqnum = @"";
    NSString *product_code = [Common info].photobook.ProductCode;
    if (product_code.length == 6) {
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
        if (_coating_idx > 0) {
            seqnum = [seqnum stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"1"];
        }
    }
    
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, @"347", seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
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
            [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
            
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

- (IBAction)selectCoating:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_coatings.count; i++) {
        SelectOption *item = _selected_theme.sel_coatings[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _coating_idx = i;

            [_collection_view reloadData];
            
            [_coating_button setTitle:item.comment forState:UIControlStateNormal];
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

@end
