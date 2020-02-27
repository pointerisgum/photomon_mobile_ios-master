//
//  MonthlyAddProductPopup.m
//  PHOTOMON
//
//  Created by 곽세욱 on 09/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MonthlyAddProductPopup.h"
#import "Common.h"

@interface MonthlyAddProductPopup ()

@end

@implementation MonthlyAddProductPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[_noThanksButton.layer setBorderWidth:1];
	[_noThanksButton.layer setBorderColor: [[UIColor grayColor] CGColor]];
	
	_selectedList = [[NSMutableArray alloc] init];
	
	_checkOnImage = [UIImage imageNamed:@"common_check_on.png"];
	_checkOffImage = [UIImage imageNamed:@"common_check_off.png"];
	_thumbIndex = 0;
}

- (void)setData:(id<MonthlySelectAddProductDoneDelegate>)delegate {
	_delegate = delegate;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [MonthlyBaby inst].addProducts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView == _thumbnailListView) {
		UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddProductCell" forIndexPath:indexPath];
		
		MonthlyAddProductInfo *info = [[MonthlyBaby inst].addProducts objectAtIndex:indexPath.row];
		if (info) {
			UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
			
			[[Common info] downloadAsyncWithURL:[NSURL URLWithString:info.thumb] completionBlock:^(BOOL succeeded, NSData *imageData) {
				if (succeeded) {
					imageview.image = [UIImage imageWithData:imageData];
					if (imageview.image == nil) {
						imageview.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
					}
				}
				else {
					NSLog(@"theme-detail's thumbnail_image is not downloaded.");
				}
			}];
		}
		return cell;
	}
	else {
		UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductInfoCell" forIndexPath:indexPath];
		
		MonthlyAddProductInfo *info = [[MonthlyBaby inst].addProducts objectAtIndex:indexPath.row];
		
		if (info) {
			
			UIImageView *checkbox = (UIImageView *)[cell viewWithTag:200];
			UILabel *pkgNameLabel = (UILabel *)[cell viewWithTag:201];
			UILabel *pkgPriceLabel = (UILabel *)[cell viewWithTag:202];
			
			if ([_selectedList containsObject:info]) {
				[checkbox setImage:_checkOnImage];
			}
			else {
				[checkbox setImage:_checkOffImage];
			}
			
			[pkgNameLabel setText:info.pkgname];
			NSNumber *price = [NSNumber numberWithInt:[info.price intValue]];
			[pkgPriceLabel setText:[NSString stringWithFormat:@"%@원", [NSNumberFormatter localizedStringFromNumber:price numberStyle:NSNumberFormatterDecimalStyle]]];
		}
		return cell;
	}
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if (collectionView == _thumbnailListView) {
		CGFloat width = collectionView.bounds.size.width;
		CGFloat height = width;
		
		return CGSizeMake(width, height);
	}
	else {
		CGFloat width = collectionView.bounds.size.width;
		CGFloat height = collectionView.bounds.size.height / 3;;
		
		return CGSizeMake(width, height);
	}
	
}
#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView == _optionListView) {
		MonthlyAddProductInfo *info = [[MonthlyBaby inst].addProducts objectAtIndex:indexPath.row];
		if (info) {
			if ([_selectedList containsObject:info]){
				[_selectedList removeObject:info];
			}
			else {
				[_selectedList addObject:info];
			}
			[_optionListView reloadData];
		}
	}
}

- (IBAction)noThanks:(id)sender {
	[[MonthlyBaby inst].selectedAddProduct removeAllObjects];
	[self dismissViewControllerAnimated:NO completion:^{
		if (_delegate) {
			[_delegate selectAddProductDone];
		}
	}];
}

- (IBAction)next:(id)sender {
	// 추가작업 필요
	if (_selectedList.count > 0) {
		[[MonthlyBaby inst].selectedAddProduct removeAllObjects];
		[[MonthlyBaby inst].selectedAddProduct addObjectsFromArray:_selectedList];
		
		[self dismissViewControllerAnimated:NO completion:^{
			if (_delegate) {
				[_delegate selectAddProductDone];
			}
		}];
	} else {
		[[Common info] alert:self Msg:@"상품을 선택하세요."];
	}
}

- (IBAction)close:(id)sender {
	[[MonthlyBaby inst].selectedAddProduct removeAllObjects];
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onPrev:(id)sender {
	_thumbIndex--;
	if (_thumbIndex < 0) {
		_thumbIndex = (int)[[MonthlyBaby inst].addProducts count] - 1;
	}
	[_thumbnailListView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_thumbIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (IBAction)onNext:(id)sender {
	_thumbIndex++;
	if (_thumbIndex >= (int)[[MonthlyBaby inst].addProducts count]) {
		_thumbIndex = 0;
	}
	[_thumbnailListView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_thumbIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}
@end
