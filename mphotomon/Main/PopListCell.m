//
//  PopListCell.m
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "PopListCell.h"
#import "ListBaseCell.h"

@interface PopListCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ListBaseCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (strong, nonatomic) RankingObject *data;
@property (assign, nonatomic) NSInteger tap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcLeadingOfIndicator;
@property (assign, nonatomic) id<PopListCellDelegate> delegate;

@end

@implementation PopListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ListBaseCell" bundle:nil] forCellWithReuseIdentifier:@"ListBaseCell"];
}

- (void)setPopListWithData:(RankingObject *)data self:(nonnull id<PopListCellDelegate>)delegate {
    
    self.delegate = delegate;
    
    self.data = data;
    
    
    UIButton *best = (UIButton *)[self viewWithTag:4100];
    UIButton *sale = (UIButton *)[self viewWithTag:4101];

    Ranking *ranktap1 = ((NSDictionary *)self.data)[@"ranktap1"];
    Ranking *ranktap2 = ((NSDictionary *)self.data)[@"ranktap2"];

    [best setTitle:((NSDictionary *)ranktap1)[@"taptitle"] forState:UIControlStateNormal];
    [best setTitle:((NSDictionary *)ranktap1)[@"taptitle"] forState:UIControlStateSelected];
    [sale setTitle:((NSDictionary *)ranktap2)[@"taptitle"] forState:UIControlStateNormal];
    [sale setTitle:((NSDictionary *)ranktap2)[@"taptitle"] forState:UIControlStateSelected];

    self.collectionView.scrollEnabled = false;
    
    [self.collectionView reloadData];
}
// tag 4100~4102
- (IBAction)didTouchBestButton:(UIButton *)sender {
    
    UIButton *best = (UIButton *)[self viewWithTag:4100];
    UIButton *sale = (UIButton *)[self viewWithTag:4101];
//    UIButton *review = (UIButton *)[self viewWithTag:4102];
    
    best.selected = false;
    sale.selected = false;
//    review.selected = false;
    
    sender.selected = true;
    
//    self.alcLeadingOfIndicator.constant = self.alcLeadingOfIndicator.constant==0 ? self.indicatorView.bounds.size.width : 0;
//
//    [UIView animateWithDuration:0.2f animations:^{
//        [self layoutIfNeeded];
//    }];
////
    [self moveTap:sender.tag-4100];
}

- (void)moveTap:(NSInteger)tap {
    self.tap = tap;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:tap inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ListBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListBaseCell" forIndexPath:indexPath];
    
    NSArray *dataList = nil;

    switch (indexPath.item) {
        case 0: {
            Ranking *ranktap1 = ((NSDictionary *)self.data)[@"ranktap1"];

            dataList = ((NSDictionary *)ranktap1)[@"taplist"];
        }
            break;
        case 1: {
            Ranking *ranktap2 = ((NSDictionary *)self.data)[@"ranktap2"];

            dataList = ((NSDictionary *)ranktap2)[@"taplist"];
        }
            break;
        case 2:
            break;
        default:
            break;
    }
    
    [cell setListBaseCellWithDataList:dataList self:self];

    return cell;
    
}

- (void)didTouchCellWithData:(Contents *)contents {
    if ([self.delegate respondsToSelector:@selector(didTouchCellWithData:)]) {
        [self.delegate didTouchCellWithData:contents];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.alcLeadingOfIndicator.constant = (self.bounds.size.width - 30)*scrollView.contentOffset.x/(self.bounds.size.width*2);

    UIButton *best = (UIButton *)[self viewWithTag:4100];
    UIButton *sale = (UIButton *)[self viewWithTag:4101];

    if (self.alcLeadingOfIndicator.constant < best.bounds.size.width) {
        best.selected = true;
        sale.selected = false;
    } else {
        best.selected = false;
        sale.selected = true;
    }
//    } else {
//        best.selected = false;
//        sale.selected = false;
//        review.selected = true;
//    }
}

@end
