//
//  CalendarDetailViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "CalendarDetailViewController.h"
#import "CalendarEditTableViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"

@interface CalendarDetailViewController ()

@end

@implementation CalendarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"CalendarDetail"];
    _thumbs = nil;
    _start_year = 0;
    _start_month = 0;
    
    NSString *intnum = @"";
    @try {
        NSString *product_code = [Common info].photobook.ProductCode;
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        
        if([intnum isEqualToString:@"369"]){
            _option_select_constraint.active = YES;
            _option_select_btn_constraint.active = YES;
            
            _minpicture_constraint.active = NO;
            _minpicture_btn_constraint.active = NO;
        }
        else{
            _select_option.hidden = YES;
            _select_option_btn.hidden = YES;
            _select_option_sidebtn.hidden = YES;
            _option_select_constraint.active = NO;
            _option_select_btn_constraint.active = NO;
        }
        SelectOption *optionitem = (SelectOption*)_selected_theme.sel_options[0];
        _selectOptionIdx = 0;
        _discountValue = optionitem.price;
            
    }
    @catch(NSException *exception) {}
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"CalendarDetail" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:_selected_theme.theme_name];
    [self updateTheme];

	NSString *productcode = @"";
	@try {
		BookInfo *tbookinfo = _selected_theme.book_infos[0];
		productcode = tbookinfo.productcode;
	}
    @catch (NSException *e) {}

	// 포스터 달력 관련 코드 추가
	if([productcode hasPrefix:@"393"]) {
		_product_size_btn.hidden = NO;
	}
	else {
		[_product_size setTitleColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateNormal];
		[_product_size setUserInteractionEnabled:NO];
		_product_size_btn.hidden = YES;
	}
    
        
}

