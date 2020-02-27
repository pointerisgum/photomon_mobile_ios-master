//
//  Util.m
//  PhotoMon
//
//  Created by Lee Kyunghyun on 2015. 12. 31..
//  Copyright © 2015년 LeeKyunghyun. All rights reserved.
//

#import "Util.h"
#import <AVFoundation/AVFoundation.h>

// size를 rect에 aspectfill 되도록 하는 영역을 반환한다.
//
CGRect aspectFillRect(CGSize size, CGRect rect)
{
    // 사진이 세로로 꽉 차고 가로로 짤리는 경우
    //
    if( size.width * CGRectGetHeight(rect) > size.height * CGRectGetWidth(rect) )
    {
        // 비율에 의해서 너비를 계산한다.
        //
        float width = size.width * CGRectGetHeight(rect) / size.height;
        return CGRectMake((CGRectGetWidth(rect) - width) / 2.f,
                          0.f,
                          width,
                          CGRectGetHeight(rect));
    }
    // 사진이 가로로 꽉 차고 세로로 짤리는 경우
    //
    else
    {
        // 비율에 의해서 높이를 계산한다.
        //
        float height = size.height * CGRectGetWidth(rect) / size.width;
        return CGRectMake(0.f,
                          (CGRectGetHeight(rect) - height) / 2.f,
                          CGRectGetWidth(rect),
                          height);
    }
}


// size를 rect에 aspectfit 영역을 반환한다.
//
CGRect aspectFitRect(CGSize size, CGRect rect)
{
    // AVFoundation Util에서 제공하는 함수를 사용한다.
    //
    return AVMakeRectWithAspectRatioInsideRect(size, rect);
}
