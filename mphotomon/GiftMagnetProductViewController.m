//
//  GiftMagnetProductViewController.m
//  
//
//  Created by photoMac on 2015. 9. 16..
//
//

#import "GiftMagnetProductViewController.h"
#import "GiftMagnetDesignViewController.h"
#import "FrameWebViewController.h"

#import "WebpageViewController.h"
#import "Common.h"

@interface GiftMagnetProduct ()
@end
@implementation GiftMagnetProduct
@end

@interface GiftMagnetProductViewController ()

@end

@implementation GiftMagnetProductViewController

static NSString * const reuseIdentifier = @"PhotobookProductCell";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	/*
	[Common info].photobook_root_controller = nil;

    //self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = nil; 
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _bookbar.hidden = YES;
    _buttonbar_constraint.constant = 0;

    //[Common info].photobook_product_root_controller = self;
	*/
    
    [self loadGiftMagnetProduct];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadGiftMagnetProduct {
    if (_gift_products != nil) {
        [_gift_products removeAllObjects];
    }
    _gift_products = [[NSMutableArray alloc] init];
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(URL_GIFT_PRODUCT, nil)]];
    if (ret_val != nil) {
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return;
        }
    }
    [_collection_view reloadData];
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GiftMagnetDesignSegue"]) {
        GiftMagnetDesignViewController *vc = (GiftMagnetDesignViewController *)[segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
	        GiftMagnetProduct *product = _gift_products[indexPath.row];
            vc.product_type = PRODUCT_MAGNET;

			if ([product.pid isEqualToString:@"square"]) vc.product_code = @"400001";
			else if ([product.pid isEqualToString:@"rect"]) vc.product_code = @"401001";
			else if ([product.pid isEqualToString:@"retro"]) vc.product_code = @"402001";
			else if ([product.pid isEqualToString:@"photobooth"]) vc.product_code = @"403001";
			else if ([product.pid isEqualToString:@"heart"]) vc.product_code = @"404001";
			else vc.product_code = @"400001";
       }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _gift_products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;

    Product *product = _gift_products[indexPath.row];
    if (product) {
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
                NSLog(@"product's thumbnail_image is not downloaded.");
            }
        }];
        
        NSString *price = [[Common info] toCurrencyString:[product.minprice intValue]];
        NSString *discount = [[Common info] toCurrencyString:[product.discountminprice intValue]];

        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        label1.text = product.productname;
        NSLog(@"%@", product.productname);

        UILabel *label2 = (UILabel *)[cell viewWithTag:103];
        label2.text = [NSString stringWithFormat:@"%@원", price];
        
        UILabel *label3 = (UILabel *)[cell viewWithTag:104];
        label3.text = [NSString stringWithFormat:@"%@원", discount];
        
        if ([price isEqualToString:discount]) {
            UILabel *label_price = (UILabel *)[cell viewWithTag:103];
            UILabel *label_strikeout = (UILabel *)[cell viewWithTag:105];
            label_price.hidden = YES;
            label_strikeout.hidden = YES;
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_product_type == PRODUCT_MAGNET) {
        Product *product = _gift_products[indexPath.row];
        
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
            [self performSegueWithIdentifier:@"GiftMagnetDesignSegue" sender:self];
	}
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4

    return CGSizeMake(width, height + 40);
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
    Product* product = _gift_products[indexPath.row];
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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"product2"]) {
        
        GiftMagnetProduct *product = [[GiftMagnetProduct alloc] init];

        product.idx = [attributeDict objectForKey:@"idx"];
        product.pid = [attributeDict objectForKey:@"id2"];
        product.thumb = [attributeDict objectForKey:@"thumb2"];
        product.productname = [attributeDict objectForKey:@"product2name"];
        product.productcode = [attributeDict objectForKey:@"product2code"];
        product.price = [attributeDict objectForKey:@"minprice2"];
        product.discount = [attributeDict objectForKey:@"discountminprice2"];
        product.minprice = [attributeDict objectForKey:@"minprice2"];
        product.discountminprice = [attributeDict objectForKey:@"discountminprice2"];
        product.openurl = [attributeDict objectForKey:@"openurl"];
        product.webviewurl = [attributeDict objectForKey:@"webviewurl"];

        [_gift_products addObject:product];
    }
}

@end
