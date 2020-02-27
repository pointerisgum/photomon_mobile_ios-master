//
//  IDPhotosPreviewViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosPreviewViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "IDPhotosUploadViewController.h"

@interface IDPhotosPreviewViewController ()

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation IDPhotosPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem=nil;
	self.navigationItem.hidesBackButton = YES;

	[Analysis log:@"IDPhotosPreviewViewController"];

	IDPhotosProductUnit *product = [Common info].idphotos.idphotos_product.product;
	NSString *price = [[Common info] toCurrencyString:[product.item_product_price intValue]];
	
	UILabel *label1 = (UILabel *)[self.view viewWithTag:101];
	label1.text = product.item_product_name;

	UILabel *label2 = (UILabel *)[self.view viewWithTag:102];
	label2.text = [NSString stringWithFormat:@"%@원", price];
	
	UILabel *label3 = (UILabel *)[self.view viewWithTag:103];
	label3.text = [NSString stringWithFormat:@"%@ %@장", product.item_product_cm, product.item_product_count];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosPreviewViewController" ScreenClass:[self.classForCoder description]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
	_constraints_collection_view_height.constant = _collection_view.contentSize.height;
	_constraints_bottom_btn_1_width.constant = self.view.bounds.size.width / 2.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239051"] ) 
		return 15;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239052"] ) 
		return 8;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239053"] ) 
		return 6;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239054"] ) 
		return 3;// 2018.02.28. daypark. 명함사진 2매 -> 3매 변경

    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
	imageview.image = _image;

	return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	float divide = 2;

	if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239051"] ) 
		divide = 5;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239052"] ) 
		divide = 4;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239053"] ) 
		divide = 3;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239054"] ) 
		divide = 3;// 2018.02.28. daypark. 명함사진 2매 -> 3매 변경

    CGFloat width = (collectionView.bounds.size.width - (divide-1) * 5 - 10 * 2) / divide;
    //CGFloat width = collectionView.bounds.size.width / divide;
    CGFloat height = width / 3.5f * 5.0f;
	if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239051"] ) 
		height = width / 2.5f * 3.0f;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239052"] ) 
		height = width / 3.0f * 4.0f;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239053"] ) 
		height = width / 3.5f * 4.5f;
	else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239054"] ) 
		height = width / 5.0f * 7.0f;
	
    return CGSizeMake(width, height);
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 10, 5, 10); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IDPhotosUploadSegue"]) {
        IDPhotosUploadViewController *vc = [segue destinationViewController];
        if (vc) {
			vc.upload_image = _image;
        }
    }
}

//check
- (IBAction)cancel:(id)sender {
    [[Common info]alert:self Title:@"편집 하신 사진이 초기화 됩니다.\n페이지를 이동 하시겠습니까?" Msg:@"" okCompletion:^{
        [self.navigationController popViewControllerAnimated:YES];

    } cancelCompletion:^{

    } okTitle:@"네" cancelTitle:@"아니오"];
    
}

- (IBAction)done:(id)sender {
	[self performSegueWithIdentifier:@"IDPhotosUploadSegue" sender:self];
}

// Resize a UIImage. From http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
- (UIImage *)resize:(UIImage *)image to:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
