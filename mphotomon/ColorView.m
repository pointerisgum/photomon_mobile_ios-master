//
//  ColorView.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 2. 3..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "ColorView.h"

int color_table[] = {
    0xffffff,
    0x000000,
    0x515151,
    0x474240,
    0x59493f,
    0xbc9e74,
    0xf7f2e4,
    0xffeeb2,
    0xfae498,
    0xffde28,
    
    0xffcb05,
    0xffa200,
    0xd0ea8b,
    0xdaeac3,
    0xb2e2d9,
    0x009c91,
    0x83dbe0,
    0x27cef2,
    0x009bdb,
    0x98caec,
    
    0x606d80,
    0x424750,
    0x2e436d,
    0x6d2e66,
    0xb52332,
    0xff8c9d,
    0xfdbdbb,
    0xfcc0cd
};

@implementation ColorView

- (int)maxValue {
    int color_count = sizeof(color_table) / sizeof(color_table[0]);
    return color_count;
}

- (int)colorValue:(int)idx {
    if (idx > ([self maxValue]-1)) {
        idx = [self maxValue]-1;
    }
    return color_table[idx];
}

- (void)drawRect:(CGRect)rect {
    int color_count = [self maxValue];
    
    float x = 0;
    float w = rect.size.width / color_count;
    float h = rect.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (int i = 0; i < color_count; i++) {

        //int a = (color_table[i] & 0xff000000) >> 24;
        int r = (color_table[i] & 0x00ff0000) >> 16;
        int g = (color_table[i] & 0x0000ff00) >>  8;
        int b = (color_table[i] & 0x000000ff);

        CGContextSetRGBFillColor(context, r/255.0f, g/255.0f, b/255.0f, 1.0f);
        
        CGRect rect = CGRectMake(x, 0, w, h);
        CGContextFillRect(context, rect);
        x += w;
    }
}

@end
