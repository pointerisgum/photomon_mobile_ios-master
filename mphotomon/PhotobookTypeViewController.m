//
//  PhotobookTypeViewController.m
//  
//
//  Created by photoMac on 2015. 9. 16..
//
//

#import "PhotobookTypeViewController.h"
#import "PhotobookDesignViewController.h"
#import "FrameWebViewController.h"

#import "WebpageViewController.h"
#import "Common.h"

@interface PhotobookTypeViewController ()

@end

@implementation PhotobookTypeViewController

static NSString * const reuseIdentifier = @"PhotobookProductCell";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[Common info].photobook_root_controller = nil;

    //self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = nil; 
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _photobook_type = 0;
    _bookbar.hidden = YES;
    _buttonbar_constraint.constant = 0;

    //[Common info].photobook_product_root_controller = self;
    
    [self loadPhotobookProduct];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotobookProduct {
    [[Common info].photobook_product.products removeAllObjects];
    [[Common info].photobook_product loadProductSub:_product_code];
    [_collection_view reloadData];
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PhotobookDesignSegue"]) {
        PhotobookDesignViewController *vc = (PhotobookDesignViewController *)[segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.product_type = PRODUCT_PHOTOBOOK;

            Product *product = [Common info].photobook_product.products[indexPath.row];
            if ([product.id isEqualToString:@"photobook"])
                vc.photobook_type = 0;
            else if ([product.id isEqualToString:@"insta"])
                vc.photobook_type = 1;
            else if ([product.id isEqualToString:@"analogue"])
                vc.photobook_type = 2;
            else if ([product.id isEqualToString:@"premium"])
                vc.photobook_type = 3;
            vc.product_code = product.productcode;
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook_product.products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;

    Product *product = [Common info].photobook_product.products[indexPath.row];
    if (product) {
        NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_product.thumb_url, product.thumb];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];

                // SJYANG
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
    if (_product_type == PRODUCT_PHOTOBOOK) {
        Product *product = [Common info].photobook_product.products[indexPath.row];
        
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
            [self performSegueWithIdentifier:@"PhotobookDesignSegue" sender:self];

        
        
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
    Product* product = [Common info].photobook_product.products[indexPath.row];
    NSString *product_code = product.productcode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

	// SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    if ([seqnum isEqualToString:@"270"]) 
		seqnum = @"269";
    else if ([seqnum isEqualToString:@"268"]) 
		seqnum = @"267";

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
