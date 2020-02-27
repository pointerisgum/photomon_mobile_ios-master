//
//  CardProductViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "CardProductViewController.h"
#import "ProductTableViewController.h"
#import "WebpageViewController.h"
#import "Common.h"
#import "CardDesignViewController.h"
#import "FrameWebViewController.h"
#import "MainTabBar.h"

@interface CardProduct ()
@end
@implementation CardProduct
@end


@interface CardProductViewController () <MainTabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *tabBaseview;
@property (strong, nonatomic) MainTabBar *tabBar;
@end

@implementation CardProductViewController

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
    
    self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tabBaseview.bounds naviIndex:5 delegate:self];
    
    [self.tabBaseview addSubview:self.tabBar];

	// 딥링크 관련 코드 ----------------------------------
	[[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
                                                      [self dismissViewControllerAnimated:NO completion:nil];
                                                  }];

	[Analysis log:@"CardProduct"];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"보관함" style:UIBarButtonItemStylePlain target:self action:@selector(goStorage)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    deeplink_idx = -1;

    [self loadCardProduct];
    // 딥링크 관련 코드 ----------------------------------
    if([Common info].deeplink_url != nil) {
        
        if ([[Common info].deeplink_url containsString:@"mobile_photocard_xmas"]){
            int idx = [self getIdxOfProduct:@"376001"];
            if (idx > -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url containsString:@"mobile_photocard_thanks"]){
            int idx = [self getIdxOfProduct:@"378015"];
            if (idx > -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url containsString:@"mobile_photocard_love"]){
            int idx = [self getIdxOfProduct:@"434001"];
            if (idx > -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url containsString:@"mobile_photocard_newyear"]){
            int idx = [self getIdxOfProduct:@"377001"];
            if (idx > -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url containsString:@"mobile_photocardmain"]
                 || [[Common info].deeplink_url rangeOfString:@"mobile_photocard"].location != NSNotFound
                 ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
        }
        
        if(deeplink_idx != -1) {
            [UIView setAnimationsEnabled:NO];
            [self performSegueWithIdentifier:@"CardDesignSegue" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];
                [UIView setAnimationsEnabled:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [Analysis firAnalyticsWithScreenName:@"CardProduct" ScreenClass:[self.classForCoder description]];
    [self.tabBar updateCollectionViewOffset];

}
- (void)viewDidLayoutSubviews {

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[Common info].card_root_controller = nil;
    [Common info].card_product_root_controller = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCardProduct {
    if (_products != nil) {
        [_products removeAllObjects];
    }
    _products = [[NSMutableArray alloc] init];
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(URL_CARD_PRODUCT, nil)]];
    if (ret_val != nil) {
        //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        //NSLog(@">> photobook product info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return;
        }
    }
    [_collection_view reloadData];
}

// 딥링크 관련 코드
- (int)getIdxOfProduct:(NSString *)productCode {
    int idx = 0;
    for( int i = 0 ; i < _products.count ; i++ )
    {
        GiftProduct* product = _products[i];
        if ( [product.productcode isEqualToString:productCode] )
            return(idx);
        idx++;
    }
    return(-1);
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CardDesignSegue"]) {
        CardDesignViewController *vc = (CardDesignViewController *)[segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            
            int idx = indexPath.row;
            
            if (deeplink_idx > -1) {
                idx = deeplink_idx;
            }

            CardProduct *product = _products[idx];
            vc.product_code = product.productcode;
            vc.product_id = product.pid;
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardProductCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    CardProduct *product = _products[indexPath.row];

	if (product) {
		NSString *intnum = @"";
		NSString *seqnum = @"";

		NSString *product_code = product.productcode;
		if (product_code.length == 6) {
			intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
			seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
		}

		NSString *fullpath = [NSString stringWithFormat:@"%@%@", URL_PRODUCT_THUMB_PATH, product.thumb];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];

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
    
    CardProduct *product = _products[indexPath.row];

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
    if(!bOpen)
        [self performSegueWithIdentifier:@"CardDesignSegue" sender:self];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    return CGSizeMake(width, height + 40);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"product"]) {
        
        CardProduct *product = [[CardProduct alloc] init];

        product.idx = [attributeDict objectForKey:@"idx"];
        product.pid = [attributeDict objectForKey:@"id"];
        product.thumb = [attributeDict objectForKey:@"thumb"];
        product.productname = [attributeDict objectForKey:@"productname"];
        product.productcode = [attributeDict objectForKey:@"productcode"];
        product.price = [attributeDict objectForKey:@"minprice"];
        product.discount = [attributeDict objectForKey:@"discountminprice"];
        product.openurl = [attributeDict objectForKey:@"openurl"];
        product.webviewurl = [attributeDict objectForKey:@"webviewurl"];

        [_products addObject:product];
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

    CardProduct *product = _products[indexPath.row];

    NSString *intnum = @"";
    NSString *seqnum = @"";

    NSString *product_code = product.productcode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

	[self popupDetailPage:intnum];
}

- (void)popupDetailPage:(NSString *)intnum {
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, @""];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
