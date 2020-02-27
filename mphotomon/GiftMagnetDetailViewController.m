//
//  GiftMagnetDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "GiftMagnetDetailViewController.h"
#import "GiftMagnetEditViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"

@interface GiftMagnetDetailViewController ()

@end

@implementation GiftMagnetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"GiftMagnetDetail"];
    _thumbs = nil;
    
    _pagecount_idx = 0;

	[_option_title setHidden:YES];
	[_option_button1 setHidden:YES];
	[_option_button2 setHidden:YES];
	[_option_select setHidden:YES];
	_constraint_deliverymsg_top_space.constant = 6;

	if ([Common info].photobook.ProductCode != nil)
	{
		if ([[Common info].photobook.ProductCode hasPrefix:@"400"])
		    [_pagecount_button setTitle:@"9개 1세트" forState:UIControlStateNormal];
		else if ([[Common info].photobook.ProductCode hasPrefix:@"401"])
		    [_pagecount_button setTitle:@"6개 1세트" forState:UIControlStateNormal];
		else if ([[Common info].photobook.ProductCode hasPrefix:@"402"])
		    [_pagecount_button setTitle:@"6개 1세트" forState:UIControlStateNormal];
		else if ([[Common info].photobook.ProductCode hasPrefix:@"403"])
		    [_pagecount_button setTitle:@"5개 1세트" forState:UIControlStateNormal];
		else if ([[Common info].photobook.ProductCode hasPrefix:@"404"])
		    [_pagecount_button setTitle:@"6개 1세트" forState:UIControlStateNormal];

		if ([[Common info].photobook.ProductCode hasPrefix:@"403"]) {
			_option_button1.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];;
			[Common info].photobook.ProductCode = @"403001";
			[_option_title setHidden:NO];
			[_option_button1 setHidden:NO];
			[_option_button2 setHidden:NO];
			[_option_select setHidden:YES];
			_constraint_deliverymsg_top_space.constant = 50;
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"GiftMagnetDetail" ScreenClass:[self.classForCoder description]];
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
    if (_selected_theme != nil && _booksize.text.length <= 0) {
		
        NSAssert(_selected_theme.book_infos.count > 0, @"magnet's book_info is not founded");
        _book_info = _selected_theme.book_infos[0]; // 1개 only.

		// 마그넷 : 임시로 이렇게 처리해 놓고, 나중에 정확히 계산
        _book_info.minpages = @"1";
        _book_info.maxpages = @"9";
        _book_info.minpictures = @"1";
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GiftMagnetEditViewController *vc = [segue destinationViewController];
    if (vc) {
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MagnetDetailCell" forIndexPath:indexPath];
    
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
        
        // 가격 표시
		{
			int original_price = [_book_info.price intValue];
			NSString *price_str = [[Common info] toCurrencyString:original_price];
			_price.text = [NSString stringWithFormat:@"%@원", price_str];
		}
		{
			int total_price = [_book_info.discount intValue];
			NSString *price_str = [[Common info] toCurrencyString:total_price];
			_discount.text = [NSString stringWithFormat:@"%@원", price_str];
		}
		
		// 2019.05.24 : 수정
        // 사이즈 + 페이지수
		//_booksize.text = _book_info.cm;
		NSArray *arr_book_info_cm = [_book_info.cm componentsSeparatedByString:@" ("];
		if(arr_book_info_cm.count > 1) {
			@try {
				_booksize.text = [NSString stringWithFormat:@"%@", arr_book_info_cm[0]];
			}
			@catch(NSException *exception) {}
			@try {
				[_pagecount_button setTitle:[[NSString stringWithFormat:@"%@", arr_book_info_cm[1]] stringByReplacingOccurrencesOfString:@")" withString:@""] forState:UIControlStateNormal];
			}
			@catch(NSException *exception) {}
		}
		else {
			_booksize.text = _book_info.cm;
		}

        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:6];

		if ([Common info].connection.polaroidRecvInfo != nil && [Common info].connection.polaroidRecvInfo.length > 0)
		{
			productmsg = [Common info].connection.polaroidRecvInfo;
		}
		else if ([Common info].connection.podRecvInfo != nil && [Common info].connection.podRecvInfo.length > 0)
		{
			productmsg = [Common info].connection.podRecvInfo;
		}

        if (productmsg.length > 0) {
            //NSString *temp_msg = [NSString stringWithFormat:@"(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
            NSString *temp_msg = @"(3만원 이상 무료)";
            productmsg = [productmsg stringByReplacingOccurrencesOfString:@"입니다." withString:@""];
            productmsg = [NSString stringWithFormat:@"%@\nD+3(토,일 제외)%@", productmsg, temp_msg];
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
    vc.product_type = PRODUCT_MAGNET;
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

- (IBAction)selectOption1:(id)sender {
	_option_button1.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];;
	_option_button2.backgroundColor = [UIColor whiteColor];
	[Common info].photobook.ProductCode = @"403001";
}

- (IBAction)selectOption2:(id)sender {
	_option_button1.backgroundColor = [UIColor whiteColor];
	_option_button2.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];;
	[Common info].photobook.ProductCode = @"403002";
}

@end
