//
//  CardDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "CardDetailViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "CardEditTableViewController.h"

@interface CardDetailViewController ()

@end

@implementation CardDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"CardDetail"];
    
    _scodix_idx = 0;
    _option_idx = 0;
    
    if ([[Common info].deeplink_url containsString:@"mobile_photocard_xmas"]
        || [[Common info].deeplink_url containsString:@"mobile_photocard_thanks"]
        || [[Common info].deeplink_url containsString:@"mobile_photocard_love"]
        || [[Common info].deeplink_url containsString:@"mobile_photocard_newyear"]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [Common info].deeplink_url= nil;
    }

	if(_selected_theme.sel_options2.count <= 0) {
		_scodix_title.hidden = YES;
		_scodix_button.hidden = YES;
		_scodix_select.hidden = YES;

		_constraint_option_1.constant -= 38;
		_constraint_option_2.constant -= 38;
		_constraint_option_3.constant -= 38;

		_constraint_delivery_1.constant -= 38;
		_constraint_delivery_2.constant -= 38;
	}
	if(_selected_theme.sel_options.count <= 0) {
		_option_title.hidden = YES;
		_option_button.hidden = YES;
		_option_select.hidden = YES;

		_constraint_delivery_1.constant -= 38;
		_constraint_delivery_2.constant -= 38;
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"CardDetail" ScreenClass:[self.classForCoder description]];
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
    if (_selected_theme != nil && _product_size.text.length <= 0) {
        NSAssert(_selected_theme.book_infos.count > 0, @"card's book_info is not founded");
        _book_info = _selected_theme.book_infos[0]; // 1개 only.
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
    }
}

- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = @"";
    vc.product_type = PRODUCT_CARD;
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
    CardEditTableViewController *vc = [segue destinationViewController];
    if (vc) {
		if(_selected_theme.sel_options.count > 0) [Common info].photobook.AddParams = [_option_button currentTitle];
		else [Common info].photobook.AddParams = @"";

		if(_selected_theme.sel_options2.count > 0) [Common info].photobook.ScodixParams = [_scodix_button currentTitle];
		else [Common info].photobook.ScodixParams = @"";

	    if ( [Common info].photobook.AddParams == nil ) [Common info].photobook.AddParams = @"";
	    if ( [Common info].photobook.ScodixParams == nil ) [Common info].photobook.ScodixParams = @"";
	    if ( [[Common info].photobook.AddParams isEqualToString:@"선택없음"] ) [Common info].photobook.AddParams = @"";
	    if ( [[Common info].photobook.ScodixParams isEqualToString:@"선택없음"] ) [Common info].photobook.ScodixParams = @"";

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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardDetailCell" forIndexPath:indexPath];
    
    if (_selected_theme != nil) {
        
		NSString *thumbname = _selected_theme.preview_thumbs[indexPath.row];
        
        NSString *url = [Common makeURLString:thumbname host:[Common info].photobook_theme.thumb_url];
		
		[[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
			if (succeeded) {
				UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
				imageview.image = [UIImage imageWithData:imageData];
			}
			else {
				NSLog(@"theme-detail's thumbnail_image is not downloaded.");
			}
		}];

		
        if(_selected_theme.sel_options2.count > 0) {
			SelectOption *sel_scodix = (SelectOption *)_selected_theme.sel_options2[_scodix_idx];
			[_scodix_button setTitle:sel_scodix.comment forState:UIControlStateNormal];
		}
		if(_selected_theme.sel_options.count > 0) {
			SelectOption *sel_option = (SelectOption *)_selected_theme.sel_options[_option_idx];
			[_option_button setTitle:sel_option.comment forState:UIControlStateNormal];
		}

        // 가격
        NSString *price = [[Common info] toCurrencyString:[_book_info.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[_book_info.discount intValue]];
        /*
        if (sel_scodix.price.length > 0) {
            price += [sel_scodix.price intValue];
            discount += [sel_scodix.price intValue];
        }
        if (sel_option.price.length > 0) {
            price += [sel_option.price intValue];
            discount += [sel_option.price intValue];
        }
        */

		_price.text = [NSString stringWithFormat:@"%@원", price];
        _discount.text = [NSString stringWithFormat:@"%@원", discount];
        _product_size.text = _book_info.cm;

        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        if (page_label != nil) {
            if (indexPath.row == 0)
                page_label.text = @"앞면";
            else if (indexPath.row == (_selected_theme.preview_thumbs.count-1))
                page_label.text = @"뒷면";
            else
                page_label.text = @"내지";
        }

        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:6];
        if (productmsg.length > 0) {
			NSString *temp_msg = [NSString stringWithFormat:@"(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
            productmsg = [productmsg stringByReplacingOccurrencesOfString:@"입니다." withString:@""];
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


- (IBAction)selectScodix:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options2.count; i++) {
        SelectOption *item = _selected_theme.sel_options2[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            _scodix_idx = i;
            
            [_collection_view reloadData];
            
            [_scodix_button setTitle:item.comment forState:UIControlStateNormal];
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
