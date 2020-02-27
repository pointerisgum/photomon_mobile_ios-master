//
//  BabyProductListViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 22/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "BabyProductListViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "WebpageViewController.h"
#import "MonthlyBaby/MonthlyBabyWebViewController.h"
#import "MainTabBar.h"

@interface BabyProduct ()
@end
@implementation BabyProduct
@end

@interface BabyProductListViewController ()<MainTabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *tabBaseview;
@property (strong, nonatomic) MainTabBar *tabBar;

@end

@implementation BabyProductListViewController

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
    // Do any additional setup after loading the view.
	
	self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tabBaseview.bounds naviIndex:7 delegate:self];
	
	[self.tabBaseview addSubview:self.tabBar];
	
    // 딥링크 관련 코드 ----------------------------------
    [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self dismissViewControllerAnimated:NO completion:nil];
                                                  }];
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_babymain"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
        }
		else {
			[self.navigationController setNavigationBarHidden:YES animated:YES];
			deeplink_imageview = [[Common info] showDeepLinkLaunchScreen:self.view];
		}
    }
//     딥링크 관련 코드 ----------------------------------
//
	if ([Common info].deeplink_url != nil) {
		[UIView setAnimationsEnabled:NO];
		[self performSegueWithIdentifier:@"MonthlyBabySegue" sender:self];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];
			[UIView setAnimationsEnabled:YES];
		});
	}
	
    [Analysis log:@"BabyProduct"];
	
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"보관함" style:UIBarButtonItemStylePlain target:self action:@selector(goStorage)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self loadProduct];
}

- (void)viewDidLayoutSubviews {
	[self.tabBar updateCollectionViewOffset];
	
}

- (void)loadProduct {
    if (_products != nil) {
        [_products removeAllObjects];
    }
    _products = [[NSMutableArray alloc] init];
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(URL_BABY_PRODUCT, nil)]];
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

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BabyProductCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    BabyProduct *product = _products[indexPath.row];
    
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
    
    BabyProduct *product = _products[indexPath.row];
    
    BOOL hasURL = NO;
    BOOL hasWebViewURL = NO;
    if (product != nil && product.openurl != nil && ![product.openurl isEqualToString:@""]) {
        hasURL = YES;
    }
    if (product != nil && product.webviewurl != nil && ![product.webviewurl isEqualToString:@""]) {
        hasWebViewURL = YES;
    }
    
    if (hasURL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:product.openurl]];
    }
    else if (hasWebViewURL) {
        // 예외처리 MonthlyBaby는 웹뷰이지만 따로 동작해야함.
        if ([product.productcode isEqualToString:@"300502"]) {
            [self performSegueWithIdentifier:@"MonthlyBabySegue" sender:self];
        }
        else {
            FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
            frameWebView.webviewUrl = product.webviewurl;
            [self presentViewController:frameWebView animated:YES completion:nil];
        }
    }
    else {
        if([product.productcode isEqualToString:@"366001"]){
            [self performSegueWithIdentifier:@"MinistandingDesignSegue" sender:self];
        }
        else {
            NSLog(@"Baby Product - Invalid productcode");
        }
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    return CGSizeMake(width, height + 40);
}

#pragma mark <NSXMLParserDelegate>

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"product"]) {
        
        BabyProduct *product = [[BabyProduct alloc] init];
        
        product.idx = [attributeDict objectForKey:@"idx"];
        product.pid = [attributeDict objectForKey:@"id"];
        product.thumb = [attributeDict objectForKey:@"thumb"];
        product.productname = [attributeDict objectForKey:@"productname"];
        product.productcode = [attributeDict objectForKey:@"productcode"];
        product.price = [attributeDict objectForKey:@"minprice"];
        product.discount = [attributeDict objectForKey:@"discountminprice"];
        product.bookcount = [attributeDict objectForKey:@"bookcount"];
        product.openurl = [attributeDict objectForKey:@"openurl"];
        product.webviewurl = [attributeDict objectForKey:@"webviewurl"];
        
        [_products addObject:product];
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"MonthlyBabySegue"]) {
        MonthlyBabyWebViewController *vc = (MonthlyBabyWebViewController *)[segue destinationViewController];
        if (vc) {
			vc.url = URL_MONTHLY_BABY_MAIN_URL;
        }
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
    Product* product = _products[indexPath.row];
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
