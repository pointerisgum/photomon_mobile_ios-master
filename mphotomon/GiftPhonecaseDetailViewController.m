//
//  GiftPhonecaseDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "GiftPhonecaseDetailViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "GiftPhonecaseEditViewController.h"
#import "UIView+Toast.h"

@interface GiftPhonecaseDetailViewController ()

@end

@implementation GiftPhonecaseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"GiftPhonecaseDetail"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"GiftPhonecaseDetail" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submit:)];
    tap.numberOfTapsRequired = 1;
    [_done_button setUserInteractionEnabled:YES];
    [_done_button addGestureRecognizer:tap];

    [self setTitle:_selected_theme.theme_name];
    [self updateTheme];

    _design.hidden = YES;
    _design_title.hidden = YES;
    _design_btn.hidden = YES;
    _constraint_material_top_space.constant = 8;
    _constraint_material_title_top_space.constant = 8;

	{
	    SelectOption *item = _selected_theme.sel_options[0];
		[_device setTitle:item.comment forState:UIControlStateNormal];
	}
    if(_selected_theme.sel_options2.count > 0) {
        _design.hidden = NO;
        _design_title.hidden = NO;
        _design_btn.hidden = NO;
        _constraint_material_top_space.constant = 48;
        _constraint_material_title_top_space.constant = 48;
		{
			SelectOption *item = _selected_theme.sel_options2[0];
			[_design setTitle:item.comment forState:UIControlStateNormal];
		}
    }

    // 솜사탕(363001 / 360009), 비누방울(363015 / 360007) : 비편집상품
    if([Common info].photobook.minpictures == 0) {
		[_done_button setTitle:@"주문하기" forState:UIControlStateNormal];
	}
	else {
		[_done_button setTitle:@"폰케이스 만들기" forState:UIControlStateNormal];
	}
}

- (void)updateTheme {
    if (_selected_theme != nil) {
        NSAssert(_selected_theme.book_infos.count > 0, @"polaroid's book_info is not founded");
        _book_info = _selected_theme.book_infos[0]; // 1개 only.

        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
    }
}

- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = @"";
    vc.product_type = PRODUCT_PHONECASE;
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
    GiftPhonecaseEditViewController *vc = [segue destinationViewController];
    if (vc) {
        vc.is_new = YES;

        NSString *deviceval = _device.titleLabel.text;
        NSString *designval = _design.titleLabel.text;
        if([deviceval isEqualToString:@"선택없음"])
            deviceval = @"";
        if([designval isEqualToString:@"선택없음"])
            designval = @"";

		// 테스트 코드
		/*
        if(![deviceval isEqualToString:@""])
            designval = @"brown";
		*/

        [Common info].photobook.Size = deviceval;
        [Common info].photobook.Color = designval;
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhonecaseDetailCell" forIndexPath:indexPath];
    
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
        _material.text = _book_info.material;
        
        // 배송 메시지
        NSString *productmsg = [[Common info].connection productMsg:6];
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

- (IBAction)selectOption:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options.count; i++) {
        SelectOption *item = _selected_theme.sel_options[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [_device setTitle:item.comment forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)selectOption2:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
    for (int i = 0; i < _selected_theme.sel_options2.count; i++) {
        SelectOption *item = _selected_theme.sel_options2[i];
        alert_action = [UIAlertAction actionWithTitle:item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [_design setTitle:item.comment forState:UIControlStateNormal];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }];
        [vc addAction:alert_action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)submit:(id)sender {
    if([Common info].photobook.minpictures == 0) {
		[self performSegueWithIdentifier:@"PhotoEditSegue" sender:self];
	}
	else {
        
        //MAcheck
        [[Common info]alert:self Title:@"\"%@\" 폰케이스를 만드시겠습까?" Msg:@"" okCompletion:^{
            [self performSegueWithIdentifier:@"PhotoEditSegue" sender:self];

        } cancelCompletion:^{
            
        } okTitle:@"네" cancelTitle:@"아니오" ];
        	}
}

@end