- (void)updateTheme {
    if (_selected_theme != nil && _product_size.titleLabel.text.length <= 0) {
        NSString *productcode = @"277006";

        @try {
			BookInfo *tbookinfo = _selected_theme.book_infos[0];
			productcode = tbookinfo.productcode;
        }
        @catch (NSException *e) {}

        for (BookInfo *bookinfo in _selected_theme.book_infos) {
            if ([bookinfo.productcode isEqualToString:productcode]) {
                [[Common info].photobook initPhotobookInfo:bookinfo ThemeInfo:_selected_theme];
                _book_info = bookinfo;
                
                if (_start_year == 0 || _start_month == 0) {
                    [_selected_start setTitle:@"시작 월을 선택해 주세요." forState:UIControlStateNormal];
                }
                else {
                    [_selected_start setTitle:[NSString stringWithFormat:@"%d년 %d월", _start_year, _start_month] forState:UIControlStateNormal];
                }
                break;
            }
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CalendarEditTableViewController *vc = [segue destinationViewController];
    if (vc) {
        vc.is_new = YES;
        vc.start_year = _start_year;
        vc.start_month = _start_month;
        vc.discount = _discountValue;
        vc.selectOptionIdx = _selectOptionIdx;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selected_theme) {
        _page_control.numberOfPages = _selected_theme.preview_thumbs.count / 5;
        return _selected_theme.preview_thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString *intnum = @"";
	@try {
		NSString *product_code = [Common info].photobook.ProductCode;
		intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
	}
	@catch(NSException *exception) {}

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarDetailCell" forIndexPath:indexPath];

    if (_selected_theme != nil) {
        if (_thumbs == nil) {
            //_thumbs = [[NSMutableArray alloc] initWithCapacity:_selected_theme.preview_thumbs.count]; // ?? 갯수만큼의 배열이 생성되지 않는다. 추후 분석 필요.
            _thumbs = [[NSMutableArray alloc] init];
        }
        
        if (indexPath.row < _thumbs.count && _thumbs[indexPath.row] != nil) {
            UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
            imageview.image = _thumbs[indexPath.row];
        }
        else {

			// 달력 썸네일 fullurl
			NSString *fullpath = @"";
			if([_selected_theme.preview_thumbs[indexPath.row] containsString:@"://"])                              
				fullpath = _selected_theme.preview_thumbs[indexPath.row];
			else
				fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, _selected_theme.preview_thumbs[indexPath.row]];
			
            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
				// SJYANG : 캘린더 시작년월 변경
				UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
	            @try {
					if (succeeded && imageData != nil ) {
						imageview.image = [UIImage imageWithData:imageData];
						[_thumbs addObject:imageview.image];
						//_thumbs[idx] = imageview.image;
					}
					else {
						UIImage *preview_image = [UIImage imageNamed: @"photobook_emptyphoto.png"];
						imageview.image = preview_image;
						[_thumbs addObject:imageview.image];
						NSLog(@"theme-detail's thumbnail_image is not downloaded.");
					}
				}
		        @catch (NSException *e) {
					UIImage *preview_image = [UIImage imageNamed: @"photobook_emptyphoto.png"];
					imageview.image = preview_image;
					[_thumbs addObject:imageview.image];
					NSLog(@"theme-detail's thumbnail_image is not downloaded.");
				}
            }];
		}
        
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        if (page_label != nil) {
			if ([intnum isEqualToString:@"393"]) {
				page_label.text = @"";
			}
			else {
				if (indexPath.row == 0) {
					page_label.text = @"cover";
				}
				else if (indexPath.row == (_selected_theme.preview_thumbs.count-1) && ![intnum isEqualToString:@"369"]) {
					page_label.text = @"back";
				}
				else {
					// SJYANG : 2018 달력
					if([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"368"] || [intnum isEqualToString:@"391"] || [intnum isEqualToString:@"392"]) {
						int month = (int)indexPath.row;
						if (month > 12) {
							month -= 12;
						}
						NSString *temp = @"(앞)";
						page_label.text = [NSString stringWithFormat:@"%d월 %@", month, temp];
					}
					else {
						int month = (int)(indexPath.row + 1) / 2;
						if (month > 12) {
							month -= 12;
						}
						NSString *temp = (((indexPath.row + 1) % 2) == 0) ? @"(앞)" : @"(뒤)";
						page_label.text = [NSString stringWithFormat:@"%d월 %@", month, temp];
					}
				}
			}
        }
        
        NSString *price = [[Common info] toCurrencyString:[_book_info.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[_book_info.discount intValue]];

		// 포스터 달력 관련 코드 추가
		if ([intnum isEqualToString:@"393"]) {
			[_product_size setTitle:[NSString stringWithFormat:@"%@", _book_info.booksize] forState:UIControlStateNormal];
			// 포스터 달력 : AddParams
			[Common info].photobook.AddParams = [NSString stringWithFormat:@"%@", _book_info.booksize];
		}
		else {
			[_product_size setTitle:[NSString stringWithFormat:@"%@", _book_info.cm] forState:UIControlStateNormal];
		}

		_price.text = [NSString stringWithFormat:@"%@원", price];
		_discount.text = [NSString stringWithFormat:@"%@원", discount];
        _minpictures.text = [NSString stringWithFormat:@"%@장", _book_info.minpictures];

		/*
		_pages.lineBreakMode = NSLineBreakByWordWrapping;  
		_pages.numberOfLines = 0;		
		*/
		_pages.text = [NSString stringWithFormat:@"%@", _book_info.pagecountinfo];

        if ([price isEqualToString:discount]) {
            _price.hidden = YES;
            _price_hypen.hidden = YES;
            _price_width_constraint.constant = 0;
        }
        
		// SJYANG : 2018 달력
        NSString *productmsg = [[Common info].connection productMsg:7];
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
    
    _page_control.currentPage = (int)(page / 5);
}

- (IBAction)selectStartYearMonth:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"시작 월을 선택해 주세요" preferredStyle:UIAlertControllerStyleActionSheet];
    
    int start_year = 0;
    @try {
		start_year = [_book_info.startyear intValue];
    }
    @catch(NSException *exception) {}

	int start_month = 0;
    @try {
		start_month = [_book_info.startmonth intValue];
    }
    @catch(NSException *exception) {}

	if(start_year <= 0) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy"];
		NSString *yearString = [formatter stringFromDate:[NSDate date]];
		start_year = [yearString intValue];
	}
	if(start_month <= 0) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"MM"];
		NSString *monthString = [formatter stringFromDate:[NSDate date]];
		start_month = [monthString intValue];
	}

	// 신규 달력 포맷 : 시작년월
    UIAlertAction *alert_action = nil;
    for (StartYear *startYear in _selected_theme.start_years) {
		start_year = startYear.year;
		start_month = startYear.month;

		NSString *title = startYear.datetext;
        alert_action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self->_start_year = start_year;
            self->_start_month = start_month;
            [self->_selected_start setTitle:title forState:UIControlStateNormal];
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
    vc.option_str = @"";
    vc.product_type = PRODUCT_CALENDAR;
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

// SJYANG : 캘린더 시작년월 변경
- (IBAction)onSubmit:(id)sender {
    if (_start_year == 0 || _start_month == 0) {
        [[Common info] alert:self Msg:@"시작 월을 선택해 주세요."];
        return;
    }
	//check
    NSString *msg = [NSString stringWithFormat:@"\"%d년 %d월\"을 달력의 시작월로 선택하셨습니다.\n편집을 진행하시겠습니까?", _start_year, _start_month];

    [[Common info]alert:self Title:msg Msg:@"" okCompletion:^{
        [self performSegueWithIdentifier:@"CalendarEditTableSegue" sender:self];

    } cancelCompletion:^{
        
    } okTitle:@"네" cancelTitle:@"아니오"];
}

- (IBAction)selectSize:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"사이즈를 선택해 주세요" preferredStyle:UIAlertControllerStyleActionSheet];
    
	// 포스터 달력 : 사이즈 선택
    UIAlertAction *alert_action = nil;
    for (BookInfo *bookinfo in _selected_theme.book_infos) {

		NSString *title = bookinfo.booksize;
		NSString *price = [[Common info] toCurrencyString:[bookinfo.price intValue]];
		NSString *discount = [[Common info] toCurrencyString:[bookinfo.discount intValue]];
		NSString *productcode = bookinfo.productcode;

        alert_action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_product_size setTitle:title forState:UIControlStateNormal];
			// 포스터 달력 : AddParams
			[Common info].photobook.AddParams = title;

			_price.text = [NSString stringWithFormat:@"%@원", price];
			_discount.text = [NSString stringWithFormat:@"%@원", discount];
			[Common info].photobook.ProductCode = productcode;

            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
	}
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)selectOption:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"옵션 선택해 주세요" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    // woodstand option select
    UIAlertAction *alert_action = nil;
    
    
    for (int idx = 0 ; idx < _selected_theme.sel_options.count ; idx++) {
        SelectOption *item = (SelectOption*)_selected_theme.sel_options[idx];
        NSString *title = item.comment;
        NSString *discount = [[Common info] toCurrencyString:[item.price intValue]];
        
        //NSString *productcode = bookinfo.productcode;

        alert_action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_select_option_btn setTitle:title forState:UIControlStateNormal];
            // 포스터 달력 : AddParams
            //[Common info].photobook.AddParams = title;
            //_price.text = [NSString stringWithFormat:@"%@원", price];
            //_discount.text = [NSString stringWithFormat:@"%@원", discount];
            //[Common info].photobook.ProductCode = productcode;
            _selectOptionIdx = idx;
            _discountValue = item.price;
            _discount.text = [NSString stringWithFormat:@"%@원", discount];

            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}


@end
