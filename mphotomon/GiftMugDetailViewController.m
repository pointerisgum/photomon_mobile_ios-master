//
//  GiftMugDetailViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "GiftMugDetailViewController.h"
#import "ZoomViewController.h"
#import "WebpageViewController.h"
#import "GiftMugEditViewController.h"

@interface GiftMugDetailViewController ()

@end

@implementation GiftMugDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"GiftMugDetail"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"GiftMugDetail" ScreenClass:[self.classForCoder description]];
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
        NSAssert(_selected_theme.book_infos.count > 0, @"polaroid's book_info is not founded");
        _book_info = _selected_theme.book_infos[0]; // 1개 only.
        
        [[Common info].photobook initPhotobookInfo:_book_info ThemeInfo:_selected_theme];
    }
}

- (IBAction)popupDetail:(id)sender {
    ZoomViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPage"];
    vc.selected_theme = _selected_theme;
    vc.option_str = @"";
    vc.product_type = PRODUCT_MUG;
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
    GiftMugEditViewController *vc = [segue destinationViewController];
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MugDetailCell" forIndexPath:indexPath];
    
    if (_selected_theme != nil) {
        
        /*if (indexPath.row == 0) {
            NSString *thumbname = [NSString stringWithFormat:@"preview_%@_%@_full_%02d.jpg", _selected_theme.theme2_id, _option_str, (int)indexPath.row+1];
            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
            //NSLog(@"thumb0:%@", fullpath);
            
            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *imageData = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url]];
            if (imageData != nil) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"theme-detail's thumbnail_image is not downloaded.");
            }
        }
        else*/ {
            NSString *thumbname = _selected_theme.preview_thumbs[indexPath.row];
            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
            //NSLog(@"thumb~:%@", fullpath);
            
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
        }
        
        // 페이지라벨
        UILabel *page_label = (UILabel *)[cell viewWithTag:500];
        page_label.text = @"";

        // 가격
        NSString *price = [[Common info] toCurrencyString:[_book_info.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[_book_info.discount intValue]];
        _price.text = [NSString stringWithFormat:@"%@원", price];
        _discount.text = [NSString stringWithFormat:@"%@원", discount];

        // 사이즈/용량/재질
        NSArray *tempArray = [_book_info.cm componentsSeparatedByString:@"("];
        NSString *mug_size = tempArray[0];
        NSString *mug_ml = tempArray[1];
        mug_ml = [mug_ml substringWithRange:NSMakeRange(0, mug_ml.length-1)];

        _product_size.text = mug_size;
        _ml.text = mug_ml;
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

@end
