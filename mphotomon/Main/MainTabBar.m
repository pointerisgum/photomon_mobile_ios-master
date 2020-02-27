//
//  MainTapBar.m
//  PHOTOMON
//
//  Created by 김민아 on 14/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MainTabBar.h"
#import "MainNaviCell.h"
#import "UIColor+HexString.h"
#import "Common.h"

@interface MainTabBar () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign) int sel_navibutton;
@property (assign, nonatomic) id<MainTabBarDelegate> delegate;
@property (assign, nonatomic) BOOL isFirst;

@property (strong, nonatomic) NSMutableArray *naviKeywords;
@property (strong, nonatomic) NSMutableArray *naviComments;

@end

@implementation MainTabBar

- (instancetype)initWithTargetFrame:(CGRect)frame naviIndex:(int)index delegate:(id<MainTabBarDelegate>)delegate {
    
    self = [super init];
    
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"MainTabBar" owner:self options:nil]lastObject];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"MainNaviCell" bundle:nil] forCellWithReuseIdentifier:@"MainNaviCell"];
        self.frame = frame;
        self.delegate = delegate;
        self.sel_navibutton = index;
        self.isFirst = true;
        
//        if (self.sel_navibutton > 6) {
//            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:9 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:false];
//        }
    }
    
    return self;
}

- (instancetype)initWithTargetFrame:(CGRect)frame naviIndex:(int)index delegate:(id<MainTabBarDelegate>)delegate naviComments:(NSMutableArray *)comments{
    
    self = [super init];
    
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"MainTabBar" owner:self options:nil]lastObject];
        
        [self.collectionView registerNib:[UINib nibWithNibName:@"MainNaviCell" bundle:nil] forCellWithReuseIdentifier:@"MainNaviCell"];
        self.frame = frame;
        self.delegate = delegate;
        self.sel_navibutton = index;
        self.isFirst = true;
        self.naviComments = comments;
        
        
        //        if (self.sel_navibutton > 6) {
        //            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:9 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:false];
        //        }
    }
    
    return self;
}


- (void)updateCollectionViewOffset {
    if (self.isFirst) {
        
        NSLog(@"offset : %@", NSStringFromCGPoint([Common info].mainTabBarOffset));
        NSLog(@"naviButton : %zd", self.sel_navibutton);
        
        [self.collectionView performBatchUpdates:^{
            self.collectionView.contentOffset = [Common info].mainTabBarOffset;

        } completion:^(BOOL finished) {
            [self layoutIfNeeded];

        }];

        
//        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.sel_navibutton inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:false];
        
        self.isFirst = false;
    }
}

- (CGPoint)collectionViewOffset {
    NSLog(@"offset : %@", NSStringFromCGPoint(self.collectionView.contentOffset));
    return self.collectionView.contentOffset;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_naviComments){
        _sel_navibutton = (int)indexPath.row;
        [_collectionView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(didTouchTabBarWithNaviIndex:)]) {
            [self.delegate didTouchTabBarWithNaviIndex:(int)indexPath.item];
        }
    }else{
    if ([self.delegate respondsToSelector:@selector(didTouchTabBarWithNaviIndex:)]) {
        [self.delegate didTouchTabBarWithNaviIndex:(int)indexPath.item];
    }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(_naviComments){
        return _naviComments.count;
    }
    return 10;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MainNaviCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MainNaviCell" forIndexPath:indexPath];
    
    if(_naviComments){
        cell.lbTitle.text = (NSString*)_naviComments[indexPath.row];
    }
    else{
        switch (indexPath.row) {
            case 0:
                cell.lbTitle.text = @"홈";
                break;
            case 1:
                cell.lbTitle.text = @"포토북";
                break;
            case 2:
                cell.lbTitle.text = @"사진인화";
                break;
            case 3:
                cell.lbTitle.text = @"달력";
                break;
            case 4:
                cell.lbTitle.text = @"액자";
                break;
            case 5:
                cell.lbTitle.text = @"카드";
                break;
            case 6:
                cell.lbTitle.text = @"굿즈";
                break;
            case 7:
                cell.lbTitle.text = @"베이비";
                break;
            case 8:
                cell.lbTitle.text = @"팬시";
                break;
            case 9:
                cell.lbTitle.text = @"선물가게";
                break;
        }
    }
    
    
    if (_sel_navibutton == indexPath.row) {
        cell.indicatorView.hidden = NO;
        cell.lbTitle.textColor = [UIColor colorFromHexString:@"ff9c00"];

    }
    else {
        cell.indicatorView.hidden = YES;
        cell.lbTitle.textColor = [UIColor darkGrayColor];
    }
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    NSString *s;
    
    if(_naviComments){
        s = (NSString*)_naviComments[indexPath.row];
    }
    else{
        
    switch (indexPath.row) {
        case 0:
            s = @"홈";
            break;
        case 1:
            s = @"포토북";
            break;
        case 2:
            s = @"사진인화";
            break;
        case 3:
            s = @"달력";
            break;
        case 4:
            s = @"액자";
            break;
        case 5:
            s = @"카드";
            break;
        case 6:
            s = @"굿즈";
            break;
        case 7:
            s = @"베이비";
            break;
        case 8:
            s = @"팬시";
            break;
        case 9:
            s = @"선물가게";
            break;
    }
    }
    
    
    CGSize calCulateSizze =[s sizeWithAttributes:NULL];
    calCulateSizze.width = calCulateSizze.width + 30;
    calCulateSizze.height = 40;
    return calCulateSizze;
    
}



@end
