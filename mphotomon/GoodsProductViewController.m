//
//  GoodsProductViewController.m
//  PHOTOMON
//
//  Created by 안영건 on 29/04/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "GoodsProductViewController.h"
#import "WebpageViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "GoodsFanbookDesignViewController.h"
#import "GoodsPaperSloganDesignViewController.h"
#import "SingleCardDetailViewController.h"
#import "MainTabBar.h"

@implementation GoodsProduct
@end

@interface GoodsProductViewController ()<MainTabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *tabBaseview;
@property (strong, nonatomic) MainTabBar *tabBar;

@end

@implementation GoodsProductViewController

// 딥링크 관련 코드
static int deeplink_idx = -1;
static UIImageView* deeplink_imageview;

- (void)didTouchTabBarWithNaviIndex:(int)index {
    
    [self dismissViewControllerAnimated:false completion:^{
        [Common info].mainTabBarOffset = [self.tabBar collectionViewOffset];
        [[Common info].main_controller moveToTargetTabBar:index];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tabBaseview.bounds naviIndex:6 delegate:self];
    
    [self.tabBaseview addSubview:self.tabBar];


    // 딥링크 관련 코드 ----------------------------------
    deeplink_idx = -1;
    deeplink_imageview = nil;

    [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self dismissViewControllerAnimated:NO completion:nil];
                                                  }];
    if([Common info].deeplink_url != nil) {
        //[[Common info] alert:self Msg:[Common info].deeplink_url];

        if ( [[Common info].deeplink_url rangeOfString:@"mobile_fanbook"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_poster"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_paperslogan"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_transparentcard"].location != NSNotFound) {
            
            if ( [[Common info].deeplink_url rangeOfString:@"mobile_transparentcard"].location != NSNotFound) {
                [[Common info].photobook_theme.themes removeAllObjects];
                [[Common info].photobook_theme loadTheme:PRODUCT_DESIGNPHOTO];
/*
// 기존 투명 포토카드 관련 딥링크는 주석으로 두고 투명 포토카드(편집대행)으로 변경해본다.
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoCard24" bundle:nil];
                SingleCardDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"designPhotoDetailViewController"];

                if (vc) {
//                    vc.selected_theme = [Common info].photobook_theme.themes[0];
                    vc.selected_theme = [self findTheme:@"Photocard" theme2ID:@"DefaultTheme"];
                    for (BookInfo *bi in vc.selected_theme.book_infos) {
                        if ([bi.productcode isEqualToString:@"347062"]) {
                            vc.cardType = bi.cardType;
                            [[Common info].photobook initPhotobookInfo:bi ThemeInfo:vc.selected_theme];
                            vc.selected_theme.productcode = bi.productcode;
                            vc.selected_theme.price = bi.price;
                            vc.selected_theme.discount = bi.discount;
                            break;
                        }
                    }
//                [vc updateTheme];
                
                }
                [self.navigationController pushViewController:vc animated:YES];
 */
                Theme *theme = [self findTheme:@"defaultdepth1" theme2ID:@"DefaultTheme"];
                
                FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
                frameWebView.webviewUrl = theme.webviewurl;
                [self presentViewController:frameWebView animated:YES completion:nil];
            }
            else {
                if ([[Common info].deeplink_url rangeOfString:@"mobile_fanbook"].location != NSNotFound) {
                    [self performSegueWithIdentifier:@"GoodsFanbook" sender:self];
                } else if ([[Common info].deeplink_url rangeOfString:@"mobile_poster"].location != NSNotFound) {
                    [self performSegueWithIdentifier:@"GoodsPoster" sender:self];
                } else if ([[Common info].deeplink_url rangeOfString:@"mobile_paperslogan"].location != NSNotFound) {
                    [self performSegueWithIdentifier:@"GoodsPaperSlogan" sender:self];
                }
            }
        }
    }
    // 딥링크 관련 코드 ----------------------------------

    [Common info].goods_root_controller = self;
    [self loadGoodsProduct];

    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ([[Common info].deeplink_url rangeOfString:@"mobile_namesticker"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"394001"];
            if(idx != -1) {
                deeplink_idx = idx;
                [UIView setAnimationsEnabled:NO];
                [self performSegueWithIdentifier:@"FancyNameStickerSegue" sender:self];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];
                    [UIView setAnimationsEnabled:YES];
                    [self.navigationController setNavigationBarHidden:NO animated:NO];
                });
            }
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [self.tabBar updateCollectionViewOffset];
}
- (void)viewDidLayoutSubviews {
    
}
// 딥링크 관련 코드
- (int)getIdxOfProduct:(NSString *)productCode {
    int idx = 0;
    for( int i = 0 ; i < _goods_products.count ; i++ )
    {
        GoodsProduct* product = _goods_products[i];
        if ( [product.productcode isEqualToString:productCode] )
            return(idx);
        idx++;
    }
    return(-1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadGoodsProduct {
    if (_goods_products != nil) {
        [_goods_products removeAllObjects];
    }
    _goods_products = [[NSMutableArray alloc] init];

    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(URL_GOODS_PRODUCT, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook product info xml: %@", data);

        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return;
        }
    }
    [_collection_view reloadData];
    
    if ([Common info].deeplink_url != nil) {
        if ([[Common info].deeplink_url rangeOfString:@"mobile_goodsphotocard"].location != NSNotFound) {
            
            [self collectionView:self.collection_view didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            [Common info].deeplink_url = nil;
        }

    }
}

- (Theme *)findTheme:(NSString *)theme1ID theme2ID:(NSString *)theme2ID {
    Theme *ret = nil;
    for (Theme *theme in [Common info].photobook_theme.themes){
        if ([theme.theme1_id isEqualToString:theme1ID] && [theme.theme2_id isEqualToString:theme2ID]){
            ret = theme;
            break;
        }
    }
    return ret;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GoodsFanbook"]) {
        GoodsFanbookDesignViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.product_type = PRODUCT_FANBOOK;

            // 딥링크 관련 코드
            long idx = indexPath.row;
            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            GoodsProduct *product = _goods_products[idx];

            NSLog(@"selected product:%@", product.productname);
        }
    } else if ([segue.identifier isEqualToString:@"GoodsPoster"]) {
        GoodsPosterDesignViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.product_type = PRODUCT_POSTER;

            // 딥링크 관련 코드
            long idx = indexPath.row;
            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            GoodsProduct *product = _goods_products[idx];

            NSLog(@"selected product:%@", product.productname);
        }
    } else if ([segue.identifier isEqualToString:@"GoodsPaperSlogan"]) {
        GoodsPaperSloganDesignViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.product_type = PRODUCT_PAPERSLOGAN;

            // 딥링크 관련 코드
            long idx = indexPath.row;
            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            GoodsProduct *product = _goods_products[idx];

            NSLog(@"selected product:%@", product.productname);
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _goods_products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GoodsProductCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;

    GoodsProduct *product = _goods_products[indexPath.row];
    if (product) {
        NSString *fullpath = [NSString stringWithFormat:@"%@%@", URL_PRODUCT_THUMB_PATH, product.thumb];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];

                // SJYANG
                // 기프트에서 상세보기 버튼 처리
                UIButton *detail_btn = (UIButton *)[cell viewWithTag:101];
                CGRect frame = detail_btn.frame;
                frame.origin.x = imageview.frame.origin.x + imageview.frame.size.width - frame.size.width;
                frame.origin.y = imageview.frame.origin.y + imageview.frame.size.height - frame.size.height;
                detail_btn.frame = frame;
            }
            else {
                NSLog(@"theme's thumbnail_image is not downloaded.");
            }
        }];

        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        UILabel *label2 = (UILabel *)[cell viewWithTag:103];
        UILabel *label3 = (UILabel *)[cell viewWithTag:104];

        label1.text = product.productname;
        label2.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[product.price intValue]]];
        label3.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[product.discount intValue]]];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodsProduct *product = _goods_products[indexPath.row];

    BOOL bOpen = NO;
    if (product != nil && product.openurl != nil && ![product.openurl isEqualToString:@""]) {
        bOpen = YES;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:product.openurl]];
    }
    if (product != nil && product.webviewurl != nil && ![product.webviewurl isEqualToString:@""]) {
        bOpen = YES;
        FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
        frameWebView.webviewUrl = product.webviewurl;
        [self presentViewController:frameWebView animated:YES completion:nil];
    }
    if(!bOpen){
        if ([product.pid isEqualToString:@"fanbook"]) {
            [self performSegueWithIdentifier:@"GoodsFanbook" sender:self];
        } else if ([product.pid isEqualToString:@"poster"]) {
            [self performSegueWithIdentifier:@"GoodsPoster" sender:self];
        } else if ([product.pid isEqualToString:@"Paperslogan"]) {
            [self performSegueWithIdentifier:@"GoodsPaperSlogan" sender:self];
        } else if ([product.pid isEqualToString:@"Photocard"]) {
            [[Common info].photobook_theme.themes removeAllObjects];
            [[Common info].photobook_theme loadTheme:PRODUCT_DESIGNPHOTO];

            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoCard24" bundle:nil];
            SingleCardDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"designPhotoDetailViewController"];

            if (vc) {
//                vc.selected_theme = [Common info].photobook_theme.themes[0];
                vc.selected_theme = [self findTheme:product.pid theme2ID:@"DefaultTheme"];
                for (BookInfo *bi in vc.selected_theme.book_infos) {
                    if ([bi.productcode isEqualToString:product.productcode]) {
                        vc.cardType = bi.cardType;
                        [[Common info].photobook initPhotobookInfo:bi ThemeInfo:vc.selected_theme];
                        vc.selected_theme.productcode = bi.productcode;
                        vc.selected_theme.price = bi.price;
                        vc.selected_theme.discount = bi.discount;
                        break;
                    }
                }
//                [vc updateTheme];
            }
            [self.navigationController pushViewController:vc animated:YES];
        }

    }


}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4

    return CGSizeMake(width, height + 40);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if ([elementName isEqualToString:@"product"]) {

        GoodsProduct *product = [[GoodsProduct alloc] init];

        product.idx = [attributeDict objectForKey:@"idx"];
        product.pid = [attributeDict objectForKey:@"id"];
        product.thumb = [attributeDict objectForKey:@"thumb"];
        product.productname = [attributeDict objectForKey:@"productname"];
        product.productcode = [attributeDict objectForKey:@"productcode"]; // SJYANG : 기프트에서 productcode property 처리
        product.price = [attributeDict objectForKey:@"minprice"];
        product.discount = [attributeDict objectForKey:@"discountminprice"];
        product.openurl = [attributeDict objectForKey:@"openurl"];
        product.webviewurl = [attributeDict objectForKey:@"webviewurl"];

        [_goods_products addObject:product];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    GoodsProduct *product = _goods_products[indexPath.row];

    NSString *product_code = product.productcode;
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
