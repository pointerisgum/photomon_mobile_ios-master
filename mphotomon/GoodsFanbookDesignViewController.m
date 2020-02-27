//
//  GoodsFanbookDesignViewController.m
//  PHOTOMON
//
//  Created by 안영건 on 02/05/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "GoodsFanbookDesignViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "WebpageViewController.h"
#import "GoodsFanbookDetailViewController.h"

@interface GoodsFanbookDesignViewController () {
    BOOL retainViewController;
}

@end

@implementation GoodsFanbookDesignViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_namesticker"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
        }
    }

    [Common info].fanbook_root_controller = self;

    [Analysis log:@"Fanbook"];

    [self loadFanbookTheme];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    retainViewController = NO;
    [Analysis firAnalyticsWithScreenName:@"Fanbook" ScreenClass:[self.classForCoder description]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!retainViewController) {
        [Common info].fanbook_root_controller = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFanbookTheme {
    [[Common info].photobook_theme.themes removeAllObjects];
    if ([[Common info].photobook_theme loadTheme:_product_type]) {
        if (_product_type == PRODUCT_FANBOOK) {
            int theme_count = (int)[Common info].photobook_theme.themes.count;
            for (int i = theme_count-1; i >= 0; i--) {
                Theme *theme = [Common info].photobook_theme.themes[i];
                if (![theme.theme1_id isEqualToString:@"fanbook"]) {
                    [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                }
            }
        }
    }
    [_collection_view reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    retainViewController = YES;
    if ([segue.identifier isEqualToString:@"FanbookDetailSegue"]) {
        GoodsFanbookDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.selected_theme = [Common info].photobook_theme.themes[indexPath.row];
            [vc updateTheme];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook_theme.themes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GoodsFanbookCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;

    Theme *theme = [Common info].photobook_theme.themes[indexPath.row];
    if (theme) {
        NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, theme.main_thumb];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"theme's thumbnail_image is not downloaded.");
            }
        }];

        NSString *price = [[Common info] toCurrencyString:[theme.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[theme.discount intValue]];

        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        label1.text = theme.theme_name;
        if (_product_type == PRODUCT_FANBOOK) {
            UILabel *label2 = (UILabel *)[cell viewWithTag:103];
            label2.text = [NSString stringWithFormat:@"%@원", price];

            UILabel *label3 = (UILabel *)[cell viewWithTag:104];
            label3.text = [NSString stringWithFormat:@"%@원", discount];
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Theme *theme = [Common info].photobook_theme.themes[indexPath.row];
    BOOL bOpen = NO;
    if (theme != nil && theme.openurl != nil && ![theme.openurl isEqualToString:@""]) {
        bOpen = YES;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theme.openurl]];
    }
    if (theme != nil && theme.webviewurl != nil && ![theme.webviewurl isEqualToString:@""]) {
        bOpen = YES;
        FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
        frameWebView.webviewUrl = theme.webviewurl;
        [self presentViewController:frameWebView animated:YES completion:nil];
    }
    if(!bOpen){

        if (_product_type == PRODUCT_FANBOOK) {
            [self performSegueWithIdentifier:@"FanbookDetailSegue" sender:self];
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4

    return CGSizeMake(width, height + 40);
}

- (IBAction)popupMore:(id)sender {
    UICollectionViewCell* cell ;
    UIButton* button = (UIButton*)sender;
    NSIndexPath *indexPath;

    @try {
        cell = (UICollectionViewCell*)[[button superview]superview];
        indexPath = [_collection_view indexPathForCell:cell];
    }
    @catch (NSException *e) {
        @try {
            cell = (UICollectionViewCell*)[[[button superview]superview]superview];
            indexPath = [_collection_view indexPathForCell:cell];
        }
        @catch (NSException *e) {
            cell = (UICollectionViewCell*)[button superview];
            indexPath = [_collection_view indexPathForCell:cell];
        }
    }

    NSString *intnum = @"";
    NSString *seqnum = @"";
    Theme *theme = [Common info].photobook_theme.themes[indexPath.row];
    BookInfo *bookinfo = theme.book_infos[0];
    NSString *product_code = bookinfo.productcode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

@end
