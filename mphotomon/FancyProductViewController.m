//
//  FancyProductViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2018. 1. 30..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import "FancyProductViewController.h"
#import "FancyDivisionDetailViewController.h"
#import "FancyDesignViewController.h"
#import "WebpageViewController.h"
#import "PhotobookStorageViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "MainTabBar.h"

@interface FancyProduct ()
@end
@implementation FancyProduct
@end


@interface FancyProductViewController ()<MainTabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *tabBaseview;
@property (strong, nonatomic) MainTabBar *tabBar;

@end

@implementation FancyProductViewController

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
    
    self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tabBaseview.bounds naviIndex:8 delegate:self];
    
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
        
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_fancy"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_fancymain"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_namesticker"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_divisionsticker"].location != NSNotFound) {
            if ( [[Common info].deeplink_url rangeOfString:@"mobile_fancy"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_fancymain"].location != NSNotFound ) {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [Common info].deeplink_url= nil;
            }
            else {
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                deeplink_imageview = [[Common info] showDeepLinkLaunchScreen:self.view];
            }
        }
    }
    // 딥링크 관련 코드 ----------------------------------
    
    [Common info].fancy_root_controller = self;
    [self loadFancyProduct];

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
        else if([[Common info].deeplink_url rangeOfString:@"mobile_divisionsticker"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"433001"];
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
    [super viewWillAppear:animated];
    [self.tabBar updateCollectionViewOffset];

}

- (void)viewDidLayoutSubviews {
    
}

    
// 딥링크 관련 코드
- (int)getIdxOfProduct:(NSString *)productCode {
    int idx = 0;
    for( int i = 0 ; i < _fancy_products.count ; i++ )
    {
        FancyProduct* product = _fancy_products[i];
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

- (void)loadFancyProduct {
    if (_fancy_products != nil) {
        [_fancy_products removeAllObjects];
    }
    _fancy_products = [[NSMutableArray alloc] init];
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(URL_FANCY_PRODUCT, nil)]];
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
    if ([segue.identifier isEqualToString:@"FancyNameStickerSegue"]) {
        FancyDesignViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            
            
            // 딥링크 관련 코드
            long idx = indexPath.row;
            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            FancyProduct *product = _fancy_products[idx];
            
            if([product.pid isEqualToString:@"namesticker"]){
                vc.product_type = PRODUCT_NAMESTICKER;
            }
            else if([product.pid isEqualToString:@"divisionsticker"]){
                vc.product_type = PRODUCT_DIVISIONSTICKER;
            }
            
            
            NSLog(@"selected product:%@", product.productname);
        }
    }
    
}
- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    //[self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotobookStorageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"stid-PhotobookStorageVC"];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fancy_products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FancyProductCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    FancyProduct *product = _fancy_products[indexPath.row];
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
    FancyProduct *product = _fancy_products[indexPath.row];
    
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
        if ([product.pid isEqualToString:@"namesticker"] || [product.pid isEqualToString:@"divisionsticker"]) {
            [self performSegueWithIdentifier:@"FancyNameStickerSegue" sender:self];
        }
        /*if ([product.pid isEqualToString:@"divisionsticker"]) {
            [self performSegueWithIdentifier:@"FancyDivisionStickerSegue" sender:self];
        }*/
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
        
        FancyProduct *product = [[FancyProduct alloc] init];
        
        product.idx = [attributeDict objectForKey:@"idx"];
        product.pid = [attributeDict objectForKey:@"id"];
        product.thumb = [attributeDict objectForKey:@"thumb"];
        product.productname = [attributeDict objectForKey:@"productname"];
        product.productcode = [attributeDict objectForKey:@"productcode"]; // SJYANG : 기프트에서 productcode property 처리
        product.price = [attributeDict objectForKey:@"minprice"];
        product.discount = [attributeDict objectForKey:@"discountminprice"];
        product.openurl = [attributeDict objectForKey:@"openurl"];
        product.webviewurl = [attributeDict objectForKey:@"webviewurl"];

        [_fancy_products addObject:product];
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
    FancyProduct *product = _fancy_products[indexPath.row];
    
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

@end
