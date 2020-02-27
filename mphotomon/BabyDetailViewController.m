//
//  BabyDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "BabyDetailViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "BabyEditViewController.h"

@interface BabyDetailViewController ()

@end

@implementation BabyDetailViewController

static BOOL infoOpened = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"BabyDetail"];
	{
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPopupInfo:)];
		tap.cancelsTouchesInView = YES;
		tap.numberOfTapsRequired = 1;
		[_info_btn setUserInteractionEnabled:YES];
		[_info_btn addGestureRecognizer:tap];
	}
	/*
	{
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupInfo:)];
		tap.cancelsTouchesInView = YES;
		tap.numberOfTapsRequired = 1;
		[_info_close_btn setUserInteractionEnabled:YES];
		[_info_close_btn addGestureRecognizer:tap];
	}
	*/
	/*
	{
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupInfo:)];
		tap.cancelsTouchesInView = YES;
		tap.numberOfTapsRequired = 1;
		[_info_popup_webview setUserInteractionEnabled:YES];
		[_info_popup_webview addGestureRecognizer:tap];
	}
	*/

//    _constraint_contentview_width.constant = self.view.frame.size.width;
	_constraint_info_btn_leading_space.constant = (self.view.frame.size.width - 167) / 2;
	_constraint_info_popup_width.constant = self.view.frame.size.width * 0.95;
	_constraint_info_popup_leading_space.constant = (self.view.frame.size.width - _constraint_info_popup_width.constant) / 2;
//    _constraint_view_height.constant = self.view.frame.size.height - _constraint_top_margin.constant - 40;
	NSLog(@"_constraint_view_height.constant : %f", _constraint_view_height.constant);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"BabyDetail" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
	[self setTitle:_selected_theme.theme_name];
	_info_popup_view.hidden = YES;
	_page_control.hidden = YES;

	[self updateTheme];
}

- (void)updateTheme {
    if (_selected_theme != nil && _product_size.text.length <= 0) {
        NSAssert(_selected_theme.book_infos.count > 0, @"polaroid's book_info is not founded");
        _book_info = _selected_theme.book_infos[0]; // 1개 only.
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
    }
}

- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = @"";
    vc.product_type = PRODUCT_BABY;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BabyEditViewController *vc = [segue destinationViewController];
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
		if(_page_control.numberOfPages > 1)
			_page_control.hidden = NO;
        return _selected_theme.preview_thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BabyDetailCell" forIndexPath:indexPath];

    if (_selected_theme != nil) {
        
		NSString *thumbname = _selected_theme.preview_thumbs[indexPath.row];
		NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
		
		NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
			if (succeeded) {
				UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
				imageview.image = [UIImage imageWithData:imageData];
			}
			else {
				NSLog(@"theme-detail's thumbnail_image is not downloaded.");
			}
		}];
        
        // 페이지라벨
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        page_label.text = @"";

        // 가격
        NSString *price = [[Common info] toCurrencyString:[_book_info.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[_book_info.discount intValue]];
		_price.text = [NSString stringWithFormat:@"%@원", price];
		_discount.text = [NSString stringWithFormat:@"%@원", discount];
		if([_book_info.price intValue] == [_book_info.discount intValue]) {
			_price_strike.hidden = YES;
			_discount.hidden = YES;
		}

        // 사이즈/용량/재질
        _product_size.text = _book_info.cm;
		_minpictures.text = [NSString stringWithFormat:@"%@장 (정면 전신 or 앉아있는사진)", _book_info.minpictures];
        _material.text = _book_info.material;
        _basicset.text = _book_info.component;
        
        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:3];
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
    //CGFloat height = width / 2.0f + 16;
    CGFloat height = width / 2.0f;
    
    return CGSizeMake(width, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _collection_view.frame.size.width;
    int page = floor((_collection_view.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    
    _page_control.currentPage = page;
}

- (IBAction)openPopupInfo:(id)sender {
	infoOpened = YES;
	_collection_view.userInteractionEnabled = NO;
	_information_btn.userInteractionEnabled = NO;
	_zoom_btn.userInteractionEnabled = NO;
	_info_popup_view.userInteractionEnabled = YES;
	_info_close_btn.userInteractionEnabled = YES;
	NSLog(@"openPopupInfo");
    NSString *product_code = [Common info].photobook.ProductCode;
    NSString *intnum = @"";
    NSString *seqnum = @"";
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_OPTION_POPUP, intnum, seqnum, @"", [Common info].device_uuid];

	_info_popup_view.layer.zPosition = 10000;
	_info_close_btn.layer.zPosition = 10010;
	_info_popup_view.hidden = NO;

    NSURL *nsurl = [[NSURL alloc] initWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nsurl];
    [_info_popup_webview loadRequest:request];
    [_info_popup_webview reload];
}

- (IBAction)closePopupInfo:(id)sender {
	NSLog(@"closePopupInfo");

	_collection_view.userInteractionEnabled = YES;
	_information_btn.userInteractionEnabled = YES;
	_zoom_btn.userInteractionEnabled = YES;

	if(infoOpened == NO) return;
	infoOpened = NO;
	_info_popup_view.hidden = YES;
}

@end
