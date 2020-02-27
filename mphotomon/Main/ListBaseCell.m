//
//  ListBaseCell.m
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "ListBaseCell.h"
#import "ListCell.h"

@interface ListBaseCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *dataList;
@property (assign, nonatomic) id<ListBaseCellDelegate> delegate;

@end

@implementation ListBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ListCell" bundle:nil] forCellWithReuseIdentifier:@"ListCell"];
}

- (void)setListBaseCellWithDataList:(NSArray *)dataList self:(nonnull id<ListBaseCellDelegate>)delegate  {
    
    self.delegate = delegate;
    
    self.dataList = dataList;
    
    [self.collectionView reloadData];
    
    self.collectionView.userInteractionEnabled = true;
    self.collectionView.scrollEnabled = false;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width, 101.0f);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
    
    [cell setListCellWithContents:self.dataList[indexPath.item] index:indexPath.item+1];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(didTouchCellWithData:)]) {
        [self.delegate didTouchCellWithData:self.dataList[indexPath.item]];
    }

}
@end
