//
//  RecommendCell.m
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "RecommendCell.h"
#import "iCarousel.h"
#import "UIImageView+WebCache.h"

@interface RecommendCell () <iCarouselDelegate, iCarouselDataSource>

@property (weak, nonatomic) IBOutlet iCarousel *wheelView;
@property (strong, nonatomic) NSArray *dataList;
@property (assign, nonatomic) id<RecommendCellDelegate> delegate;

@end

@implementation RecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.wheelView.delegate = self;
    self.wheelView.dataSource = self;
    
    self.wheelView.type = iCarouselTypeCustom;
    self.wheelView.pagingEnabled = YES;
}

- (void)setRecommentList:(NSArray *)list self:(nonnull id<RecommendCellDelegate>)delegate {
    
    self.delegate = delegate;
    
    self.dataList = list;
    
    [self.wheelView reloadData];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(nullable UIView *)view
{
    if (view == nil)
    {
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 290.5f, 265.0f)];
        
        NSDictionary *data = self.dataList[index];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:contentView.bounds];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:data[@"thumb"]]];
        
        [contentView addSubview:imageView];
        
        contentView.clipsToBounds = true;
        
        view = contentView;
        
        view.contentMode = UIViewContentModeCenter;
    }
    
    return view;
}

#pragma mark - iCarouselDelegate


- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.dataList.count;
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
    
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(didTouchCellWithData:)]) {
        [self.delegate didTouchCellWithData:self.dataList[index]];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    // 간격 여기서 조정
    if (option == iCarouselOptionSpacing)
    {
        return value * 0.9f;
    }
    if (option == iCarouselOptionRadius)
    {
        return value * 6.0f;
    }
    
    if(option == iCarouselOptionWrap) return YES;
    return value;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    const CGFloat radius = [self carousel:carousel valueForOption:iCarouselOptionRadius withDefault:200.0f];
    const CGFloat offsetFactor = [self carousel:carousel valueForOption:iCarouselOptionSpacing withDefault:1.0f]*carousel.itemWidth;
    const CGFloat angle = offset*offsetFactor/radius;
    
    const CGFloat shrinkFactor = 2.0f;
    
    CGFloat f = (sqrtf(offset*offset+1)-1) / 2;
    
    
    transform = CATransform3DTranslate(transform, radius*sinf(angle), radius*(1-cosf(angle)), 0.0);
    transform = CATransform3DScale(transform, 1/(f*shrinkFactor+1.0f), 1/(f*shrinkFactor+1.0f), 1.0);
    
    return transform;
}


@end
