//
//  IDPhotosProductListViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosProductListViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "IDPhotosProductMainViewController.h"

@interface IDPhotosProductListViewController ()

@end

static NSString * const reuseIdentifier = @"IDPhotosProductCell";

@implementation IDPhotosProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_idphoto"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
		}
    }

	[Analysis log:@"IDPhotosProductList"];

    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:URL_RECV_INFO]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSArray *temp_array = [data componentsSeparatedByString:@"\n"];
        NSString *line = temp_array[0];
		if (![line isEqualToString:@""]) {
            NSString *msg = line;
            msg = [msg stringByReplacingOccurrencesOfString:@" <font color=red><b>" withString:@" "];
            msg = [msg stringByReplacingOccurrencesOfString:@"</b></font>" withString:@" "];
            NSLog(@">> product_msg: %@", msg);
            _lb_guide.text = msg;
		}
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosProductList" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	self.navigationItem.leftBarButtonItem = nil;   
    [self loadIDPhotosProduct];
}

- (void)loadIDPhotosProduct {
    [[Common info].idphotos.idphotos_product.products removeAllObjects];
    [[Common info].idphotos.idphotos_product loadProduct];
    [_collection_view reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].idphotos.idphotos_product.products.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[Common info].idphotos.idphotos_product.product = [Common info].idphotos.idphotos_product.products[indexPath.row];
	//[self performSegueWithIdentifier:@"IDPhotosProductMainSegue" sender:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;

    IDPhotosProductUnit *product = [Common info].idphotos.idphotos_product.products[indexPath.row];
    if (product) {
        NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].idphotos.idphotos_product.thumb_url, product.item_product_image];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"product's thumbnail_image is not downloaded.");
            }
        }];
        
        NSString *price = [[Common info] toCurrencyString:[product.item_product_price intValue]];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:101];
        label1.text = product.item_product_name;
        NSLog(@"%@", product.item_product_name);

        UILabel *label2 = (UILabel *)[cell viewWithTag:102];
        label2.text = [NSString stringWithFormat:@"%@원", price];
        
        UILabel *label3 = (UILabel *)[cell viewWithTag:103];
        label3.text = [NSString stringWithFormat:@"%@ %@장", product.item_product_cm, product.item_product_count];
    }
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 10.0;
    CGFloat width = (collectionView.bounds.size.width - spacing*3) / 2;
    
    CGFloat height = width * 1.1;
    
    return CGSizeMake(width, height);
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	/*
    if ([segue.identifier isEqualToString:@"IDPhotosProductMainSegue"]) {
        IDPhotosProductMainViewController *vc = [segue destinationViewController];
        if (vc) {
        }
    }
	*/
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
