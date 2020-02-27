//
//  zxcRollingBanner.h
//  ZXCDemo
//
//  Created by zhang on 16/12/16.
//  Copyright © 2016年 张绪川. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZXCRollingBannerDelegate <NSObject>

@optional
//当前显示图片索引
-(void)scrollToIndex:(NSInteger)index;

//被点击图片索引
-(void)tapAtIndex:(NSInteger)index;

@end


@interface ZXCRollingBanner : UIView



@property ( nonatomic,weak) id<ZXCRollingBannerDelegate> delegate ;

/**
 加载时替代图片
 */
@property ( nonatomic,strong) UIImage * placeholderImage ;

/**
 滚动间隔时长,若不设置默认3秒
 */
@property (nonatomic,assign) NSInteger  scrollTime;






/**
 必须指定初始化frame
 */
- (instancetype)initWithFrame:(CGRect)frame;

-(void)stopScroll;

-(void)beginScroll;



/**
 设置图片<UIImage>
 
 @param imgArr 图片数组
 */
-(void)setImageWithImgArr:(NSArray<UIImage *>*)imgArr;


/**
 设置图片<NSString> [该方法使用SDWebImage组件,若不需要可屏蔽]
 
 @param urlArr 链接数组
 */
-(void)setImageWithUrlArr:(NSArray<NSString *>*)urlArr;




#pragma mark --若不实现代理方法则可通过一下两个方法得到当前图片和点击图片的索引值
#pragma mark --但是请注意代理方法和回调方法将同时进行

/**
 当前点击的图片回调
 
 @param block 当前点击的图片回调
 */
-(void)tapWihtBlock:(void(^)(NSInteger tapIndex))block;



/**
 当前显示的图片回调
 
 @param block 当前显示的图片回调
 */
-(void)scrollWithBlock:(void(^)(NSInteger currentIndex))block;

@end

