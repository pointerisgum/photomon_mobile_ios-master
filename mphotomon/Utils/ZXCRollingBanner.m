//
//  zxcRollingBanner.m
//  ZXCDemo
//
//  Created by zhang on 16/12/16.
//  Copyright © 2016年 张绪川. All rights reserved.
//

#import "ZXCRollingBanner.h"
//#import "UIImageView+WebCache.h"

@interface ZXCRollingBanner ()<UIScrollViewDelegate>
{
    
    BOOL _autoScrollStatus;
}

///视图
@property ( nonatomic,strong) UIScrollView * scrollView ;
///分页指示器
@property ( nonatomic,strong) UIPageControl * pageControl ;

@property ( nonatomic,strong) NSMutableArray * dataSourceUrl ;

@property (nonatomic,copy) void (^scrollBlock) (NSInteger currentIndex);

@property (nonatomic,copy) void (^tapBlock) (NSInteger tapIndex);

@end

@implementation ZXCRollingBanner

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化滚动时间
        _scrollTime = 5;
        //创建子视图
        [self buildView];
        
        
    }
    return self;
}




-(void)buildView{
    
    [self addSubview:self.scrollView];
    
    [self addSubview:self.pageControl];
    
}



//填充子视图-0
-(void)setImageWithUrlArr:(NSArray<NSString *> *)urlArr{
    
    [self stopScroll];
    
    self.dataSourceUrl = [NSMutableArray arrayWithArray:urlArr];
    
    [self removeAllSubviewsFromView:self.scrollView];
    
    for (int i = 0; i< self.dataSourceUrl.count+1; i++) {
        
        UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
        
        imgView.contentMode = UIViewContentModeScaleToFill;
        
        if(i == self.dataSourceUrl.count){
            
//            [imgView sd_setImageWithURL:[NSURL URLWithString:self.dataSourceUrl[0]] placeholderImage:self.placeholderImage options:SDWebImageAllowInvalidSSLCertificates];
            
            [self.scrollView addSubview:imgView];
            break;
            //最后一项的特殊处理
        }
        
//        [imgView sd_setImageWithURL:[NSURL URLWithString:self.dataSourceUrl[i]] placeholderImage:self.placeholderImage options:SDWebImageAllowInvalidSSLCertificates];
        
        [self.scrollView addSubview:imgView];
        
        
        
        
    }
    self.pageControl.numberOfPages = self.dataSourceUrl.count;
    //显示包含内容大小
    self.scrollView.contentSize = CGSizeMake((self.dataSourceUrl.count+1)*self.bounds.size.width, self.bounds.size.height);
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    //cmh : 아이템이 1개일 때 롤링배너 미적용
    if (self.dataSourceUrl.count == 1) {
        self.scrollView.scrollEnabled = NO;
        [self.pageControl setHidden:YES];
    }else{
        self.scrollView.scrollEnabled = YES;
        [self.pageControl setHidden:NO];
        [self beginScroll];
    }
}

//填充子视图-1
-(void)setImageWithImgArr:(NSArray<UIImage *> *)imgArr{
    
    [self stopScroll];
    
    self.dataSourceUrl = [NSMutableArray arrayWithArray:imgArr];
    
    [self removeAllSubviewsFromView:self.scrollView];
    
    for (int i = 0; i< self.dataSourceUrl.count+1; i++) {
        
        UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
        
        imgView.contentMode = UIViewContentModeScaleToFill;
        
        if(i == self.dataSourceUrl.count){
            
            imgView.image = self.dataSourceUrl[0];
            
            [self.scrollView addSubview:imgView];
            break;
            //最后一项的特殊处理
        }
        
        imgView.image = self.dataSourceUrl[i];
        
        
        
        [self.scrollView addSubview:imgView];
        
        
    }
    
    self.pageControl.numberOfPages = self.dataSourceUrl.count;
    //显示包含内容大小
    self.scrollView.contentSize = CGSizeMake((self.dataSourceUrl.count+1)*self.bounds.size.width, self.bounds.size.height);
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    [self beginScroll];
    
    
}



#pragma mark - 组件方法



-(void)pageing:(UIPageControl *)pgc{
    NSInteger  currentPage = pgc.currentPage;
    ///调整滚动页
    [self.scrollView setContentOffset:CGPointMake(currentPage*_scrollView.bounds.size.width, 0) animated:YES];
}


-(void)timerGo{
    
    
    NSInteger currentPage = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    //修改滚动视图的偏移量
    [self.scrollView setContentOffset:CGPointMake((currentPage+1) * _scrollView.bounds.size.width, 0) animated:YES];
}

-(void)tap:(UITapGestureRecognizer*)gesture{
    
    NSInteger  index = [self getVisbleIndex];
    [self.delegate tapAtIndex:index];
    
    if (_tapBlock) {
        _tapBlock(index);
    }
}

-(NSInteger)getVisbleIndex{
    NSInteger currentPage = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    NSInteger wholePage = self.scrollView.contentSize.width/self.scrollView.bounds.size.width;
    
    if (wholePage == currentPage+1) {
        currentPage = 0;
    }
    return currentPage;
}

#pragma mark --操作回调

-(void)tapWihtBlock:(void(^)(NSInteger tapIndex))block{
    _tapBlock = block;
}

-(void)scrollWithBlock:(void(^)(NSInteger currentIndex))block{
    _scrollBlock = block;
}

#pragma mark - 控制事件



-(void)stopScroll{
    
    _autoScrollStatus = NO;
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
}

-(void)beginScroll{
    
    _autoScrollStatus = YES;
    
    [self performSelector:@selector(timerGo) withObject:nil afterDelay:self.scrollTime];
    
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    [self scrollViewDidEndDecelerating:scrollView];
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSInteger wholePage = scrollView.contentSize.width/scrollView.bounds.size.width;
    
    if (wholePage <= currentPage+1) {
        currentPage = 0;
        scrollView.contentOffset = CGPointMake(0, 0);
    }
    self.pageControl.currentPage = currentPage;
    

    
    [self.delegate scrollToIndex:currentPage];
    
    if (_scrollBlock) {
        _scrollBlock(currentPage);
    }
    
    
    [self stopScroll];
    [self beginScroll];
    
}





#pragma mark - 懒加载

-(NSMutableArray*)dataSourceUrl{
    if (_dataSourceUrl == nil) {
        _dataSourceUrl = [[NSMutableArray alloc] init];
    }
    return _dataSourceUrl;
}


-(UIPageControl*)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(self.bounds.size.width-140, self.bounds.size.height-30, 150, 30)];
        _pageControl.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height - 15);
        _pageControl.currentPageIndicatorTintColor =[UIColor colorWithWhite:0.7 alpha:0.9];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        [_pageControl addTarget:self action:@selector(pageing:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageControl;
}

-(UIScrollView*)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator =NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}


- (void)removeAllSubviewsFromView:(UIView *)view {
    //[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    while (view.subviews.count) {
        [view.subviews.lastObject removeFromSuperview];
    }
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
