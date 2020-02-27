//
//  NewDesignCell.m
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "NewDesignCell.h"
#import "SubCell.h"

@interface NewDesignCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *productList;
@property (assign, nonatomic) BOOL isNewDesignType;
@property (assign, nonatomic) id<NewDesignCellDelegate> delegate;

@end

@implementation NewDesignCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"SubCell" bundle:nil] forCellWithReuseIdentifier:@"SubCell"];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.productList = nil;
    self.isNewDesignType = nil;
    self.productList = nil;
}

- (void)setNewDesignCellWithDataList:(NSArray *)dataList isNewDesignType:(BOOL)isNewDesignType self:(nonnull id<NewDesignCellDelegate>)delegate {
    
    self.delegate = delegate;
    
    self.isNewDesignType = isNewDesignType;
    
    if (self.isNewDesignType) {
        self.lbTitle.text = @"새로 나온 디자인";
    } else {
        self.lbTitle.text = @"나만 가질 수 있어 더 특별한 굿즈 컬렉션";
    }

    self.collectionView.scrollEnabled = self.isNewDesignType;

    NSLog(@"dataList %@ \n product List : %@", dataList, self.productList);
    
    if (dataList.count != 0) {
        self.productList = dataList;
        [self.collectionView reloadData];

    }
    
//    self.productList = dataList;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.isNewDesignType ? UIEdgeInsetsMake(0.0f, 14.5f, 0.0f, 14.5f) : UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.isNewDesignType ? 10.5f : 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.isNewDesignType ? 0.0f : 10.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isNewDesignType) {
        return CGSizeMake(145.0f, 220.0f);
    }
    
    CGFloat deviceWidth = [UIScreen mainScreen].bounds.size.width;
    
    return CGSizeMake((deviceWidth-10)/2, 190.0f);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.productList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubCell" forIndexPath:indexPath];
    
    NSDictionary *data = self.productList[indexPath.item];
    
    NSString *title = self.isNewDesignType ? data[@"title"] : data[@"category"];
    
    [cell setSubCell:self.isNewDesignType thumb:data[@"thumb"] title:title subTitle:data[@"category"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didTouchCellWithData:)]) {
        [self.delegate didTouchCellWithData:self.productList[indexPath.item]];
    }
}

@end
