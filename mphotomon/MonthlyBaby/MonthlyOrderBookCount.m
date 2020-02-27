//
//  MonthlyOrderBookCount.m
//  PHOTOMON
//
//  Created by 곽세욱 on 09/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MonthlyOrderBookCount.h"
#import "MonthlyBaby.h"

@interface MonthlyOrderBookCount ()

@end

@implementation MonthlyOrderBookCount

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	_addedOrderCount = 0;
	[_orderCountCollectionView setHidden:YES];
	[_orderCountButton.layer setBorderWidth:1];
	[_orderCountButton.layer setBorderColor: [[UIColor grayColor] CGColor]];
	[_addPriceView.layer setBorderWidth:1];
	[_addPriceView.layer setBorderColor: [[UIColor grayColor] CGColor]];
	
	[self updateUI];
}

- (void)setData:(nonnull id<MonthlySelectOrderCountDoneDelegate>)delegate {
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
	return 11;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OrderCountCell" forIndexPath:indexPath];
	
	[cell setNeedsLayout];
	[cell layoutIfNeeded];
	
	UILabel *label = (UILabel *)[cell viewWithTag:101];
	int perBookCount = [MonthlyBaby inst].isSeperated ? 2 : 1;
	
	if (indexPath.row == 0) {
		[label setText:@"아니오"];
	}
	else {
		[label setText:[NSString stringWithFormat:@"+%d권", perBookCount * (int)indexPath.row]];
	}
	return cell;
}

- (void) updateUI {
	
	int perBookCount = [MonthlyBaby inst].isSeperated ? 2 : 1;
	
	if (_addedOrderCount == 0){
		[_orderCountButton setTitle:@"아니오" forState:UIControlStateNormal];
		[_addPriceLabel setText:@"0원"];
	}
	else{
		
		[_orderCountButton setTitle:[NSString stringWithFormat:@"+%d권", _addedOrderCount * perBookCount] forState:UIControlStateNormal];
		[_addPriceLabel setText:[NSString stringWithFormat:@"+%d원", _addedOrderCount * 5000 * perBookCount]];
	}
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	_addedOrderCount = (int)indexPath.row;
	
	[self updateUI];
	[_orderCountCollectionView setHidden:YES];
}

- (IBAction)selectCount:(id)sender {
	// 토글
	if ([_orderCountCollectionView isHidden]) {
		
		[_orderCountCollectionView setHidden:NO];
		[_orderCountCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
	}
	else {
		[_orderCountCollectionView setHidden:YES];
	}
}

- (IBAction)order:(id)sender {
	
	[MonthlyBaby inst].orderBookCount = 1 + _addedOrderCount;
	
	[self dismissViewControllerAnimated:NO completion:^{
		if (_delegate) {
			[_delegate selectOrderCountDone];
		}
	}];
}
@end
