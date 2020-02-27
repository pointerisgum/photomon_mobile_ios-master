//
//  TopBannerCell.m
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "TopBannerCell.h"
#import "GBInfiniteScrollView.h"

#import "UIImageView+WebCache.h"


@interface TopBannerCell () <GBInfiniteScrollViewDataSource, GBInfiniteScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *scrollViewBaseView;
@property (strong, nonatomic) GBInfiniteScrollView *scrollView;
@property (strong, nonatomic) NSArray <Contents *> *dataList;
@property (weak, nonatomic) IBOutlet UILabel *lbPageCount;

@property (assign, nonatomic) id<TopBannerCellDelegate> delegate;
@end
@implementation TopBannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.scrollView = [[GBInfiniteScrollView alloc] initWithFrame:self.scrollViewBaseView.bounds];
    
    self.scrollView.infiniteScrollViewDataSource = self;
    self.scrollView.infiniteScrollViewDelegate = self;
    
    self.scrollView.pageIndex = 0;
    
    [self.scrollViewBaseView addSubview:self.scrollView];
    
}

- (void)setCellWithDataList:(NSArray *)dataList self:(nonnull id<TopBannerCellDelegate>)delegate {
    
    self.delegate = delegate;
    
    self.scrollView.frame = self.bounds;
    
    self.dataList = dataList;
    
    [self.scrollView reloadData];
    
    [self.scrollView startAutoScroll];
}

- (GBInfiniteScrollViewPage *)infiniteScrollView:(GBInfiniteScrollView *)infiniteScrollView pageAtIndex:(NSUInteger)index;
{
    GBInfiniteScrollViewPage *page = [infiniteScrollView dequeueReusablePage];
    
    if (page == nil) {
        page = [[GBInfiniteScrollViewPage alloc] initWithFrame:self.bounds style:GBInfiniteScrollViewPageStyleText];
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSDictionary *content = self.dataList[index];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:content[@"thumb"]]];
    
    [page addSubview:imageView];
    
    UIButton *button = [[UIButton alloc]initWithFrame:self.bounds];
    
    button.tag = index;
    
    [button addTarget:self action:@selector(didTouchPage:) forControlEvents:UIControlEventTouchUpInside];
    
    [page addSubview:button];
    
    return page;
}

- (void)didTouchPage:(UIButton *)button {
    
    NSLog(@"didTouchPage: %zd", button.tag);
    
    Contents *data = self.dataList[button.tag];
    
    if ([self.delegate respondsToSelector:@selector(didTouchCellWithData:)]) {
        [self.delegate didTouchCellWithData:data];
    }
}

- (NSInteger)numberOfPagesInInfiniteScrollView:(GBInfiniteScrollView *)infiniteScrollView {
    return self.dataList.count;
}


- (void)infiniteScrollViewDidScrollNextPage:(GBInfiniteScrollView *)infiniteScrollView {
    
    self.lbPageCount.text = [NSString stringWithFormat:@"%zd / %lu", infiniteScrollView.currentPageIndex+1, (unsigned long)self.dataList.count];
    
}

- (void)infiniteScrollViewDidScrollPreviousPage:(GBInfiniteScrollView *)infiniteScrollView {
    self.lbPageCount.text = [NSString stringWithFormat:@"%zd / %lu", infiniteScrollView.currentPageIndex+1, (unsigned long)self.dataList.count];
}

- (void)infiniteScrollView:(GBInfiniteScrollView *)infiniteScrollView didTapAtIndex:(NSInteger)pageIndex {
    

    
}

@end
