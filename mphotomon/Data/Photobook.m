//
//  Photobook.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 4..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "Photobook.h"
#import "Common.h"
#import "Instagram.h"
#import "PhotoLayerView.h"
#import "PHAssetUtility.h"
#import "UIColor+HexString.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

/*
@implementation Text

- (id)init {
    if (self = [super init]) {
        _gid = @"";
        _fontname = @"";
        _fontsize = 0;
        _italic = FALSE;
        _bold = FALSE;
        _color = [UIColor blackColor];
        _halign = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
*/
#pragma mark - Layer
@implementation Layer

static int pageNum = 0;

- (id)init {
    if (self = [super init]) {
        _AreaType = 0; // 레이어 종류 0 -> 이미지레이어, 1 -> 스티커 레이어, 2 -> 텍스트 레이어, 3 -> guideinfo 레이어(마그넷)
        _PageIndex = 0; // 페이지 순서
        _LayerIndex = 0; // 레이어 순서
        _Edited = FALSE; // 사용안함
        _RightContent = FALSE; // 사용안함
        _MaskX = 0; // 코디 레이어 영역 x 좌표
        _MaskY = 0;// 코디 레이어 영역 y 좌표
        _MaskW = 0;// 코디 레이어 영역 width
        _MaskH = 0; // 코디 레이어 영역 height
        _MaskR = 0;// 코디 레이어 영역 rotation
        _MaskRotateflip = @""; // 현재 사용안함
        _MaskAlpha = 255.0f;// 현재 사용안함
        _MaskMonotone = @"";// 현재 사용안함
        _MaskMultiply = FALSE;// 현재 사용안함
        _MaskContrast = 0.0f;// 현재 사용안함
        _MaskBrightness = 0.0f;// 현재 사용안함
        _X = 0; // 현재 사용안함
        _Y = 0;// 현재 사용안함
        _W = 0;// 현재 사용안함
        _H = 0;// 현재 사용안함
        _R = 0;// 현재 사용안함
        _ImageR = 0;// 현재 이미지 편집시 rotate 에 사용됨.
        _ColorMode = 0; // 현재 사용안함
        _Contrast = 0.0f;// 현재 사용안함
        _Brightness = 0.0f;// 현재 사용안함
        _Flip = FALSE;// 현재 사용안함
        _Flop = FALSE;// 현재 사용안함
        _Alpha = 255;// 현재 사용안함
        _Filter1 = 0;// 현재 사용안함
        _Filter2 = 0;// 현재 사용안함
        _Filter3 = 0;// 현재 사용안함
        _Filter4 = 0;// 현재 사용안함
        _Filter5 = 0;// 현재 사용안함
        _FrameFilename = @"";// 현재 사용안함
        _FrameSize = 0;// 현재 사용안함
        _FrameColor = 0;// 현재 사용안함
        _FrameAlpha = 255;// 현재 사용안함
        _Filename = @"";// 갤러리 파일 url
        _ImageFilename = @"";// 보관함폴더의 파일이름
        _ImageEditname = @"";// 편집용파일이름
        _ImageOriWidth = 0; // 원본 pixel
        _ImageOriHeight = 0;// 원본 pixel
        _ImageCropX = 0;// 편집용 crop 좌표
        _ImageCropY = 0;// 편집용 crop 좌표
        _ImageCropW = 0;// 편집용 crop 좌표
        _ImageCropH = 0;// 편집용 crop 좌표
        _NotMove = FALSE;// 현재 사용안함
        _NotDelete = FALSE;// 현재 사용안함
        _NotEdit = FALSE;// 현재 사용안함
        _Zorderlock = FALSE;// 현재 사용안함
        _Require = FALSE;// 현재 사용안함
        _ImageDescription = @"";// 현재 사용안함
        _Grouping = @"";// 현재 사용안함
        _Gid = @"";// 텍스트영역의 경우 책등은 spine 으로 셋팅됨
        _Macro = @"";// 현재 사용안함
        _Halign = @"";// 텍스트 영역의 정렬 left, center, right
        _VAlign = @"";// 현재 사용안함
        _Writevertical = FALSE;// 현재 사용안함
        _Movelock = FALSE;// 현재 사용안함
        _Removelock = FALSE;// 현재 사용안함
        _Resizelock = FALSE;// 현재 사용안함
        _LineGab = 0.0f;// 현재 사용안함
        _TextVisible = FALSE;// 현재 사용안함
        _TextFontname = @"";// 폰트이름
        _TextFontsize = 0;// 폰트크기
        _TextFontcolor = 0;// 폰트색상
        _TextBold = FALSE; // 현재 사용안함
        _TextItalic = FALSE;// 현재 사용안함
        _TextDescription = @"";// 글 편집 내용
        _EditImageMaxSize = 0; // 편집용 이미지의 최대 크기 pixel 수

        _text_color = [UIColor blackColor];
        _is_lowres = NO;
        _edit_image = nil;

        // 신규 달력 포맷
        _Frameinfo = @"";
        _Type = 0;
        _Align = @"";
        _Fontname = @"";
        _Fontsize = 0;
        _Fontcolor = @"";
        _Holidaycolor = @"";
        _Fonturl = @"";
        _Calid = @"";
        _Anniversary = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

// 신규 달력 포맷 + 마그넷 : 직렬화
- (void)encodeWithCoder: (NSCoder *)coder {
    [coder encodeInt:_AreaType forKey:@"AreaType"];
    [coder encodeInt:_PageIndex forKey:@"PageIndex"];
    [coder encodeInt:_LayerIndex forKey:@"LayerIndex"];

    [coder encodeInt:_X forKey:@"X"];
    [coder encodeInt:_Y forKey:@"Y"];
    [coder encodeInt:_W forKey:@"W"];
    [coder encodeInt:_H forKey:@"H"];
    [coder encodeObject:_Frameinfo forKey:@"Frameinfo"];
    [coder encodeObject:_SkinFilename forKey:@"Skinfilename"]; // 마그넷
    [coder encodeInt:_Type forKey:@"Type"];
    [coder encodeObject:_Align forKey:@"Align"];
    [coder encodeObject:_Fontname forKey:@"Fontname"];
    [coder encodeInt:_Fontsize forKey:@"Fontsize"];
    [coder encodeObject:_Fontcolor forKey:@"Fontcolor"];
    [coder encodeObject:_Holidaycolor forKey:@"Holidaycolor"];
    [coder encodeObject:_Fonturl forKey:@"Fonturl"];
    [coder encodeObject:_Calid forKey:@"Calid"];
    [coder encodeObject:_Anniversary forKey:@"Anniversary"];
    [coder encodeObject:_Gid forKey:@"Gid"];
}

// 신규 달력 포맷 + 마그넷 : 직렬화
- (id)initWithCoder: (NSCoder *)decoder {
    if(self == [super init]) {
        self.AreaType = [decoder decodeIntForKey:@"AreaType"];
        self.PageIndex = [decoder decodeIntForKey:@"PageIndex"];
        self.LayerIndex = [decoder decodeIntForKey:@"LayerIndex"];

        self.X = [decoder decodeIntForKey:@"X"];
        self.Y = [decoder decodeIntForKey:@"Y"];
        self.W = [decoder decodeIntForKey:@"W"];
        self.H = [decoder decodeIntForKey:@"H"];
        self.Frameinfo = [decoder decodeObjectForKey:@"Frameinfo"];
        // 신규 달력 포맷 : FrameFilename
        if(self.FrameFilename == nil || [self.FrameFilename isEqualToString:@""])
            self.FrameFilename = [decoder decodeObjectForKey:@"Frameinfo"];
		// 마그넷 : SkinFilename
        if(self.SkinFilename == nil || [self.SkinFilename isEqualToString:@""])
            self.SkinFilename = [decoder decodeObjectForKey:@"Skinfilename"];
        self.Type = [decoder decodeIntForKey:@"Type"];
        self.Align = [decoder decodeObjectForKey:@"Align"];
        self.Fontname = [decoder decodeObjectForKey:@"Fontname"];
        self.Fontsize = [decoder decodeIntForKey:@"Fontsize"];
        self.Fontcolor = [decoder decodeObjectForKey:@"Fontcolor"];
        self.Holidaycolor = [decoder decodeObjectForKey:@"Holidaycolor"];
        self.Fonturl = [decoder decodeObjectForKey:@"Fonturl"];
        self.Calid = [decoder decodeObjectForKey:@"Calid"];
        self.Anniversary = [decoder decodeObjectForKey:@"Anniversary"];
        self.Gid = [decoder decodeObjectForKey:@"Gid"];
    }
    return self;
}

- (Layer *)copy {
    Layer *layer = [[Layer alloc] init];

    layer.AreaType = _AreaType; // 레이어 종류 0 -> 이미지레이어, 1 -> 스티커 레이어, 2 -> 텍스트 레이어
    layer.PageIndex = _PageIndex; // 페이지 순서
    layer.LayerIndex = _LayerIndex; // 레이어 순서
    layer.Edited = _Edited; // 사용안함
    layer.RightContent = _RightContent; // 사용안함
    layer.MaskX = _MaskX; // 코디 레이어 영역 x 좌표
    layer.MaskY = _MaskY;// 코디 레이어 영역 y 좌표
    layer.MaskW = _MaskW;// 코디 레이어 영역 width
    layer.MaskH = _MaskH; // 코디 레이어 영역 height
    layer.MaskR = _MaskR;// 코디 레이어 영역 rotation
    layer.MaskRotateflip = _MaskRotateflip; // 현재 사용안함
    layer.MaskAlpha = _MaskAlpha;// 현재 사용안함
    layer.MaskMonotone = _MaskMonotone;// 현재 사용안함
    layer.MaskMultiply = _MaskMultiply;// 현재 사용안함
    layer.MaskContrast = _MaskContrast;// 현재 사용안함
    layer.MaskBrightness = _MaskBrightness;// 현재 사용안함
    layer.X = _X; // 현재 사용안함
    layer.Y = _Y;// 현재 사용안함
    layer.W = _W;// 현재 사용안함
    layer.H = _H;// 현재 사용안함
    layer.R = _R;// 현재 사용안함
    layer.ImageR = _ImageR;// 현재 이미지 편집시 rotate 에 사용됨.
    layer.ColorMode = _ColorMode; // 현재 사용안함
    layer.Contrast = _Contrast;// 현재 사용안함
    layer.Brightness = _Brightness;// 현재 사용안함
    layer.Flip = _Flip;// 현재 사용안함
    layer.Flop = _Flop;// 현재 사용안함
    layer.Alpha = _Alpha;// 현재 사용안함
    layer.Filter1 = _Filter1;// 현재 사용안함
    layer.Filter2 = _Filter2;// 현재 사용안함
    layer.Filter3 = _Filter3;// 현재 사용안함
    layer.Filter4 = _Filter4;// 현재 사용안함
    layer.Filter5 = _Filter5;// 현재 사용안함
    layer.FrameFilename = _FrameFilename;// 현재 사용안함
    layer.FrameSize = _FrameSize;// 현재 사용안함
    layer.FrameColor = _FrameColor;// 현재 사용안함
    layer.FrameAlpha = _FrameAlpha;// 현재 사용안함
    if (_AreaType == 1) { // 아이콘 타입은 모두 복사.
        layer.Filename = _Filename;// 갤러리 파일 url
        layer.ImageFilename = _ImageFilename;// 보관함폴더의 파일이름
        layer.ImageEditname = _ImageEditname;// 편집용파일이름
    }
    else {
        layer.Filename = @"";//_Filename;// 갤러리 파일 url
        layer.ImageFilename = @"";//_ImageFilename;// 보관함폴더의 파일이름
        layer.ImageEditname = @"";//_ImageEditname;// 편집용파일이름
    }
    layer.ImageOriWidth = _ImageOriWidth; // 원본 pixel
    layer.ImageOriHeight = _ImageOriHeight;// 원본 pixel
    layer.ImageCropX = _ImageCropX;// 편집용 crop 좌표
    layer.ImageCropY = _ImageCropY;// 편집용 crop 좌표
    layer.ImageCropW = _ImageCropW;// 편집용 crop 좌표
    layer.ImageCropH = _ImageCropH;// 편집용 crop 좌표
    layer.NotMove = _NotMove;// 현재 사용안함
    layer.NotDelete = _NotDelete;// 현재 사용안함
    layer.NotEdit = _NotEdit;// 현재 사용안함
    layer.Zorderlock = _Zorderlock;// 현재 사용안함
    layer.Require = _Require;// 현재 사용안함
    layer.ImageDescription = _ImageDescription;// 현재 사용안함
    layer.Grouping = _Grouping;// 현재 사용안함
    layer.Gid = _Gid;// 텍스트영역의 경우 책등은 spine 으로 셋팅됨
    layer.Macro = _Macro;// 현재 사용안함
    layer.Halign = _Halign;// 텍스트 영역의 정렬 left, center, right
    layer.VAlign = _VAlign;// 현재 사용안함
    layer.Writevertical = _Writevertical;// 현재 사용안함
    layer.Movelock = _Movelock;// 현재 사용안함
    layer.Removelock = _Removelock;// 현재 사용안함
    layer.Resizelock = _Resizelock;// 현재 사용안함
    layer.LineGab = _LineGab;// 현재 사용안함
    layer.TextVisible = _TextVisible;// 현재 사용안함
    layer.TextFontname = _TextFontname;// 폰트이름
    layer.TextFontsize = _TextFontsize;// 폰트크기
    layer.TextFontcolor = _TextFontcolor;// 폰트색상
    layer.TextBold = _TextBold; // 현재 사용안함
    layer.TextItalic = _TextItalic;// 현재 사용안함
    layer.TextDescription = @"";//_TextDescription;// 글 편집 내용
    layer.TextFontUrl = _TextFontUrl;// 폰트다운로드주소
    layer.EditImageMaxSize = _EditImageMaxSize; // 편집용 이미지의 최대 크기 pixel 수

    layer.text_color = _text_color;
    layer.is_lowres = FALSE;//_is_lowres;
    layer.edit_image = nil;//_edit_image;

    // 신규 달력 포맷
    layer.Frameinfo = _Frameinfo;
    // 신규 달력 포맷 : FrameFilename
    if(layer.FrameFilename == nil || [layer.FrameFilename isEqualToString:@""]) {
        if(_Frameinfo != nil && ![_Frameinfo isEqualToString:@""])
            layer.FrameFilename = _Frameinfo;
    }
    layer.Type = _Type;
    layer.Align = _Align;
    layer.Fontname = _Fontname;
    layer.Fontsize = _Fontsize;
    layer.Fontcolor = _Fontcolor;
    layer.Holidaycolor = _Holidaycolor;
    layer.Fonturl = _Fonturl;
    layer.Calid = _Calid;
    layer.Anniversary = _Anniversary;
    layer.str_positionSide = _str_positionSide;

    return layer;
}

- (NSData *)saveData {
    NSMutableData *data = [[NSMutableData alloc] init];

    _X = _MaskX;
    _Y = _MaskY;
    _W = _MaskW;
    _H = _MaskH;
    _R = _MaskR;

    if (_AreaType == 2) {
        CGFloat red, green, blue, alpha;
        [_text_color getRed:&red green:&green blue:&blue alpha:&alpha];

        int a = (int)(alpha*255) & 0xFF;
        int r = (int)(red*255) & 0xFF;
        int g = (int)(green*255) & 0xFF;
        int b = (int)(blue*255) & 0xFF;
        _TextFontcolor = (a << 24) + (r << 16) + (g << 8) + (b);
        //NSLog(@"save font color: %d, (%d,%d,%d,%d)",_TextFontcolor, a, r, g, b);

        NSLog(@"_TextDescription : %@", _TextDescription);
    }

    // 신규 달력 포맷 : FrameFilename
    if(_Frameinfo != nil && ![_Frameinfo isEqualToString:@""]) {
        if(_FrameFilename == nil || [_FrameFilename isEqualToString:@""]) {
            _FrameFilename = _Frameinfo;
        }
    }

    [[Common info] appendInteger:_AreaType to:data];
    [[Common info] appendInteger:_PageIndex to:data];
    [[Common info] appendInteger:_LayerIndex to:data];
    [[Common info] appendBoolean:_Edited to:data]; //
    [[Common info] appendBoolean:_RightContent to:data]; //
    [[Common info] appendInteger:_MaskX to:data];
    [[Common info] appendInteger:_MaskY to:data];
    [[Common info] appendInteger:_MaskW to:data];
    [[Common info] appendInteger:_MaskH to:data];
    [[Common info] appendInteger:_MaskR to:data];
    [[Common info] appendString:_MaskRotateflip to:data]; //
    [[Common info] appendFloat:_MaskAlpha to:data]; //
    [[Common info] appendString:_MaskMonotone to:data]; //
    [[Common info] appendBoolean:_MaskMultiply to:data]; //
    [[Common info] appendFloat:_MaskContrast to:data]; //
    [[Common info] appendFloat:_MaskBrightness to:data]; //
    [[Common info] appendInteger:_X to:data]; //
    [[Common info] appendInteger:_Y to:data]; //
    [[Common info] appendInteger:_W to:data]; //
    [[Common info] appendInteger:_H to:data]; //
    [[Common info] appendInteger:_R to:data]; //
    [[Common info] appendInteger:_ImageR to:data];
    [[Common info] appendInteger:_ColorMode to:data]; //
    [[Common info] appendFloat:_Contrast to:data]; //
    [[Common info] appendFloat:_Brightness to:data]; //
    [[Common info] appendBoolean:_Flip to:data]; //
    [[Common info] appendBoolean:_Flop to:data]; //
    [[Common info] appendInteger:_Alpha to:data]; //
    [[Common info] appendInteger:_Filter1 to:data]; //
    [[Common info] appendInteger:_Filter2 to:data]; //
    [[Common info] appendInteger:_Filter3 to:data]; //
    [[Common info] appendInteger:_Filter4 to:data]; //
    [[Common info] appendInteger:_Filter5 to:data]; //
    [[Common info] appendString:_FrameFilename to:data]; //
    [[Common info] appendInteger:_FrameSize to:data]; //
    [[Common info] appendInteger:_FrameColor to:data]; //
    [[Common info] appendInteger:_FrameAlpha to:data]; //
    [[Common info] appendString:_Filename to:data];
    [[Common info] appendString:_ImageFilename to:data];
    [[Common info] appendString:_ImageEditname to:data];
    [[Common info] appendInteger:_ImageOriWidth to:data];
    [[Common info] appendInteger:_ImageOriHeight to:data];
    [[Common info] appendInteger:_ImageCropX to:data];
    [[Common info] appendInteger:_ImageCropY to:data];
    [[Common info] appendInteger:_ImageCropW to:data];
    [[Common info] appendInteger:_ImageCropH to:data];
    [[Common info] appendBoolean:_NotMove to:data]; //
    [[Common info] appendBoolean:_NotDelete to:data]; //
    [[Common info] appendBoolean:_NotEdit to:data]; //
    [[Common info] appendBoolean:_Zorderlock to:data]; //
    [[Common info] appendBoolean:_Require to:data]; //
    [[Common info] appendString:_ImageDescription to:data]; //
    [[Common info] appendString:_Grouping to:data]; //
    [[Common info] appendString:_Gid to:data];
    [[Common info] appendString:_Macro to:data]; //
    [[Common info] appendString:_Halign to:data];
    [[Common info] appendString:_VAlign to:data]; //
    [[Common info] appendBoolean:_Writevertical to:data]; //
    [[Common info] appendBoolean:_Movelock to:data]; //
    [[Common info] appendBoolean:_Removelock to:data]; //
    [[Common info] appendBoolean:_Resizelock to:data]; //
    [[Common info] appendFloat:_LineGab to:data]; //
    [[Common info] appendBoolean:_TextVisible to:data]; //
    [[Common info] appendString:_TextFontname to:data];
    [[Common info] appendInteger:_TextFontsize to:data];
    [[Common info] appendInteger:_TextFontcolor to:data];
    [[Common info] appendBoolean:_TextBold to:data]; //
    [[Common info] appendBoolean:_TextItalic to:data]; //
    [[Common info] appendString:_TextDescription to:data];
    [[Common info] appendInteger:_EditImageMaxSize to:data];
    
    //photobook v2 append layer info
    /*if([Common info].photobook.depth1_key.length > 0){
        [[Common info] appendString:_str_positionSide to:data];
    }*/

    // 2017.12.14 : SJYANG : EUCKR 인코딩으로 저장하여 '뜽' 같은 글자가 저장이 안됨
    //NSLog(@"appendString:_TextDescription : %@", _TextDescription);
    //NSLog(@"_ImageR : %d", _ImageR);
    //NSLog(@"org(%dx%d) edit(%.0fx%.0f) rotate(%d)", _ImageOriWidth, _ImageOriHeight, edit_image.size.width, edit_image.size.height, _ImageR);
    //NSLog(@"org(%dx%d) rotate(%d)", _ImageOriWidth, _ImageOriHeight, _ImageR);
    //NSLog(@"crop(%d,%d,%d,%d)", _ImageCropX, _ImageCropY, _ImageCropW, _ImageCropH);

    // 10 empty loop.
    for (int i = 0; i < 10; i++) {
        [[Common info] appendLengthOnly:0 to:data]; // empty slot
    }

    return (NSData *)data;
}

- (void)loadData:(NSData *)data From:(int *)offset {
    //NSLog(@">>>> layer data.");
    _AreaType = [[[Common info] readString:data From:offset] intValue];
    _PageIndex = [[[Common info] readString:data From:offset] intValue];
    _LayerIndex = [[[Common info] readString:data From:offset] intValue];
    _Edited = [[[Common info] readString:data From:offset] boolValue];
    _RightContent = [[[Common info] readString:data From:offset] boolValue];
    _MaskX = [[[Common info] readString:data From:offset] intValue];
    _MaskY = [[[Common info] readString:data From:offset] intValue];
    _MaskW = [[[Common info] readString:data From:offset] intValue];
    _MaskH = [[[Common info] readString:data From:offset] intValue];
    _MaskR = [[[Common info] readString:data From:offset] intValue];
    _MaskRotateflip = [[Common info] readString:data From:offset];
    _MaskAlpha = [[[Common info] readString:data From:offset] floatValue];
    _MaskMonotone = [[Common info] readString:data From:offset];
    _MaskMultiply = [[[Common info] readString:data From:offset] boolValue];
    _MaskContrast = [[[Common info] readString:data From:offset] floatValue];
    _MaskBrightness = [[[Common info] readString:data From:offset] floatValue];
    _X = [[[Common info] readString:data From:offset] intValue];
    _Y = [[[Common info] readString:data From:offset] intValue];
    _W = [[[Common info] readString:data From:offset] intValue];
    _H = [[[Common info] readString:data From:offset] intValue];
    _R = [[[Common info] readString:data From:offset] intValue];
    _ImageR = [[[Common info] readString:data From:offset] intValue];
    _ColorMode = [[[Common info] readString:data From:offset] intValue];
    _Contrast = [[[Common info] readString:data From:offset] floatValue];
    _Brightness = [[[Common info] readString:data From:offset] floatValue];
    _Flip = [[[Common info] readString:data From:offset] boolValue];
    _Flop = [[[Common info] readString:data From:offset] boolValue];
    _Alpha = [[[Common info] readString:data From:offset] intValue];
    _Filter1 = [[[Common info] readString:data From:offset] intValue];
    _Filter2 = [[[Common info] readString:data From:offset] intValue];
    _Filter3 = [[[Common info] readString:data From:offset] intValue];
    _Filter4 = [[[Common info] readString:data From:offset] intValue];
    _Filter5 = [[[Common info] readString:data From:offset] intValue];
    _FrameFilename = [[Common info] readString:data From:offset];
    _FrameSize = [[[Common info] readString:data From:offset] intValue];
    _FrameColor = [[[Common info] readString:data From:offset] intValue];
    _FrameAlpha = [[[Common info] readString:data From:offset] intValue];
    _Filename = [[Common info] readString:data From:offset];
    _ImageFilename = [[Common info] readString:data From:offset];
    _ImageEditname = [[Common info] readString:data From:offset];
    _ImageOriWidth = [[[Common info] readString:data From:offset] intValue];
    _ImageOriHeight = [[[Common info] readString:data From:offset] intValue];
    _ImageCropX = [[[Common info] readString:data From:offset] intValue];
    _ImageCropY = [[[Common info] readString:data From:offset] intValue];
    _ImageCropW = [[[Common info] readString:data From:offset] intValue];
    _ImageCropH = [[[Common info] readString:data From:offset] intValue];
    _NotMove = [[[Common info] readString:data From:offset] boolValue];
    _NotDelete = [[[Common info] readString:data From:offset] boolValue];
    _NotEdit = [[[Common info] readString:data From:offset] boolValue];
    _Zorderlock = [[[Common info] readString:data From:offset] boolValue];
    _Require = [[[Common info] readString:data From:offset] boolValue];
    _ImageDescription = [[Common info] readString:data From:offset];
    _Grouping = [[Common info] readString:data From:offset];
    _Gid = [[Common info] readString:data From:offset];
    _Macro = [[Common info] readString:data From:offset];
    _Halign = [[Common info] readString:data From:offset];
    _VAlign = [[Common info] readString:data From:offset];
    _Writevertical = [[[Common info] readString:data From:offset] boolValue];
    _Movelock = [[[Common info] readString:data From:offset] boolValue];
    _Removelock = [[[Common info] readString:data From:offset] boolValue];
    _Resizelock = [[[Common info] readString:data From:offset] boolValue];
    _LineGab = [[[Common info] readString:data From:offset] floatValue];
    _TextVisible = [[[Common info] readString:data From:offset] boolValue];
    _TextFontname = [[Common info] readString:data From:offset];
    _TextFontsize = [[[Common info] readString:data From:offset] intValue];
    _TextFontcolor = [[[Common info] readString:data From:offset] intValue];
    _TextBold = [[[Common info] readString:data From:offset] boolValue];
    _TextItalic = [[[Common info] readString:data From:offset] boolValue];
    _TextDescription = [[Common info] readString:data From:offset];
    _EditImageMaxSize = [[[Common info] readString:data From:offset] intValue];
    
    //photobook v2 load layer info
    /*if([Common info].photobook.depth1_key.length > 0){
        _str_positionSide = [[Common info] readString:data From:offset];
    }*/

    // #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
    if (_AreaType == 2) {
        int a = (_TextFontcolor & 0xff000000) >> 24;
        int r = (_TextFontcolor & 0x00ff0000) >> 16;
        int g = (_TextFontcolor & 0x0000ff00) >>  8;
        int b = (_TextFontcolor & 0x000000ff);
        _text_color = [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
        //NSLog(@"load font color: %d, (%d,%d,%d,%d)",_TextFontcolor, a, r, g, b);
    }
    else if (_AreaType == 0) {
        NSLog(@"loaddata:%@", _ImageFilename);
    }

    // 10 empty loop.
    NSString *dummy = @"";
    //NSLog(@"10 empty load...");
    for (int i = 0; i < 10; i++) {
        dummy = [[Common info] readString:data From:offset];
    }
}

-(NSString *)description {
    NSString *str = [NSString stringWithFormat:@"Layer : (AreaType : %i)", self.AreaType];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageIndex : %i)", self.PageIndex]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(LayerIndex : %i)", self.LayerIndex]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(MaskX : %i)", self.MaskX]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(MaskY : %i)", self.MaskY]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(MaskW : %i)", self.MaskW]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(MaskH : %i)", self.MaskH]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(MaskR : %i)", self.MaskR]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageR : %i)", self.ImageR]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Alpha : %i)", self.Alpha]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(FrameFilename : %@)", self.FrameFilename]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(FrameAlpha : %i)", self.FrameAlpha]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Filename : %@)", self.Filename]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageFilename : %@)", self.ImageFilename]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageEditname : %@)", self.ImageEditname]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageOriWidth : %i)", self.ImageOriWidth]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageOriHeight : %i)", self.ImageOriHeight]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageCropX : %i)", self.ImageCropX]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageCropY : %i)", self.ImageCropY]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageCropW : %i)", self.ImageCropW]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ImageCropH : %i)", self.ImageCropH]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Gid : %@)", self.Gid]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Halign : %@)", self.Halign]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(TextFontname : %@)", self.TextFontname]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(TextFontsize : %i)", self.TextFontsize]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(TextFontcolor : %i)", self.TextFontcolor]];

    // 신규 달력 포맷
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(frameinfo : %@)", self.Frameinfo]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(type : %i)", self.Type]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(align : %@)", self.Align]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(fontname : %@)", self.Fontname]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(fontsize : %i)", self.Fontsize]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(fontcolor : %@)", self.Fontcolor]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(holidaycolor : %@)", self.Holidaycolor]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(fonturl : %@)", self.Fonturl]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(calid : %@)", self.Calid]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(anniversary : %@)", self.Anniversary]];

    return str;
}

@end

#pragma mark - Page
@implementation Page

- (id)init {
    if (self = [super init]) {
        _IsCover = FALSE; // 커버일 경우 true
        _IsPage = FALSE; // 일반 페이지 일 경우 true
        _IsProlog = FALSE; // 프롤로그 일 경우 true
        _IsEpilog = FALSE; // 에필로그 일 경우 true , 현재는 셋팅값없음
        _IsProject = FALSE; // 사용안함
        _IsXmlLoaded = FALSE; // 사용안함
        _PageWidth = 0; // 코디 호출시 셋팅한 page width
        _PageHeight = 0; // 코디 호출시 셋팅한 page height
        _PageFile = @"";// 코디 호출시 셋팅한 page 배경 파일
        _PageColorA = 255; // 배경의 Alpha 색상
        _PageColorR = 255;// 배경의 Red 색상
        _PageColorG = 255;// 배경의 Green 색상
        _PageColorB = 255;// 배경의 Blue 색상

        _CalendarCommonLayoutType = @"";
        _CalendarYear = 0;
        _CalendarMonth = 0;
        _Datefile = @"";

        _layers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (Page *)copy {
    Page *page = [[Page alloc] init];
    page.IsCover = _IsCover;
    page.IsPage = _IsPage;
    page.IsProlog = _IsProlog;
    page.IsEpilog = _IsEpilog;
    page.IsProject = _IsProject;
    page.IsXmlLoaded = _IsXmlLoaded;
    page.PageWidth = _PageWidth;
    page.PageHeight = _PageHeight;
    page.PageLeftWidth = _PageLeftWidth;
    page.PageMiddleWidth = _PageMiddleWidth;
    page.PageRightWidth = _PageRightWidth;
    page.PageFile = _PageFile;
    page.PageMiddleFile = _PageMiddleFile;
    page.PageRightFile = _PageRightFile;
    page.pageLayoutType = _pageLayoutType;
    page.cover_backrect = _cover_backrect;
    page.cover_middlerect = _cover_middlerect;
    page.cover_frontrect = _cover_frontrect;
    page.page_leftrect = _page_leftrect;
    page.page_rightrect = _page_rightrect;
    page.idx = _idx;
    page.PageColorA = _PageColorA;
    page.PageColorR = _PageColorR;
    page.PageColorG = _PageColorG;
    page.PageColorB = _PageColorB;
    page.PageCenterColor = _PageCenterColor;
    page.PageRightColor = _PageRightColor;

    page.CalendarCommonLayoutType = _CalendarCommonLayoutType;
    page.CalendarYear = _CalendarYear;
    page.CalendarMonth = _CalendarMonth;
    page.Datefile = _Datefile;

    page.layers = [[NSMutableArray alloc] init];
    for (Layer *layer in _layers) {
        Layer *copylayer = [layer copy];
        [page.layers addObject:copylayer];
    }
    return page;
}

- (int)getImageLayerCount {
    int count = 0;
    for (Layer *layer in _layers) {
        if (layer.AreaType == 0) {
            ++count;
        }
    }
    return count;
}

- (Layer *)point2Layer:(CGPoint)point {
    for (Layer *layer in _layers) {
        CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
        if (CGRectContainsPoint(mask_rect, point)) {
            //NSLog(@"tap:%d,%d", (int)point.x, (int)point.y);
            return layer;
        }
    }
    return nil;
}
- (Layer *)point2LayerViewPoint:(CGPoint)viewPoint scaleFactor:(CGFloat)scale_factor {
    CGFloat min_interval= 99999.0f;
    Layer *retLayer = nil;
    for (Layer *layer in _layers) {
        CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
        if (CGRectContainsPoint(mask_rect, viewPoint)) {
            
            if(min_interval > fabs(mask_rect.origin.y - viewPoint.y)){
                min_interval = fabs(mask_rect.origin.y - viewPoint.y);
                retLayer = layer;
                NSLog(@"tap:%d,%d", (int)viewPoint.x, (int)viewPoint.y);
            }
            //return layer;
        }
    }
    return retLayer;
}

- (Layer *)point2LayerOfCard:(CGPoint)point {
    for (Layer *layer in _layers) {
        if(layer.AreaType == 2) {
            CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
            if (CGRectContainsPoint(mask_rect, point)) {
                return layer;
            }
        }
        else if(layer.AreaType == 0) {
            CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
            if (CGRectContainsPoint(mask_rect, point)) {
                return layer;
            }
        }
    }
    return nil;
}

/**
 *  TEXT LAYER 우선 탐색
 */
- (Layer *)point2LayerOfCardTextFirst:(CGPoint)point {
    for (Layer *layer in _layers) {
        if(layer.AreaType == 2) {
            CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
            if (CGRectContainsPoint(mask_rect, point)) {
                return layer;
            }
        }
    }

    for (Layer *layer in _layers) {
        if(layer.AreaType == 0) {
            CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
            if (CGRectContainsPoint(mask_rect, point)) {
                return layer;
            }
        }
    }



    return nil;
}

- (Layer *)point2LayerOfPolaroidTextArea:(CGPoint)point {
    for (Layer *layer in _layers) {
        //NSLog(@"(float)layer.MaskH : %f", (float)layer.MaskH);
        if(layer.AreaType == 2) {
            if( (float)layer.MaskH <= 90.0f ) {
                //NSLog(@"HERE");
                CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY - layer.MaskH * 0.60f, layer.MaskW, layer.MaskH + layer.MaskH * 1.00f);
                //NSLog(@"HERE_RECT : %@", NSStringFromCGRect(mask_rect));
                //NSLog(@"HERE_POINT : %@", NSStringFromCGPoint(point));
                if (CGRectContainsPoint(mask_rect, point)) {
                    //NSLog(@"HERE2");
                    return layer;
                }
            }
            else {
                CGRect mask_rect = CGRectMake(layer.MaskX, layer.MaskY - layer.MaskH * 0.15f, layer.MaskW, layer.MaskH + layer.MaskH * 0.01f);
                if (CGRectContainsPoint(mask_rect, point)) {
                    return layer;
                }
            }
        }
    }
    return nil;
}

- (NSData *)saveData {
    NSMutableData *data = [[NSMutableData alloc] init];

    [[Common info] appendBoolean:_IsCover to:data];
    [[Common info] appendBoolean:_IsPage to:data];
    [[Common info] appendBoolean:_IsProlog to:data];
    [[Common info] appendBoolean:_IsEpilog to:data];
    [[Common info] appendBoolean:_IsProject to:data]; //
    [[Common info] appendBoolean:_IsXmlLoaded to:data]; //
    [[Common info] appendInteger:_PageWidth to:data];
    [[Common info] appendInteger:_PageHeight to:data];
    [[Common info] appendString:_PageFile to:data];
    [[Common info] appendInteger:_PageColorA to:data];
    [[Common info] appendInteger:_PageColorR to:data];
    [[Common info] appendInteger:_PageColorG to:data];
    [[Common info] appendInteger:_PageColorB to:data];

    [[Common info] appendString:_CalendarCommonLayoutType to:data];
    [[Common info] appendInteger:_CalendarYear to:data];
    [[Common info] appendInteger:_CalendarMonth to:data];
    
    
    //photobook v2 append page info
    if([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 ){
        [[Common info] appendString:_pageLayoutType to:data]; //String _PageKind
        [[Common info] appendInteger:_PageLeftWidth to:data];
        [[Common info] appendInteger:_PageRightWidth to:data];
        [[Common info] appendString:_PageRightFile to:data];
        [[Common info] appendInteger:_PageRightColor to:data];// int _RightPageColor;
        [[Common info] appendInteger:_PageMiddleWidth to:data];
        [[Common info] appendString:_PageMiddleFile to:data];
        [[Common info] appendInteger:_PageCenterColor to:data];// int _CenterPageColor;
    
        /*for (int i = 0; i < 8; i++) {
         [[Common info] appendString:@"" to:data]; // empty slot
         }*/
        
        [[Common info] appendString:_Datefile to:data];
        
        // 20 empty loop. -> 16 empty loop. (캘린더의 4개 필드 추가로 인해 변경)
        for (int i = 0; i < 8; i++) {
            [[Common info] appendString:@"" to:data]; // empty slot
        }
    }
    else{
        for (int i = 0; i < 8; i++) {
         [[Common info] appendString:@"" to:data]; // empty slot
        }
        
        [[Common info] appendString:_Datefile to:data];
        
        // 20 empty loop. -> 16 empty loop. (캘린더의 4개 필드 추가로 인해 변경)
        for (int i = 0; i < 8; i++) {
            [[Common info] appendString:@"" to:data]; // empty slot
        }
    }
    
    // save imagelayer
    int imagelayer_count = 0;
    for (Layer *layer in _layers) {
        if (layer.AreaType == 0) { // image layer
            imagelayer_count++;
        }
    }
    [[Common info] appendInteger:imagelayer_count to:data];
    for (Layer *layer in _layers) {
        if (layer.AreaType == 0) { // image layer
            [data appendData:[layer saveData]];
        }
    }

    // save iconlayer
    int iconlayer_count = 0;
    for (Layer *layer in _layers) {
        if (layer.AreaType == 1) { // icon layer
            iconlayer_count++;
        }
    }
    [[Common info] appendInteger:iconlayer_count to:data];
    for (Layer *layer in _layers) {
        if (layer.AreaType == 1) { // icon layer
            [data appendData:[layer saveData]];
        }
    }

    // save textLayer
    int textlayer_count = 0;
    for (Layer *layer in _layers) {
        if (layer.AreaType == 2) { // text layer
            textlayer_count++;
        }
    }
    [[Common info] appendInteger:textlayer_count to:data];
    for (Layer *layer in _layers) {
        if (layer.AreaType == 2) { // text layer
            [data appendData:[layer saveData]];
        }
    }

    // 10 empty loop.
    for (int i = 0; i < 10; i++) {
        [[Common info] appendString:@"" to:data]; // empty slot
    }
    return (NSData *)data;
}

- (void)loadData:(NSData *)data From:(int *)offset {
    //NSLog(@">>>> page data.");
    _IsCover = [[[Common info] readString:data From:offset] boolValue];
    _IsPage = [[[Common info] readString:data From:offset] boolValue];
    _IsProlog = [[[Common info] readString:data From:offset] boolValue];
    _IsEpilog = [[[Common info] readString:data From:offset] boolValue];
    _IsProject = [[[Common info] readString:data From:offset] boolValue];
    _IsXmlLoaded = [[[Common info] readString:data From:offset] boolValue];
    _PageWidth = [[[Common info] readString:data From:offset] intValue];
    _PageHeight = [[[Common info] readString:data From:offset] intValue];
    _PageFile = [[Common info] readString:data From:offset];
    _PageColorA = [[[Common info] readString:data From:offset] intValue];
    _PageColorR = [[[Common info] readString:data From:offset] intValue];
    _PageColorG = [[[Common info] readString:data From:offset] intValue];
    _PageColorB = [[[Common info] readString:data From:offset] intValue];

    _CalendarCommonLayoutType = [[Common info] readString:data From:offset];
    _CalendarYear = [[[Common info] readString:data From:offset] intValue];
    _CalendarMonth = [[[Common info] readString:data From:offset] intValue];
    
    NSString *dummy = @"";
    //photobook v2 page info load
    if([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 ){
        
        _pageLayoutType = [[Common info] readString:data From:offset]; //String _PageKind
        _PageLeftWidth = [[[Common info] readString:data From:offset]intValue];
        _PageRightWidth = [[[Common info] readString:data From:offset]intValue];
        _PageRightFile = [[Common info] readString:data From:offset];
        _PageRightColor = [[[Common info] readString:data From:offset]intValue];// int _RightPageColor;
        _PageMiddleWidth = [[[Common info] readString:data From:offset]intValue];
        _PageMiddleFile = [[Common info] readString:data From:offset];
        _PageCenterColor = [[[Common info] readString:data From:offset]intValue];// int _CenterPageColor;
        /*for (int i = 0; i < 8; i++) {
         dummy = [[Common info] readString:data From:offset];
         }*/
        _Datefile = [[Common info] readString:data From:offset];
        // (android)마그넷 : 포토부스 : 스케일
        //ByteArrayProc.writeToByteArray(pdata, ppage.getPageScale());
        
        for (int i = 0; i < 8; i++) {
            dummy = [[Common info] readString:data From:offset];
        }
    }else{
        for (int i = 0; i < 8; i++) {
         dummy = [[Common info] readString:data From:offset];
         }
        _Datefile = [[Common info] readString:data From:offset];
        // (android)마그넷 : 포토부스 : 스케일
        //ByteArrayProc.writeToByteArray(pdata, ppage.getPageScale());
        
        for (int i = 0; i < 8; i++) {
            dummy = [[Common info] readString:data From:offset];
        }
    }
    
    // 20 empty loop. -> 16 empty loop. (캘린더의 4개 필드 추가로 인해 변경)
    //NSLog(@"20 empty load...");
    
    // load layer
    //NSLog(@"imageLayer load...");
    int imagelayer_count = [[[Common info] readString:data From:offset] intValue];
    for (int i = 0; i < imagelayer_count; i++) {
        Layer *layer = [[Layer alloc] init];
        [_layers addObject:layer];

        [layer loadData:data From:offset];
    }
    //NSLog(@"iconLayer load...");
    int iconlayer_count = [[[Common info] readString:data From:offset] intValue];
    for (int i = 0; i < iconlayer_count; i++) {
        Layer *layer = [[Layer alloc] init];
        [_layers addObject:layer];

        [layer loadData:data From:offset];
    }
    //NSLog(@"textLayer load...");
    int textlayer_count = [[[Common info] readString:data From:offset] intValue];
    for (int i = 0; i < textlayer_count; i++) {
        Layer *layer = [[Layer alloc] init];
        [_layers addObject:layer];

        [layer loadData:data From:offset];
    }

    // 10 empty loop.
    //NSLog(@"10 empty load...");
    for (int i = 0; i < 10; i++) {
        dummy = [[Common info] readString:data From:offset];
    }
}


-(NSString *)description {
    NSString *str = [NSString stringWithFormat:@"Photobook : (IsCover : %@)", self.IsCover ? @"Y":@"N"];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(IsPage : %@)", self.IsPage ? @"Y":@"N"]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(IsProlog : %@)", self.IsProlog ? @"Y":@"N"]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(IsEpilog : %@)", self.IsEpilog ? @"Y":@"N"]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(IsProject : %@)", self.IsProject ? @"Y":@"N"]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(IsXmlLoaded : %@)", self.IsXmlLoaded ? @"Y":@"N"]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageWidth : %i)", self.PageWidth]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageHeight : %i)", self.PageHeight]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageColorA : %i)", self.PageColorA]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageColorR : %i)", self.PageColorR]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageColorG : %i)", self.PageColorG]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageColorB : %i)", self.PageColorB]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(CalendarYear : %i)", self.CalendarYear]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(CalendarMonth : %i)", self.CalendarMonth]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(idx : %i)", self.idx]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PageFile : %@)", self.PageFile]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(CalendarCommonLayoutType : %@)", self.CalendarCommonLayoutType]];


    return str;
}



@end

#pragma mark - Photobook
@implementation Photobook

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)clear {
    // 신규 달력 포맷
    //_FONT_SIZE_RATIO = 10.f / 8.f;
    //_FONT_SIZE_RATIO = 10.f / 8.f * 1.077f;
    _FONT_SIZE_RATIO = 10.f / 8.f * 1.077f;

    _BasketName = @"";
    _ProductId = @"";
    _ProductCode = @"";
    _ProductOption1 = @"";
    _ProductOption2 = @"";
    _ExistCover = @"";
    _DefaultCover = @"";
    _ThemeName = @"";
    _DefaultStyle = @"";
    _ThemeHangulName = @"";
    _ProductName = @"";
    _ProductType = @"";
    _ProductSize = @"";
    _ProductPrice = 0;
    _DefaultProductPrice = 0;
    _PricePerPage = 0;
    _MinPage = 0;
    _MaxPage = 0;
    _CallStyles = @"";
    _Page_PoolLayout = @"";
    _Page_PoolSkin = @"";
    _Cover_PoolLayout = @"";
    _Cover_PoolSkin = @"";
    _AddParams = @"";
    _ScodixParams = @"";
    _Size = @"";
    _Color = @"";
    _Edited = FALSE;
    _TotalPageCount = 0;

    _product_type = PRODUCT_UNKNOWN;
    _page_rect = CGRectMake(0, 0, 0, 0);
    _minpictures = 0;
    _start_year = 0;
    _start_month = 0;

    _base_folder = @"";
    _thumbs = [[NSMutableArray alloc] init];
    _scale_factor = 1.0f;
    _title = @"";
    
    _skin_url = URL_PRODUCT_PAGESKIN_PATH;

    _page_bkimage_photobook = [[UIImage imageNamed:@"photobook_page_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15) resizingMode:UIImageResizingModeTile];
    _page_bkimage_calendar = [[UIImage imageNamed:@"calendar_page_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 18, 7) resizingMode:UIImageResizingModeStretch];
    _page_bkimage_calendar2 = [[UIImage imageNamed:@"calendar_bg_border___.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 18, 7) resizingMode:UIImageResizingModeStretch];
    _page_pattern_calendar = [UIImage imageNamed:@"calendar_page_ring.png"];
    _page_bkimage_polaroid = [[UIImage imageNamed:@"polaroid_page_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];

    _warning_image = [UIImage imageNamed:@"photo_warning.png"];
    _cover_grad_image = [UIImage imageNamed:@"photobook_cover_grad.png"];
    _inner_grad_image = [UIImage imageNamed:@"photobook_inner_grad.png"];
    _cover_banner_image = [UIImage imageNamed:@"photobook_coverpage.png"];
    _blank_banner_image = [UIImage imageNamed:@"photobook_blankpage.png"];
    _blank_rvs_banner_image = [UIImage imageNamed:@"photobook_blankpage_rvs.png"]; // SJYANG : 에필로그 페이지 blank 이미지

    _useTitleHint = YES;
    _edit_scale = 1.0f;

    if (_pages != nil && _pages.count > 0) {
        [_pages removeAllObjects];
    }
    _pages = [[NSMutableArray alloc] init];

    // 신규 달력 포맷 : 폰트 로드
    _fonts = [[NSMutableDictionary alloc] init];
    _fontUrls = [[NSMutableArray alloc] init];

    [self clearAddVal];
}

- (void)dumpLog {
    if (_product_type == PRODUCT_PHOTOBOOK) {
        NSLog(@"[Photobook]");
    }
    else if (_product_type == PRODUCT_CALENDAR) {
        NSLog(@"[Calendar]");
    }
    else if (_product_type == PRODUCT_POLAROID) {
        NSLog(@"[Polaroid]");
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        NSLog(@"[DesignPhoto]");
    }
    else if (_product_type == PRODUCT_SINGLECARD) {
        NSLog(@"[SINGLECARD]");
    }
    else if (_product_type == PRODUCT_CARD) {
        NSLog(@"[Card]");
    }
    else if (_product_type == PRODUCT_PHONECASE) {
        NSLog(@"[Phonecase]");
    }
    else if (_product_type == PRODUCT_MUG) {
        NSLog(@"[Mug]");
    }
    else if (_product_type == PRODUCT_POSTCARD) {
        NSLog(@"[Postcard]");
    }
    else if (_product_type == PRODUCT_MAGNET) {
        NSLog(@"[Magnet]");
    }
    else if (_product_type == PRODUCT_BABY) {
        NSLog(@"[Baby]");
    }
    else {
        NSLog(@"[Unknown]");
    }
/*    NSLog(@"BasketName: %@", _BasketName);
    NSLog(@"ProductId: %@", _ProductId);
    NSLog(@"ProductCode: %@", _ProductCode);
    NSLog(@"ProductOption1: %@", _ProductOption1);
    NSLog(@"ProductOption1: %@", _ProductOption2);
    NSLog(@"ThemeName: %@", _ThemeName);
    NSLog(@"DefaultStyle: %@", _DefaultStyle);
    NSLog(@"ThemeHangulName: %@", _ThemeHangulName);
    NSLog(@"ProductSize: %@", _ProductSize);
    NSLog(@"ProductPrice: %d", _ProductPrice);
    NSLog(@"DefaultProductPrice: %d", _DefaultProductPrice);
    NSLog(@"PricePerPage: %d", _PricePerPage);
    NSLog(@"MinPage: %d", _MinPage);
    NSLog(@"MaxPage: %d", _MaxPage);
    NSLog(@"Edited: %d", _Edited);
    NSLog(@"TotalPageCount: %d", _TotalPageCount);

    NSLog(@"minpictures: %d", _minpictures);
    NSLog(@"start_year: %d", _start_year);
    NSLog(@"start_month: %d", _start_month);
*/
    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
/*        NSLog(@">>Page (%d).........................", i);
        NSLog(@" IsCover:%d", page.IsCover);
        NSLog(@" IsProlog:%d", page.IsProlog);
        NSLog(@" IsEpilog:%d", page.IsEpilog);
        NSLog(@" IsPage:%d", page.IsPage);
        NSLog(@" PageW/H:%dx%d", page.PageWidth, page.PageHeight);
        NSLog(@" PageFile:%@", page.PageFile);
        NSLog(@" PageColor:%d,%d,%d,%d", page.PageColorA, page.PageColorR, page.PageColorG, page.PageColorB);
        NSLog(@" CalendarCommonLayoutType:%@", page.CalendarCommonLayoutType);
        NSLog(@" CalendarYear:%d", page.CalendarYear);
        NSLog(@" CalendarMonth:%d", page.CalendarMonth);
*/
        for (Layer *layer in page.layers) {
            switch (layer.AreaType) {
                case 0: NSLog(@"  -> image layer"); break;
                case 1: NSLog(@"  -> sticker layer"); break;
                case 2: NSLog(@"  -> text layer"); break;
                default: NSLog(@"  -> unknown layer"); break;
            }
        }
    }
}

- (void)initPhotobookInfo:(BookInfo *)bookinfo ThemeInfo:(Theme *)theme {
    [self clear];

    _BasketName = @"";
    _ProductId = @""; // 주문서내 생산코드 - 전송시 규약에 맞춰 생성함.
    _ProductCode = bookinfo.productcode;
    _ProductOption1 = bookinfo.productoption1;
    _ProductOption2 = bookinfo.productoption2;
    _ExistCover = @"";
    _DefaultCover = @"";
    _ThemeName = theme.theme1_id;
    _DefaultStyle = theme.theme2_id;
    _ThemeHangulName = theme.theme_name;
    _ProductName = @"";
    _ProductType = [Common info].photobook.ProductTypeXML;
    _ProductSize = bookinfo.booksize;
    _ProductPrice = [bookinfo.price intValue];
    _DefaultProductPrice = [bookinfo.discount intValue];
    _PricePerPage = [bookinfo.addpageprice intValue];
    _MinPage = [bookinfo.minpages intValue];
    _MaxPage = [bookinfo.maxpages intValue];
    _CallStyles = @"";
    _Page_PoolLayout = @"";
    _Page_PoolSkin = @"";
    _Cover_PoolLayout = @"";
    _Cover_PoolSkin = @"";
    _AddParams = @"";
    _ScodixParams = @"";
    _Size = @"";
    _Color = @"";
    _Edited = TRUE;
    _TotalPageCount = 0;

    _realPageMarginX = 0;
    _minpictures = [bookinfo.minpictures intValue];
    _start_year = [bookinfo.startyear intValue];
    _start_month = [bookinfo.startmonth intValue];
	_monthCount = [bookinfo.monthcount intValue];
	_isDouble = [bookinfo.isdouble boolValue];
	_showSpring = [bookinfo.showspring boolValue];
	_neededPageCount = [bookinfo.totalpagecount intValue];

    // check photobook or calendar
    _product_type = [self productType:_ProductCode];
    
    //depth1, depth2 key 저장
    _depth1_key = theme.depth1_key;
    _depth2_key = theme.depth2_key;
}

- (int)productType:(NSString *)productCode {
    int product_type = PRODUCT_UNKNOWN;
    if (productCode.length >= 6) {
        NSString *type = [productCode substringWithRange:NSMakeRange(0,3)];
        if (type != nil) {
            if ([type isEqualToString:@"300"]) { // photobook
                product_type = PRODUCT_PHOTOBOOK;
            }
            else if ([type isEqualToString:@"120"]) { // 카달로그
                product_type = PRODUCT_PHOTOBOOK;
            }
            else if ([type isEqualToString:@"362"]) { // premiumbook(제니스북)
                product_type = PRODUCT_PHOTOBOOK;
            }
            else if ([type isEqualToString:@"277"] || [type isEqualToString:@"367"] || [type isEqualToString:@"368"] || [type isEqualToString:@"369"] || [type isEqualToString:@"391"] || [type isEqualToString:@"392"] || [type isEqualToString:@"393"]
					  || [type isEqualToString:@"447"] || [type isEqualToString:@"448"] || [type isEqualToString:@"449"]
					 || [type isEqualToString:@"450"] || [type isEqualToString:@"368"] || [type isEqualToString:@"451"] || [type isEqualToString:@"452"]
					 || [type isEqualToString:@"455"]) { // calendar
                product_type = PRODUCT_CALENDAR;
            }
            else if ([productCode isEqualToString:@"347036"]) {
                product_type = PRODUCT_SINGLECARD;
            }
            else if ([productCode isEqualToString:@"347062"]) {
                product_type = PRODUCT_TRANSPARENTCARD;
            }
            else if ([productCode isEqualToString:@"347037"] || // designphoto
                     [productCode isEqualToString:@"347063"] || // miniwallet
                     [productCode isEqualToString:@"347064"] // division
                     ) {
                product_type = PRODUCT_DESIGNPHOTO;
            }
            else if ([type isEqualToString:@"347"] && ![productCode isEqualToString:@"347037"]) { // polaroid
                product_type = PRODUCT_POLAROID;
            }
            else if ([type isEqualToString:@"376"] || [type isEqualToString:@"377"] || [type isEqualToString:@"378"] || [type isEqualToString:@"434"]) {
                product_type = PRODUCT_CARD;
            }
            else if ([type isEqualToString:@"350"] || [type isEqualToString:@"351"] || [type isEqualToString:@"356"] || [type isEqualToString:@"436"]) { // frame
                product_type = PRODUCT_FRAME;
            }
            else if ([type isEqualToString:@"357"]) {
                product_type = PRODUCT_MUG;
            }
            else if ([type isEqualToString:@"360"] || [type isEqualToString:@"363"]) {
                product_type = PRODUCT_PHONECASE;
            }
            else if ([type isEqualToString:@"359"]) {
                product_type = PRODUCT_POSTCARD;
            }
            else if ([type isEqualToString:@"400"] || [type isEqualToString:@"401"] || [type isEqualToString:@"402"] || [type isEqualToString:@"403"] || [type isEqualToString:@"404"]) {
                product_type = PRODUCT_MAGNET;
            }
            else if ([type isEqualToString:@"366"]) {
                product_type = PRODUCT_BABY;
            }
            else if ([type isEqualToString:@"413"]) {
                product_type = PRODUCT_POSTER;
            }
            else if ([type isEqualToString:@"414"]) {
                product_type = PRODUCT_PAPERSLOGAN;
            }
            else if ([type isEqualToString:@"433"]) {
                product_type = PRODUCT_DIVISIONSTICKER;
            }
            
        }
    }
    return product_type;
}

- (BOOL)initPhotobookPagesLocal{
    pageNum = 0;
    _pages = [[NSMutableArray alloc] init];
    return YES;
}

- (BOOL)initPhotobookPages {
    NSString *intnum = @"";
    @try {
        intnum = [_ProductCode substringWithRange:NSMakeRange(0, 3)];
    }
    @catch(NSException *exception) {}

    pageNum = 0;
    _pages = [[NSMutableArray alloc] init];
    NSString *url = @"";
    if (_product_type == PRODUCT_PHOTOBOOK) {
        url = URL_PHOTOBOOK_EDIT;
    }
    else if (_product_type == PRODUCT_CALENDAR) {
        url = URL_CALENDAR_EDIT;
    }
    else if (_product_type == PRODUCT_POLAROID) {
        url = URL_POLAROID_EDIT;
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        url = URL_DESIGNPHOTO_EDIT;
    }
    else if (_product_type == PRODUCT_SINGLECARD) {
        url = URL_DESIGNPHOTO_EDIT;
    }
    else if (_product_type == PRODUCT_CARD) {
        url = URL_CARD_EDIT;
    }
    else if (_product_type == PRODUCT_MUG) {
        url = URL_GIFT_EDIT;
    }
    else if (_product_type == PRODUCT_PHONECASE) {
        url = URL_GIFT_EDIT;
    }
    else if (_product_type == PRODUCT_POSTCARD) {
        url = URL_GIFT_EDIT;
    }
    else if (_product_type == PRODUCT_MAGNET) {
        url = URL_GIFT_EDIT;
    }
    else if (_product_type == PRODUCT_BABY) {
    }
    else if (_product_type == PRODUCT_POSTER) {
        url = URL_POSTER_EDIT;
    }
    else if (_product_type == PRODUCT_PAPERSLOGAN || _product_type == PRODUCT_DIVISIONSTICKER) {
        url = URL_FANCY_EDIT;
    }
    else if (_product_type == PRODUCT_TRANSPARENTCARD) {
        url = URL_DESIGNPHOTO_EDIT;
    }
    else if (_product_type == PRODUCT_FRAME) {
        NSAssert(NO, @"initPhotobookPages: product type is wrong..");
    }
    else {
        NSAssert(NO, @"initPhotobookPages: product type is wrong..");
    }

    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        //NSLog(@">> photobook(calendar) theme info xml: %@", data);
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return FALSE;
        }
    }

    if (_pages.count <= 0) {
        NSLog(@"DEBUG :: page count is 0");
        return FALSE;
    }

    // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    if ([_ProductCode isEqualToString:@"300270"]) {
        if (_minpictures > 0) {
            int nImageLayers = 0;
            for (Page *page in _pages) {
                for (Layer *layer in page.layers) {
                    if (layer.AreaType == 0) { // 0: image
                        nImageLayers++;
                    }
                }
            }
            int t = 0;

            if (nImageLayers > _minpictures) {
                @try {
                    t = (int)_pages.count - 1;
                    while (true) {
                        int nImageLayersPerPage = 0;
                        Page* page = _pages[t];
                        for (Layer *layer in page.layers) {
                            if (layer.AreaType == 0) { // 0: image
                                nImageLayersPerPage++;
                            }
                        }
                        if( nImageLayersPerPage == (nImageLayers - _minpictures) )
                            break;
                        t--;
                    }
                }
                @catch (NSException *e) {
                    t = (int)_pages.count - 1;
                    @try {
                        int surplusLayoutCnt = nImageLayers - _minpictures;
                        if (surplusLayoutCnt > 0) {
                            for (int i = 0; i < surplusLayoutCnt; i++) {
                                Page *page = _pages[t];
                                for (int x=0;x<page.layers.count;x++) {
                                    Layer *layer = page.layers[x];
                                    if (layer.AreaType == 0) { // 0: image
                                        [page.layers removeObjectAtIndex:x];
                                    }
                                }
                            }
                        } else {
                            // SJYANG : 더 이상 이미지를 넣을 레이아웃 공간이 없을 떄의 처리
                            t = 1;
                        }
                    }
                    @catch (NSException *e) {
                        t = 1;
                    }
                }
            }
            if (t > 0) {
                Page* replacement = [_pages[t] copy];
                [_pages removeObjectAtIndex:_pages.count - 1];
                [_pages addObject:replacement];
            }
        }
    }

    if (_product_type == PRODUCT_CALENDAR) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        Page *epilog = nil;
		
		int calPageCount = _neededPageCount;
		
        for (Page *page in _pages) {
            if (page.IsCover) {
                [tempArray addObject:page];
            }
            else if (page.IsPage) {
                int yearmonth = page.CalendarYear*100 + page.CalendarMonth;
                int start_yearmonth = _start_year*100 + _start_month;
				// 포스터 달력 관련 코드 추가
                if (yearmonth >= start_yearmonth || [intnum isEqualToString:@"393"]) {
                    [tempArray addObject:page];
                }
            }
            else if (page.IsEpilog) {
                epilog = page;
				calPageCount--;
            }
			
			if (tempArray.count >= calPageCount) break;
			
//            if (tempArray.count >= (14 * 2 + 2 - 1) && [intnum isEqualToString:@"277"]) break;
//            if (tempArray.count >= (12 + 2 - 1) && [intnum isEqualToString:@"367"]) break;
//            if (tempArray.count >= (14 + 2 - 1) && [intnum isEqualToString:@"368"]) break;
//            if (tempArray.count >= (15 * 2 + 1) && [intnum isEqualToString:@"369"]) break; // 우드스탠드는 에필로그가 없으므로, 이렇게 계산
//            // SJYANG : 2018 달력
//            if (tempArray.count >= (14 + 2 - 1) && [intnum isEqualToString:@"391"]) break;
//            if (tempArray.count >= (12 + 2 - 1) && [intnum isEqualToString:@"392"]) break;
//			// 포스터 달력 관련 코드 추가
//            if (tempArray.count >= 1 && [intnum isEqualToString:@"393"]) break;
        }
        if (epilog != nil) {
            [tempArray addObject:epilog];
        }
        //NSLog(@"tempArray.count : %d", tempArray.count);
        [_pages removeAllObjects];
        _pages = tempArray;

		if (_pages.count != _neededPageCount) return FALSE;

//        if (_pages.count != (14 * 2 + 2) && [intnum isEqualToString:@"277"]) return FALSE;
//        if (_pages.count != (12 + 2) && [intnum isEqualToString:@"367"]) return FALSE;
//        if (_pages.count != (14 + 2) && [intnum isEqualToString:@"368"]) return FALSE;
//        if (_pages.count != (15 * 2 + 1) && [intnum isEqualToString:@"369"]) return FALSE;
//        // SJYANG : 2018 달력
//        if (_pages.count != (14 + 2) && [intnum isEqualToString:@"391"]) return FALSE;
//        if (_pages.count != (12 + 2) && [intnum isEqualToString:@"392"]) return FALSE;
//		// 포스터 달력 관련 코드 추가
//        if (_pages.count != 1 && [intnum isEqualToString:@"393"]) return FALSE;
    }
	// 마그넷 : minpictures, maxpage, minpage 계산
    else if (_product_type == PRODUCT_MAGNET) {
		int nPages = 0;
		int nLayers = 0;
		for (Page *page in _pages) {
			for (Layer *layer in page.layers) {
				if (layer.AreaType == 0) { // 0: image
					nLayers++;
				}
			}
			nPages++;
		}
		_minpictures = nLayers;
		_MinPage = _MaxPage = nPages;
	}

    return TRUE;
}
- (BOOL)initPhotobookV2CodyPages:(int)type paramDepth1Key:(NSString*)depth1 paramDepth2Key:(NSString*)depth2 paramProductOption1:(NSString*)productoption1{
    NSString *intnum = @"";
    
    @try {
        intnum = [_ProductCode substringWithRange:NSMakeRange(0, 3)];
    }
    @catch(NSException *exception) {}
    
    pageNum = 0;
    _pages = [[NSMutableArray alloc] init];
    NSString *url = @"";
    if (_product_type == PRODUCT_PHOTOBOOK) {
        url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_CODY, depth1, depth2, productoption1];
    }
    else {
        NSAssert(NO, @"initPhotobookV2CodyPages: product type is wrong..");
    }
    
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook(cody) info xml: %@", data);
        //파싱이 안되서 encoding 속성을 euc-kr에서 utf-8로 수정하여 재인코딩해보니까 파싱이 성공함
        //인코딩 자체는 상관이 없는것 같고 encoding속성이 euc-kr로 되어있으면 파싱이 안되는듯
        data = [data stringByReplacingOccurrencesOfString:@"euc-kr" withString:@"utf-8"];
        NSData *ret_valEncoding =  [data dataUsingEncoding:NSUTF8StringEncoding];
        //[str dataUsingEncoding:NSUTF8StringEncoding];
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_valEncoding];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return FALSE;
        }
    }
    
    if (_pages.count <= 0) {
        NSLog(@"DEBUG :: page count is 0");
        return FALSE;
    }
    
    if(_product_type == PRODUCT_PHOTOBOOK){
        NSMutableArray *newPhotobookPages = [[NSMutableArray alloc] init];
        
        for (Page *page in _pages) {
            Page *newPage = [page copy];
            
            if([newPage.pageLayoutType isEqualToString:@"coverback"]){
                //newPage.PageFile = newPage.PageFile;
                newPage.PageWidth = newPage.cover_backrect.size.width;
                newPage.PageHeight = newPage.cover_backrect.size.height;
                
                for (Layer *layer in newPage.layers) {
                    layer.str_positionSide = @"L";
                }
                
                [newPhotobookPages addObject:newPage];
            }
            else if([newPage.pageLayoutType isEqualToString:@"covermiddle"]){
                Page *coverPage = [newPhotobookPages firstObject];
                coverPage.PageMiddleFile = newPage.PageFile;
                coverPage.PageMiddleWidth = newPage.PageMiddleWidth;
                coverPage.cover_middlerect = CGRectMake(coverPage.PageWidth,0, newPage.cover_middlerect.size.width, newPage.cover_middlerect.size.height);
                coverPage.PageCenterColor = [self rgbaIntegerWithColor:newPage.PageColorR green:newPage.PageColorG blue:newPage.PageColorB alpha:newPage.PageColorA ];
                
                for (Layer *layer in newPage.layers) {
                    layer.MaskX += coverPage.PageWidth;
                    layer.str_positionSide = @"C";
                    [coverPage.layers addObject:layer];
                }
                coverPage.PageWidth += coverPage.PageMiddleWidth;
            }
            else if([newPage.pageLayoutType isEqualToString:@"coverfront"]){
                Page *coverPage = [newPhotobookPages firstObject];
                coverPage.PageRightFile = newPage.PageFile;
                coverPage.PageRightWidth = newPage.PageRightWidth;
                coverPage.cover_frontrect = CGRectMake(coverPage.PageWidth,0, newPage.cover_frontrect.size.width, newPage.cover_frontrect.size.height);
                
                coverPage.PageRightColor = [self rgbaIntegerWithColor:newPage.PageColorR green:newPage.PageColorG blue:newPage.PageColorB alpha:newPage.PageColorA ];
                
                for (Layer *layer in newPage.layers) {
                    layer.MaskX += coverPage.PageWidth;
                    layer.str_positionSide = @"R";
                    [coverPage.layers addObject:layer];
                }
                coverPage.PageWidth += coverPage.PageRightWidth;
            }
            else if([[newPage.pageLayoutType lowercaseString] isEqualToString:@"prolog"]){
                
                newPage.page_leftrect = CGRectMake(0,0, newPage.PageWidth, newPage.PageHeight);
                [newPhotobookPages addObject:newPage];
            }
            else if([newPage.pageLayoutType isEqualToString:@"page"]){
                if(newPage.idx == 0){
                    Page *currentPage = [newPhotobookPages lastObject];
                    currentPage.PageRightFile = newPage.PageFile;
                    currentPage.PageRightWidth = newPage.PageLeftWidth;
                    currentPage.page_rightrect = CGRectMake(currentPage.PageWidth,0, newPage.PageWidth, newPage.PageHeight);
                    
                    currentPage.PageRightColor = [self rgbaIntegerWithColor:newPage.PageColorR green:newPage.PageColorG blue:newPage.PageColorB alpha:newPage.PageColorA ];
                    
                    for (Layer *layer in newPage.layers) {
                        layer.MaskX += currentPage.PageWidth;
                        layer.str_positionSide = @"R";
                        [currentPage.layers addObject:layer];
                    }
                    currentPage.PageWidth += currentPage.PageRightWidth;
                }
                else if (newPage.idx == 1 || newPage.idx % 2 == 1){
                    
                    newPage.page_leftrect = CGRectMake(0,0, newPage.PageWidth, newPage.PageHeight);
                    for (Layer *layer in newPage.layers) {
                      layer.str_positionSide = @"L";
                    }
                    [newPhotobookPages addObject:newPage];
                }
                else{
                    Page *currentPage = [newPhotobookPages lastObject];
                    currentPage.PageRightFile = newPage.PageFile;
                    currentPage.PageRightWidth = newPage.PageLeftWidth;
                    currentPage.page_rightrect = CGRectMake(currentPage.PageWidth,0, newPage.PageWidth, newPage.PageHeight);
                    
                    currentPage.PageRightColor = [self rgbaIntegerWithColor:newPage.PageColorR green:newPage.PageColorG blue:newPage.PageColorB alpha:newPage.PageColorA ];
                    
                    for (Layer *layer in newPage.layers) {
                        layer.MaskX += currentPage.PageWidth;
                        layer.str_positionSide = @"R";
                        [currentPage.layers addObject:layer];
                    }
                    currentPage.PageWidth += currentPage.PageRightWidth;
                }
                
            }
            else if([[newPage.pageLayoutType lowercaseString] isEqualToString:@"epilog"]){
                [newPhotobookPages addObject:newPage];
            }
            
        }
        _pages = newPhotobookPages;
    }
    
    // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    if ([_ProductCode isEqualToString:@"300270"]) {
        if (_minpictures > 0) {
            int nImageLayers = 0;
            for (Page *page in _pages) {
                for (Layer *layer in page.layers) {
                    if (layer.AreaType == 0) { // 0: image
                        nImageLayers++;
                    }
                }
            }
            int t = 0;
            
            if (nImageLayers > _minpictures) {
                @try {
                    t = (int)_pages.count - 1;
                    while (true) {
                        int nImageLayersPerPage = 0;
                        Page* page = _pages[t];
                        for (Layer *layer in page.layers) {
                            if (layer.AreaType == 0) { // 0: image
                                nImageLayersPerPage++;
                            }
                        }
                        if( nImageLayersPerPage == (nImageLayers - _minpictures) )
                            break;
                        t--;
                    }
                }
                @catch (NSException *e) {
                    t = (int)_pages.count - 1;
                    @try {
                        int surplusLayoutCnt = nImageLayers - _minpictures;
                        if (surplusLayoutCnt > 0) {
                            for (int i = 0; i < surplusLayoutCnt; i++) {
                                Page *page = _pages[t];
                                for (int x=0;x<page.layers.count;x++) {
                                    Layer *layer = page.layers[x];
                                    if (layer.AreaType == 0) { // 0: image
                                        [page.layers removeObjectAtIndex:x];
                                    }
                                }
                            }
                        } else {
                            // SJYANG : 더 이상 이미지를 넣을 레이아웃 공간이 없을 떄의 처리
                            t = 1;
                        }
                    }
                    @catch (NSException *e) {
                        t = 1;
                    }
                }
            }
            if (t > 0) {
                Page* replacement = [_pages[t] copy];
                [_pages removeObjectAtIndex:_pages.count - 1];
                [_pages addObject:replacement];
            }
        }
    }
    
    if (_product_type == PRODUCT_CALENDAR) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        Page *epilog = nil;
        for (Page *page in _pages) {
            if (page.IsCover) {
                [tempArray addObject:page];
            }
            else if (page.IsPage) {
                int yearmonth = page.CalendarYear*100 + page.CalendarMonth;
                int start_yearmonth = _start_year*100 + _start_month;
                // 포스터 달력 관련 코드 추가
                if (yearmonth >= start_yearmonth || [intnum isEqualToString:@"393"]) {
                    [tempArray addObject:page];
                }
            }
            else if (page.IsEpilog) {
                epilog = page;
            }
            if (tempArray.count >= (14 * 2 + 2 - 1) && [intnum isEqualToString:@"277"]) break;
            if (tempArray.count >= (12 + 2 - 1) && [intnum isEqualToString:@"367"]) break;
            if (tempArray.count >= (14 + 2 - 1) && [intnum isEqualToString:@"368"]) break;
            if (tempArray.count >= (15 * 2 + 1) && [intnum isEqualToString:@"369"]) break; // 우드스탠드는 에필로그가 없으므로, 이렇게 계산
            // SJYANG : 2018 달력
            if (tempArray.count >= (14 + 2 - 1) && [intnum isEqualToString:@"391"]) break;
            if (tempArray.count >= (12 + 2 - 1) && [intnum isEqualToString:@"392"]) break;
            // 포스터 달력 관련 코드 추가
            if (tempArray.count >= 1 && [intnum isEqualToString:@"393"]) break;
        }
        if (epilog != nil) {
            [tempArray addObject:epilog];
        }
        //NSLog(@"tempArray.count : %d", tempArray.count);
        [_pages removeAllObjects];
        _pages = tempArray;
        
        if (_pages.count != (14 * 2 + 2) && [intnum isEqualToString:@"277"]) return FALSE;
        if (_pages.count != (12 + 2) && [intnum isEqualToString:@"367"]) return FALSE;
        if (_pages.count != (14 + 2) && [intnum isEqualToString:@"368"]) return FALSE;
        if (_pages.count != (15 * 2 + 1) && [intnum isEqualToString:@"369"]) return FALSE;
        // SJYANG : 2018 달력
        if (_pages.count != (14 + 2) && [intnum isEqualToString:@"391"]) return FALSE;
        if (_pages.count != (12 + 2) && [intnum isEqualToString:@"392"]) return FALSE;
        // 포스터 달력 관련 코드 추가
        if (_pages.count != 1 && [intnum isEqualToString:@"393"]) return FALSE;
    }
    // 마그넷 : minpictures, maxpage, minpage 계산
    else if (_product_type == PRODUCT_MAGNET) {
        int nPages = 0;
        int nLayers = 0;
        for (Page *page in _pages) {
            for (Layer *layer in page.layers) {
                if (layer.AreaType == 0) { // 0: image
                    nLayers++;
                }
            }
            nPages++;
        }
        _minpictures = nLayers;
        _MinPage = _MaxPage = nPages;
    }
    
    return TRUE;
}

- (int)needPhotobookPageCount {
    if (_product_type == PRODUCT_PHOTOBOOK) {
        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
        /*
        if ([_ProductCode isEqualToString:@"300269"] || [_ProductCode isEqualToString:@"300270"]) { //[_ThemeName isEqualToString:@"analogue"]) {
            return _MaxPage/2;
        }
        */
        /*
        if ([_ProductCode isEqualToString:@"300268"]) {
            //return 101;
            return _MaxPage/2;
        }
        */
        if ([_ProductCode isEqualToString:@"300267"]) {
            return 12;
        }
        else if ([_ProductCode isEqualToString:@"300270"]) {
            return 12;
        }
        else if ([_ProductCode isEqualToString:@"300269"]) {
            return 8;
        }
        // SJYANG : 스키니북
        else if ([_ProductCode isEqualToString:@"300180"]) {
            return 12;
        }
        // SJYANG : 카달로그
        else if ([_ProductCode isEqualToString:@"120069"]) {
            return 12;
        }
        // 구닥북
        else if ([[Common info] isGudakBook:_ProductCode]) {
            return 12;
        }

        int photo_count = (int)[Common info].photo_pool.sel_photos.count;
        photo_count += [[Instagram info] selectedCount];

        int total_count = [self getImageLayerCount];
        if (photo_count <= total_count) {
            return (int)_pages.count;
        }

        int page_max = (_MaxPage + 3)/2;
        int page_index = 2;
        for (int i = (int)_pages.count+1; i < page_max; i++) {

            Page *page = _pages[page_index++];
            total_count += [page getImageLayerCount];
            if (photo_count <= total_count) {
                return i;
            }
            if (page_index >= (int)_pages.count) {
                page_index = 2;
            }
        }
        return page_max;
    }
    else if (_product_type == PRODUCT_CALENDAR) {
//        NSString *intnum = @"";
//        @try {
//            intnum = [_ProductCode substringWithRange:NSMakeRange(0, 3)];
//        }
//        @catch(NSException *exception) {}

//        if ([intnum isEqualToString:@"277"]) return (14 * 2 + 2);
//        else if ([intnum isEqualToString:@"367"]) return (12 + 2);
//        else if ([intnum isEqualToString:@"368"]) return (14 + 2);
//        else if ([intnum isEqualToString:@"369"]) return (15 * 2 + 1);
//        // SJYANG : 2018 달력
//        else if ([intnum isEqualToString:@"391"]) return (14 + 2);
//        else if ([intnum isEqualToString:@"392"]) return (12 + 2);
//        else if ([intnum isEqualToString:@"393"]) return 1;
//        else return CALENDAR_PAGE_MAX;
		
		return _neededPageCount;
    }
    else if (_product_type == PRODUCT_POLAROID) {
        if ([_ProductCode isEqualToString:@"347034"]) { // 우드&코팅없음
            _minpictures = 18;
        }
        else if ([_ProductCode isEqualToString:@"347054"]) { // 우드&반짝블록
            _minpictures = 17;
        }
        else if ([_ProductCode isEqualToString:@"347055"] || [_ProductCode isEqualToString:@"347056"] || [_ProductCode isEqualToString:@"347057"]) {  // 스탠딩폴라
            _minpictures = 10;
        }
		else if ([_ProductCode isEqualToString:@"347031"] || [_ProductCode isEqualToString:@"347032"]){
			//레트로 폴라로이드는 아무거도 안건드림
        }
        else if ([_ProductCode isEqualToString:@"347033"]){
            //스퀘어 포토 사진인화 최소페이지 처리 (처리가 안되서 1로 처리하는 문제가 있었음)
        }
		else {
            _minpictures = 1;
        }
        NSLog(@"minpics: %d", _minpictures);
        return _minpictures;
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        return 8;
    }
    else if (_product_type == PRODUCT_SINGLECARD) {
        return 2;
    }
    else if (_product_type == PRODUCT_MUG) {
        return _minpictures;
    }
    else if (_product_type == PRODUCT_PHONECASE) {
        return _minpictures;
    }
    else if (_product_type == PRODUCT_CARD) {
        return 4;
    }
    else if (_product_type == PRODUCT_POSTCARD) {
        return _MinPage; // _MinPage == _MaxPage (Detail화면 옵션에서 8p or 24p로 세팅됨)
    }
	// TODO : 마그넷 : 체크 필요
    else if (_product_type == PRODUCT_MAGNET) {
        return _MinPage; // _MinPage == _MaxPage (Detail화면 옵션에서 8p or 24p로 세팅됨)
    }
    else if (_product_type == PRODUCT_BABY) {
        return _minpictures;
    }
    else if (_product_type == PRODUCT_POSTER) {
        return _MinPage;
    }
    else if (_product_type == PRODUCT_PAPERSLOGAN || _product_type == PRODUCT_DIVISIONSTICKER ) {
        return _MinPage;
    }
    else if (_product_type == PRODUCT_TRANSPARENTCARD) {
        return _MinPage;
    }
    NSAssert(NO, @"needPhotobookPageCount: product type mismatch !!");
    return 0;
}

- (void)fillPhotobookPages {
    NSString *intnum = @"";
    @try {
        intnum = [_ProductCode substringWithRange:NSMakeRange(0, 3)];
    }
    @catch(NSException *exception) {}
    
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR) {
        _skin_url = URL_CALENDAR_PAGESKIN_PATH;
    }
    else if (
             [intnum isEqualToString:@"434"]
             || [intnum isEqualToString:@"378"]
             || [_ProductCode isEqualToString:@"347063"]
             || [_ProductCode isEqualToString:@"347064"]
             || [_ProductCode isEqualToString:@"436001"]
             || _product_type == PRODUCT_DIVISIONSTICKER
         ){
        _skin_url = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
    }else if(_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0  || [Common info].photobook.ProductType.length > 0 )){
        _skin_url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_SKIN_PATH, [Common info].connection.tplServerInfo];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *docPath = [[Common info] documentPath];  // 도큐먼트 폴더 찾기
    NSString *folderName = [[Common info] timeString]; // 포토북 폴더명 생성
    NSString *baseFolder = [NSString stringWithFormat:@"%@/%@", docPath, folderName];

    if (_product_type == PRODUCT_MUG) {
        baseFolder = [NSString stringWithFormat:@"%@/mug", docPath];
    }
    else if (_product_type == PRODUCT_PHONECASE) {
        baseFolder = [NSString stringWithFormat:@"%@/phonecase", docPath];
    }
    else if (_product_type == PRODUCT_BABY) {
        baseFolder = [NSString stringWithFormat:@"%@/baby", docPath];
    }

    _base_folder = baseFolder;
    _BasketName = [[Common info] timeStringForTitle];
    if(_product_type == PRODUCT_CARD) {
        if(_ProductId == nil || [_ProductId isEqualToString:@""])
            _ProductId = [[Common info] createProductId:_ProductCode];
    }
    else {
        _ProductId = [[Common info] createProductId:_ProductCode];
    }

    if ([fileManager createDirectoryAtPath:baseFolder withIntermediateDirectories:YES attributes:nil error:NULL] == YES) {
        // 원본/편집본 폴더 생성
        NSString *orgFolder = [NSString stringWithFormat:@"%@/org", baseFolder];
        NSString *editFolder = [NSString stringWithFormat:@"%@/edit", baseFolder];
        NSString *thumbFolder = [NSString stringWithFormat:@"%@/thumb", baseFolder];
        NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", baseFolder];
        NSString *fontFolder = [NSString stringWithFormat:@"%@/fonts", baseFolder];
        BOOL isOrgSuccess = [fileManager createDirectoryAtPath:orgFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL isEditSuccess = [fileManager createDirectoryAtPath:editFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL isThumbSuccess = [fileManager createDirectoryAtPath:thumbFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL isTempSuccess = [fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL isFontSuccess = [fileManager createDirectoryAtPath:fontFolder withIntermediateDirectories:YES attributes:nil error:NULL];

        if (isOrgSuccess && isEditSuccess && isThumbSuccess && isTempSuccess) {
            int page_max = [self needPhotobookPageCount];

            if (_product_type == PRODUCT_POSTCARD && _pages.count < page_max) {
                int add_count = page_max - (int)_pages.count;
                for (int i = 0; i < add_count; i++) {
                    Page *page = [_pages[i] copy];
                    [_pages addObject:page];
                    //NSLog(@"%d번째 페이지복사해서 %d번째에 추가됨", i+1, _pages.count);
                }
            }

            // SJYANG
            // 프리미엄북 : 마지막 페이지를 에필로그 페이지로 별도 저장
            Page* epilog_page = nil;
            BOOL epilog_page_added = NO;

            if( [_ThemeName isEqualToString:@"premium"] ) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for(int i = 0; i < _pages.count-1; i++) {
                    [tempArray addObject:_pages[i]];
                }
                epilog_page = _pages[_pages.count-1];
                [_pages removeAllObjects];
                _pages = tempArray;
            }

            //
            int pick_index_insta = 0;
            int pick_index = 0;
            for (int i = 0; i < _pages.count; i++) { // MinPage까지 완성
                Page *page = _pages[i];
                [_delegate photobookProcess:i+1 TotalCount:page_max];

                if (page.PageFile.length > 0) {

                    if ([[Common info].photobook.ProductCode isEqualToString:@"300479"]) { // 소프트커버
                        page.PageFile = [page.PageFile stringByReplacingOccurrencesOfString:@"_ha_"
                                                                       withString:@"_so_"];
                    }
                    if(_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0  || [Common info].photobook.ProductType.length > 0 )){
                        if(page.IsCover){
                            NSURL *backImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                            NSURL *middleImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageMiddleFile]];
                            NSURL *frontImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageRightFile]];
                            NSString *backImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                            NSString *middleImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageMiddleFile];
                            NSString *frontImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageRightFile];
                            [[Common info] downloadImage:backImgUrl ToFile:backImgLocalPathName];
                            [[Common info] downloadImage:middleImgUrl ToFile:middleImgLocalPathName];
                            [[Common info] downloadImage:frontImgUrl ToFile:frontImgLocalPathName];
                        }else if(page.IsProlog){
                            /*NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                            NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                            [[Common info] downloadImage:url ToFile:localpathname];*/
                            NSURL *leftImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                            NSURL *rightImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageRightFile]];
                            
                            NSString *leftImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                            NSString *rightImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageRightFile];
                            
                            [[Common info] downloadImage:leftImgUrl ToFile:leftImgLocalPathName];
                            [[Common info] downloadImage:rightImgUrl ToFile:rightImgLocalPathName];
                        }else if(page.IsEpilog){
                            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                            NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                            [[Common info] downloadImage:url ToFile:localpathname];
                        }
                        else if(page.IsPage){
                            NSURL *leftImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                            NSURL *rightImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageRightFile]];
                            
                            NSString *leftImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                            NSString *rightImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageRightFile];
                            
                            [[Common info] downloadImage:leftImgUrl ToFile:leftImgLocalPathName];
                            [[Common info] downloadImage:rightImgUrl ToFile:rightImgLocalPathName];
                            
                        }
                        
                    }
                    else{
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                        [[Common info] downloadImage:url ToFile:localpathname];
                    }

                    
                }

                for (Layer *layer in page.layers) {
                    if (layer.AreaType == 0) { // 0: image
						//PhotoContainer
						
//                        InstaPhoto *insta_photo = [self pickInstaPhoto:pick_index_insta];
//                        if (insta_photo != nil) {
//                            [self addPhotoFromInstagram:insta_photo Layer:layer PickIndex:pick_index_insta];
//                            pick_index_insta++;
//                        }
//                        else {
//                            Photo *photo = [self pickPhoto:pick_index];   // 선택된 사진을 꺼내어 레이어에 순서내로 할당한다.
//                            [self addPhoto:photo Layer:layer PickIndex:pick_index];
//                            pick_index++;
//                        }
						PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:pick_index];
						if (photoItem) {
							[self addPhotoNew:photoItem Layer:layer PickIndex:pick_index];
							pick_index++;
						}
//					InstaPhoto *insta_photo = [self pickInstaPhoto:pick_index_insta];
//					if (insta_photo != nil) {
//						[self addPhotoFromInstagram:insta_photo Layer:layer PickIndex:pick_index_insta];
//						pick_index_insta++;
//					}
//					else {
//						Photo *photo = [self pickPhoto:pick_index];   // 선택된 사진을 꺼내어 레이어에 순서내로 할당한다.
//						[self addPhoto:photo Layer:layer PickIndex:pick_index];
//						pick_index++;
//					}

						if (layer.FrameFilename.length > 0) {
                            NSURL *url;
                            if(_product_type == PRODUCT_CALENDAR)
                            {
                                NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.FrameFilename]];
                            }
                            else if(_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 )){ //photobook v2 clipartpath
                                NSString *host = [NSString stringWithFormat:URL_PHOTOBOOK_V2_CLIPART_PATH, [Common info].connection.tplServerInfo];
                                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.FrameFilename]];
                            }
                            else {
                                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.FrameFilename]];
                            }
                            
                            NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, layer.FrameFilename];
                            [[Common info] downloadImage:url ToFile:localpathname];
                        }
                        // 신규 달력 포맷 : frameinfo
                        if (layer.Frameinfo.length > 0) {
                            NSString *frameInfoFile = @"";
                            NSString *cutFrameInfoFile = @"";

                            NSArray *tarr = [layer.Frameinfo componentsSeparatedByString:@"^"];
                            frameInfoFile = [tarr objectAtIndex:0];
                            if([tarr count] > 1)
                                cutFrameInfoFile = [tarr objectAtIndex:1];

                            if(frameInfoFile.length > 0) {
                                NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, frameInfoFile]];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, frameInfoFile];
                                [[Common info] downloadImage:url ToFile:localpathname];
                            }
                            if(cutFrameInfoFile.length > 0) {
                                NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, cutFrameInfoFile]];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, cutFrameInfoFile];
                                [[Common info] downloadImage:url ToFile:localpathname];
                            }
                        }
                    }
                    else if (layer.AreaType == 1) { // 1:icon
                        NSURL *url;
                        if(_product_type == PRODUCT_CALENDAR || _product_type == PRODUCT_CARD)
                        {
                            NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.Filename]];
                        }
                        else if(_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 )){
                            NSString *host = [NSString stringWithFormat:URL_PHOTOBOOK_V2_CLIPART_PATH, [Common info].connection.tplServerInfo];
                            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.Filename]];
                        }
                        else{
                            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.Filename]];
                        }
                        
                        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, layer.Filename];
                        [[Common info] downloadImage:url ToFile:localpathname];
                    }
                    else if (layer.AreaType == 3) { // 마그넷 : guideinfo
                        if (_product_type == PRODUCT_MAGNET && layer.SkinFilename !=nil && layer.SkinFilename.length > 0) {
		                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, layer.SkinFilename]];
                            NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, layer.SkinFilename];
                            [[Common info] downloadImage:url ToFile:localpathname];
                        }
                    }
                }
            }

            if (_product_type == PRODUCT_PHOTOBOOK) {
                int page_index = 2;
                for (int i = (int)_pages.count; i < page_max; i++) {
					// PhotoContainer
//                    if (pick_index >= [Common info].photo_pool.sel_photos.count) break;
					if (pick_index >= [[PhotoContainer inst] selectCount]) break;

                    Page *page = [_pages[page_index++] copy];

                    // SJYANG
                    // 프리미엄북 : 이미지가 1장 이하로 남은 경우 해당 페이지를 에필로그 페이지로 변경
                    if( [_ThemeName isEqualToString:@"premium"] ) {
						// PhotoContainer
//                        if ([Common info].photo_pool.sel_photos.count - pick_index <= 1) {
//                            epilog_page_added = YES;
//                            page = epilog_page;
//						}
						if ([[PhotoContainer inst] selectCount] - pick_index <= 1) {
							epilog_page_added = YES;
							page = epilog_page;
						}
                    }
					
                    [_pages addObject:page];
                    [_delegate photobookProcess:i+1 TotalCount:page_max];

                    if (page.PageFile.length > 0) {
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                        [[Common info] downloadImage:url ToFile:localpathname];
                    }
                    for (Layer *layer in page.layers) {
                        if (layer.AreaType == 0) { // 0: image
							// PhotoContainer
//                            InstaPhoto *insta_photo = [self pickInstaPhoto:pick_index_insta];
//                            if (insta_photo != nil) {
//                                [self addPhotoFromInstagram:insta_photo Layer:layer PickIndex:pick_index_insta];
//                                pick_index_insta++;
//                            }
//                            else {
//                                Photo *photo = [self pickPhoto:pick_index];   // 선택된 사진을 꺼내어 레이어에 순서내로 할당한다.
//                                [self addPhoto:photo Layer:layer PickIndex:pick_index];
//                                pick_index++;
//                            }
							PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:pick_index];
							if (photoItem) {
								[self addPhotoNew:photoItem Layer:layer PickIndex:pick_index];
								pick_index++;
							}
							
							if (layer.FrameFilename.length > 0) {
                                NSURL *url;
                                if(_product_type == PRODUCT_CALENDAR)
                                {
                                    NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.FrameFilename]];
                                }
                                else
                                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.FrameFilename]];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, layer.FrameFilename];
                                [[Common info] downloadImage:url ToFile:localpathname];
                            }
                        }
                        else if (layer.AreaType == 1) { // 1:icon
                            NSURL *url;
                            if(_product_type == PRODUCT_CALENDAR)
                            {
                                NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.Filename]];
                            }
                            else
                                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.Filename]];
                            NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, layer.Filename];
                            [[Common info] downloadImage:url ToFile:localpathname];
                        }
                    }
                    if (page_index >= (int)_pages.count) {
                        page_index = 2;
                    }
                }
                // SJYANG : 2016.06.14
                // 프리미엄북 : 에필로그 페이지가 포함되지 않은 경우, 에필로그 페이지 추가
                if( [_ThemeName isEqualToString:@"premium"] ) {
                    if(epilog_page_added == NO) {
                        [_pages addObject:epilog_page];
                        [_delegate photobookProcess:page_max TotalCount:page_max];

                        Page *page = epilog_page;

                        if (page.PageFile.length > 0) {
                            if(page.IsCover){
                                NSURL *backImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                                NSURL *middleImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageMiddleFile]];
                                NSURL *frontImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageRightFile]];
                                NSString *backImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                                NSString *middleImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageMiddleFile];
                                NSString *frontImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageRightFile];
                                [[Common info] downloadImage:backImgUrl ToFile:backImgLocalPathName];
                                [[Common info] downloadImage:middleImgUrl ToFile:middleImgLocalPathName];
                                [[Common info] downloadImage:frontImgUrl ToFile:frontImgLocalPathName];
                            }else if(page.IsProlog){
                                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                                [[Common info] downloadImage:url ToFile:localpathname];
                            }else if(page.IsEpilog){
                                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                                [[Common info] downloadImage:url ToFile:localpathname];
                            }
                            else if(page.IsPage){
                                NSURL *leftImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                                NSURL *rightImgUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageRightFile]];
                                
                                NSString *leftImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageFile];
                                NSString *rightImgLocalPathName = [NSString stringWithFormat:@"%@/%@", tempFolder, page.PageRightFile];
                                
                                [[Common info] downloadImage:leftImgUrl ToFile:leftImgLocalPathName];
                                [[Common info] downloadImage:rightImgUrl ToFile:rightImgLocalPathName];
                                
                            }
                        
                        }
                        for (Layer *layer in page.layers) {
                            if (layer.AreaType == 0) { // 0: image
								//PhotoContainer
//                                InstaPhoto *insta_photo = [self pickInstaPhoto:pick_index_insta];
//                                if (insta_photo != nil) {
//                                    [self addPhotoFromInstagram:insta_photo Layer:layer PickIndex:pick_index_insta];
//                                    pick_index_insta++;
//                                }
//                                else {
//                                    Photo *photo = [self pickPhoto:pick_index];   // 선택된 사진을 꺼내어 레이어에 순서내로 할당한다.
//                                    [self addPhoto:photo Layer:layer PickIndex:pick_index];
//                                    pick_index++;
//                                }
								PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:pick_index];
								if (photoItem) {
									[self addPhotoNew:photoItem Layer:layer PickIndex:pick_index];
									pick_index++;
								}
                                if (layer.FrameFilename.length > 0) {
                                    NSURL *url;
                                    if(_product_type == PRODUCT_CALENDAR)
                                    {
                                        NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.FrameFilename]];
                                    }
                                    else
                                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.FrameFilename]];
                                    NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, layer.FrameFilename];
                                    [[Common info] downloadImage:url ToFile:localpathname];
                                }
                            }
                            else if (layer.AreaType == 1) { // 1:icon
                                NSURL *url;
                                if(_product_type == PRODUCT_CALENDAR)
                                {
                                    NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.Filename]];
                                }
                                else
                                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.Filename]];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, layer.Filename];
                                [[Common info] downloadImage:url ToFile:localpathname];
                            }
                        }
                    }
                }
            }

            // 양성진 수정/추가 : 카달로그 상품에서 초기 페이지 구성시 4의 배수로 안맞아 떨어지는 문제 수정
            if (intnum != nil && [intnum isEqualToString:@"120"]) { // 카달로그
                if (_pages.count % 2 != 0) {
                    Page *page = [_pages[1] copy];
                    [_pages addObject:page];
                }
            }

            if (![_ProductCode isEqualToString:@"347037"]) {
//                [self saveFile];
            }
        }
    }

    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR) {
        [self loadMemoriayDays];
        [self loadFonts];
    }
    else if (_product_type == PRODUCT_PHOTOBOOK && _depth1_key.length > 0) {
        [self loadFonts];
    }
}

- (void)loadPhotobookPages {
    if (_pages != nil) {
        [_pages removeAllObjects];
        _pages = nil;
    }
    _pages = [[NSMutableArray alloc] init];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullpathname = [NSString stringWithFormat:@"%@/save.ctg", _base_folder];

    BOOL is_dir;
    if ([fileManager fileExistsAtPath:fullpathname isDirectory:&is_dir]) {
        NSData *data = [fileManager contentsAtPath:fullpathname];
        [self loadData:data IsHeaderOnly:NO];
    }
    _title = [self getBookTitle];

    // 신규 달력 포맷 + 마그넷 : 직렬화
    if (_product_type == PRODUCT_CALENDAR) {
        for (int i = 1; i <= _pages.count; i++) {
            Page *page = _pages[i - 1];

            NSMutableArray *discardedItems = [NSMutableArray array];
            for (Layer *layer in page.layers) {
                if(layer.AreaType == 11 || layer.AreaType == 12 || layer.AreaType == 13 || layer.AreaType == 14)
                    [discardedItems addObject:layer];
            }
            [page.layers removeObjectsInArray:discardedItems];

            BOOL is_dir;
            if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/save.%d.cal", _base_folder, i] isDirectory:&is_dir]) {
                NSArray* addLayers = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/save.%d.cal", _base_folder, i]];
                for (Layer *layer in addLayers) {
                    if(layer.AreaType == 0) {
                        if(layer.Frameinfo != nil && layer.Frameinfo.length > 0) {
                            for(Layer *pLayer in page.layers) {
                                if(pLayer.LayerIndex == layer.LayerIndex) {
                                    pLayer.Frameinfo = layer.Frameinfo;
                                    // 신규 달력 포맷 : FrameFilename
                                    if(pLayer.FrameFilename == nil || [pLayer.FrameFilename isEqualToString:@""])
                                        pLayer.FrameFilename = layer.Frameinfo;
                                }
                            }
                        }
                    }
                    else if(layer.AreaType == 11 || layer.AreaType == 12 || layer.AreaType == 13 || layer.AreaType == 14) {
                        [page.layers addObject:layer];
                    }
                }
            }
        }
    }
    else if (_product_type == PRODUCT_MAGNET) {
        for (int i = 1; i <= _pages.count; i++) {
            Page *page = _pages[i - 1];

            NSMutableArray *discardedItems = [NSMutableArray array];
            for (Layer *layer in page.layers) {
                if(layer.AreaType == 3)
                    [discardedItems addObject:layer];
            }
            [page.layers removeObjectsInArray:discardedItems];

            BOOL is_dir;
            if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/save.%d.dat", _base_folder, i] isDirectory:&is_dir]) {
                NSArray* addLayers = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@/save.%d.dat", _base_folder, i]];
                for (Layer *layer in addLayers) {
                    if(layer.AreaType == 3) {
                        [page.layers addObject:layer];
                    }
                }
            }
        }
    }

    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR) {
        [self loadMemoriayDays];
        [self loadFonts];
    }
    else if (_product_type == PRODUCT_PHOTOBOOK && _depth1_key.length > 0) {
        [self loadFonts];
    }
    

/*
    // 중복 체크
    if ([self checkDuplicate]) {
        NSLog(@"중복 체크 -> ok");
    }
    else {
        NSLog(@"중복 체크 -> error... 중복 제거 완료");
    }
*/
    NSLog(@"loadPhotobookPages.. 이미지레이어 개수:%d", [self getImageLayerCount]);
}

- (void)saveFile {
    NSLog(@"saveFile.. 이미지레이어 개수:%d", [self getImageLayerCount]);

    _Edited = [self isEditComplete];

	if(_product_type == PRODUCT_CARD) {
        if(_ProductId == nil || [_ProductId isEqualToString:@""])
            _ProductId = [[Common info] createProductId:_ProductCode];
    }
    else {
        _ProductId = [[Common info] createProductId:_ProductCode];
    }
    NSLog(@"product id: %@", _ProductId);

    // ctg 파일 생성
    NSData *ctg_data = [self saveData];
    if (ctg_data.length > 0) {
        NSLog(@"ctg_data writeToFile : %@/save.ctg", _base_folder);
        [ctg_data writeToFile:[NSString stringWithFormat:@"%@/save.ctg", _base_folder] atomically:YES];

        // 신규 달력 포맷 + 마그넷 : 직렬화
        if (_product_type == PRODUCT_CALENDAR) {
            for (int i = 1; i <= _pages.count; i++) {
                Page *page = _pages[i - 1];
                NSData *objectArchived = [NSKeyedArchiver archivedDataWithRootObject:page.layers];
                [objectArchived writeToFile:[NSString stringWithFormat:@"%@/save.%d.cal", _base_folder, i] atomically:YES];
            }
        }
        else if (_product_type == PRODUCT_MAGNET) {
            for (int i = 1; i <= _pages.count; i++) {
                Page *page = _pages[i - 1];
                NSData *objectArchived = [NSKeyedArchiver archivedDataWithRootObject:page.layers];
                [objectArchived writeToFile:[NSString stringWithFormat:@"%@/save.%d.dat", _base_folder, i] atomically:YES];
            }
        }
    }

    // 보관함의 썸네일 생성
    if (_product_type == PRODUCT_PHOTOBOOK) {
        [self makeThumb:0 ToFile1:@"temp00.jpg" ToFile2:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile1:@"temp01.jpg" ToFile2:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile1:@"thumb02.jpg" ToFile2:@"temp02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_CALENDAR) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_POLAROID) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_SINGLECARD) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_MUG) {
        // 머그컵은 보관함을 사용하지 않는다.
    }
    else if (_product_type == PRODUCT_PHONECASE) {
        // 폰케이스는 보관함을 사용하지 않는다.
    }
    else if (_product_type == PRODUCT_POSTCARD) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_MAGNET) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_CARD) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
        [self makeThumb:3 ToFile:@"thumb03.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_BABY) {
        // 베이비는 보관함을 사용하지 않는다.
    }
    else if (_product_type == PRODUCT_POSTER) {

    }
    else if (_product_type == PRODUCT_DIVISIONSTICKER) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
        [self makeThumb:3 ToFile:@"thumb03.jpg" IncludeBg:NO];
    }
    else {
        NSAssert(NO, @"save thumb : product type mismatch..");
    }

    if (_product_type == PRODUCT_CARD) {
        NSString *params_filepath = [NSString stringWithFormat:@"%@/edit/params.%@", _base_folder, _ProductId];
        if( [Common info].photobook.ScodixParams == nil ) [Common info].photobook.ScodixParams = @"";
        if( [Common info].photobook.AddParams == nil ) [Common info].photobook.AddParams = @"";
        [[NSString stringWithFormat:@"%@:%@", [Common info].photobook.ScodixParams, [Common info].photobook.AddParams] writeToFile:params_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (void)saveFileWithPageCount:(int) pageCount {
    NSLog(@"saveFile.. 이미지레이어 개수:%d", [self getImageLayerCount]);

    if (_product_type == PRODUCT_TRANSPARENTCARD) {
        _Edited = [self isEditCompleteWithPageCountMax18:pageCount];
    } else {
        _Edited = [self isEditCompleteWithPageCount:pageCount];
    }

    if(_product_type == PRODUCT_CARD) {
        if(_ProductId == nil || [_ProductId isEqualToString:@""])
            _ProductId = [[Common info] createProductId:_ProductCode];
    }
    else {
        _ProductId = [[Common info] createProductId:_ProductCode];
    }
    NSLog(@"product id: %@", _ProductId);

    // ctg 파일 생성
    NSData *ctg_data = [self saveData];
    if (ctg_data.length > 0) {
        NSLog(@"ctg_data writeToFile : %@/save.ctg", _base_folder);
        [ctg_data writeToFile:[NSString stringWithFormat:@"%@/save.ctg", _base_folder] atomically:YES];

        // 신규 달력 포맷 + 마그넷 : 직렬화
        if (_product_type == PRODUCT_CALENDAR) {
            for (int i = 1; i <= _pages.count; i++) {
                Page *page = _pages[i - 1];
                NSData *objectArchived = [NSKeyedArchiver archivedDataWithRootObject:page.layers];
                [objectArchived writeToFile:[NSString stringWithFormat:@"%@/save.%d.cal", _base_folder, i] atomically:YES];
            }
        }
        else if (_product_type == PRODUCT_MAGNET) {
            for (int i = 1; i <= _pages.count; i++) {
                Page *page = _pages[i - 1];
                NSData *objectArchived = [NSKeyedArchiver archivedDataWithRootObject:page.layers];
                [objectArchived writeToFile:[NSString stringWithFormat:@"%@/save.%d.dat", _base_folder, i] atomically:YES];
            }
        }
    }

    // 보관함의 썸네일 생성
    if (_product_type == PRODUCT_PHOTOBOOK) {
        [self makeThumb:0 ToFile1:@"temp00.jpg" ToFile2:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile1:@"temp01.jpg" ToFile2:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile1:@"thumb02.jpg" ToFile2:@"temp02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_CALENDAR) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_POLAROID) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_SINGLECARD) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_MUG) {
        // 머그컵은 보관함을 사용하지 않는다.
    }
    else if (_product_type == PRODUCT_PHONECASE) {
        // 폰케이스는 보관함을 사용하지 않는다.
    }
    else if (_product_type == PRODUCT_POSTCARD) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_MAGNET) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_CARD) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
        [self makeThumb:3 ToFile:@"thumb03.jpg" IncludeBg:NO];
    }
    else if (_product_type == PRODUCT_BABY) {
        // 베이비는 보관함을 사용하지 않는다.
    }
    else if (_product_type == PRODUCT_POSTER) {

    }
    else if (_product_type == PRODUCT_PAPERSLOGAN) {

    }
    else if (_product_type == PRODUCT_TRANSPARENTCARD) {

    }
    else if (_product_type == PRODUCT_DIVISIONSTICKER) {
        [self makeThumb:0 ToFile:@"thumb00.jpg" IncludeBg:NO];
        [self makeThumb:1 ToFile:@"thumb01.jpg" IncludeBg:NO];
        [self makeThumb:2 ToFile:@"thumb02.jpg" IncludeBg:NO];
        [self makeThumb:3 ToFile:@"thumb03.jpg" IncludeBg:NO];
    }
    else {
        NSAssert(NO, @"save thumb : product type mismatch..");
    }

    if (_product_type == PRODUCT_CARD) {
        NSString *params_filepath = [NSString stringWithFormat:@"%@/edit/params.%@", _base_folder, _ProductId];
        if( [Common info].photobook.ScodixParams == nil ) [Common info].photobook.ScodixParams = @"";
        if( [Common info].photobook.AddParams == nil ) [Common info].photobook.AddParams = @"";
        [[NSString stringWithFormat:@"%@:%@", [Common info].photobook.ScodixParams, [Common info].photobook.AddParams] writeToFile:params_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (NSString *)getBookTitle {
    NSString *title = @"";
    if (_pages.count > 0) {
        Page *cover_page = _pages[0];
        for (Layer *layer in cover_page.layers) {
            if (layer.AreaType == 2) {
                if (layer.TextDescription.length > 0) {
                    title = layer.TextDescription;
                }
            }
        }
    }
    return title;
}

- (void)setBookTitle:(NSString *)title {
    if (title.length > 10) {
        title = [title substringToIndex:10];
    }

    _title = title;
    Page *cover_page = _pages[0];
    for (Layer *layer in cover_page.layers) {
        if(_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 )){
            if (layer.AreaType == 2 && [layer.str_positionSide isEqualToString:@"C"]) {
                layer.TextDescription = title;
            }
        }else{
            if (layer.AreaType == 2) {
                layer.TextDescription = title;
            }
        }
    }
}

- (BOOL)addPhotoFromInstagram:(InstaPhoto *)photo Layer:(Layer *)layer PickIndex:(int)pick_index {
    if (photo != nil && layer != nil) {

        NSString *time_str = [[Common info] timeStringEx];
        NSString *filename = [NSString stringWithFormat:@"%04d_i.jpg", pick_index];

        int randnum = arc4random() % 100;
        NSString *org_filename = [NSString stringWithFormat:@"%@_%03d_%@", time_str, randnum, filename];
        NSString *org_pathname = [NSString stringWithFormat:@"%@/org/%@", _base_folder, org_filename];

        layer.Filename = @"";
        layer.ImageFilename = org_filename;
        layer.ImageEditname = [NSString stringWithFormat:@"_%@", org_filename];
        NSLog(@"addPhotoFile:%@", layer.ImageFilename);

        // url로부터 복사.
        if (![photo download:org_pathname]) {
            return NO;
        }

        // 원본이미지
        UIImage *org_image = [UIImage imageWithContentsOfFile:org_pathname];

        // 편집이미지
        CGFloat scale = 1.0f;
        int min_side = (int)MIN(org_image.size.width, org_image.size.height);
        if (min_side > 480) {
            scale = 480.0f / (CGFloat)min_side;
        }

        CGSize image_size = CGSizeMake(org_image.size.width * scale, org_image.size.height * scale);

        UIGraphicsBeginImageContext(image_size);
        [org_image drawInRect:CGRectMake(0, 0, image_size.width, image_size.height)];
        UIImage *edit_image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        CGFloat compressionQuality = 0.5f;
        NSData *edit_data = UIImageJPEGRepresentation(edit_image, compressionQuality);
        [edit_data writeToFile:[NSString stringWithFormat:@"%@/edit/%@", _base_folder, layer.ImageEditname] atomically:YES];

        //
        // 원본 크기
        layer.ImageOriWidth = org_image.size.width;
        layer.ImageOriHeight = org_image.size.height;

        // 편집용 이미지 장축 기록
        layer.EditImageMaxSize = MAX((int)edit_image.size.width, (int)edit_image.size.height);

        // 기본 크롭 정보 생성
        CGRect maskRect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
        CGRect cropRect = [[Common info] getDefaultCropRect:maskRect src:edit_image.size];
        layer.ImageCropX = cropRect.origin.x;
        layer.ImageCropY = cropRect.origin.y;
        layer.ImageCropW = cropRect.size.width;
        layer.ImageCropH = cropRect.size.height;

        layer.is_lowres = [[Common info] isLowResolution:layer];
        layer.edit_image = nil;

        //NSLog(@"org(%dx%d) edit(%.0fx%.0f) rotate(%d)", layer.ImageOriWidth, layer.ImageOriHeight, edit_image.size.width, edit_image.size.height, layer.ImageR);
        //NSLog(@"crop(%d,%d,%d,%d)", layer.ImageCropX, layer.ImageCropY, layer.ImageCropW, layer.ImageCropH);
        return YES;
    }
    return NO;
}

- (BOOL)addPhoto:(Photo *)photo Layer:(Layer *)layer PickIndex:(int)pick_index {
    BOOL is_debug = NO;


    if(is_debug) NSLog(@"addPhoto #001");
    if (photo != nil && layer != nil) {
        __block UIImageOrientation ph_orientation = UIImageOrientationUp;

        if(is_debug) NSLog(@"addPhoto #002");
        NSString *time_str = [[Common info] timeStringEx];
        NSString *filename = [NSString stringWithFormat:@"%04d.jpg", pick_index];

        int randnum = arc4random() % 100;
        NSString *org_filename = [NSString stringWithFormat:@"%@_%03d_%@", time_str, randnum, filename];
        __block NSString *org_pathname = [NSString stringWithFormat:@"%@/org/%@", _base_folder, org_filename];

        if(is_debug) NSLog(@"addPhoto #003");
        layer.Filename = @"";
        layer.ImageFilename = org_filename;
        layer.ImageEditname = [NSString stringWithFormat:@"_%@", org_filename];
        if(is_debug) NSLog(@"addPhoto:%@", layer.ImageFilename);

        CGFloat rotate = 0;
        UIImage *org_image = nil;

        layer.ImageR = 0;

        @autoreleasepool
        {
            // HEIF Fix
            @autoreleasepool
            {
                __block NSData *org_data;
                __block NSData *org_data_as_heif;

                {
                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                    options.networkAccessAllowed = YES;
                    options.synchronous = YES;

                    if(is_debug) NSLog(@"addPhoto #004");
                    [[PHImageManager defaultManager] requestImageDataForAsset:photo.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                        if(is_debug) NSLog(@"addPhoto #004-1");
                        if(![[PHAssetUtility info] isHEIF:photo.asset])
                            org_data = [imageData copy];
                        if(is_debug) NSLog(@"addPhoto #004-2");
                        ph_orientation = orientation;
                        //NSLog(@"info : %@", info);
                        if(is_debug) NSLog(@"addPhoto : [PHImageManager defaultManager] requestImageDataForAsset");
                    }];
                }

                if([[PHAssetUtility info] isHEIF:photo.asset]) {
                    if(is_debug) NSLog(@"addPhoto : PRE getFastJpegImageDataForAsset");
                    org_data_as_heif = [[PHAssetUtility info] getFastJpegImageDataForAsset:photo.asset];
                    if(is_debug) NSLog(@"addPhoto : [[PHAssetUtility info] isHEIF:photo.asset] #1");

                    [photo.asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
                        @synchronized(self) {
                            if (contentEditingInput.fullSizeImageURL) {
                                // 2017.11.16 : SJYANG : @autoreleasepool 추가
                                @autoreleasepool
                                {
                                    if(is_debug) NSLog(@"addPhoto : [[PHAssetUtility info] isHEIF:photo.asset] #2");
                                    CIImage *ciImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
                                    CIContext *context = [CIContext context];
                                    NSData* jpgData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
                                    [jpgData writeToFile:org_pathname atomically:YES];
                                    if(is_debug) NSLog(@"addPhoto : [[PHAssetUtility info] isHEIF:photo.asset] #3");
                                }
                            }
                        }
                    }];
                }
                else {
                    [org_data writeToFile:org_pathname atomically:YES];
                }

                rotate = 0; // 원본 회전 정보

                switch (ph_orientation) {
                    case UIImageOrientationUp:    // 0도, 기본값.
                    case UIImageOrientationUpMirrored:
                        break;
                    case UIImageOrientationLeft:  // 90도
                    case UIImageOrientationLeftMirrored:
                        rotate = 90;
                        break;
                    case UIImageOrientationRight: // -90도
                    case UIImageOrientationRightMirrored:
                        rotate = -90;
                        break;
                    case UIImageOrientationDown:  // 180도
                    case UIImageOrientationDownMirrored:
                        rotate = 180;
                        break;
                    default:
                        break;
                }
                if(is_debug) NSLog(@"addPhoto #005");

                if(org_data != nil)
                    org_image = [UIImage imageWithData:org_data];
                else {
                    if(org_data_as_heif != nil)
                        org_image = [UIImage imageWithData:org_data_as_heif];
                }
            }

            CGFloat scale = 1.0f;
            int min_side = (int)MIN(org_image.size.width, org_image.size.height);
            if (min_side > 480) {
                scale = 480.0f / (CGFloat)min_side;
            }

            CGSize image_size = CGSizeMake(org_image.size.width * scale, org_image.size.height * scale);
            CGSize canvas_size = image_size;
            if (rotate == 90 || rotate == -90) {
                canvas_size = CGSizeMake(image_size.height, image_size.width);
            }

            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            UIGraphicsBeginImageContext(canvas_size);

            if(is_debug) NSLog(@"addPhoto #006");
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextTranslateCTM(context, canvas_size.width/2, canvas_size.height/2);
            CGContextRotateCTM(context, rotate * M_PI/180);

            // mirrored image flip or flop............................................
            switch (ph_orientation) {
                case UIImageOrientationUpMirrored:
                case UIImageOrientationDownMirrored:
                    CGContextScaleCTM(context, -1, 1);
                    break;
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRightMirrored:
                    CGContextScaleCTM(context, 1, -1);
                    break;
                default:
                    break;
            } // mirrored image flip or flop..........................................

            CGContextTranslateCTM(context, -image_size.width/2, -image_size.height/2);

            // org_image 가 쓰이는 부분은 여기까지...
            [org_image drawInRect:CGRectMake(0, 0, image_size.width, image_size.height)];

            if(is_debug) NSLog(@"addPhoto #007");
            UIImage *edit_image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            CGFloat compressionQuality = 0.1f;
            if (_product_type == PRODUCT_POLAROID) { // 2015.12.21. 이강일팀장 의견(폴라로이드 편집이미지 화질이 너무 떨어진다는..)
                compressionQuality = 0.5f;
            }
            NSData *edit_data = UIImageJPEGRepresentation(edit_image, compressionQuality);
            [edit_data writeToFile:[NSString stringWithFormat:@"%@/edit/%@", _base_folder, layer.ImageEditname] atomically:YES];

            if(is_debug) NSLog(@"addPhoto #008");
            // 원본 크기
            layer.ImageOriWidth = [[PHAssetUtility info] getPixelWidth:photo.asset];
            layer.ImageOriHeight = [[PHAssetUtility info] getPixelHeight:photo.asset];

            // 편집용 이미지 장축 기록
            layer.EditImageMaxSize = MAX((int)edit_image.size.width, (int)edit_image.size.height);

            // 기본 크롭 정보 생성
            CGRect maskRect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
            CGRect cropRect = [[Common info] getDefaultCropRect:maskRect src:edit_image.size];
            layer.ImageCropX = cropRect.origin.x;
            layer.ImageCropY = cropRect.origin.y;
            layer.ImageCropW = cropRect.size.width;
            layer.ImageCropH = cropRect.size.height;

            if(is_debug) NSLog(@"addPhoto #009");
            layer.is_lowres = [[Common info] isLowResolution:layer];
            layer.edit_image = nil;
        }

        //NSLog(@"org(%dx%d) edit(%.0fx%.0f) rotate(%d)", layer.ImageOriWidth, layer.ImageOriHeight, edit_image.size.width, edit_image.size.height, layer.ImageR);
        //NSLog(@"crop(%d,%d,%d,%d)", layer.ImageCropX, layer.ImageCropY, layer.ImageCropW, layer.ImageCropH);
        return TRUE;
    }
    return FALSE;
}

- (void)deletePhoto:(Layer *)layer {
    if (layer != nil) {
        layer.Filename = @"";
        layer.ImageFilename = @"";
        layer.ImageEditname = @"";
    }
}

- (void)makeThumb:(int)index ToFile1:(NSString *)file1 ToFile2:(NSString *)file2 IncludeBg:(BOOL)include_bg {
    UIImageView *bkview = nil;
    if (include_bg) {
        UIImageView *bkimageview = [[UIImageView alloc] init];
        bkimageview.image = _page_bkimage_photobook;
        bkview = bkimageview;
    }
    else {
        bkview = [[UIImageView alloc] init];
        bkview.backgroundColor = [UIColor whiteColor];
    }

    // SJYANG.2018.06 : 가로모드 처리
    if (_product_type == PRODUCT_DESIGNPHOTO || _product_type == PRODUCT_SINGLECARD) {
        Page* page = (Page*)_pages[index];
        _page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);

        [bkview setFrame:_page_rect];
    }
    else {
        [bkview setFrame:_page_rect];
    }

    [self composePage:index ParentView:bkview IncludeBg:NO IsEdit:NO];

    UIGraphicsBeginImageContextWithOptions(bkview.bounds.size, NO, 0);
    [bkview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef cgimage = image.CGImage;
    size_t width = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    CGImageRef l_cgimage = CGImageCreateWithImageInRect(cgimage, CGRectMake(0, 0, width/2, height));
    CGImageRef r_cgimage = CGImageCreateWithImageInRect(cgimage, CGRectMake(width/2, 0, width/2, height));
    UIImage *l_image = [UIImage imageWithCGImage:l_cgimage scale:image.scale orientation:image.imageOrientation];
    UIImage *r_image = [UIImage imageWithCGImage:r_cgimage scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(l_cgimage);
    CGImageRelease(r_cgimage);

    NSData *l_data = UIImageJPEGRepresentation(l_image, 0.5f);
    NSData *r_data = UIImageJPEGRepresentation(r_image, 0.5f);
    [l_data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file1] atomically:YES];
    [r_data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file2] atomically:YES];
}

- (void)makeThumb:(int)index ToFile:(NSString *)file IncludeBg:(BOOL)include_bg {
    NSString *intnum = @"";
    @try {
        intnum = [_ProductCode substringWithRange:NSMakeRange(0, 3)];
    }
    @catch(NSException *exception) {}

    if (_product_type == PRODUCT_PHONECASE) {
        NSData *data = UIImageJPEGRepresentation(_thumb_captured_image, 0.5f);
        [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
    }
    else if (_product_type == PRODUCT_CARD) {
        UIImageView *bkview = nil;
        if (include_bg) {
            UIImageView *bkimageview = [[UIImageView alloc] init];
            bkimageview.image = _page_bkimage_photobook;
            bkview = bkimageview;
        }
        else {
            bkview = [[UIImageView alloc] init];
            bkview.backgroundColor = [UIColor whiteColor];
        }
		if ( index < _pages.count ) {
			Page* page = (Page*)_pages[index];
			CGRect pageRect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);
			[bkview setFrame:pageRect];
		}
		else {
			[bkview setFrame:_page_rect];
		}

        [self composePage:index ParentView:bkview IncludeBg:NO IsEdit:NO];

        UIGraphicsBeginImageContextWithOptions(bkview.bounds.size, NO, 0);
        [bkview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        if (index == 0) {
            NSData *data = UIImageJPEGRepresentation(image, 0.5f);
            [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
        }
        else if (index == 1) {
            NSData *data = UIImageJPEGRepresentation(image, 0.5f);
            [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
        }
        else if (index == 2) {
            NSData *data = UIImageJPEGRepresentation(image, 0.5f);
            [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
        }
        else if (index == 3) {
            NSData *data = UIImageJPEGRepresentation(image, 0.5f);
            [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
        }
    }
    else if (_product_type == PRODUCT_POLAROID || _product_type == PRODUCT_MAGNET) { // 마그넷 : 추가
        NSLog(@"MAKE THUMB");
        UIImageView *bkview = nil;
        if (include_bg) {
            UIImageView *bkimageview = [[UIImageView alloc] init];
            bkimageview.image = _page_bkimage_photobook;
            bkview = bkimageview;
        }
        else {
            bkview = [[UIImageView alloc] init];
            bkview.backgroundColor = [UIColor whiteColor];
        }
        [bkview setFrame:_page_rect];

        [self composePage:index ParentView:bkview IncludeBg:NO IsEdit:NO];

        UIGraphicsBeginImageContextWithOptions(bkview.bounds.size, NO, 0);
        [bkview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSData *data = UIImageJPEGRepresentation(image, 0.5f);
        [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        NSLog(@"MAKE THUMB");
        UIImageView *bkview = nil;
        if (include_bg) {
            UIImageView *bkimageview = [[UIImageView alloc] init];
            bkimageview.image = _page_bkimage_photobook;
            bkview = bkimageview;
        }
        else {
            bkview = [[UIImageView alloc] init];
            bkview.backgroundColor = [UIColor whiteColor];
        }

        // SJYANG.2018.06 : 가로모드 처리
        if(index <= _pages.count - 1) {
            Page* page = (Page*)_pages[index];
            _page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);
        }
        [bkview setFrame:_page_rect];

        [self composePage:index ParentView:bkview IncludeBg:NO IsEdit:NO];

        UIGraphicsBeginImageContextWithOptions(bkview.bounds.size, NO, 0);
        [bkview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSData *data = UIImageJPEGRepresentation(image, 0.5f);
        [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
    }
    else if (_product_type == PRODUCT_SINGLECARD) {
        NSLog(@"MAKE THUMB file : %@", file);
        NSLog(@"_base_folder : %@", _base_folder);

        //Define 할위치가 멀어서 변수로 선언함
        NSInteger margin = 20; //사진 마진 (x,y)통합
        CGFloat radious = 40.0; //모서리 하드코딩함

        UIImageView *bkview = [[UIImageView alloc] init];
        UIImageView *bkview2 = [[UIImageView alloc] init];;
        bkview.backgroundColor = [UIColor whiteColor];
        bkview2.backgroundColor = [UIColor whiteColor];
        bkview.layer.cornerRadius = radious;
        bkview.layer.masksToBounds = YES;
        bkview2.layer.cornerRadius = radious;
        bkview2.layer.masksToBounds = YES;


        // SJYANG.2018.06 : 가로모드 처리
        if(index <= _pages.count - 1) {
            Page* page = (Page*)_pages[index];
            _page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight);
        }
        [bkview setFrame:_page_rect];
        [bkview2 setFrame:_page_rect];

        [self composePage:index ParentView:bkview IncludeBg:NO IsEdit:NO];
        [self composePage:index+1 ParentView:bkview2 IncludeBg:NO IsEdit:NO];

        //이미지 합치는 곳
        UIImageView *ivSum = [[UIImageView alloc] init];
        [ivSum setBackgroundColor:[UIColor colorWithRed:191/255.0f green:191/255.0f blue:191/255.0f alpha:1.0f]];
        [ivSum setFrame:CGRectMake(0, 0, bkview.frame.size.width * 2 + (margin * 3), bkview.frame.size.height + (margin *2))];

        [ivSum addSubview:bkview];
        [ivSum addSubview:bkview2];

        CGRect r = bkview.frame;
        r.origin.x = margin;
        r.origin.y = margin;
        [bkview setFrame:r];

        CGRect r2 = bkview2.frame;
        r2.origin.x = bkview.frame.size.width + bkview.frame.origin.x + (margin);
        r2.origin.y = margin;
        [bkview2 setFrame:r2];

        //view 이미지로 저장
        UIGraphicsBeginImageContextWithOptions(ivSum.bounds.size, NO, 0);
        [ivSum.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        //img 파일저장
        NSData *data = UIImageJPEGRepresentation(image, 0.5f);
        [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
    }
    else if (_product_type == PRODUCT_PAPERSLOGAN) {
        UIImageView *bkview = nil;
        if (include_bg) {
            UIImageView *bkimageview = [[UIImageView alloc] init];
            // SJYANG : 2018 달력
            if ([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"])
                bkimageview.image = _page_bkimage_calendar2; // BORDER
            else
                bkimageview.image = _page_bkimage_calendar; // RING
            bkview = bkimageview;
        }
        else {
            bkview = [[UIImageView alloc] init];
            bkview.backgroundColor = [UIColor whiteColor];
        }

        CGFloat width = _page_rect.size.width - 20;
        CGFloat heightRatio = (CGFloat) _page_rect.size.height / _page_rect.size.width;
        CGFloat height = width * heightRatio;
        CGFloat heightScale = height / _page_rect.size.height;
        CGSize size = CGSizeMake(width, (height * 2 + 210) * heightScale);

        [bkview setFrame:CGRectMake(_page_rect.origin.x, _page_rect.origin.y, size.width, size.height)];
        self.heightScale = heightScale;
        self.widthScale = width / _page_rect.size.width;

        [self composePaperSloganPage:index ParentView:bkview IncludeBg:NO IsEdit:YES IsThumbnail:YES];

        UIGraphicsBeginImageContextWithOptions(bkview.bounds.size, NO, 0);
        [bkview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSData *data = UIImageJPEGRepresentation(image, 0.5f);
        [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
    }
    else {
        UIImageView *bkview = nil;
        if (include_bg) {
            UIImageView *bkimageview = [[UIImageView alloc] init];
            // SJYANG : 2018 달력
            if ([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"])
                bkimageview.image = _page_bkimage_calendar2; // BORDER
            else
                bkimageview.image = _page_bkimage_calendar; // RING
            bkview = bkimageview;
        }
        else {
            bkview = [[UIImageView alloc] init];
            bkview.backgroundColor = [UIColor whiteColor];
        }

        [bkview setFrame:_page_rect];

        [self composePage:index ParentView:bkview IncludeBg:NO IsEdit:NO];

        UIGraphicsBeginImageContextWithOptions(bkview.bounds.size, NO, 0);
        [bkview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        NSData *data = UIImageJPEGRepresentation(image, 0.5f);
        [data writeToFile:[NSString stringWithFormat:@"%@/thumb/%@", _base_folder, file] atomically:YES];
    }
}

- (InstaPhoto *)pickInstaPhoto:(NSInteger)index {
    if (index < [[Instagram info] selectedCount]) {
        return (InstaPhoto *)[Instagram info].sel_images[index];
    }
    return nil;
}

- (Photo *)pickPhoto:(NSInteger)index {
    if (index < [Common info].photo_pool.sel_photos.count) {
        return (Photo *)[Common info].photo_pool.sel_photos[index];
    }
    return nil;
}
/*
- (int)getImageCount {
    int imagecount = 0;
    for (Page *page in _pages) {
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0) {
                imagecount++;
            }
        }
    }
    return imagecount;
}
*/
- (int)getTotalPageCount {
    int total_count = 0;
    if (_product_type == PRODUCT_PHOTOBOOK) {
        total_count = (int)_pages.count * 2;
        for (int i = 0; i < _pages.count; i++) {
            Page *page = _pages[i];
            if (page.IsCover) {
                total_count -= 2;
            }
            else if (page.IsProlog) {
                total_count -= 1;
            }
        }
        // SJYANG : 2016.05.31
        // 프리미엄 포토북은 마지막 blank 페이지를 전체 페이지수에서 뺀다
        if( [self.ThemeName isEqualToString:@"premium"] )
            total_count--;
        // 카달로그
        if( [self.ProductCode isEqualToString:@"120069"] )
            total_count+=2;
    }
    else if (_product_type == PRODUCT_CALENDAR) {
        total_count = CALENDAR_PAGE_MAX;
    }
    else if (_product_type == PRODUCT_POLAROID) {
        // SJYANG : 미니폴라로이드 단종 오류 수정
        if (_ProductCode != nil && [_ProductCode isEqualToString:@"347032"]) {
            total_count = (int)_pages.count;
            // SJYANG : 미니폴라로이드 단종 오류 수정 : 재수정
            if(total_count <= 0)
                total_count = _minpictures;
            /*
            else
                _minpictures = total_count; // <== PTODO : 이 코드 체크 필요
            */
        }
        else {
            total_count = _minpictures;
        }
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        total_count = (int)_pages.count;
    }
    else if (_product_type == PRODUCT_SINGLECARD) {
        total_count = (int)_pages.count;
    }
    else if (_product_type == PRODUCT_FRAME) {
        total_count = 1;
    }
    else if (_product_type == PRODUCT_MUG) {
        total_count = 1;
    }
    else if (_product_type == PRODUCT_PHONECASE) {
        total_count = 1;
    }
    else if (_product_type == PRODUCT_POSTCARD) {
        total_count = _MinPage;
    }
	// TODO : 마그넷 : 체크 필요
    else if (_product_type == PRODUCT_MAGNET) {
        total_count = _MinPage;
    }
    else if (_product_type == PRODUCT_BABY) {
        total_count = 1;
    }
    else if (_product_type == PRODUCT_CARD) {
        // TODO
        total_count = _minpictures;
    }
    else if (_product_type == PRODUCT_POSTER) {
        total_count = _MinPage;
    }
    else if (_product_type == PRODUCT_PAPERSLOGAN) {
        total_count = _MinPage;
    }
    else if (_product_type == PRODUCT_TRANSPARENTCARD) {
        total_count = _MinPage;
    }
    else if (_product_type == PRODUCT_DIVISIONSTICKER) {
        total_count = _MinPage;
    }
    else {
        NSAssert(NO, @"getTotalPageCount: product type mismatch !!");
    }
    return total_count;
}

- (BOOL)isUV {
    NSString *check_uv = [_ProductCode substringWithRange:NSMakeRange(3, 3)];
    if (check_uv != nil && check_uv.length > 0) {
        BOOL isUV = ([check_uv isEqualToString:@"221"] || [check_uv isEqualToString:@"223"] || [check_uv isEqualToString:@"225"]);// || [check_uv isEqualToString:@"268"]);
        //BOOL isUV = [check_uv isEqualToString:@"221"];
        if (isUV) {
            return TRUE;
        }
    }
    return FALSE;
}

- (int)getTotalPrice {
    int total_price = _DefaultProductPrice;
    if ([self isUV]) {
        total_price += 5000;
    }

    int total_count = [self getTotalPageCount]; // 커버와 프롤로그 제외 -3된 개수 넘어옴.
    int added_count = total_count - _MinPage;

    return total_price + _PricePerPage * added_count;
}

- (BOOL)isEditComplete {

    if (_product_type == PRODUCT_SINGLECARD) {
        NSArray *array = [self.AddVal10 componentsSeparatedByString: @"^"];
        NSInteger total = 0;
        for (NSInteger i = 0; i < array.count; i = i + 2) {
            total = total + [array[i] integerValue];
        }
        if (total < 24) {
            return NO;
        }
    }
    //test code send divisionsticker
    /*if (_product_type == PRODUCT_DIVISIONSTICKER) {
       return YES;
    }*/
    //test code send photobookv2
    /*if (_product_type == PRODUCT_PHOTOBOOK) {
        return YES;
    }*/

    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0) { // 0: image
                if (layer.ImageFilename.length < 1) {
                    return FALSE;
                }
            }
            else if (layer.AreaType == 2) { // 2: text
                if (layer.TextDescription.length < 1) {
                    //return FALSE;
                }
            }
        }
    }
    return YES;
}

- (BOOL)isEditCompleteWithPageCount:(int) pageCount {
    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0) { // 0: image
                if (layer.ImageFilename.length < 1) {
                    return FALSE;
                }
            }
            else if (layer.AreaType == 2) { // 2: text
                if (layer.TextDescription.length < 1) {
                    //return FALSE;
                }
            }
        }
    }
    return pageCount == [Common info].photobook.MaxPage;
}

- (BOOL)isEditCompleteWithPageCountMax18:(int) pageCount {
    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0) { // 0: image
                if (layer.ImageFilename.length < 1) {
                    return FALSE;
                }
            }
            else if (layer.AreaType == 2) { // 2: text
                if (layer.TextDescription.length < 1) {
                    //return FALSE;
                }
            }
        }
    }
    return pageCount == 18;
}

- (int)getImageLayerCount {
    int count = 0;
    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
        count += [page getImageLayerCount];
    }
    return count;
}

- (BOOL)validateDuplicate:(NSString *)filename PageIdx:(int)page_idx LayerIdx:(int)layer_idx {
    BOOL is_valid = TRUE;
    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
        for (int j = 0; j < page.layers.count; j++) {
            if ((i != page_idx) || (j != layer_idx)) {
                Layer* layer = page.layers[j];
                if (layer.AreaType == 0) {
                    NSLog(@"[%d,%d]__비교:%@", i, j, layer.ImageFilename);
                    if ([layer.ImageFilename isEqualToString:filename]) {
                        layer.ImageFilename = @"";
                        layer.ImageEditname = @"";
                        is_valid = FALSE;
                    }
                }
            }
        }
    }
    return is_valid;
}

- (BOOL)checkDuplicate {
    BOOL is_valid = TRUE;
    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
        for (int j = 0; j < page.layers.count; j++) {
            Layer* layer = page.layers[j];
            if (layer.AreaType == 0) {
                if (layer.ImageFilename.length > 0) {
                    NSLog(@"[%d,%d]파일:%@", i, j, layer.ImageFilename);
                    if (![self validateDuplicate:layer.ImageFilename PageIdx:i LayerIdx:j]) {
                        is_valid = FALSE;
                    }
                }
            }
        }
    }
    return is_valid;
}

- (Layer *)getLayer:(NSInteger)index FromPoint:(CGPoint)point {
    //NSLog(@"_realPageMarginX : %d", _realPageMarginX);
    CGPoint scaled_point;
    if (_product_type == PRODUCT_PHONECASE || _product_type == PRODUCT_CARD || _product_type == PRODUCT_SINGLECARD)
        scaled_point = CGPointMake((point.x - 20)/_scale_factor - _realPageMarginX, point.y/_scale_factor);
    else if (_product_type == PRODUCT_POSTER || _product_type == PRODUCT_PAPERSLOGAN) {
        scaled_point = CGPointMake((point.x)/_scale_factor, (point.y)/_scale_factor);
    } else if (_product_type == PRODUCT_DIVISIONSTICKER) {
        scaled_point = CGPointMake((point.x)/_scale_factor, (point.y)/_scale_factor);
    }
    else if (_product_type == PRODUCT_DESIGNPHOTO) {
        scaled_point = CGPointMake((point.x)/_scale_factor, (point.y)/_scale_factor);
    }
    else if (_product_type == PRODUCT_PHOTOBOOK  && _depth1_key.length > 0){
        scaled_point = CGPointMake((point.x-20)/_scale_factor, (point.y-13)/_scale_factor);
    }
    else {
        scaled_point = CGPointMake((point.x-20)/_scale_factor, (point.y-20)/_scale_factor);
    }
    //NSLog(@"scaled_point:%f,%f", scaled_point.x, scaled_point.y);

    if(_product_type == PRODUCT_CARD) {
        if (index >= 0 && index < _pages.count) {
            Layer *layer = [_pages[index] point2LayerOfCard:scaled_point];
            return layer;
        }
    } else if (_product_type == PRODUCT_SINGLECARD || _product_type == PRODUCT_MAGNET) { // 2019.03.08
        if (index >= 0 && index < _pages.count) {
            Layer *layer = [_pages[index] point2LayerOfCardTextFirst:scaled_point];
            return layer;
        }
        
    }else if (_product_type == PRODUCT_DIVISIONSTICKER) { // 2019.07.26
        if (index >= 0 && index < _pages.count) {
            Layer *layer = [_pages[index] point2LayerOfCardTextFirst:scaled_point];
            return layer;
        }
        
    }
    else if (_product_type == PRODUCT_PHOTOBOOK && _depth1_key.length > 0) { // 2019.07.26
        if (index >= 0 && index < _pages.count) {
            Layer *layer = [_pages[index] point2LayerViewPoint:scaled_point scaleFactor:_scale_factor];
            return layer;
        }
        
    }
    else {
        if (index >= 0 && index < _pages.count) {
            Layer *layer = [_pages[index] point2Layer:scaled_point];
            return layer;
        }
    }
    return nil;
}

- (Layer *)getLayerOfPaperSlogan:(NSInteger)index FromPoint:(CGPoint)point {
    //NSLog(@"_realPageMarginX : %d", _realPageMarginX);
    CGPoint scaled_point = CGPointMake((point.x-20)/_widthScale, (point.y-20)/_heightScale);
    //NSLog(@"scaled_point:%f,%f", scaled_point.x, scaled_point.y);

    if (index >= 0 && index < _pages.count) {
        Layer *layer = [_pages[index] point2Layer:scaled_point];
        return layer;
    }

    return nil;
}

- (Layer *)getLayerOfPolaroidTextArea:(NSInteger)index FromPoint:(CGPoint)point {
    CGPoint scaled_point;
    scaled_point = CGPointMake((point.x-20)/_scale_factor, (point.y-30)/_scale_factor);

    if (index >= 0 && index < _pages.count) {
        Layer *layer = [_pages[index] point2LayerOfPolaroidTextArea:scaled_point];
        return layer;
    }
    return nil;
}

- (BOOL)changeBackground:(NSInteger)index From:(Background *)background {
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR) {
        _skin_url = URL_CALENDAR_PAGESKIN_PATH;
    }
    
    if (_product_type == PRODUCT_DIVISIONSTICKER) {
        _skin_url = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
    }

    //NSLog(@"i've just arrived at changeBackground");
    if (index >= 0 && index < _pages.count) {

        Page *page = _pages[index];

        page.PageFile = background.skinfilename;
        if (page.PageFile.length > 0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
            NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
            [[Common info] downloadImage:url ToFile:localpathname];
        }
        page.PageColorA = background.alpha;
        page.PageColorR = background.red;
        page.PageColorG = background.green;
        page.PageColorB = background.blue;

        return TRUE;
    }
    return FALSE;
}
- (BOOL)changeBackground:(NSInteger)index From:(Background *)background SelectLR:(NSString*)selectLRstr{
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR) {
        _skin_url = URL_CALENDAR_PAGESKIN_PATH;
    }
    
    if (_product_type == PRODUCT_DIVISIONSTICKER) {
        _skin_url = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
    }else if(_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 )){
        _skin_url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_SKIN_PATH, [Common info].connection.tplServerInfo];
    }
    
    //NSLog(@"i've just arrived at changeBackground");
    if (index >= 0 && index < _pages.count) {
        
        Page *page = _pages[index];
        if(page.IsCover){
            if([selectLRstr isEqualToString:@"L"]){
                page.PageFile = background.skinfilename;
                if (page.PageFile.length > 0) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                    [[Common info] downloadImage:url ToFile:localpathname];
                }
                page.PageColorA = background.alpha;
                page.PageColorR = background.red;
                page.PageColorG = background.green;
                page.PageColorB = background.blue;
            }else if([selectLRstr isEqualToString:@"R"]){
                page.PageRightFile = background.skinfilename;
                if (page.PageRightFile.length > 0) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageRightFile]];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageRightFile];
                    [[Common info] downloadImage:url ToFile:localpathname];
                }
                page.PageColorA = background.alpha;
                page.PageColorR = background.red;
                page.PageColorG = background.green;
                page.PageColorB = background.blue;
            }
            
        }
        else if(page.IsPage){
            if([selectLRstr isEqualToString:@"L"]){
                page.PageFile = background.skinfilename;
                if (page.PageFile.length > 0) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                    [[Common info] downloadImage:url ToFile:localpathname];
                }
                page.PageColorA = background.alpha;
                page.PageColorR = background.red;
                page.PageColorG = background.green;
                page.PageColorB = background.blue;
            }else if([selectLRstr isEqualToString:@"R"]){
                page.PageRightFile = background.skinfilename;
                if (page.PageRightFile.length > 0) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageRightFile]];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageRightFile];
                    [[Common info] downloadImage:url ToFile:localpathname];
                }
                page.PageColorA = background.alpha;
                page.PageColorR = background.red;
                page.PageColorG = background.green;
                page.PageColorB = background.blue;
            }
        }
        
        
        
        return TRUE;
    }
    return FALSE;
}

- (BOOL)changeLayout:(NSInteger)index From:(Layout *)selected_layout {
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR) {
        _skin_url = URL_CALENDAR_PAGESKIN_PATH;
    }
    
    if (_product_type == PRODUCT_DIVISIONSTICKER) {
        _skin_url = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
    }

    // 복사해서 사용할 것. (2016.4.8. 앞/뒤 페이지를 같은 레이아웃으로 변경하면 사진을 넣고 뺄때 똑같이 반영되는 버그 수정)
    Layout *layout = [selected_layout copy];

    // 2018.06 : 디자인포토 가로모드 지원
    if ([_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"]
        || [_ProductCode isEqualToString:@"347063"]
        || [_ProductCode isEqualToString:@"347064"]
        || _product_type == PRODUCT_DIVISIONSTICKER ) {
        /*
        layout.width = layout.width;
        layout.height = layout.height;
        */
        _page_rect = CGRectMake(0, 0, layout.width, layout.height);
    }

    //
    if (index >= 0 && index < _pages.count) {

        Page *page = _pages[index];

        // 2018.06 : 디자인포토 가로모드 지원
        if ([_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"]
            || [_ProductCode isEqualToString:@"347063"]
            || [_ProductCode isEqualToString:@"347064"]
            || _product_type == PRODUCT_DIVISIONSTICKER) {
            page.PageWidth = layout.width;
            page.PageHeight = layout.height;
        }

#if 1   // 배경이미지는 changeBackground를 통해서 바꾸도록 정책 변경됨. 2016.1.19. (커버페이지만 기존 정책대로 동작)
        // 디자인포토(네컷인화)는 예외 처리
        if ([layout.type isEqualToString:@"cover"] || [_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"]
            || [_ProductCode isEqualToString:@"347063"]
            || [_ProductCode isEqualToString:@"347064"]
            || _product_type == PRODUCT_DIVISIONSTICKER) {
            page.PageFile = layout.skinfilename;
            if (page.PageFile.length > 0) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                [[Common info] downloadImage:url ToFile:localpathname];
            }
        } else if (_product_type == PRODUCT_POSTER) {
            page.PageFile = [layout.thumbnail stringByReplacingOccurrencesOfString:@"A2" withString:_ProductSize];
            if (page.PageFile.length > 0) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                [[Common info] downloadImage:url ToFile:localpathname];
            }
        } else if (_product_type == PRODUCT_PAPERSLOGAN) {
            page.PageFile = layout.thumbnail;
            if (page.PageFile.length > 0) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                [[Common info] downloadImage:url ToFile:localpathname];
            }
        } else if (_product_type == PRODUCT_TRANSPARENTCARD) {
            page.PageFile = layout.thumbnail;
            if (page.PageFile.length > 0) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                [[Common info] downloadImage:url ToFile:localpathname];
            }
        }
        else if (_product_type == PRODUCT_DIVISIONSTICKER) {
            page.PageFile = layout.thumbnail;
            if (page.PageFile.length > 0) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                [[Common info] downloadImage:url ToFile:localpathname];
            }
        }
#endif
        int i = 0;
        for (Layer *layer in layout.layers) { // .......................... 새로 고른 레이아웃에 이전 레이아웃의 이미지를 채우기 위해 순회한다.

            if (layer.AreaType == 0) {
                Layer *old_layer = nil;
                while (i < page.layers.count) { // ........................ 사용 중인 레이아웃의 각 레이어를 순회하며,
                    Layer *temp_layer = page.layers[i++];
                    if (temp_layer.AreaType == 0) {
                        old_layer = temp_layer; // ........................ 이미지 레이어를 찾으면,
                        break;
                    }
                }
                if (old_layer != nil) { // ................................ 이미지 정보를 [새로운 레이어]에 넣는다.
                    layer.Filename = old_layer.Filename;
                    layer.ImageFilename = old_layer.ImageFilename;
                    layer.ImageEditname = old_layer.ImageEditname;
                    layer.ImageOriWidth = old_layer.ImageOriWidth;
                    layer.ImageOriHeight = old_layer.ImageOriHeight;
                    layer.EditImageMaxSize = old_layer.EditImageMaxSize;
                    layer.TextDescription = old_layer.TextDescription;

                    // 크롭정보, 회전정보, 화소체크는 리셋한다.
                    layer.ImageR = 0;
                    layer.ImageCropX = 0;
                    layer.ImageCropY = 0;
                    layer.ImageCropW = 0;
                    layer.ImageCropH = 0;
                    layer.is_lowres = NO;
                }
                if (layer.FrameFilename.length > 0) {
                    NSURL *url;
                    if(_product_type == PRODUCT_CALENDAR)
                    {
                        NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.FrameFilename]];
                    }
                    else
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.FrameFilename]];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, layer.FrameFilename];
                    [[Common info] downloadImage:url ToFile:localpathname];
                }
                // 신규 달력 포맷 : frameinfo
                if (layer.Frameinfo.length > 0) {
                    NSString *frameInfoFile = @"";
                    NSString *cutFrameInfoFile = @"";

                    NSArray *tarr = [layer.Frameinfo componentsSeparatedByString:@"^"];
                    frameInfoFile = [tarr objectAtIndex:0];
                    if([tarr count] > 1)
                        cutFrameInfoFile = [tarr objectAtIndex:1];

                    if(frameInfoFile.length > 0) {
                        NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, frameInfoFile]];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, frameInfoFile];
                        [[Common info] downloadImage:url ToFile:localpathname];
                    }
                    if(cutFrameInfoFile.length > 0) {
                        NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, cutFrameInfoFile]];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, cutFrameInfoFile];
                        [[Common info] downloadImage:url ToFile:localpathname];
                    }
                }
            }
            else if (layer.AreaType == 1) { //
                NSURL *url;
                if(_product_type == PRODUCT_CALENDAR)
                {
                    NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.Filename]];
                }
                else
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.Filename]];
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, layer.Filename];
                [[Common info] downloadImage:url ToFile:localpathname];
            }
            else if (layer.AreaType == 2) {
                if (_product_type == PRODUCT_POLAROID) {
                    Layer *old_layer = nil;
                    i = 0;
                    while (i < page.layers.count) { // ............................ 사용 중인 레이아웃의 각 레이어를 순회하며,
                        Layer *temp_layer = page.layers[i++];
                        if (temp_layer.AreaType == 2) {
                            if(temp_layer.MaskX == layer.MaskX && temp_layer.MaskY == layer.MaskY && temp_layer.MaskW == layer.MaskW && temp_layer.MaskH == layer.MaskH && temp_layer.MaskR == layer.MaskR) {
                                old_layer = temp_layer; // ........................ 텍스트 레이어를 찾으면,
                                break;
                            }
                        }
                    }
                    if (old_layer != nil) { // ................................ 이미지 정보를 [새로운 레이어]에 넣는다.
                        layer.TextDescription = old_layer.TextDescription;
                    }
                }
            }
            // 신규 달력 포맷 : 폰트 다운로드
            else if (layer.AreaType == 11 || layer.AreaType == 12 || layer.AreaType == 13 || layer.AreaType == 14) {
                NSString *fontName = layer.Fontname;
                NSString *fontUrl = layer.Fonturl;

                if (fontUrl != nil && fontUrl.length > 0)
                {
                    NSString *fontFileName = [[Common info] makeMD5Hash:fontUrl];

                    NSURL *url = [NSURL URLWithString:fontUrl];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/fonts/%@", _base_folder, fontFileName];
                    [[Common info] downloadFile:url ToFile:localpathname];
                }
            }
        }

        NSMutableArray *iconlayers = [NSMutableArray array];
        NSMutableArray *removeiconlayers = [NSMutableArray array];
        if (_product_type == PRODUCT_CALENDAR) {
            for (Layer *layer in page.layers) {
                if (layer.AreaType == 1) {
					// 신규 달력 포맷 : 2018.12.03 : 버그 수정
                    // 신규 달력 포맷 : 2018.11.12
					/*
                    if([layer.Filename hasPrefix:@"un_"] || (layer.Gid != nil && ![[layer.Gid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]))
                        [iconlayers insertObject:layer atIndex:0];
					*/
                    if(!([layer.Filename hasPrefix:@"un_"] || (layer.Gid != nil && ![[layer.Gid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])))
                        [removeiconlayers insertObject:layer atIndex:0];
					else
                        [iconlayers insertObject:layer atIndex:0];
                }
            }
			[page.layers removeObjectsInArray:removeiconlayers];
		}
        // 신규 달력 포맷 : 레이아웃 변경
        NSMutableArray *callayers = [NSMutableArray array];
        if (_product_type == PRODUCT_CALENDAR) {
            for (Layer *layer in page.layers) {
                if (layer.AreaType == 11 || layer.AreaType == 12 || layer.AreaType == 13 || layer.AreaType == 14) {
                    [callayers insertObject:layer atIndex:0];
                }
            }
        }

        /*
        if (_product_type == PRODUCT_POLAROID) {
            for (Layer *layer in layout.layers) {
                Layer *old_layer = nil;
                i = 0;
                while (i < page.layers.count) { // ........................... 사용 중인 레이아웃의 각 레이어를 순회하며,
                    Layer *temp_layer = page.layers[i++];
                    NSLog(@"#1");
                    if (temp_layer.AreaType == 2) {
                        NSLog(@"#2");
                        if(temp_layer.MaskX == layer.MaskX && temp_layer.MaskY == layer.MaskY && temp_layer.MaskW == layer.MaskW && temp_layer.MaskH == layer.MaskH && temp_layer.MaskR == layer.MaskR) {
                            NSLog(@"#3");
                            old_layer = temp_layer; // ........................ 텍스트 레이어를 찾으면,
                            break;
                        }
                    }
                }
                if (old_layer != nil) { // .................................... 이미지 정보를 [새로운 레이어]에 넣는다.
                    layer.TextDescription = old_layer.TextDescription;
                }
            }
        }
        */

        page.layers = layout.layers;

        if (_product_type == PRODUCT_CALENDAR) {
            for (Layer *layer in iconlayers) {
                [page.layers addObject:layer];
            }
            // 신규 달력 포맷 : 레이아웃 변경
            for (Layer *layer in callayers) {
                [page.layers addObject:layer];
            }
        }

        return TRUE;
    }
    return FALSE;
}
- (BOOL)changeLayout:(NSInteger)index From:(Layout *)selected_layout SelectLR:(NSString*)selectLRstr {
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR) {
        _skin_url = URL_CALENDAR_PAGESKIN_PATH;
    }
    
    if (_product_type == PRODUCT_DIVISIONSTICKER) {
        _skin_url = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
    }
    else if (_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 )) {
        _skin_url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_SKIN_PATH, [Common info].connection.tplServerInfo];
    }
    
    // 복사해서 사용할 것. (2016.4.8. 앞/뒤 페이지를 같은 레이아웃으로 변경하면 사진을 넣고 뺄때 똑같이 반영되는 버그 수정)
    Layout *layout = [selected_layout copy];
    
    // 2018.06 : 디자인포토 가로모드 지원
    if ([_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"]
        || [_ProductCode isEqualToString:@"347063"]
        || [_ProductCode isEqualToString:@"347064"]
        || _product_type == PRODUCT_DIVISIONSTICKER ) {
        /*
         layout.width = layout.width;
         layout.height = layout.height;
         */
        _page_rect = CGRectMake(0, 0, layout.width, layout.height);
    }
    
    //
    if (index >= 0 && index < _pages.count) {
        
        Page *page = _pages[index];
        
        // 2018.06 : 디자인포토 가로모드 지원
        if ([_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"]
            || [_ProductCode isEqualToString:@"347063"]
            || [_ProductCode isEqualToString:@"347064"]
            || _product_type == PRODUCT_DIVISIONSTICKER) {
            page.PageWidth = layout.width;
            page.PageHeight = layout.height;
        }
        
#if 1   // 배경이미지는 changeBackground를 통해서 바꾸도록 정책 변경됨. 2016.1.19. (커버페이지만 기존 정책대로 동작)
        // 디자인포토(네컷인화)는 예외 처리
        if (([layout.type isEqualToString:@"cover"] && [Common info].photobook.depth1_key.length <= 0) || [_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"]
            || [_ProductCode isEqualToString:@"347063"]
            || [_ProductCode isEqualToString:@"347064"]
            || _product_type == PRODUCT_DIVISIONSTICKER) {
            page.PageFile = layout.skinfilename;
            if (page.PageFile.length > 0) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _skin_url, page.PageFile]];
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile];
                [[Common info] downloadImage:url ToFile:localpathname];
            }
        }
#endif
        int i = 0;
        for (Layer *layer in layout.layers) { // .......................... 새로 고른 레이아웃에 이전 레이아웃의 이미지를 채우기 위해 순회한다.
            
            if (layer.AreaType == 0) {
                Layer *old_layer = nil;
                while (i < page.layers.count) { // ........................ 사용 중인 레이아웃의 각 레이어를 순회하며,
                    Layer *temp_layer = page.layers[i++];
                    if (temp_layer.AreaType == 0 && [temp_layer.str_positionSide isEqualToString:selectLRstr]) {
                        old_layer = temp_layer; // ........................ 이미지 레이어를 찾으면,
                        break;
                    }
                }
                if (old_layer != nil) { // ................................ 이미지 정보를 [새로운 레이어]에 넣는다.
                    layer.Filename = old_layer.Filename;
                    layer.ImageFilename = old_layer.ImageFilename;
                    layer.ImageEditname = old_layer.ImageEditname;
                    layer.ImageOriWidth = old_layer.ImageOriWidth;
                    layer.ImageOriHeight = old_layer.ImageOriHeight;
                    layer.EditImageMaxSize = old_layer.EditImageMaxSize;
                    layer.TextDescription = old_layer.TextDescription;
                    layer.str_positionSide = selectLRstr;
                    
                    // 크롭정보, 회전정보, 화소체크는 리셋한다.
                    layer.ImageR = 0;
                    layer.ImageCropX = 0;
                    layer.ImageCropY = 0;
                    layer.ImageCropW = 0;
                    layer.ImageCropH = 0;
                    layer.is_lowres = NO;
                }
                if (layer.FrameFilename.length > 0) {
                    NSURL *url;
                    if(_product_type == PRODUCT_CALENDAR)
                    {
                        NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.FrameFilename]];
                    }
                    else if(_product_type == PRODUCT_PHOTOBOOK){ //photobook v2 clipartpath
                        NSString *host = [NSString stringWithFormat:URL_PHOTOBOOK_V2_CLIPART_PATH, [Common info].connection.tplServerInfo];
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.FrameFilename]];
                    }
                    else{
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.FrameFilename]];
                    }
                    
                    NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, layer.FrameFilename];
                    [[Common info] downloadImage:url ToFile:localpathname];
                }
                // 신규 달력 포맷 : frameinfo
                if (layer.Frameinfo.length > 0) {
                    NSString *frameInfoFile = @"";
                    NSString *cutFrameInfoFile = @"";
                    
                    NSArray *tarr = [layer.Frameinfo componentsSeparatedByString:@"^"];
                    frameInfoFile = [tarr objectAtIndex:0];
                    if([tarr count] > 1)
                        cutFrameInfoFile = [tarr objectAtIndex:1];
                    
                    if(frameInfoFile.length > 0) {
                        NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, frameInfoFile]];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, frameInfoFile];
                        [[Common info] downloadImage:url ToFile:localpathname];
                    }
                    if(cutFrameInfoFile.length > 0) {
                        NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, cutFrameInfoFile]];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, cutFrameInfoFile];
                        [[Common info] downloadImage:url ToFile:localpathname];
                    }
                }
                //photobookv2 사이드별 좌표 조정
                if([selectLRstr isEqualToString:@"L"]){
                    //차이없음
                }else if([selectLRstr isEqualToString:@"R"]){
                    if(page.IsCover){
                        layer.MaskX += page.PageLeftWidth + page.PageMiddleWidth;
                    }else{
                        layer.MaskX += page.PageLeftWidth;
                    }
                    
                }
            }
            else if (layer.AreaType == 1) { //아이콘 레이어
                NSURL *url;
                if(_product_type == PRODUCT_CALENDAR)
                {
                    NSString *host = [NSString stringWithFormat:URL_CALENDAR_STICKER_PATH, [Common info].connection.tplServerInfo];
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.Filename]];
                }
                else if(_product_type == PRODUCT_PHOTOBOOK){ //photobook v2 clipartpath
                    NSString *host = [NSString stringWithFormat:URL_PHOTOBOOK_V2_CLIPART_PATH, [Common info].connection.tplServerInfo];
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", host, layer.Filename]];
                }
                else{
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PRODUCT_STICKER_PATH, layer.Filename]];
                }
                
                NSString *localpathname = [NSString stringWithFormat:@"%@/temp/%@", _base_folder, layer.Filename];
                [[Common info] downloadImage:url ToFile:localpathname];
                
                //photobookv2 사이드별 좌표 조정
                if([selectLRstr isEqualToString:@"L"]){
                    //차이없음
                }else if([selectLRstr isEqualToString:@"R"]){
                    if(page.IsCover){
                        layer.MaskX += page.PageLeftWidth + page.PageMiddleWidth;
                    }else{
                        layer.MaskX += page.PageLeftWidth;
                    }
                    
                }
                
            }
            else if (layer.AreaType == 2) {
                if (_product_type == PRODUCT_POLAROID) {
                    Layer *old_layer = nil;
                    i = 0;
                    while (i < page.layers.count) { // ............................ 사용 중인 레이아웃의 각 레이어를 순회하며,
                        Layer *temp_layer = page.layers[i++];
                        if (temp_layer.AreaType == 2) {
                            if(temp_layer.MaskX == layer.MaskX && temp_layer.MaskY == layer.MaskY && temp_layer.MaskW == layer.MaskW && temp_layer.MaskH == layer.MaskH && temp_layer.MaskR == layer.MaskR) {
                                old_layer = temp_layer; // ........................ 텍스트 레이어를 찾으면,
                                break;
                            }
                        }
                    }
                    if (old_layer != nil) { // ................................ 이미지 정보를 [새로운 레이어]에 넣는다.
                        layer.TextDescription = old_layer.TextDescription;
                    }
                }
                //photobookv2 사이드별 좌표 조정
                if([selectLRstr isEqualToString:@"L"]){
                    //차이없음
                }else if([selectLRstr isEqualToString:@"R"]){
                    if(page.IsCover){
                        layer.MaskX += page.PageLeftWidth + page.PageMiddleWidth;
                    }else{
                        layer.MaskX += page.PageLeftWidth;
                    }
                    
                }
                NSString *fontName = layer.TextFontname;
                NSString *fontUrl = layer.TextFontUrl;
                
                if (fontUrl != nil && fontUrl.length > 0)
                {
                    NSString *fontFileName = [[Common info] makeMD5Hash:fontUrl];
                    
                    NSURL *url = [NSURL URLWithString:fontUrl];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/fonts/%@", _base_folder, fontFileName];
                    [[Common info] downloadFile:url ToFile:localpathname];
                }
            }
            // 신규 달력 포맷 : 폰트 다운로드
            else if (layer.AreaType == 11 || layer.AreaType == 12 || layer.AreaType == 13 || layer.AreaType == 14) {
                NSString *fontName = layer.Fontname;
                NSString *fontUrl = layer.Fonturl;
                
                if (fontUrl != nil && fontUrl.length > 0)
                {
                    NSString *fontFileName = [[Common info] makeMD5Hash:fontUrl];
                    
                    NSURL *url = [NSURL URLWithString:fontUrl];
                    NSString *localpathname = [NSString stringWithFormat:@"%@/fonts/%@", _base_folder, fontFileName];
                    [[Common info] downloadFile:url ToFile:localpathname];
                }
            }
        }
        
        NSMutableArray *iconlayers = [NSMutableArray array];
        NSMutableArray *removeiconlayers = [NSMutableArray array];
        /*if (_product_type == PRODUCT_CALENDAR) {
            for (Layer *layer in page.layers) {
                if (layer.AreaType == 1) {
         
                    if(!([layer.Filename hasPrefix:@"un_"] || (layer.Gid != nil && ![[layer.Gid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])))
                        [removeiconlayers insertObject:layer atIndex:0];
                    else
                        [iconlayers insertObject:layer atIndex:0];
                }
            }
            [page.layers removeObjectsInArray:removeiconlayers];
        }*/
        // 신규 달력 포맷 : 레이아웃 변경
        NSMutableArray *callayers = [NSMutableArray array];
        /*if (_product_type == PRODUCT_CALENDAR) {
            for (Layer *layer in page.layers) {
                if (layer.AreaType == 11 || layer.AreaType == 12 || layer.AreaType == 13 || layer.AreaType == 14) {
                    [callayers insertObject:layer atIndex:0];
                }
            }
        }*/
        
        //photobook v2 변경 레이아웃 요소 적용
         NSMutableArray *removelayers = [NSMutableArray array];
        if(_product_type == PRODUCT_PHOTOBOOK){
            for (Layer *layer in page.layers) {
                if([layer.str_positionSide isEqualToString:selectLRstr]){
                    [removelayers addObject:layer];
                    
                }
            }
            [page.layers removeObjectsInArray:removelayers];
            
            for (Layer *layer in layout.layers) {
                layer.str_positionSide = selectLRstr;
                [page.layers addObject:layer];
            }
            
        }else {
            page.layers = layout.layers;
        }
        
        if (_product_type == PRODUCT_CALENDAR) {
            for (Layer *layer in iconlayers) {
                [page.layers addObject:layer];
            }
            // 신규 달력 포맷 : 레이아웃 변경
            for (Layer *layer in callayers) {
                [page.layers addObject:layer];
            }
        }
        
        return TRUE;
    }
    return FALSE;
}

- (BOOL)canPageAdd {
    NSUInteger page_count = _pages.count*2 - 3;
    if ([_ProductCode isEqualToString:@"120069"]) { // SJYANG : 카달로그
        if (page_count + 3 < _MaxPage) {
            return TRUE;
        }
    }
    else {
        if (page_count < _MaxPage) {
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)insertPage:(NSInteger)index FromDefaultPage:(Page *)default_page {
    // SJYANG.2017.05 : 네컷인화 상품은 index 0 페이지를 복사함
    if((!([_ProductCode isEqualToString:@"347037"] ||
        [_ProductCode isEqualToString:@"347063"] || // miniwallet
        [_ProductCode isEqualToString:@"347064"]) || // division
        [_ProductCode isEqualToString:@"347036"]) && _product_type != PRODUCT_POSTER && _product_type != PRODUCT_TRANSPARENTCARD) {
        if (index <= 0) {
            return FALSE;
        }
    }

    if (default_page == nil) {
        if (index <= 1) {
            Page *page = [_pages[2] copy];
            [_pages insertObject:page atIndex:index+1];
        }
        else if (index < _pages.count) {
            Page *page = [_pages[index] copy];
            [_pages insertObject:page atIndex:index+1];
        }
    }
    else { // 유서희과장요청: 페이지 추가 시, 2-3p 배경(내지 01번) + 기본 1구 레이아웃(m_e02f001)으로 디폴트 세팅 해주세요.
        Page *page = [default_page copy];
        [_pages insertObject:page atIndex:index+1];
    }
    return TRUE;
}

- (BOOL)deletePage:(NSInteger)index {
    if ([_ProductCode isEqualToString:@"120069"]) { // SJYANG : 카달로그
        if (index <= 0) {
            return FALSE;
        }
    }
    else {
        if (index <= 1) {
            return FALSE;
        }
    }
    if (index < _pages.count) {
        [_pages removeObjectAtIndex:index];
    }
    return TRUE;
}

- (void)setUILabel:(UILabel *)myLabel withMaxFrame:(CGRect)maxFrame withText:(NSString *)theText usingVerticalAlign:(int)vertAlign {
    //CGSize stringSize = [theText sizeWithFont:myLabel.font constrainedToSize:maxFrame.size lineBreakMode:myLabel.lineBreakMode];
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = myLabel.lineBreakMode;
    paragraphStyle.alignment = myLabel.textAlignment;
    NSDictionary* attributes = @{NSFontAttributeName : myLabel.font, NSParagraphStyleAttributeName: paragraphStyle};
    CGSize stringSize = [myLabel.text boundingRectWithSize:maxFrame.size options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;


    switch (vertAlign) {
        case 0: // vertical align = top
            myLabel.frame = CGRectMake(myLabel.frame.origin.x,
                                       myLabel.frame.origin.y,
                                       myLabel.frame.size.width,
                                       stringSize.height
                                       );
            break;

        case 1: // vertical align = middle
            // don't do anything, lines will be placed in vertical middle by default
            break;

        case 2: // vertical align = bottom
            myLabel.frame = CGRectMake(myLabel.frame.origin.x,
                                       (myLabel.frame.origin.y + myLabel.frame.size.height) - stringSize.height,
                                       myLabel.frame.size.width,
                                       stringSize.height
                                       );
            break;
    }

    myLabel.text = theText;
}


- (void)setPolaroidUILabel:(UILabel *)myLabel withMaxFrame:(CGRect)maxFrame withText:(NSString *)theText usingVerticalAlign:(int)vertAlign {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = myLabel.lineBreakMode;
    paragraphStyle.alignment = myLabel.textAlignment;
    paragraphStyle.lineHeightMultiple = 0.90f;
    //paragraphStyle.lineSpacing = 10;
    //paragraphStyle.minimumLineHeight = 0;
    NSDictionary* attributes = @{NSFontAttributeName : myLabel.font, NSParagraphStyleAttributeName: paragraphStyle};
    CGSize stringSize = [myLabel.text boundingRectWithSize:maxFrame.size options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
            myLabel.frame = CGRectMake(myLabel.frame.origin.x,
                                       myLabel.frame.origin.y,
                                       myLabel.frame.size.width,
                                       stringSize.height
                                       );


    switch (vertAlign) {
        case 0: // vertical align = top
            myLabel.frame = CGRectMake(myLabel.frame.origin.x,
                                       myLabel.frame.origin.y,
                                       myLabel.frame.size.width,
                                       stringSize.height
                                       );
            break;

        case 1: // vertical align = middle
            // don't do anything, lines will be placed in vertical middle by default
            break;

        case 2: // vertical align = bottom
            myLabel.frame = CGRectMake(myLabel.frame.origin.x,
                                       (myLabel.frame.origin.y + myLabel.frame.size.height) - stringSize.height,
                                       myLabel.frame.size.width,
                                       stringSize.height
                                       );
            break;
    }

    NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:theText];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [theText length])];
    myLabel.attributedText = attrString;
}

// 2017.11.13 : SJYANG : 에러가 존재할 경우 FALSE, 에러가 없을 경우 TRUE 를 리턴하도록 수정
- (BOOL)composePage:(NSInteger)index ParentView:(UIImageView *)parentview IncludeBg:(BOOL)include_bg IsEdit:(BOOL)is_edit {

    BOOL errorExists = FALSE;
    NSString *intnum = @"";
    @try {
        intnum = [_ProductCode substringWithRange:NSMakeRange(0, 3)];
    }
    @catch(NSException *exception) {}

    CGRect working_rect = parentview.bounds;
    _working_rect = working_rect;
    if (_product_type == PRODUCT_PHONECASE) {
        // 2017.11.21 : SJYANG : 폰케이스의 이 부분 계산이 잘못된 듯 하여서 수정
        //float max_rect_width = 304.0f;
        //float max_rect_height = _pageViewHeight - 185.f;
        float max_rect_width = _pageViewHeight - 20.f;
        float max_rect_height = _pageViewHeight - 185.f;

        if( _page_rect.size.width / _page_rect.size.height > max_rect_width / max_rect_height ) {
            working_rect = CGRectMake(0, 0, max_rect_width, (float)max_rect_height / (float)_page_rect.size.width * (float)max_rect_width );
            _realPageMarginX = 0;
            _realPageWidth = (int)max_rect_width;
            _realPageHeight = (int)((float)max_rect_height / (float)_page_rect.size.width * (float)max_rect_width);
        }
        else {
            float w = (float)_page_rect.size.width / (float)_page_rect.size.height * (float)max_rect_height;
            float h = max_rect_height;
            working_rect = CGRectMake((parentview.frame.size.width - w)/2, 0, w, h);
            _realPageMarginX = (int)((parentview.frame.size.width - w)/2.f);
            _realPageWidth = (int)w;
            _realPageHeight = (int)h;
        }

//        NSLog(@"_page_rect.size.width : %f", _page_rect.size.width);
//        NSLog(@"_page_rect.size.height : %f", _page_rect.size.height);
//        NSLog(@"working_rect.size.width : %f", working_rect.size.width);
//        NSLog(@"working_rect.size.height : %f", working_rect.size.height);
    }
    if (include_bg) {
        if (_product_type == PRODUCT_PHOTOBOOK) {
            parentview.image = _page_bkimage_photobook;
            working_rect = CGRectInset(working_rect, 15, 15);
        }
        else if (_product_type == PRODUCT_CALENDAR) {
            // SJYANG : 2018 달력
            // 367:?, 369: wood stand, 391 : sheetcalendar, 393: poster
            if ([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"] || ![Common info].photobook.showSpring)
                parentview.image = _page_bkimage_calendar2;
            else
                parentview.image = _page_bkimage_calendar;

            working_rect.origin.x += 7;
            working_rect.origin.y += 7;
            working_rect.size.width -= (7+7);
            working_rect.size.height -= (7+18);

			/*
            working_rect = CGRectInset(working_rect, 7, 7);
			working_rect.size.height -= 11;
			*/
		}
        else if (_product_type == PRODUCT_POLAROID) {
            parentview.image = _page_bkimage_polaroid;
            working_rect = CGRectInset(working_rect, 5, 5);
        }
        else if (_product_type == PRODUCT_DESIGNPHOTO) {
            parentview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_SINGLECARD) {
            parentview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_MUG) {
            parentview.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_PHONECASE) {
            parentview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_CARD) {
            parentview.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_POSTCARD) {
            parentview.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = _page_bkimage_polaroid;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_MAGNET) {
			// 마그넷 : 마그넷은 백그라운드 이미지 + 외곽선 처리를 하지 않음

			// 마그넷 : 하트 상품 외곽선 처리
			if ([intnum isEqualToString:@"404"] && index < _pages.count) {
				Page *page = _pages[index];

				BOOL imageExists = NO;
				Layer *guideinfo = nil;
				for (Layer *layer in page.layers) {
					if (layer.AreaType == 3)
						guideinfo = layer;
					else if(layer.AreaType == 0) {
						if (layer.ImageEditname.length > 0) {
							imageExists = YES;
						}
					}
				}

	            working_rect = CGRectInset(working_rect, 0, 0);

				if (guideinfo != nil && !imageExists) {
					NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", [Common info].photobook.base_folder];
					NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, guideinfo.SkinFilename];

					UIImage *guideinfoImage = [UIImage imageWithContentsOfFile:localpathname];
					if(guideinfoImage != nil) {
						guideinfoImage = [[Common info].photobook maskImage:guideinfoImage];
						guideinfoImage = [[Common info].photobook outlineMaskBitmap:guideinfoImage withR:200 withG:200 withB:200 withA:255];

						parentview.image = guideinfoImage;
			            //working_rect = CGRectInset(working_rect, 1, 1); // 원래 있던 코드
					}
					// TODO : 마그넷 : guideinfo : 하트 상품 외곽선이 제대로 표시되지 않는 버그 수정 : 체크 필요
					else
						return NO;
				}
			}
        }
        else if (_product_type == PRODUCT_BABY) {
            // 미니스탠딩 : 여길 고치면 외곽선이 없어짐
            parentview.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        } else if (_product_type == PRODUCT_POSTER) {
            parentview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_TRANSPARENTCARD) {
            parentview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
        else if (_product_type == PRODUCT_DIVISIONSTICKER) {
            parentview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }
		else if (_product_type == PRODUCT_MONTHLYBABY) {
			parentview.image = _page_bkimage_polaroid;
			working_rect = CGRectInset(working_rect, 5, 5);
		}
        else {
            NSAssert(NO, @"composePage: productype is wrong...");
        }
    }
    
    if(_product_type == PRODUCT_PHOTOBOOK){
        if (index < _pages.count){
            Page *page = _pages[index];
            
            // SJYANG : 2018 달력
            if(_product_type == PRODUCT_CALENDAR && _ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                UIImageView *testview = [[UIImageView alloc] init]; // @@@
                [parentview addSubview:testview];
                [testview setFrame:working_rect];
                testview.backgroundColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
            }
            
            UIImageView *pageview = [[UIImageView alloc] init]; // @@@
            pageview.tag = 5001;
            [parentview addSubview:pageview];
            
            [pageview setFrame:working_rect];
            
            pageview.image = nil;
            pageview.backgroundColor = [UIColor colorWithRed:page.PageColorR/255.0f green:page.PageColorG/255.0f blue:page.PageColorB/255.0f alpha:page.PageColorA];
            
            // SJYANG : 2018 달력
            if(_product_type == PRODUCT_CALENDAR && _ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                if([intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"]) { // 369 => 우드스탠드, 391 => 시트달력
                    pageview.layer.cornerRadius = 20;
                    pageview.layer.borderWidth = 1;
                    pageview.layer.borderColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f].CGColor;
                }
                else {
                    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:pageview.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(20.0, 20.0)];
                    
                    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                    maskLayer.frame = pageview.bounds;
                    maskLayer.path  = maskPath.CGPath;
                    
                    pageview.layer.mask = maskLayer;
                }
            }
            
            if (page.PageFile.length > 0 ||
                page.PageMiddleFile.length > 0 ||
                page.PageRightFile.length > 0) {
                pageview.contentMode = UIViewContentModeScaleAspectFill;
                pageview.clipsToBounds = YES;
                if(_product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 )){
                    UIImage *combinedImage;
                    if(page.IsCover){
                        //[pageview setFrame:CGRectMake(15,15,315,200)];
                        UIImage *backCoverImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                        UIImage *middleCoverImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageMiddleFile]];
                        UIImage *frontCoverImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageRightFile]];
                        CGSize combinedSize = CGSizeMake(page.PageWidth, page.PageHeight);
                        CGRect centerRect = CGRectMake(page.PageLeftWidth, 0,page.PageMiddleWidth,page.PageHeight);
                        CGRect rightRect = CGRectMake(page.PageLeftWidth+page.PageMiddleWidth, 0,page.PageRightWidth,page.PageHeight);
                        UIColor *centerColor = [self colorWithRGBAInteger:page.PageCenterColor];
                        UIColor *rightColor = [self colorWithRGBAInteger:page.PageRightColor];
                        
                        UIGraphicsBeginImageContext(combinedSize);
                        
                        [centerColor setFill];
                        UIRectFill(centerRect);
                        [rightColor setFill];
                        UIRectFill(rightRect);
                        
                        [backCoverImage drawAtPoint:CGPointMake(0,0)];
                        [middleCoverImage drawAtPoint:CGPointMake(page.PageLeftWidth,0)];
                        [frontCoverImage drawAtPoint:CGPointMake(page.PageLeftWidth+page.PageMiddleWidth,0)];
                        
                        
                        /*CGContextRef context = UIGraphicsGetCurrentContext();
                        
                        CGContextClipToMask(context, page.cover_backrect, backCoverImage.CGImage);
                        CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
                        CGContextFillRect(context, page.cover_backrect);
                        
                        CGContextClipToMask(context, page.cover_middlerect, middleCoverImage.CGImage);
                        CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
                        CGContextFillRect(context, page.cover_middlerect);
                        
                        CGContextClipToMask(context, page.cover_frontrect, frontCoverImage.CGImage);
                        CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
                        CGContextFillRect(context, page.cover_frontrect);*/
                        
                       
                        
                        combinedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        pageview.image = combinedImage;
                    }
                    else if(page.IsProlog){
                        //pageview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                        UIImage *leftImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                        UIImage *rightImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageRightFile]];
                        
                        CGSize combinedSize = CGSizeMake(page.PageWidth, page.PageHeight);
                        
                        
                        CGRect rightRect = CGRectMake(page.PageLeftWidth, 0,page.PageRightWidth,page.PageHeight);
                       
                        UIColor *rightColor = [self colorWithRGBAInteger:page.PageRightColor];
                        
                        UIGraphicsBeginImageContext(combinedSize);
                        
                        
                        [rightColor setFill];
                        UIRectFill(rightRect);
                        
                        [leftImage drawAtPoint:CGPointMake(0,0)];
                        [rightImage drawAtPoint:CGPointMake(page.PageLeftWidth,0)];
                        
                        combinedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        pageview.image = combinedImage;
                    }
                    else if(page.IsEpilog){
                        pageview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                    }
                    else if(page.IsPage){
                        UIImage *leftImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                        UIImage *rightImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageRightFile]];
                        
                        CGSize combinedSize = CGSizeMake(page.PageWidth, page.PageHeight);
                        CGRect rightRect = CGRectMake(page.PageLeftWidth, 0,page.PageRightWidth,page.PageHeight);
                        
                        UIColor *rightColor = [self colorWithRGBAInteger:page.PageRightColor];
                        
                        UIGraphicsBeginImageContext(combinedSize);
                        
                        
                        [rightColor setFill];
                        UIRectFill(rightRect);
                        
                        [leftImage drawAtPoint:CGPointMake(0,0)];
                        [rightImage drawAtPoint:CGPointMake(page.PageLeftWidth,0)];
                        
                        combinedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        pageview.image = combinedImage;
                    }
                    
                    
                }
                else {
                    pageview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                    
                }
            }
            
            CGFloat scale = 1.0f;
            scale = working_rect.size.width/page.PageWidth;
            _edit_scale = scale;
            
            NSLog(@"working_rect.size.width : %f", working_rect.size.width);
            NSLog(@"page.PageWidth : %d", page.PageWidth);
            NSLog(@"page.PageHeight : %d", page.PageHeight);
            NSLog(@"_edit_scale : %f", _edit_scale);
            
            // 마그넷 : guideinfo
            Layer *guideinfo = nil;
            if(_product_type == PRODUCT_MAGNET) {
                for (Layer *layer in page.layers) {
                    if (layer.AreaType == 3)
                        guideinfo = layer;
                }
            }
            
            for (Layer *layer in page.layers) {
                
                if (layer.AreaType == 2) { // 2:text
                    UILabel *layerview = [[UILabel alloc] init]; // @@@
                    
                    layerview.textAlignment = NSTextAlignmentCenter;
                    if ([layer.Halign isEqualToString:@"left"]) {
                        layerview.textAlignment = NSTextAlignmentLeft;
                    }
                    else if ([layer.Halign isEqualToString:@"right"]) {
                        layerview.textAlignment = NSTextAlignmentRight;
                    }
                    
                    layerview.textColor = layer.text_color;
                    
                    if ([layer.Gid isEqualToString:@"spine"]) {
                        layerview.text = layer.TextDescription;
                        layerview.adjustsFontSizeToFitWidth = YES;
                        //[layerview setFont:[UIFont systemFontOfSize:8.0f]];
                        layerview.font = [UIFont systemFontOfSize:layer.TextFontsize * scale];
                        //layerview.backgroundColor =UIColor.cyanColor;
                        
                        if (layerview.text.length <= 0) {
                            layerview.text = @"제목을 입력해 주세요";
                        }
                        
                        CGFloat margin = 10.f;
                        /*[layerview setFrame:CGRectMake(margin, 0, working_rect.size.height-margin*2, 26*scale)];
                        [layerview setCenter:CGPointMake(working_rect.size.width/2, margin + working_rect.size.height/2)];*/
                        [layerview setFrame:CGRectMake(0, 0, working_rect.size.height-margin*2, 26*scale)];
                        if([Common info].photobook.ProductType.length > 0){
                            [layerview setCenter:CGPointMake(working_rect.size.width/2, working_rect.size.height/2)];
                        }
                        else {
                            [layerview setCenter:CGPointMake(working_rect.size.width/2, margin + working_rect.size.height/2)];
                        }
                        
                        [layerview setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                        [pageview addSubview:layerview];
                    }
                    else {
                        if (_product_type == PRODUCT_PHONECASE) {
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            float fontsize = layer.TextFontsize;
                            fontsize = fontsize * 0.575f * 1.087f;
                            
                            CGSize labelSize = [layerview.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontsize]}];
                            float tx, ty, tw, th;
                            tw = labelSize.width;
                            th = labelSize.height;
                            if( layer.MaskW*scale > tw )
                                tx = layer.MaskX*scale + (layer.MaskW*scale - tw) / 2.f;
                            else
                                tx = layer.MaskX*scale - (tw - layer.MaskW*scale) / 2.f;
                            if( layer.MaskH*scale > th )
                                ty = layer.MaskY*scale + (layer.MaskH*scale - th) / 2.f;
                            else
                                ty = layer.MaskY*scale - (th - layer.MaskH*scale) / 2.f;
                            
                            layerview.adjustsFontSizeToFitWidth = YES;
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            [layerview setFrame: CGRectMake(tx, ty, tw, th)];
                            [pageview addSubview:layerview];
                        }
                        else if (_product_type == PRODUCT_CARD) {
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            
                            layerview.adjustsFontSizeToFitWidth = YES;
                            float fontsize = layer.TextFontsize;
                            
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            fontsize = layer.TextFontsize * 1.00f;
                            NSString *fs_filepath = [NSString stringWithFormat:@"%@/edit/fs.%@.%ld", _base_folder, _ProductId, (long)index];
                            BOOL isDir = YES;
                            if(include_bg == YES) {
                                [[NSString stringWithFormat:@"%f", scale] writeToFile:fs_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                            else {
                                if( [[NSFileManager defaultManager] fileExistsAtPath:fs_filepath isDirectory:&isDir]==YES ) {
                                    NSString* tstr = [NSString stringWithContentsOfFile:fs_filepath encoding:NSUTF8StringEncoding error:nil];
                                    CGFloat tscale = [tstr floatValue];
                                    fontsize = layer.TextFontsize * 1.00f * (scale / tscale);
                                }
                            }
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            layerview.layer.borderWidth = 1.0;
                            
                            [layerview setFrame: CGRectMake(0, 0, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            playerview.layer.borderWidth = 1.0;
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        }
                        else if (_product_type == PRODUCT_POLAROID) {
                            layerview.textColor = layer.text_color;
                            
                            /*
                             NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld.%d%d%d%d%d", _base_folder, _BasketName, index, layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH, layer.MaskR];
                             NSString *textcontents = [NSString stringWithContentsOfFile:tc_filepath encoding:NSUTF8StringEncoding error:nil];
                             layer.TextDescription = textcontents;
                             */
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO || include_bg == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"내용입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            layerview.adjustsFontSizeToFitWidth = NO;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            float fontsize = layer.TextFontsize;
                            //fontsize = fontsize * 0.436f; // iPhone 5s
                            fontsize = fontsize * 1.65f * scale; // iPhone 6s
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            layerview.layer.borderWidth = 1.0;
                            
                            //[layerview setFrame: CGRectMake(layer.MaskW * scale * 0.005f, layer.MaskH * scale * 0.015f, layer.MaskW*scale, layer.MaskH*scale)];
                            [layerview setFrame: CGRectMake(layer.MaskW * scale * 0.005f, layer.MaskH * scale * 0.085f, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            layerview.numberOfLines = 0;
                            layerview.adjustsFontSizeToFitWidth = NO;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            if(include_bg == NO)
                                playerview.layer.borderWidth = 0.0;
                            else
                                playerview.layer.borderWidth = 1.0;
                            
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            [self setPolaroidUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        } else if (_product_type == PRODUCT_SINGLECARD) {
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            // ... 올 수 있도록 수정
                            layerview.minimumScaleFactor = 1.0 ;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            
                            layerview.adjustsFontSizeToFitWidth = YES;
                            float fontsize = layer.TextFontsize;
                            
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            fontsize = layer.TextFontsize * 1.00f;
                            NSString *fs_filepath = [NSString stringWithFormat:@"%@/edit/fs.%@.%ld", _base_folder, _ProductId, (long)index];
                            BOOL isDir = YES;
                            if(include_bg == YES) {
                                [[NSString stringWithFormat:@"%f", scale] writeToFile:fs_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                            else {
                                if( [[NSFileManager defaultManager] fileExistsAtPath:fs_filepath isDirectory:&isDir]==YES ) {
                                    NSString* tstr = [NSString stringWithContentsOfFile:fs_filepath encoding:NSUTF8StringEncoding error:nil];
                                    CGFloat tscale = [tstr floatValue];
                                    fontsize = layer.TextFontsize * 1.00f * (scale / tscale);
                                }
                            }
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            layerview.layer.borderWidth = 1.0;
                            
                            [layerview setFrame: CGRectMake(0, 0, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            playerview.layer.borderWidth = 1.0;
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        } else if (_product_type == PRODUCT_MAGNET) { // 마그넷 : 텍스트 영역 추가
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            // ... 올 수 있도록 수정
                            layerview.minimumScaleFactor = 1.0 ;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            
                            // 마그넷 : 작업중
                            //layerview.adjustsFontSizeToFitWidth = YES;
                            layerview.adjustsFontSizeToFitWidth = YES;
                            float fontsize = layer.TextFontsize;
                            
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            // 2019.03.08
                            //fontsize = layer.TextFontsize * 1.00f;
                            fontsize = layer.TextFontsize * 1.5f * 0.8f * _edit_scale;
                            
                            // TODO : 마그넷 : ProductId 를 파일명에서 뺐는데, 그래도 되는 것인지 체크 필요
                            NSString *fs_filepath = [NSString stringWithFormat:@"%@/edit/fs.%ld", _base_folder, (long)index];
                            //NSLog(@"tscale : path : %@", fs_filepath);
                            
                            // 2019.03.08 : 주석 처리
                            /*
                             BOOL isDir = YES;
                             if(include_bg == YES) {
                             [[NSString stringWithFormat:@"%f", scale] writeToFile:fs_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                             }
                             else {
                             //NSLog(@"FIND tscale");
                             if( [[NSFileManager defaultManager] fileExistsAtPath:fs_filepath isDirectory:&isDir]==YES ) {
                             NSString* tstr = [NSString stringWithContentsOfFile:fs_filepath encoding:NSUTF8StringEncoding error:nil];
                             CGFloat tscale = [tstr floatValue];
                             
                             // 2019.03.07
                             //fontsize = layer.TextFontsize * 1.00f * (scale / tscale);
                             fontsize = layer.TextFontsize * 1.5f * (scale / tscale);
                             }
                             }
                             */
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            // 마그넷 : 작업중
                            if(_useTitleHint == YES || true)
                                layerview.layer.borderWidth = 1.0;
                            else
                                layerview.layer.borderWidth = 0.0;
                            
                            [layerview setFrame: CGRectMake(0, 0, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            // 마그넷 : 작업중
                            if(_useTitleHint == YES || true)
                                playerview.layer.borderWidth = 1.0;
                            else
                                playerview.layer.borderWidth = 0.0;
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            // 마그넷 : 작업중
                            NSLog(@"DEBUG :: layer.MaskH*scale : %f", layer.MaskH*scale);
                            NSLog(@"DEBUG :: fontsize : %f", fontsize);
                            
                            int valign = 0; // 기본 : 상하 top 정렬
                            /*
                             if ([_ProductCode isEqualToString:@"400005"]) valign = 1; // 정사각 > 리얼후르츠 : 상하 center 정렬
                             if ([_ProductCode isEqualToString:@"401002"]) valign = 1; // 직사각 > 심플컬러 : 상하 center 정렬??
                             if ([_ProductCode isEqualToString:@"401005"]) valign = 1; // 직사각 > 리얼후르츠 : 상하 center 정렬
                             if ([intnum isEqualToString:@"402"]) valign = 1; // 레트로 : 상하 bottom 정렬 => 상하 center 정렬 : 2019.03.07
                             // 2019.03.06
                             if ([intnum isEqualToString:@"403"]) valign = 1; // 포토부스 : 상하 center 정렬
                             */
                            
                            //[self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            if ((int)((layer.MaskH*scale) / fontsize) <= 1)
                                [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:valign];
                            else
                                [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        }
                        else if (_product_type == PRODUCT_PHOTOBOOK && _depth1_key.length > 0) {
                            
                            layerview.text = layer.TextDescription;
                            layerview.numberOfLines = 0;
                            [layerview setLineBreakMode:NSLineBreakByWordWrapping];
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO || include_bg == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            if(layer.TextFontname.length > 0){
                                layerview.font = [UIFont fontWithName:[_fonts objectForKey:layer.TextFontname] size:layer.TextFontsize * scale];
                            }
                            else
                            {
                                layerview.font = [UIFont systemFontOfSize:layer.TextFontsize * scale];
                            }
                            
                            //[layerview setFont:[UIFont systemFontOfSize:8.0f]];
                            if (layer.TextDescription.length <= 0 && is_edit) {
                                
                                layerview.adjustsFontSizeToFitWidth = YES;
                                layerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                                layerview.layer.borderWidth = 1.0;
                            }
                            //layerview.backgroundColor = UIColor.blueColor;
                            [layerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            [pageview addSubview:layerview];
                            //[self drawPhotobookText:layerview.text withPage:page withLayer:layer inView:layerview withHScale:scale withVScale:scale];
                            /*
                            float h_scale = working_rect.size.width / page.PageWidth;
                            float v_scale = working_rect.size.height / page.PageHeight;
                            
                            v_scale = h_scale;
                            
                            UIImageView *layerview = [[UIImageView alloc] init];
                            [pageview addSubview:layerview];
                            
                            CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                            [layerview setFrame: layer_rect];
                            //layerview.backgroundColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:30/255.0f]; // 디버깅 용도
                            
                            NSString* text = [NSString stringWithFormat: @"%ld", (long)page.CalendarYear];
                            [self drawPhotobookText:text withPage:page withLayer:layer inView:layerview withHScale:h_scale withVScale:v_scale];
                             */
                        }
                        else {
                            layerview.text = layer.TextDescription;
                           
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO || include_bg == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            layerview.font = [UIFont systemFontOfSize:layer.TextFontsize * scale];
                            //[layerview setFont:[UIFont systemFontOfSize:8.0f]];
                            if (layer.TextDescription.length <= 0 && is_edit) {
                                
                                layerview.adjustsFontSizeToFitWidth = YES;
                                layerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                                layerview.layer.borderWidth = 1.0;
                            }
                            //layerview.backgroundColor = UIColor.blueColor;
                            [layerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            [pageview addSubview:layerview];
                        }
                    }
                }
                else if (layer.AreaType == 1) { // 1:icon
                    UIImageView *layerview = [[UIImageView alloc] init];
                    [pageview addSubview:layerview];
                    
                    layerview.clipsToBounds = YES;
                    
                    // SJYANG : 2018 달력 : 대형벽걸이 - 그린리프에서 4월과 6월이 나뭇잎이 이상하게 나오는 버그 수정
                    //layerview.contentMode = UIViewContentModeScaleAspectFill;
                    if (_product_type == PRODUCT_CALENDAR)
                        layerview.contentMode = UIViewContentModeScaleToFill;
                    else
                        layerview.contentMode = UIViewContentModeScaleAspectFill;
                    
                    layerview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, layer.Filename]];
                    
                    CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                    [layerview setFrame: layer_rect];
                }
                // 신규 달력 포맷 : DAY
                else if (layer.AreaType == 14) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        
                        UIImage* image = [self resizeImage:[UIImage imageNamed:@"transparent.png"] convertToSize:CGSizeMake(layer.W*h_scale, layer.H*v_scale)];
                        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
                        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                        
                        int nWeeks = [self getNumberOfWeeks:page.CalendarYear withMonth:page.CalendarMonth];
                        int firstDayOfWeek = [self getFirstDayOfWeek:page.CalendarYear withMonth:page.CalendarMonth];
                        
                        int offsetX = 0;
                        int offsetY = 0;
                        
                        // 신규 달력 포맷 : row type
                        int rows = 5;
                        int cols = 7;
                        
                        if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                            if (layer.Type == 2) {
                                rows = 2;
                                cols = 16;
                            }
                            else {
                                rows = 1;
                                cols = [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth];
                            }
                        }
                        
                        
                        // 신규 달력 포맷 : 2018.11.22
                        int lastDay = [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth] + 1;
                        float *rowCellPosX = (float *)malloc(sizeof(float) * lastDay);
                        
                        if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                            float totalTextWidth = 0;
                            for (int x = 1; x <= lastDay; x++)
                            {
                                NSString *text = [@(x) stringValue];
                                UIFont *font = nil;
                                float fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale;
                                
                                if(layer.Fontname != nil && layer.Fontname.length > 0 && [_fonts objectForKey:layer.Fontname] != nil)
                                    font = [UIFont fontWithName:[_fonts objectForKey:layer.Fontname] size:fontSize];
                                if(font == nil)
                                    font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
                                NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor whiteColor]};
                                CGSize textSize = [text sizeWithAttributes:attr];
                                
                                if (x <= [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth])
                                    totalTextWidth += textSize.width;
                            }
                            
                            float eachMarginWidth = ((float) (float) layer.W * h_scale - totalTextWidth) / (float) (lastDay - 1);
                            
                            for (int x = 1; x <= lastDay; x++)
                            {
                                NSString *text = [@(x) stringValue];
                                UIFont *font = nil;
                                float fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale;
                                
                                if(layer.Fontname != nil && layer.Fontname.length > 0 && [_fonts objectForKey:layer.Fontname] != nil)
                                    font = [UIFont fontWithName:[_fonts objectForKey:layer.Fontname] size:fontSize];
                                if(font == nil)
                                    font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
                                NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor whiteColor]};
                                CGSize textSize = [text sizeWithAttributes:attr];
                                
                                if (x >= 2)
                                    rowCellPosX[x - 1] = rowCellPosX[x - 2] + textSize.width + eachMarginWidth;
                                else
                                    rowCellPosX[x - 1] = textSize.width + eachMarginWidth;
                            }
                        }
                        
                        
                        float cellWidth = (float) layer.W * h_scale / (float) cols;
                        float cellHeight = (float) layer.H * v_scale / (float) rows;
                        
                        int dayOfMonth = 1;
                        for (int i = 1; i <= rows; i++) {
                            for (int j = 1; j <= cols; j++) {
                                // 신규 달력 포맷 : row type
                                if (rows == 5) {
                                    if (i == 1 && j < firstDayOfWeek)
                                        continue;
                                }
                                if (dayOfMonth > [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth])
                                    continue;
                                
                                NSString *fmtDate = [NSString stringWithFormat: @"%@%02d%02d", [[@(page.CalendarYear) stringValue] substringWithRange:NSMakeRange(2, 2)], page.CalendarMonth, dayOfMonth];
                                
                                float fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale;
                                
                                NSString *text = [@(dayOfMonth) stringValue];
                                if (i == 5 && nWeeks == 6) {
                                    if (dayOfMonth + 7 <= [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth]) {
                                        fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale * 0.75f;
                                        text = [NSString stringWithFormat: @"%ld/%ld", (long)dayOfMonth, (long)(dayOfMonth + 7)];
                                    }
                                }
                                
                                UIColor* fontColor;
                                // 신규 달력 포맷 : row type
                                if ([self getDayOfWeek:page.CalendarYear withMonth:page.CalendarMonth withDay:dayOfMonth] == 1 || (_holidays != nil && [_holidays objectForKey:fmtDate] != nil))
                                    fontColor = [self fromArgbString:layer.Holidaycolor];
                                else
                                    fontColor = [self fromArgbString:layer.Fontcolor];
                                
                                UIFont *font = nil;
                                
                                if(layer.Fontname != nil && layer.Fontname.length > 0 && [_fonts objectForKey:layer.Fontname] != nil)
                                    font = [UIFont fontWithName:[_fonts objectForKey:layer.Fontname] size:fontSize];
                                if(font == nil)
                                    font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
                                NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: fontColor};
                                CGSize textSize = [text sizeWithAttributes:attr];
                                
                                float y = offsetY + cellHeight * (i - 1);
                                CGFloat topPadding = font.ascender - font.capHeight + 1;
                                y += topPadding;
                                
                                float x = 0;
                                // 신규 달력 포맷 : 2018.11.22
                                if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                                    if([layer.Align isEqualToString:@"center"]) {
                                        if (dayOfMonth >= 2)
                                            x = offsetX + rowCellPosX[dayOfMonth - 2] + (rowCellPosX[dayOfMonth - 1] - rowCellPosX[dayOfMonth - 2]) / 2.f - textSize.width / 2.f;
                                        else
                                            x = offsetX + rowCellPosX[dayOfMonth - 1] / 2.f - textSize.width / 2.f;
                                    }
                                    else if([layer.Align isEqualToString:@"right"]) {
                                        x = offsetX + rowCellPosX[dayOfMonth - 1] - textSize.width;
                                    }
                                    else {
                                        if (dayOfMonth >= 2)
                                            x = offsetX + rowCellPosX[dayOfMonth - 2];
                                        else
                                            x = offsetX;
                                    }
                                }
                                else {
                                    if([layer.Align isEqualToString:@"center"]) {
                                        x = offsetX + cellWidth * (j - 1) + (cellWidth - textSize.width) / 2.f;
                                    }
                                    else if([layer.Align isEqualToString:@"right"]) {
                                        x = offsetX + cellWidth * j - textSize.width;
                                    }
                                    else {
                                        x = offsetX + cellWidth * (j - 1);
                                    }
                                }
                                [text drawAtPoint:CGPointMake(x, y) withAttributes:attr];
                                
                                {
                                    NSString *fmtDate2 = @"";
                                    if([text containsString:@"/"])
                                        fmtDate2 = [NSString stringWithFormat: @"%@%02d%02d", [[@(page.CalendarYear) stringValue] substringWithRange:NSMakeRange(2, 2)], page.CalendarMonth, dayOfMonth + 7];
                                    
                                    if (_memorials != nil && (layer.Anniversary != nil && [layer.Anniversary isEqualToString:@"true"])
                                        && ([_memorials objectForKey:fmtDate] != nil ||
                                            (![fmtDate2 isEqualToString:@""] && [_memorials objectForKey:fmtDate2] != nil)
                                            ))
                                    {
                                        float mFontSize = _FONT_SIZE_RATIO * 4 * v_scale;
                                        
                                        NSString *mTxt = @"";
                                        if ([_memorials objectForKey:fmtDate])
                                            mTxt = ((MemorialDay*)[_memorials objectForKey:fmtDate]).title;
                                        else
                                            mTxt = ((MemorialDay*)[_memorials objectForKey:fmtDate2]).title;
                                        
                                        [[self fromArgbString:layer.Fontcolor] set];
                                        
                                        UIFont *mFont = [UIFont systemFontOfSize:mFontSize weight:UIFontWeightUltraLight];
                                        NSDictionary *mAttr = @{ NSFontAttributeName:mFont, NSForegroundColorAttributeName: [self fromArgbString:layer.Fontcolor]};
                                        CGSize mTextSize = [mTxt sizeWithAttributes:mAttr];
                                        
                                        CGFloat mTopPadding = mFont.ascender - mFont.capHeight + 1;
                                        
                                        //float my = offsetY + cellHeight * (i - 1) + textSize.height + mTopPadding + 0.3f * v_scale;
                                        float my = offsetY + cellHeight * (i - 1) + (font.ascender - font.descender) + mTopPadding + 0.1f * v_scale;
                                        
                                        // 신규 달력 포맷 : 2018.11.22
                                        float mx = 0;
                                        if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                                            if([layer.Align isEqualToString:@"center"]) {
                                                if (dayOfMonth >= 2)
                                                    mx = offsetX + rowCellPosX[dayOfMonth - 2] + (rowCellPosX[dayOfMonth - 1] - rowCellPosX[dayOfMonth - 2]) / 2.f - mTextSize.width / 2.f;
                                                else
                                                    mx = offsetX + rowCellPosX[dayOfMonth - 1] / 2.f - textSize.width / 2.f;
                                            }
                                            else if([layer.Align isEqualToString:@"right"]) {
                                                mx = offsetX + rowCellPosX[dayOfMonth - 1] - mTextSize.width;
                                            }
                                            else {
                                                mx = x;
                                            }
                                        }
                                        else {
                                            if([layer.Align isEqualToString:@"center"]) {
                                                mx = offsetX + cellWidth * (j - 1) + (cellWidth - mTextSize.width) / 2.f;
                                            }
                                            else if([layer.Align isEqualToString:@"right"]) {
                                                mx = offsetX + cellWidth * j - mTextSize.width;
                                            }
                                            else {
                                                mx = x;
                                            }
                                        }
                                        [mTxt drawAtPoint:CGPointMake(mx, my) withAttributes:mAttr];
                                    }
                                }
                                
                                dayOfMonth++;
                            }
                        }
                        
                        free(rowCellPosX);
                        
                        image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        layerview.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
                        layerview.contentMode = UIViewContentModeScaleAspectFill;
                        layerview.image = image;
                    }
                }
                // 신규 달력 포맷 : YEAR
                else if (layer.AreaType == 11) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        v_scale = h_scale;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        //layerview.backgroundColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:30/255.0f]; // 디버깅 용도
                        
                        NSString* text = [NSString stringWithFormat: @"%ld", (long)page.CalendarYear];
                        [self drawCalendarText:text withPage:page withLayer:layer inView:layerview withHScale:h_scale withVScale:v_scale];
                    }
                }
                // 신규 달력 포맷 : MONTH_ENG
                else if (layer.AreaType == 12) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        v_scale = h_scale;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        NSString *month1[] = {@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC"};
                        NSString *month2[] = {@"jan", @"feb", @"mar", @"apr", @"may", @"jun", @"jul", @"aug", @"sep", @"oct", @"nov", @"dec"};
                        NSString *month3[] = {@"JANUARY", @"FEBRUARY", @"MARCH", @"APRIL", @"MAY", @"JUNE", @"JULY", @"AUGUST", @"SEPTEMBER", @"OCTOBER", @"NOVEMBER", @"DECEMBER"};
                        NSString *month4[] = {@"january", @"february", @"march", @"april", @"may", @"june", @"july", @"august", @"september", @"october", @"november", @"december"};
                        NSString *month5[] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};
                        
                        NSString* text = @"";
                        if (layer.Calid != nil && layer.Calid.length > 0)
                        {
                            if([layer.Calid isEqualToString:@"em1"])
                                text = month1[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em2"])
                                text = month2[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em3"])
                                text = month3[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em4"])
                                text = month4[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em5"])
                                text = month5[page.CalendarMonth - 1];
                        }
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        
                        [self drawCalendarText:text withPage:page withLayer:layer inView:layerview withHScale:h_scale withVScale:v_scale];
                    }
                }
                // 신규 달력 포맷 : MONTH_NUM
                else if (layer.AreaType == 13) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        v_scale = h_scale;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        
                        NSString* text = [NSString stringWithFormat: @"%02d", (int)page.CalendarMonth];
                        [self drawCalendarText:text withPage:page withLayer:layer inView:layerview withHScale:h_scale withVScale:v_scale];
                    }
                }
                else if (layer.AreaType == 3) {
                    // 마그넷 : guideinfo : 아무것도 처리하지 않음
                }
                else {
                    // 폰케이스
                    if (_product_type == PRODUCT_PHONECASE) {
                        UIImage *working_image;
                        PhotoLayerView *layerview;
                        {
                            layerview = [[PhotoLayerView alloc] init];
                            CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                            
                            layerview.clipsToBounds = TRUE;
                            [layerview setFrame: layer_rect];
                            if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] ) errorExists = TRUE;
                        }
                        UIImage* edit_image;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(layerview.frame.size.width, layerview.frame.size.height));
                            [layerview.layer renderInContext:UIGraphicsGetCurrentContext()];
                            edit_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        layerview.hidden = YES;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                            [edit_image drawInRect:layer_rect];
                            
                            working_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            [working_image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            [pageview.image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            NSString *urlstr = @"";
                            if([[Common info].photobook.Size isEqualToString:@"iPhone 6"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_I6.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"iPhone 6+"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_I6plus.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY S5"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_s5.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY S6"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_s6.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"iPhone_6"])
                                urlstr = [NSString stringWithFormat:@"%@iPhone_6_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"iPhone_6plus"])
                                urlstr = [NSString stringWithFormat:@"%@iPhone_6plus_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY_S5"])
                                urlstr = [NSString stringWithFormat:@"%@GALAXY_S5_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY_S6"])
                                urlstr = [NSString stringWithFormat:@"%@GALAXY_S6_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else {
                                // check error
                            }
                            
                            NSURL *url = [NSURL URLWithString:urlstr];
                            NSData *data = [NSData dataWithContentsOfURL:url];
                            UIImage *phonetemplate = [UIImage imageWithData:data];
                            [phonetemplate drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            pageview.image = maskedImage;
                        }
                    }
                    else if (_product_type == PRODUCT_CARD) {
                        UIImage *working_image;
                        PhotoLayerView *layerview;
                        {
                            layerview = [[PhotoLayerView alloc] init];
                            CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                            
                            layerview.clipsToBounds = TRUE;
                            [layerview setFrame: layer_rect];
                            if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] ) errorExists = TRUE;
                            
                            if (layer.is_lowres && is_edit) {
                                UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                                [layerview addSubview:waring_view];
                                
                                CGRect waring_rect = CGRectZero;
                                waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                                waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                                waring_rect.size.width = 30;
                                waring_rect.size.height = 30;
                                
                                waring_view.image = _warning_image;
                                waring_view.clipsToBounds = TRUE;
                                waring_view.alpha = 0.8f;
                                [waring_view setFrame: waring_rect];
                            }
                        }
                        UIImage* edit_image;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(layerview.frame.size.width, layerview.frame.size.height));
                            [layerview.layer renderInContext:UIGraphicsGetCurrentContext()];
                            
                            edit_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        layerview.hidden = YES;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                            [edit_image drawInRect:layer_rect];
                            
                            working_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            [working_image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            [pageview.image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            pageview.image = maskedImage;
                        }
                    }
                    // 마그넷
                    else if (_product_type == PRODUCT_MAGNET) {
                        UIImage *working_image;
                        
                        PhotoLayerView *layerview;
                        {
                            layerview = [[PhotoLayerView alloc] init];
                            [pageview addSubview:layerview]; // 추가
                            
                            CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                            
                            layerview.clipsToBounds = TRUE;
                            [layerview setFrame: layer_rect];
                            if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] ) errorExists = TRUE;
                            
                            if (layer.is_lowres && is_edit) {
                                UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                                [layerview addSubview:waring_view];
                                
                                CGRect waring_rect = CGRectZero;
                                waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                                waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                                waring_rect.size.width = 30;
                                waring_rect.size.height = 30;
                                
                                waring_view.image = _warning_image;
                                waring_view.clipsToBounds = TRUE;
                                waring_view.alpha = 0.8f;
                                [waring_view setFrame: waring_rect];
                            }
                        }
                        UIImage* edit_image;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(layerview.frame.size.width, layerview.frame.size.height));
                            [layerview.layer renderInContext:UIGraphicsGetCurrentContext()];
                            
                            edit_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        
                        layerview.hidden = YES;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                            [edit_image drawInRect:layer_rect];
                            
                            working_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        // 마그넷 : 마스킹 S ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            [working_image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            [pageview.image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            if (layer.ImageEditname.length == 0) {
                                if (is_edit) {
                                    {
                                        CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                                        CGContextRef context = UIGraphicsGetCurrentContext();
                                        CGContextSetRGBStrokeColor(context, 189.0f/255.0f, 189.0f/255.0f, 189.0f/255.0f, 0.5f);
                                        CGContextStrokeRect(context, layer_rect);
                                    }
                                }
                            }
                            
                            UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            pageview.image = maskedImage;
                        }
                        
                        // 마그넷 : 하트 상품일 경우의 별도 마스킹 처리
                        if ([_ProductCode hasPrefix:@"404"]) {
                            UIImage *frameInfoImage = nil;
                            if(page.PageFile != nil && page.PageFile.length > 0) {
                                NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", _base_folder];
                                
                                NSString *frameInfoFile = page.PageFile;
                                
                                if(frameInfoFile.length > 0) {
                                    NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, frameInfoFile];
                                    frameInfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                    frameInfoImage = [self maskImage:frameInfoImage];
                                }
                            }
                            
                            if(frameInfoImage != nil)
                            {
                                CALayer *mask = [CALayer layer];
                                mask.contents = (id)[frameInfoImage CGImage];
                                mask.frame = CGRectMake(0, 0, pageview.frame.size.width, pageview.frame.size.height);
                                pageview.layer.mask = mask;
                                pageview.layer.masksToBounds = YES;
                            }
                        }
                        else {
                            // TODO : 마그넷 : guideinfo : 하트 상품이 아닌 경우에만 guideinfo 를 처리하는 것이 맞는지 체크 필요
                            // 마그넷 : guideinfo 처리
                            if (guideinfo != nil) {
                                NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", _base_folder];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, guideinfo.SkinFilename];
                                UIImage *guideinfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                if(guideinfoImage != nil) {
                                    guideinfoImage = [self maskImage:guideinfoImage];
                                    
                                    CALayer *mask = [CALayer layer];
                                    mask.contents = (id)[guideinfoImage CGImage];
                                    mask.frame = CGRectMake(0, 0, pageview.frame.size.width, pageview.frame.size.height);
                                    pageview.layer.mask = mask;
                                    pageview.layer.masksToBounds = YES;
                                }
                            }
                        }
                        // 마그넷 : 마스킹 E ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    }
                    else {
                        PhotoLayerView *layerview = [[PhotoLayerView alloc] init]; // @@@
                        
                        if (_product_type == PRODUCT_SINGLECARD || _product_type == PRODUCT_DIVISIONSTICKER){
                            
                            [parentview addSubview:layerview];
                            pageview.backgroundColor = [UIColor clearColor];
                            [parentview addSubview:pageview];
                            
                        }else{
                            [pageview addSubview:layerview];
                            if (_product_type == PRODUCT_TRANSPARENTCARD) {
                                layerview.alpha = 0.7;
                            }
                        }
                        /*UILabel *testlabel = [[UILabel alloc]init];
                        [testlabel setText:@"test"];
                        [testlabel setFrame:CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                        [pageview addSubview:testlabel];*/
                        
                        
                        CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                        
                        
                        
                        if (_product_type == PRODUCT_POSTER || _product_type == PRODUCT_TRANSPARENTCARD) {
                            layer_rect = CGRectMake((layer.MaskX + 5)*scale,
                                                    (layer.MaskY + 5)*scale,
                                                    (layer.MaskW - 10)*scale,
                                                    (layer.MaskH - 10)*scale);
                        }
                        layerview.clipsToBounds = TRUE;
                        layerview.tintColor = UIColor.redColor;
                        
                        // 가로모드 디버깅중
                        
                        
                        //MaskR Rotation
                        if(layer.MaskR != 0){
                            //[layerview setCenter:CGPointMake(layerview.frame.size.width/2,  layerview.frame.size.height/2)];
                            //[layerview setFrame: layer_rect];
                            
                            layerview.layer.anchorPoint = CGPointMake(0,0);
                            [layerview setFrame: layer_rect];
                            [layerview setTransform:CGAffineTransformMakeRotation(layer.MaskR * M_PI / 180)];
                            //[layerview setFrame: layer_rect];
                            
                            /*CGPoint convertedCenter = [layerview convertPoint:parentview.center fromView:parentview ];

                                 CGSize offset = CGSizeMake(layerview.center.x - convertedCenter.x, layerview.center.y - convertedCenter.y);
                             
                                 CGFloat rotation = (layer.MaskR * M_PI / 180); //get your angle (radians)

                                 CGAffineTransform tr = CGAffineTransformMakeTranslation(-offset.width, -offset.height);
                                      tr = CGAffineTransformConcat(tr, CGAffineTransformMakeRotation(rotation) );
                                      tr = CGAffineTransformConcat(tr, CGAffineTransformMakeTranslation(offset.width, offset.height) );


                                [layerview setTransform:tr];*/
                            
                            
                        }else{
                            [layerview setFrame: layer_rect];
                        }
                        
                        /*
                         if (_product_type == PRODUCT_DESIGNPHOTO) {
                         //[layerview setFrame: CGRectMake(layerview.frame.origin.x + pageview.frame.origin.x, layerview.frame.origin.y + pageview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height)];
                         [layerview setFrame: CGRectMake(layerview.frame.origin.x + pageview.frame.origin.x, layerview.frame.origin.y + pageview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height)];
                         }
                         */
                        
                        
                        if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] )
                        {
                            // 2017.11.16 : SJYANG
                            errorExists = TRUE;
                            //[pageview removeFromSuperview];
                            
                            UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                            [layerview addSubview:waring_view];
                            
                            CGRect waring_rect = CGRectZero;
                            waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                            waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                            waring_rect.size.width = 30;
                            waring_rect.size.height = 30;
                            
                            waring_view.image = _warning_image;
                            waring_view.clipsToBounds = TRUE;
                            waring_view.alpha = 0.8f;
                            [waring_view setFrame: waring_rect];
                        }
                        else {
                            if (layer.is_lowres && is_edit) {
                                //errorExists = TRUE; // 2017.11.16 : SJYANG
                                
                                UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                                [layerview addSubview:waring_view];
                                
                                CGRect waring_rect = CGRectZero;
                                waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                                waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                                waring_rect.size.width = 30;
                                waring_rect.size.height = 30;
                                
                                waring_view.image = _warning_image;
                                waring_view.clipsToBounds = TRUE;
                                waring_view.alpha = 0.8f;
                                [waring_view setFrame: waring_rect];
                            }
                        }
                        
                        // 신규 달력 포맷 : 마스킹
                        if (_product_type == PRODUCT_CALENDAR) {
                            if (layer.ImageEditname == nil || layer.ImageEditname.length == 0) {
                                if(layer.Frameinfo != nil && layer.Frameinfo.length > 0) {
                                    NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", _base_folder];
                                    
                                    NSString *frameInfoFile = @"";
                                    NSString *cutFrameInfoFile = @"";
                                    
                                    NSArray *tarr = [layer.Frameinfo componentsSeparatedByString:@"^"];
                                    frameInfoFile = [tarr objectAtIndex:0];
                                    if([tarr count] > 1)
                                        cutFrameInfoFile = [tarr objectAtIndex:1];
                                    
                                    if(frameInfoFile.length > 0) {
                                        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, frameInfoFile];
                                        UIImage *frameInfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                        
                                        if([self isOuterAlphaImage:frameInfoImage])
                                            frameInfoImage = [self transactFrameInfoBitmap:frameInfoImage];
                                        
                                        UIImageView *view = [[UIImageView alloc] init];
                                        [layerview addSubview:view];
                                        
                                        CGRect rect = CGRectMake(0, 0, layer_rect.size.width, layer_rect.size.height);
                                        [view setFrame:rect];
                                        
                                        // FIX : 2019.03.07 : 신규 달력 포맷 : 마스킹 : 대형벽걸이 > 그린리프 마스킹 오류 수정
                                        //view.contentMode = UIViewContentModeScaleAspectFill;
                                        view.contentMode = UIViewContentModeScaleToFill;
                                        view.image = frameInfoImage;
                                    }
                                    if(cutFrameInfoFile.length > 0) {
                                        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, cutFrameInfoFile];
                                        UIImage *cutFrameInfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                        
                                        UIImageView *view = [[UIImageView alloc] init];
                                        [layerview addSubview:view];
                                        
                                        CGRect rect = CGRectMake(0, 0, layer_rect.size.width, layer_rect.size.height);
                                        [view setFrame:rect];
                                        
                                        // FIX : 2019.03.07 : 신규 달력 포맷 : 마스킹 : 대형벽걸이 > 그린리프 마스킹 오류 수정
                                        //view.contentMode = UIViewContentModeScaleAspectFill;
                                        view.contentMode = UIViewContentModeScaleToFill;
                                        view.image = cutFrameInfoImage;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 폰케이스의 경우, 미리 화면 캡쳐를 해 둔다.
            if (_product_type == PRODUCT_PHONECASE) {
                UIGraphicsBeginImageContextWithOptions(pageview.bounds.size, pageview.opaque, 0.0);
                [pageview.layer renderInContext:UIGraphicsGetCurrentContext()];
                _thumb_captured_image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            if (include_bg) {
                if (_product_type == PRODUCT_PHOTOBOOK) {
                    UIImageView *centerview = [[UIImageView alloc] init]; // @@@
                    centerview.contentMode = UIViewContentModeScaleToFill;
                    [pageview addSubview:centerview];
                    
                    if (index == 0) {
                        centerview.image = _cover_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (26*scale)/2), 0, 26*scale, working_rect.size.height)];
                        centerview.alpha = 0.2;
                        
                        UIImageView *cover_mark_view = [[UIImageView alloc] init]; // @@@
                        cover_mark_view.image = _cover_banner_image;
                        [pageview addSubview:cover_mark_view];
                        [cover_mark_view setFrame:CGRectMake(0, 0, 70, 70)];
                    }
                    else if (index == 1 && !([_ProductCode isEqualToString:@"300269"] || [_ProductCode isEqualToString:@"300270"] || [_ProductCode isEqualToString:@"120069"])) { // SJYANG : 카달로그 추가
                        centerview.image = _inner_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (182*scale)/2), 0, 182*scale, working_rect.size.height)];
                        
                        UIImageView *cover_mark_view = [[UIImageView alloc] init]; // @@@
                        cover_mark_view.image = _blank_banner_image;
                        [pageview addSubview:cover_mark_view];
                        [cover_mark_view setFrame:CGRectMake(0, 0, 70, 70)];
                    }
                    // SJYANG
                    // 프리미엄북 : 에필로그 페이지에 역(reverse) blank 이미지 삽입
                    else if (index == _pages.count - 1 && [_ThemeName isEqualToString:@"premium"]) {
                        centerview.image = _inner_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (182*scale)/2), 0, 182*scale, working_rect.size.height)];
                        
                        UIImageView *cover_mark_view = [[UIImageView alloc] init]; // @@@
                        cover_mark_view.image = _blank_rvs_banner_image;
                        [pageview addSubview:cover_mark_view];
                        [cover_mark_view setFrame:CGRectMake(working_rect.size.width - 70, 0, 70, 70)];
                    }
                    else {
                        centerview.image = _inner_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (182*scale)/2), 0, 182*scale, working_rect.size.height)];
                    }
                }
                else if (_product_type == PRODUCT_CALENDAR) {
                    
                    // SJYANG : 2018 달력
                    // 포스터 달력 관련 코드 추가
                    if (!([intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"] || [intnum isEqualToString:@"393"])) { // 369 => 우드스탠드, 391 => 시트달력
                        if ([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"392"]) { // 367 => 소형벽걸이달력, 392 => 대형벽걸이달력
                            UIView *ringview = [[UIView alloc] init]; // @@@
                            [parentview addSubview:ringview];
                            
                            CGRect ring_rect = working_rect;
                            ring_rect.origin.y -= 7;
                            ring_rect.size.height = 21;
                            
                            // SJYANG : 2018 달력
                            /*
                             if(_ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                             ring_rect.origin.x += 21;
                             ring_rect.size.width -= 21 * 2;
                             }
                             */
                            
                            UIGraphicsBeginImageContext(CGSizeMake(ring_rect.size.width, ring_rect.size.height));
                            
                            UIImage *tringimg = [UIImage imageNamed:@"calendar_page_ring.png"];
                            CGFloat tringscale = tringimg.size.height / ring_rect.size.height;
                            UIImage *ringimg = [UIImage imageWithCGImage:[tringimg CGImage] scale:(tringimg.scale * tringscale) orientation:(tringimg.imageOrientation)];
                            
                            UIImage *tcircleimg = [UIImage imageNamed:@"calendar_bg_circle.png"];
                            CGFloat tcirclescale = tcircleimg.size.height / ring_rect.size.height / 1.6f;
                            UIImage *circleimg = [UIImage imageWithCGImage:[tcircleimg CGImage] scale:(tcircleimg.scale * tcirclescale) orientation:(tcircleimg.imageOrientation)];
                            
                            CGFloat circle_x1 = ring_rect.size.width / 2.f - circleimg.size.width / 2.f;
                            CGFloat circle_x2 = ring_rect.size.width / 2.f + circleimg.size.width / 2.f;
                            
                            CGFloat x;
                            x = circle_x2 + ringimg.size.width * 0.5f;
                            for(int i=0;;i++) {
                                if(x + ringimg.size.width * i + ringimg.size.width >= ring_rect.size.width) break;
                                BOOL bok = NO;
                                if (ringimg.size.width * i > circle_x2) bok = YES;
                                if (ringimg.size.width * (i + 1) < circle_x1) bok = YES;
                                if(bok == YES)
                                    [ringimg drawInRect:CGRectMake(x + ringimg.size.width * i, 0, ringimg.size.width, ringimg.size.height)];
                            }
                            x = circle_x1 - ringimg.size.width - ringimg.size.width * 0.5f;
                            for(int i=0;;i++) {
                                if(x - ringimg.size.width * i <= 0) break;
                                BOOL bok = NO;
                                if (ringimg.size.width * i > circle_x2) bok = YES;
                                if (ringimg.size.width * (i + 1) < circle_x1) bok = YES;
                                if(bok == YES)
                                    [ringimg drawInRect:CGRectMake(x - ringimg.size.width * i, 0, ringimg.size.width, ringimg.size.height)];
                            }
                            [circleimg drawInRect:CGRectMake(circle_x1, -circleimg.size.height * 0.36f, circleimg.size.width, circleimg.size.height)];
                            
                            UIImage *resultimg = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            [ringview setFrame:ring_rect];
                            [ringview setBackgroundColor: [UIColor colorWithPatternImage:resultimg]];
                        }
                        else {
                            UIView *ringview = [[UIView alloc] init]; // @@@
                            [parentview addSubview:ringview];
                            
                            CGRect ring_rect = working_rect;
                            ring_rect.origin.y -= 7;
                            ring_rect.size.height = 21;
                            
                            // SJYANG : 2018 달력
                            /*
                             if(_ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                             ring_rect.origin.x += 21;
                             ring_rect.size.width -= 21 * 2;
                             }
                             */
                            
                            [ringview setFrame:ring_rect];
                            [ringview setBackgroundColor: [UIColor colorWithPatternImage:_page_pattern_calendar]];
                        }
                    }
                }
                else if (_product_type == PRODUCT_POLAROID) {
                    // 폴라로이드는 할거 없음.
                }
                // PTODO : 진짜 할 것이 없는지 체크 필요
                else if (_product_type == PRODUCT_DESIGNPHOTO) {
                    // 폴라로이드는 할거 없음.
                }
                else if (_product_type == PRODUCT_SINGLECARD) {
                    // 폴라로이드는 할거 없음.
                }
                else if (_product_type == PRODUCT_CARD) {
                    // 포토카드는 할거 없음.
                }
                else if (_product_type == PRODUCT_MUG) {
                    // 머그도 할거 없음.
                }
                else if (_product_type == PRODUCT_PHONECASE) {
                    // 폰케이스도 할거 없음.
                }
                else if (_product_type == PRODUCT_POSTCARD) {
                    // 할거 없나?
                }
                else if (_product_type == PRODUCT_MAGNET) {
                    // 할거 없나?
                }
                else if (_product_type == PRODUCT_BABY) {
                    // 베이비도 할거 없음.
                } else if (_product_type == PRODUCT_POSTER) {
                    
                }
                else if (_product_type == PRODUCT_TRANSPARENTCARD) {
                    
                }
                else if (_product_type == PRODUCT_DIVISIONSTICKER) {
                    //할거없음?
                }
                else if (_product_type == PRODUCT_MONTHLYBABY) {
                    // 월간 포토몬도 할거 없음.
                }
                else {
                    NSAssert(NO, @"producttype is wrong..");
                }
            }
            
            
            // 디버그
            if (_product_type == PRODUCT_DESIGNPHOTO) {
                if (page.PageFile.length > 0) {
                    
                    UIImage* maskImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                    UIImageView *maskview = [[UIImageView alloc] init]; // @@@
                    maskview.image = maskImage;
                    [pageview addSubview:maskview];
                    
                    // 가로모드 디버깅중
                    //[maskview setFrame:pageview.frame];
                    [maskview setFrame:CGRectMake(0, 0, pageview.frame.size.width, pageview.frame.size.height)]; // 디버깅중
                    maskview.contentMode = UIViewContentModeScaleAspectFill;
                    maskview.clipsToBounds = YES;
                }
            }
            
            _scale_factor = scale;
        }
    }else{
        if (index < _pages.count){
            Page *page = _pages[index];
            
            // SJYANG : 2018 달력
            if(_product_type == PRODUCT_CALENDAR && _ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                UIImageView *testview = [[UIImageView alloc] init]; // @@@
                [parentview addSubview:testview];
                [testview setFrame:working_rect];
                testview.backgroundColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f];
            }
            
            UIImageView *pageview = [[UIImageView alloc] init]; // @@@
            pageview.tag = 5001;
            [parentview addSubview:pageview];
            
            [pageview setFrame:working_rect];
            
            pageview.image = nil;
            pageview.backgroundColor = [UIColor colorWithRed:page.PageColorR/255.0f green:page.PageColorG/255.0f blue:page.PageColorB/255.0f alpha:page.PageColorA];
            
            // SJYANG : 2018 달력
            if(_product_type == PRODUCT_CALENDAR && _ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                if([intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"]) { // 369 => 우드스탠드, 391 => 시트달력
                    pageview.layer.cornerRadius = 20;
                    pageview.layer.borderWidth = 1;
                    pageview.layer.borderColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f alpha:1.0f].CGColor;
                }
                else {
                    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:pageview.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(20.0, 20.0)];
                    
                    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                    maskLayer.frame = pageview.bounds;
                    maskLayer.path  = maskPath.CGPath;
                    
                    pageview.layer.mask = maskLayer;
                }
            }
            
            if (page.PageFile.length > 0) {
                pageview.contentMode = UIViewContentModeScaleAspectFill;
                pageview.clipsToBounds = YES;
                pageview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
            }
            
            CGFloat scale = 1.0f;
            scale = working_rect.size.width/page.PageWidth;
            _edit_scale = scale;
            
            NSLog(@"working_rect.size.width : %f", working_rect.size.width);
            NSLog(@"page.PageWidth : %d", page.PageWidth);
            NSLog(@"page.PageHeight : %d", page.PageHeight);
            NSLog(@"_edit_scale : %f", _edit_scale);
            
            // 마그넷 : guideinfo
            Layer *guideinfo = nil;
            if(_product_type == PRODUCT_MAGNET) {
                for (Layer *layer in page.layers) {
                    if (layer.AreaType == 3)
                        guideinfo = layer;
                }
            }
            
            for (Layer *layer in page.layers) {
                
                if (layer.AreaType == 2) { // 2:text
                    UILabel *layerview = [[UILabel alloc] init]; // @@@
                    
                    layerview.textAlignment = NSTextAlignmentCenter;
                    if ([layer.Halign isEqualToString:@"left"]) {
                        layerview.textAlignment = NSTextAlignmentLeft;
                    }
                    else if ([layer.Halign isEqualToString:@"right"]) {
                        layerview.textAlignment = NSTextAlignmentRight;
                    }
                    
                    layerview.textColor = layer.text_color;
                    
                    if ([layer.Gid isEqualToString:@"spine"]) {
                        layerview.text = layer.TextDescription;
                        layerview.adjustsFontSizeToFitWidth = YES;
                        [layerview setFont:[UIFont systemFontOfSize:8.0f]];
                        
                        if (layerview.text.length <= 0) {
                            layerview.text = @"제목을 입력해 주세요";
                        }
                        
                        CGFloat margin = 10.f;
                        [layerview setFrame:CGRectMake(margin, 0, working_rect.size.height-margin*2, 26*scale)];
                        [layerview setCenter:CGPointMake(working_rect.size.width/2, margin + working_rect.size.height/2)];
                        [layerview setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                        [pageview addSubview:layerview];
                    }
                    else {
                        if (_product_type == PRODUCT_PHONECASE) {
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            float fontsize = layer.TextFontsize;
                            fontsize = fontsize * 0.575f * 1.087f;
                            
                            CGSize labelSize = [layerview.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontsize]}];
                            float tx, ty, tw, th;
                            tw = labelSize.width;
                            th = labelSize.height;
                            if( layer.MaskW*scale > tw )
                                tx = layer.MaskX*scale + (layer.MaskW*scale - tw) / 2.f;
                            else
                                tx = layer.MaskX*scale - (tw - layer.MaskW*scale) / 2.f;
                            if( layer.MaskH*scale > th )
                                ty = layer.MaskY*scale + (layer.MaskH*scale - th) / 2.f;
                            else
                                ty = layer.MaskY*scale - (th - layer.MaskH*scale) / 2.f;
                            
                            layerview.adjustsFontSizeToFitWidth = YES;
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            [layerview setFrame: CGRectMake(tx, ty, tw, th)];
                            [pageview addSubview:layerview];
                        }
                        else if (_product_type == PRODUCT_CARD) {
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            
                            layerview.adjustsFontSizeToFitWidth = YES;
                            float fontsize = layer.TextFontsize;
                            
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            fontsize = layer.TextFontsize * 1.00f;
                            NSString *fs_filepath = [NSString stringWithFormat:@"%@/edit/fs.%@.%ld", _base_folder, _ProductId, (long)index];
                            BOOL isDir = YES;
                            if(include_bg == YES) {
                                [[NSString stringWithFormat:@"%f", scale] writeToFile:fs_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                            else {
                                if( [[NSFileManager defaultManager] fileExistsAtPath:fs_filepath isDirectory:&isDir]==YES ) {
                                    NSString* tstr = [NSString stringWithContentsOfFile:fs_filepath encoding:NSUTF8StringEncoding error:nil];
                                    CGFloat tscale = [tstr floatValue];
                                    fontsize = layer.TextFontsize * 1.00f * (scale / tscale);
                                }
                            }
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            layerview.layer.borderWidth = 1.0;
                            
                            [layerview setFrame: CGRectMake(0, 0, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            playerview.layer.borderWidth = 1.0;
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        }
                        else if (_product_type == PRODUCT_POLAROID) {
                            layerview.textColor = layer.text_color;
                            
                            /*
                             NSString *tc_filepath = [NSString stringWithFormat:@"%@/edit/tc.%@.%ld.%d%d%d%d%d", _base_folder, _BasketName, index, layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH, layer.MaskR];
                             NSString *textcontents = [NSString stringWithContentsOfFile:tc_filepath encoding:NSUTF8StringEncoding error:nil];
                             layer.TextDescription = textcontents;
                             */
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO || include_bg == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"내용입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            layerview.adjustsFontSizeToFitWidth = NO;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            float fontsize = layer.TextFontsize;
                            //fontsize = fontsize * 0.436f; // iPhone 5s
                            fontsize = fontsize * 1.65f * scale; // iPhone 6s
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            layerview.layer.borderWidth = 1.0;
                            
                            //[layerview setFrame: CGRectMake(layer.MaskW * scale * 0.005f, layer.MaskH * scale * 0.015f, layer.MaskW*scale, layer.MaskH*scale)];
                            [layerview setFrame: CGRectMake(layer.MaskW * scale * 0.005f, layer.MaskH * scale * 0.085f, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            layerview.numberOfLines = 0;
                            layerview.adjustsFontSizeToFitWidth = NO;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            if(include_bg == NO)
                                playerview.layer.borderWidth = 0.0;
                            else
                                playerview.layer.borderWidth = 1.0;
                            
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            [self setPolaroidUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        } else if (_product_type == PRODUCT_SINGLECARD) {
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            // ... 올 수 있도록 수정
                            layerview.minimumScaleFactor = 1.0 ;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            
                            layerview.adjustsFontSizeToFitWidth = YES;
                            float fontsize = layer.TextFontsize;
                            
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            fontsize = layer.TextFontsize * 1.00f;
                            NSString *fs_filepath = [NSString stringWithFormat:@"%@/edit/fs.%@.%ld", _base_folder, _ProductId, (long)index];
                            BOOL isDir = YES;
                            if(include_bg == YES) {
                                [[NSString stringWithFormat:@"%f", scale] writeToFile:fs_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                            }
                            else {
                                if( [[NSFileManager defaultManager] fileExistsAtPath:fs_filepath isDirectory:&isDir]==YES ) {
                                    NSString* tstr = [NSString stringWithContentsOfFile:fs_filepath encoding:NSUTF8StringEncoding error:nil];
                                    CGFloat tscale = [tstr floatValue];
                                    fontsize = layer.TextFontsize * 1.00f * (scale / tscale);
                                }
                            }
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            layerview.layer.borderWidth = 1.0;
                            
                            [layerview setFrame: CGRectMake(0, 0, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            playerview.layer.borderWidth = 1.0;
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        } else if (_product_type == PRODUCT_MAGNET) { // 마그넷 : 텍스트 영역 추가
                            layerview.text = layer.TextDescription;
                            layerview.textColor = layer.text_color;
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            
                            layerview.numberOfLines = 0;
                            // ... 올 수 있도록 수정
                            layerview.minimumScaleFactor = 1.0 ;
                            layerview.lineBreakMode = NSLineBreakByWordWrapping;
                            
                            
                            // 마그넷 : 작업중
                            //layerview.adjustsFontSizeToFitWidth = YES;
                            layerview.adjustsFontSizeToFitWidth = YES;
                            float fontsize = layer.TextFontsize;
                            
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            // 2019.03.08
                            //fontsize = layer.TextFontsize * 1.00f;
                            fontsize = layer.TextFontsize * 1.5f * 0.8f * _edit_scale;
                            
                            // TODO : 마그넷 : ProductId 를 파일명에서 뺐는데, 그래도 되는 것인지 체크 필요
                            NSString *fs_filepath = [NSString stringWithFormat:@"%@/edit/fs.%ld", _base_folder, (long)index];
                            //NSLog(@"tscale : path : %@", fs_filepath);
                            
                            // 2019.03.08 : 주석 처리
                            /*
                             BOOL isDir = YES;
                             if(include_bg == YES) {
                             [[NSString stringWithFormat:@"%f", scale] writeToFile:fs_filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                             }
                             else {
                             //NSLog(@"FIND tscale");
                             if( [[NSFileManager defaultManager] fileExistsAtPath:fs_filepath isDirectory:&isDir]==YES ) {
                             NSString* tstr = [NSString stringWithContentsOfFile:fs_filepath encoding:NSUTF8StringEncoding error:nil];
                             CGFloat tscale = [tstr floatValue];
                             
                             // 2019.03.07
                             //fontsize = layer.TextFontsize * 1.00f * (scale / tscale);
                             fontsize = layer.TextFontsize * 1.5f * (scale / tscale);
                             }
                             }
                             */
                            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                            
                            [layerview setFont:[UIFont systemFontOfSize:fontsize]];
                            layerview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
                            // 마그넷 : 작업중
                            if(_useTitleHint == YES || true)
                                layerview.layer.borderWidth = 1.0;
                            else
                                layerview.layer.borderWidth = 0.0;
                            
                            [layerview setFrame: CGRectMake(0, 0, layer.MaskW*scale, layer.MaskH*scale)];
                            
                            UIView *playerview = [[UIView alloc] init]; // @@@
                            playerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                            // 마그넷 : 작업중
                            if(_useTitleHint == YES || true)
                                playerview.layer.borderWidth = 1.0;
                            else
                                playerview.layer.borderWidth = 0.0;
                            [playerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [playerview addSubview:layerview];
                            
                            // 마그넷 : 작업중
                            NSLog(@"DEBUG :: layer.MaskH*scale : %f", layer.MaskH*scale);
                            NSLog(@"DEBUG :: fontsize : %f", fontsize);
                            
                            int valign = 0; // 기본 : 상하 top 정렬
                            /*
                             if ([_ProductCode isEqualToString:@"400005"]) valign = 1; // 정사각 > 리얼후르츠 : 상하 center 정렬
                             if ([_ProductCode isEqualToString:@"401002"]) valign = 1; // 직사각 > 심플컬러 : 상하 center 정렬??
                             if ([_ProductCode isEqualToString:@"401005"]) valign = 1; // 직사각 > 리얼후르츠 : 상하 center 정렬
                             if ([intnum isEqualToString:@"402"]) valign = 1; // 레트로 : 상하 bottom 정렬 => 상하 center 정렬 : 2019.03.07
                             // 2019.03.06
                             if ([intnum isEqualToString:@"403"]) valign = 1; // 포토부스 : 상하 center 정렬
                             */
                            
                            //[self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            if ((int)((layer.MaskH*scale) / fontsize) <= 1)
                                [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:valign];
                            else
                                [self setUILabel:layerview withMaxFrame:layerview.frame withText:layerview.text usingVerticalAlign:0];
                            [pageview addSubview:playerview];
                        }
                        else {
                            layerview.text = layer.TextDescription;
                            
                            if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                                if(_useTitleHint == NO || include_bg == NO)
                                    layerview.text = @"";
                                else
                                    layerview.text = @"텍스트 입력";
                            }
                            else
                                layerview.text = layer.TextDescription;
                            layerview.font = [UIFont systemFontOfSize:layer.TextFontsize * scale];
                            if (layer.TextDescription.length <= 0 && is_edit) {
                                
                                layerview.adjustsFontSizeToFitWidth = YES;
                                layerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                                layerview.layer.borderWidth = 1.0;
                            }
                            [layerview setFrame: CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale)];
                            [pageview addSubview:layerview];
                        }
                    }
                }
                else if (layer.AreaType == 1) { // 1:icon
                    UIImageView *layerview = [[UIImageView alloc] init];
                    [pageview addSubview:layerview];
                    
                    layerview.clipsToBounds = YES;
                    
                    // SJYANG : 2018 달력 : 대형벽걸이 - 그린리프에서 4월과 6월이 나뭇잎이 이상하게 나오는 버그 수정
                    //layerview.contentMode = UIViewContentModeScaleAspectFill;
                    if (_product_type == PRODUCT_CALENDAR)
                        layerview.contentMode = UIViewContentModeScaleToFill;
                    else
                        layerview.contentMode = UIViewContentModeScaleAspectFill;
                    
                    layerview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, layer.Filename]];
                    
                    CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                    [layerview setFrame: layer_rect];
                }
                // 신규 달력 포맷 : DAY
                else if (layer.AreaType == 14) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        
                        UIImage* image = [self resizeImage:[UIImage imageNamed:@"transparent.png"] convertToSize:CGSizeMake(layer.W*h_scale, layer.H*v_scale)];
                        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
                        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                        
                        int nWeeks = [self getNumberOfWeeks:page.CalendarYear withMonth:page.CalendarMonth];
                        int firstDayOfWeek = [self getFirstDayOfWeek:page.CalendarYear withMonth:page.CalendarMonth];
                        
                        int offsetX = 0;
                        int offsetY = 0;
                        
                        // 신규 달력 포맷 : row type
                        int rows = 5;
                        int cols = 7;
                        
                        if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                            if (layer.Type == 2) {
                                rows = 2;
                                cols = 16;
                            }
                            else {
                                rows = 1;
                                cols = [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth];
                            }
                        }
                        
                        
                        // 신규 달력 포맷 : 2018.11.22
                        int lastDay = [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth] + 1;
                        float *rowCellPosX = (float *)malloc(sizeof(float) * lastDay);
                        
                        if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                            float totalTextWidth = 0;
                            for (int x = 1; x <= lastDay; x++)
                            {
                                NSString *text = [@(x) stringValue];
                                UIFont *font = nil;
                                float fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale;
                                
                                if(layer.Fontname != nil && layer.Fontname.length > 0 && [_fonts objectForKey:layer.Fontname] != nil)
                                    font = [UIFont fontWithName:[_fonts objectForKey:layer.Fontname] size:fontSize];
                                if(font == nil)
                                    font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
                                NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor whiteColor]};
                                CGSize textSize = [text sizeWithAttributes:attr];
                                
                                if (x <= [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth])
                                    totalTextWidth += textSize.width;
                            }
                            
                            float eachMarginWidth = ((float) (float) layer.W * h_scale - totalTextWidth) / (float) (lastDay - 1);
                            
                            for (int x = 1; x <= lastDay; x++)
                            {
                                NSString *text = [@(x) stringValue];
                                UIFont *font = nil;
                                float fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale;
                                
                                if(layer.Fontname != nil && layer.Fontname.length > 0 && [_fonts objectForKey:layer.Fontname] != nil)
                                    font = [UIFont fontWithName:[_fonts objectForKey:layer.Fontname] size:fontSize];
                                if(font == nil)
                                    font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
                                NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor whiteColor]};
                                CGSize textSize = [text sizeWithAttributes:attr];
                                
                                if (x >= 2)
                                    rowCellPosX[x - 1] = rowCellPosX[x - 2] + textSize.width + eachMarginWidth;
                                else
                                    rowCellPosX[x - 1] = textSize.width + eachMarginWidth;
                            }
                        }
                        
                        
                        float cellWidth = (float) layer.W * h_scale / (float) cols;
                        float cellHeight = (float) layer.H * v_scale / (float) rows;
                        
                        int dayOfMonth = 1;
                        for (int i = 1; i <= rows; i++) {
                            for (int j = 1; j <= cols; j++) {
                                // 신규 달력 포맷 : row type
                                if (rows == 5) {
                                    if (i == 1 && j < firstDayOfWeek)
                                        continue;
                                }
                                if (dayOfMonth > [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth])
                                    continue;
                                
                                NSString *fmtDate = [NSString stringWithFormat: @"%@%02d%02d", [[@(page.CalendarYear) stringValue] substringWithRange:NSMakeRange(2, 2)], page.CalendarMonth, dayOfMonth];
                                
                                float fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale;
                                
                                NSString *text = [@(dayOfMonth) stringValue];
                                if (i == 5 && nWeeks == 6) {
                                    if (dayOfMonth + 7 <= [self getLastDayOfMonth:page.CalendarYear withMonth:page.CalendarMonth]) {
                                        fontSize = _FONT_SIZE_RATIO * layer.Fontsize * v_scale * 0.75f;
                                        text = [NSString stringWithFormat: @"%ld/%ld", (long)dayOfMonth, (long)(dayOfMonth + 7)];
                                    }
                                }
                                
                                UIColor* fontColor;
                                // 신규 달력 포맷 : row type
                                if ([self getDayOfWeek:page.CalendarYear withMonth:page.CalendarMonth withDay:dayOfMonth] == 1 || (_holidays != nil && [_holidays objectForKey:fmtDate] != nil))
                                    fontColor = [self fromArgbString:layer.Holidaycolor];
                                else
                                    fontColor = [self fromArgbString:layer.Fontcolor];
                                
                                UIFont *font = nil;
                                
                                if(layer.Fontname != nil && layer.Fontname.length > 0 && [_fonts objectForKey:layer.Fontname] != nil)
                                    font = [UIFont fontWithName:[_fonts objectForKey:layer.Fontname] size:fontSize];
                                if(font == nil)
                                    font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
                                NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: fontColor};
                                CGSize textSize = [text sizeWithAttributes:attr];
                                
                                float y = offsetY + cellHeight * (i - 1);
                                CGFloat topPadding = font.ascender - font.capHeight + 1;
                                y += topPadding;
                                
                                float x = 0;
                                // 신규 달력 포맷 : 2018.11.22
                                if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                                    if([layer.Align isEqualToString:@"center"]) {
                                        if (dayOfMonth >= 2)
                                            x = offsetX + rowCellPosX[dayOfMonth - 2] + (rowCellPosX[dayOfMonth - 1] - rowCellPosX[dayOfMonth - 2]) / 2.f - textSize.width / 2.f;
                                        else
                                            x = offsetX + rowCellPosX[dayOfMonth - 1] / 2.f - textSize.width / 2.f;
                                    }
                                    else if([layer.Align isEqualToString:@"right"]) {
                                        x = offsetX + rowCellPosX[dayOfMonth - 1] - textSize.width;
                                    }
                                    else {
                                        if (dayOfMonth >= 2)
                                            x = offsetX + rowCellPosX[dayOfMonth - 2];
                                        else
                                            x = offsetX;
                                    }
                                }
                                else {
                                    if([layer.Align isEqualToString:@"center"]) {
                                        x = offsetX + cellWidth * (j - 1) + (cellWidth - textSize.width) / 2.f;
                                    }
                                    else if([layer.Align isEqualToString:@"right"]) {
                                        x = offsetX + cellWidth * j - textSize.width;
                                    }
                                    else {
                                        x = offsetX + cellWidth * (j - 1);
                                    }
                                }
                                [text drawAtPoint:CGPointMake(x, y) withAttributes:attr];
                                
                                {
                                    NSString *fmtDate2 = @"";
                                    if([text containsString:@"/"])
                                        fmtDate2 = [NSString stringWithFormat: @"%@%02d%02d", [[@(page.CalendarYear) stringValue] substringWithRange:NSMakeRange(2, 2)], page.CalendarMonth, dayOfMonth + 7];
                                    
                                    if (_memorials != nil && (layer.Anniversary != nil && [layer.Anniversary isEqualToString:@"true"])
                                        && ([_memorials objectForKey:fmtDate] != nil ||
                                            (![fmtDate2 isEqualToString:@""] && [_memorials objectForKey:fmtDate2] != nil)
                                            ))
                                    {
                                        float mFontSize = _FONT_SIZE_RATIO * 4 * v_scale;
                                        
                                        NSString *mTxt = @"";
                                        if ([_memorials objectForKey:fmtDate])
                                            mTxt = ((MemorialDay*)[_memorials objectForKey:fmtDate]).title;
                                        else
                                            mTxt = ((MemorialDay*)[_memorials objectForKey:fmtDate2]).title;
                                        
                                        [[self fromArgbString:layer.Fontcolor] set];
                                        
                                        UIFont *mFont = [UIFont systemFontOfSize:mFontSize weight:UIFontWeightUltraLight];
                                        NSDictionary *mAttr = @{ NSFontAttributeName:mFont, NSForegroundColorAttributeName: [self fromArgbString:layer.Fontcolor]};
                                        CGSize mTextSize = [mTxt sizeWithAttributes:mAttr];
                                        
                                        CGFloat mTopPadding = mFont.ascender - mFont.capHeight + 1;
                                        
                                        //float my = offsetY + cellHeight * (i - 1) + textSize.height + mTopPadding + 0.3f * v_scale;
                                        float my = offsetY + cellHeight * (i - 1) + (font.ascender - font.descender) + mTopPadding + 0.1f * v_scale;
                                        
                                        // 신규 달력 포맷 : 2018.11.22
                                        float mx = 0;
                                        if (page.Datefile != nil && [page.Datefile isEqualToString:@"row"]) {
                                            if([layer.Align isEqualToString:@"center"]) {
                                                if (dayOfMonth >= 2)
                                                    mx = offsetX + rowCellPosX[dayOfMonth - 2] + (rowCellPosX[dayOfMonth - 1] - rowCellPosX[dayOfMonth - 2]) / 2.f - mTextSize.width / 2.f;
                                                else
                                                    mx = offsetX + rowCellPosX[dayOfMonth - 1] / 2.f - textSize.width / 2.f;
                                            }
                                            else if([layer.Align isEqualToString:@"right"]) {
                                                mx = offsetX + rowCellPosX[dayOfMonth - 1] - mTextSize.width;
                                            }
                                            else {
                                                mx = x;
                                            }
                                        }
                                        else {
                                            if([layer.Align isEqualToString:@"center"]) {
                                                mx = offsetX + cellWidth * (j - 1) + (cellWidth - mTextSize.width) / 2.f;
                                            }
                                            else if([layer.Align isEqualToString:@"right"]) {
                                                mx = offsetX + cellWidth * j - mTextSize.width;
                                            }
                                            else {
                                                mx = x;
                                            }
                                        }
                                        [mTxt drawAtPoint:CGPointMake(mx, my) withAttributes:mAttr];
                                    }
                                }
                                
                                dayOfMonth++;
                            }
                        }
                        
                        free(rowCellPosX);
                        
                        image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        layerview.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
                        layerview.contentMode = UIViewContentModeScaleAspectFill;
                        layerview.image = image;
                    }
                }
                // 신규 달력 포맷 : YEAR
                else if (layer.AreaType == 11) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        v_scale = h_scale;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        //layerview.backgroundColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:30/255.0f]; // 디버깅 용도
                        
                        NSString* text = [NSString stringWithFormat: @"%ld", (long)page.CalendarYear];
                        [self drawCalendarText:text withPage:page withLayer:layer inView:layerview withHScale:h_scale withVScale:v_scale];
                    }
                }
                // 신규 달력 포맷 : MONTH_ENG
                else if (layer.AreaType == 12) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        v_scale = h_scale;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        NSString *month1[] = {@"JAN", @"FEB", @"MAR", @"APR", @"MAY", @"JUN", @"JUL", @"AUG", @"SEP", @"OCT", @"NOV", @"DEC"};
                        NSString *month2[] = {@"jan", @"feb", @"mar", @"apr", @"may", @"jun", @"jul", @"aug", @"sep", @"oct", @"nov", @"dec"};
                        NSString *month3[] = {@"JANUARY", @"FEBRUARY", @"MARCH", @"APRIL", @"MAY", @"JUNE", @"JULY", @"AUGUST", @"SEPTEMBER", @"OCTOBER", @"NOVEMBER", @"DECEMBER"};
                        NSString *month4[] = {@"january", @"february", @"march", @"april", @"may", @"june", @"july", @"august", @"september", @"october", @"november", @"december"};
                        NSString *month5[] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};
                        
                        NSString* text = @"";
                        if (layer.Calid != nil && layer.Calid.length > 0)
                        {
                            if([layer.Calid isEqualToString:@"em1"])
                                text = month1[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em2"])
                                text = month2[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em3"])
                                text = month3[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em4"])
                                text = month4[page.CalendarMonth - 1];
                            else if([layer.Calid isEqualToString:@"em5"])
                                text = month5[page.CalendarMonth - 1];
                        }
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        
                        [self drawCalendarText:text withPage:page withLayer:layer inView:layerview withHScale:h_scale withVScale:v_scale];
                    }
                }
                // 신규 달력 포맷 : MONTH_NUM
                else if (layer.AreaType == 13) {
                    if (_product_type == PRODUCT_CALENDAR) {
                        float h_scale = working_rect.size.width / page.PageWidth;
                        float v_scale = working_rect.size.height / page.PageHeight;
                        
                        v_scale = h_scale;
                        
                        UIImageView *layerview = [[UIImageView alloc] init];
                        [pageview addSubview:layerview];
                        
                        CGRect layer_rect = CGRectMake(layer.X*h_scale, layer.Y*v_scale, layer.W*h_scale, layer.H*v_scale);
                        [layerview setFrame: layer_rect];
                        
                        NSString* text = [NSString stringWithFormat: @"%02d", (int)page.CalendarMonth];
                        [self drawCalendarText:text withPage:page withLayer:layer inView:layerview withHScale:h_scale withVScale:v_scale];
                    }
                }
                else if (layer.AreaType == 3) {
                    // 마그넷 : guideinfo : 아무것도 처리하지 않음
                }
                else {
                    // 폰케이스
                    if (_product_type == PRODUCT_PHONECASE) {
                        UIImage *working_image;
                        PhotoLayerView *layerview;
                        {
                            layerview = [[PhotoLayerView alloc] init];
                            CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                            
                            layerview.clipsToBounds = TRUE;
                            [layerview setFrame: layer_rect];
                            if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] ) errorExists = TRUE;
                        }
                        UIImage* edit_image;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(layerview.frame.size.width, layerview.frame.size.height));
                            [layerview.layer renderInContext:UIGraphicsGetCurrentContext()];
                            edit_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        layerview.hidden = YES;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                            [edit_image drawInRect:layer_rect];
                            
                            working_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            [working_image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            [pageview.image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            NSString *urlstr = @"";
                            if([[Common info].photobook.Size isEqualToString:@"iPhone 6"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_I6.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"iPhone 6+"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_I6plus.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY S5"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_s5.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY S6"])
                                urlstr = [NSString stringWithFormat:@"%@phone_form_s6.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"iPhone_6"])
                                urlstr = [NSString stringWithFormat:@"%@iPhone_6_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"iPhone_6plus"])
                                urlstr = [NSString stringWithFormat:@"%@iPhone_6plus_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY_S5"])
                                urlstr = [NSString stringWithFormat:@"%@GALAXY_S5_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else if([[Common info].photobook.Size isEqualToString:@"GALAXY_S6"])
                                urlstr = [NSString stringWithFormat:@"%@GALAXY_S6_form.png", URL_PRODUCT_PAGESKIN_PATH];
                            else {
                                // check error
                            }
                            
                            NSURL *url = [NSURL URLWithString:urlstr];
                            NSData *data = [NSData dataWithContentsOfURL:url];
                            UIImage *phonetemplate = [UIImage imageWithData:data];
                            [phonetemplate drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            pageview.image = maskedImage;
                        }
                    }
                    else if (_product_type == PRODUCT_CARD) {
                        UIImage *working_image;
                        PhotoLayerView *layerview;
                        {
                            layerview = [[PhotoLayerView alloc] init];
                            CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                            
                            layerview.clipsToBounds = TRUE;
                            [layerview setFrame: layer_rect];
                            if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] ) errorExists = TRUE;
                            
                            if (layer.is_lowres && is_edit) {
                                UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                                [layerview addSubview:waring_view];
                                
                                CGRect waring_rect = CGRectZero;
                                waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                                waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                                waring_rect.size.width = 30;
                                waring_rect.size.height = 30;
                                
                                waring_view.image = _warning_image;
                                waring_view.clipsToBounds = TRUE;
                                waring_view.alpha = 0.8f;
                                [waring_view setFrame: waring_rect];
                            }
                        }
                        UIImage* edit_image;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(layerview.frame.size.width, layerview.frame.size.height));
                            [layerview.layer renderInContext:UIGraphicsGetCurrentContext()];
                            
                            edit_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        layerview.hidden = YES;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                            [edit_image drawInRect:layer_rect];
                            
                            working_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            [working_image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            [pageview.image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            pageview.image = maskedImage;
                        }
                    }
                    // 마그넷
                    else if (_product_type == PRODUCT_MAGNET) {
                        UIImage *working_image;
                        
                        PhotoLayerView *layerview;
                        {
                            layerview = [[PhotoLayerView alloc] init];
                            [pageview addSubview:layerview]; // 추가
                            
                            CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                            
                            layerview.clipsToBounds = TRUE;
                            [layerview setFrame: layer_rect];
                            if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] ) errorExists = TRUE;
                            
                            if (layer.is_lowres && is_edit) {
                                UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                                [layerview addSubview:waring_view];
                                
                                CGRect waring_rect = CGRectZero;
                                waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                                waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                                waring_rect.size.width = 30;
                                waring_rect.size.height = 30;
                                
                                waring_view.image = _warning_image;
                                waring_view.clipsToBounds = TRUE;
                                waring_view.alpha = 0.8f;
                                [waring_view setFrame: waring_rect];
                            }
                        }
                        UIImage* edit_image;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(layerview.frame.size.width, layerview.frame.size.height));
                            [layerview.layer renderInContext:UIGraphicsGetCurrentContext()];
                            
                            edit_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        
                        layerview.hidden = YES;
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                            [edit_image drawInRect:layer_rect];
                            
                            working_image = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                        }
                        // 마그넷 : 마스킹 S ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        {
                            UIGraphicsBeginImageContext(CGSizeMake(pageview.frame.size.width, pageview.frame.size.height));
                            
                            [working_image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            [pageview.image drawInRect:CGRectMake(0.0, 0.0, pageview.frame.size.width, pageview.frame.size.height)];
                            
                            if (layer.ImageEditname.length == 0) {
                                if (is_edit) {
                                    {
                                        CGRect layer_rect = CGRectMake(layerview.frame.origin.x, layerview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height);
                                        CGContextRef context = UIGraphicsGetCurrentContext();
                                        CGContextSetRGBStrokeColor(context, 189.0f/255.0f, 189.0f/255.0f, 189.0f/255.0f, 0.5f);
                                        CGContextStrokeRect(context, layer_rect);
                                    }
                                }
                            }
                            
                            UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            pageview.image = maskedImage;
                        }
                        
                        // 마그넷 : 하트 상품일 경우의 별도 마스킹 처리
                        if ([_ProductCode hasPrefix:@"404"]) {
                            UIImage *frameInfoImage = nil;
                            if(page.PageFile != nil && page.PageFile.length > 0) {
                                NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", _base_folder];
                                
                                NSString *frameInfoFile = page.PageFile;
                                
                                if(frameInfoFile.length > 0) {
                                    NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, frameInfoFile];
                                    frameInfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                    frameInfoImage = [self maskImage:frameInfoImage];
                                }
                            }
                            
                            if(frameInfoImage != nil)
                            {
                                CALayer *mask = [CALayer layer];
                                mask.contents = (id)[frameInfoImage CGImage];
                                mask.frame = CGRectMake(0, 0, pageview.frame.size.width, pageview.frame.size.height);
                                pageview.layer.mask = mask;
                                pageview.layer.masksToBounds = YES;
                            }
                        }
                        else {
                            // TODO : 마그넷 : guideinfo : 하트 상품이 아닌 경우에만 guideinfo 를 처리하는 것이 맞는지 체크 필요
                            // 마그넷 : guideinfo 처리
                            if (guideinfo != nil) {
                                NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", _base_folder];
                                NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, guideinfo.SkinFilename];
                                UIImage *guideinfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                if(guideinfoImage != nil) {
                                    guideinfoImage = [self maskImage:guideinfoImage];
                                    
                                    CALayer *mask = [CALayer layer];
                                    mask.contents = (id)[guideinfoImage CGImage];
                                    mask.frame = CGRectMake(0, 0, pageview.frame.size.width, pageview.frame.size.height);
                                    pageview.layer.mask = mask;
                                    pageview.layer.masksToBounds = YES;
                                }
                            }
                        }
                        // 마그넷 : 마스킹 E ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    }
                    else {
                        PhotoLayerView *layerview = [[PhotoLayerView alloc] init]; // @@@
                        
                        if (_product_type == PRODUCT_SINGLECARD || _product_type == PRODUCT_DIVISIONSTICKER || _product_type == PRODUCT_DESIGNPHOTO){
                            
                            [parentview addSubview:layerview];
                            pageview.backgroundColor = [UIColor clearColor];
                            [parentview addSubview:pageview];
                            
                        }else{
                            [pageview addSubview:layerview];
                            if (_product_type == PRODUCT_TRANSPARENTCARD) {
                                layerview.alpha = 0.7;
                            }
                        }
                        
                        
                        CGRect layer_rect = CGRectMake(layer.MaskX*scale, layer.MaskY*scale, layer.MaskW*scale, layer.MaskH*scale);
                        
                        if (_product_type == PRODUCT_POSTER || _product_type == PRODUCT_TRANSPARENTCARD) {
                            layer_rect = CGRectMake((layer.MaskX + 5)*scale,
                                                    (layer.MaskY + 5)*scale,
                                                    (layer.MaskW - 10)*scale,
                                                    (layer.MaskH - 10)*scale);
                        }
                        layerview.clipsToBounds = TRUE;
                        
                        
                        // 가로모드 디버깅중
                        [layerview setFrame: layer_rect];
                        /*
                         if (_product_type == PRODUCT_DESIGNPHOTO) {
                         //[layerview setFrame: CGRectMake(layerview.frame.origin.x + pageview.frame.origin.x, layerview.frame.origin.y + pageview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height)];
                         [layerview setFrame: CGRectMake(layerview.frame.origin.x + pageview.frame.origin.x, layerview.frame.origin.y + pageview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height)];
                         }
                         */
                        
                        
                        if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] )
                        {
                            // 2017.11.16 : SJYANG
                            errorExists = TRUE;
                            //[pageview removeFromSuperview];
                            
                            UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                            [layerview addSubview:waring_view];
                            
                            CGRect waring_rect = CGRectZero;
                            waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                            waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                            waring_rect.size.width = 30;
                            waring_rect.size.height = 30;
                            
                            waring_view.image = _warning_image;
                            waring_view.clipsToBounds = TRUE;
                            waring_view.alpha = 0.8f;
                            [waring_view setFrame: waring_rect];
                        }
                        else {
                            if (layer.is_lowres && is_edit) {
                                //errorExists = TRUE; // 2017.11.16 : SJYANG
                                
                                UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                                [layerview addSubview:waring_view];
                                
                                CGRect waring_rect = CGRectZero;
                                waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                                waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                                waring_rect.size.width = 30;
                                waring_rect.size.height = 30;
                                
                                waring_view.image = _warning_image;
                                waring_view.clipsToBounds = TRUE;
                                waring_view.alpha = 0.8f;
                                [waring_view setFrame: waring_rect];
                            }
                        }
                        
                        // 신규 달력 포맷 : 마스킹
                        if (_product_type == PRODUCT_CALENDAR) {
                            if (layer.ImageEditname == nil || layer.ImageEditname.length == 0) {
                                if(layer.Frameinfo != nil && layer.Frameinfo.length > 0) {
                                    NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", _base_folder];
                                    
                                    NSString *frameInfoFile = @"";
                                    NSString *cutFrameInfoFile = @"";
                                    
                                    NSArray *tarr = [layer.Frameinfo componentsSeparatedByString:@"^"];
                                    frameInfoFile = [tarr objectAtIndex:0];
                                    if([tarr count] > 1)
                                        cutFrameInfoFile = [tarr objectAtIndex:1];
                                    
                                    if(frameInfoFile.length > 0) {
                                        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, frameInfoFile];
                                        UIImage *frameInfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                        
                                        if([self isOuterAlphaImage:frameInfoImage])
                                            frameInfoImage = [self transactFrameInfoBitmap:frameInfoImage];
                                        
                                        UIImageView *view = [[UIImageView alloc] init];
                                        [layerview addSubview:view];
                                        
                                        CGRect rect = CGRectMake(0, 0, layer_rect.size.width, layer_rect.size.height);
                                        [view setFrame:rect];
                                        
                                        // FIX : 2019.03.07 : 신규 달력 포맷 : 마스킹 : 대형벽걸이 > 그린리프 마스킹 오류 수정
                                        //view.contentMode = UIViewContentModeScaleAspectFill;
                                        view.contentMode = UIViewContentModeScaleToFill;
                                        view.image = frameInfoImage;
                                    }
                                    if(cutFrameInfoFile.length > 0) {
                                        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, cutFrameInfoFile];
                                        UIImage *cutFrameInfoImage = [UIImage imageWithContentsOfFile:localpathname];
                                        
                                        UIImageView *view = [[UIImageView alloc] init];
                                        [layerview addSubview:view];
                                        
                                        CGRect rect = CGRectMake(0, 0, layer_rect.size.width, layer_rect.size.height);
                                        [view setFrame:rect];
                                        
                                        // FIX : 2019.03.07 : 신규 달력 포맷 : 마스킹 : 대형벽걸이 > 그린리프 마스킹 오류 수정
                                        //view.contentMode = UIViewContentModeScaleAspectFill;
                                        view.contentMode = UIViewContentModeScaleToFill;
                                        view.image = cutFrameInfoImage;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 폰케이스의 경우, 미리 화면 캡쳐를 해 둔다.
            if (_product_type == PRODUCT_PHONECASE) {
                UIGraphicsBeginImageContextWithOptions(pageview.bounds.size, pageview.opaque, 0.0);
                [pageview.layer renderInContext:UIGraphicsGetCurrentContext()];
                _thumb_captured_image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            if (include_bg) {
                if (_product_type == PRODUCT_PHOTOBOOK) {
                    UIImageView *centerview = [[UIImageView alloc] init]; // @@@
                    centerview.contentMode = UIViewContentModeScaleToFill;
                    [pageview addSubview:centerview];
                    
                    if (index == 0) {
                        centerview.image = _cover_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (26*scale)/2), 0, 26*scale, working_rect.size.height)];
                        centerview.alpha = 0.2;
                        
                        UIImageView *cover_mark_view = [[UIImageView alloc] init]; // @@@
                        cover_mark_view.image = _cover_banner_image;
                        [pageview addSubview:cover_mark_view];
                        [cover_mark_view setFrame:CGRectMake(0, 0, 70, 70)];
                    }
                    else if (index == 1 && !([_ProductCode isEqualToString:@"300269"] || [_ProductCode isEqualToString:@"300270"] || [_ProductCode isEqualToString:@"120069"])) { // SJYANG : 카달로그 추가
                        centerview.image = _inner_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (182*scale)/2), 0, 182*scale, working_rect.size.height)];
                        
                        UIImageView *cover_mark_view = [[UIImageView alloc] init]; // @@@
                        cover_mark_view.image = _blank_banner_image;
                        [pageview addSubview:cover_mark_view];
                        [cover_mark_view setFrame:CGRectMake(0, 0, 70, 70)];
                    }
                    // SJYANG
                    // 프리미엄북 : 에필로그 페이지에 역(reverse) blank 이미지 삽입
                    else if (index == _pages.count - 1 && [_ThemeName isEqualToString:@"premium"]) {
                        centerview.image = _inner_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (182*scale)/2), 0, 182*scale, working_rect.size.height)];
                        
                        UIImageView *cover_mark_view = [[UIImageView alloc] init]; // @@@
                        cover_mark_view.image = _blank_rvs_banner_image;
                        [pageview addSubview:cover_mark_view];
                        [cover_mark_view setFrame:CGRectMake(working_rect.size.width - 70, 0, 70, 70)];
                    }
                    else {
                        centerview.image = _inner_grad_image;
                        [centerview setFrame:CGRectMake((working_rect.size.width/2 - (182*scale)/2), 0, 182*scale, working_rect.size.height)];
                    }
                }
                else if (_product_type == PRODUCT_CALENDAR) {
                    
                    // SJYANG : 2018 달력
                    // 포스터 달력 관련 코드 추가
                    if (!([intnum isEqualToString:@"369"] || [intnum isEqualToString:@"391"] || [intnum isEqualToString:@"393"] || ![Common info].photobook.showSpring)) { // 369 => 우드스탠드, 391 => 시트달력 , showspring bool check add
                        if ([intnum isEqualToString:@"367"] || [intnum isEqualToString:@"392"]) { // 367 => 소형벽걸이달력, 392 => 대형벽걸이달력
                            UIView *ringview = [[UIView alloc] init]; // @@@
                            [parentview addSubview:ringview];
                            
                            CGRect ring_rect = working_rect;
                            ring_rect.origin.y -= 7;
                            ring_rect.size.height = 21;
                            
                            // SJYANG : 2018 달력
                            /*
                             if(_ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                             ring_rect.origin.x += 21;
                             ring_rect.size.width -= 21 * 2;
                             }
                             */
                            
                            UIGraphicsBeginImageContext(CGSizeMake(ring_rect.size.width, ring_rect.size.height));
                            
                            UIImage *tringimg = [UIImage imageNamed:@"calendar_page_ring.png"];
                            CGFloat tringscale = tringimg.size.height / ring_rect.size.height;
                            UIImage *ringimg = [UIImage imageWithCGImage:[tringimg CGImage] scale:(tringimg.scale * tringscale) orientation:(tringimg.imageOrientation)];
                            
                            UIImage *tcircleimg = [UIImage imageNamed:@"calendar_bg_circle.png"];
                            CGFloat tcirclescale = tcircleimg.size.height / ring_rect.size.height / 1.6f;
                            UIImage *circleimg = [UIImage imageWithCGImage:[tcircleimg CGImage] scale:(tcircleimg.scale * tcirclescale) orientation:(tcircleimg.imageOrientation)];
                            
                            CGFloat circle_x1 = ring_rect.size.width / 2.f - circleimg.size.width / 2.f;
                            CGFloat circle_x2 = ring_rect.size.width / 2.f + circleimg.size.width / 2.f;
                            
                            CGFloat x;
                            x = circle_x2 + ringimg.size.width * 0.5f;
                            for(int i=0;;i++) {
                                if(x + ringimg.size.width * i + ringimg.size.width >= ring_rect.size.width) break;
                                BOOL bok = NO;
                                if (ringimg.size.width * i > circle_x2) bok = YES;
                                if (ringimg.size.width * (i + 1) < circle_x1) bok = YES;
                                if(bok == YES)
                                    [ringimg drawInRect:CGRectMake(x + ringimg.size.width * i, 0, ringimg.size.width, ringimg.size.height)];
                            }
                            x = circle_x1 - ringimg.size.width - ringimg.size.width * 0.5f;
                            for(int i=0;;i++) {
                                if(x - ringimg.size.width * i <= 0) break;
                                BOOL bok = NO;
                                if (ringimg.size.width * i > circle_x2) bok = YES;
                                if (ringimg.size.width * (i + 1) < circle_x1) bok = YES;
                                if(bok == YES)
                                    [ringimg drawInRect:CGRectMake(x - ringimg.size.width * i, 0, ringimg.size.width, ringimg.size.height)];
                            }
                            [circleimg drawInRect:CGRectMake(circle_x1, -circleimg.size.height * 0.36f, circleimg.size.width, circleimg.size.height)];
                            
                            UIImage *resultimg = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            [ringview setFrame:ring_rect];
                            [ringview setBackgroundColor: [UIColor colorWithPatternImage:resultimg]];
                        }
                        else {
                            UIView *ringview = [[UIView alloc] init]; // @@@
                            [parentview addSubview:ringview];
                            
                            CGRect ring_rect = working_rect;
                            ring_rect.origin.y -= 7;
                            ring_rect.size.height = 21;
                            
                            // SJYANG : 2018 달력
                            /*
                             if(_ThemeHangulName != nil && [_ThemeHangulName rangeOfString:@"라운드" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                             ring_rect.origin.x += 21;
                             ring_rect.size.width -= 21 * 2;
                             }
                             */
                            
                            [ringview setFrame:ring_rect];
                            [ringview setBackgroundColor: [UIColor colorWithPatternImage:_page_pattern_calendar]];
                        }
                    }
                }
                else if (_product_type == PRODUCT_POLAROID) {
                    // 폴라로이드는 할거 없음.
                }
                // PTODO : 진짜 할 것이 없는지 체크 필요
                else if (_product_type == PRODUCT_DESIGNPHOTO) {
                    // 폴라로이드는 할거 없음.
                }
                else if (_product_type == PRODUCT_SINGLECARD) {
                    // 폴라로이드는 할거 없음.
                }
                else if (_product_type == PRODUCT_CARD) {
                    // 포토카드는 할거 없음.
                }
                else if (_product_type == PRODUCT_MUG) {
                    // 머그도 할거 없음.
                }
                else if (_product_type == PRODUCT_PHONECASE) {
                    // 폰케이스도 할거 없음.
                }
                else if (_product_type == PRODUCT_POSTCARD) {
                    // 할거 없나?
                }
                else if (_product_type == PRODUCT_MAGNET) {
                    // 할거 없나?
                }
                else if (_product_type == PRODUCT_BABY) {
                    // 베이비도 할거 없음.
                } else if (_product_type == PRODUCT_POSTER) {
                    
                }
                else if (_product_type == PRODUCT_TRANSPARENTCARD) {
                    
                }
                else if (_product_type == PRODUCT_DIVISIONSTICKER) {
                    //할거없음?
                }
                else if (_product_type == PRODUCT_MONTHLYBABY) {
                    // 월간 포토몬도 할거 없음.
                }
                else {
                    NSAssert(NO, @"producttype is wrong..");
                }
            }
            
            
            // 디버그
            /*if (_product_type == PRODUCT_DESIGNPHOTO) {
                if (page.PageFile.length > 0) {
                    
                    UIImage* maskImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
                    UIImageView *maskview = [[UIImageView alloc] init]; // @@@
                    maskview.image = maskImage;
                    [pageview addSubview:maskview];
                    
                    // 가로모드 디버깅중
                    //[maskview setFrame:pageview.frame];
                    [maskview setFrame:CGRectMake(0, 0, pageview.frame.size.width, pageview.frame.size.height)]; // 디버깅중
                    maskview.contentMode = UIViewContentModeScaleAspectFill;
                    maskview.clipsToBounds = YES;
                }
            }*/
            
            _scale_factor = scale;
        }
    }

    

    if( errorExists ) return FALSE;
    else return TRUE;
}

- (BOOL)composePaperSloganPage:(NSInteger)index ParentView:(UIImageView *)parentview IncludeBg:(BOOL)include_bg IsEdit:(BOOL)is_edit IsThumbnail:(BOOL)is_thumbnail {

    BOOL errorExists = FALSE;

    for (int i = 0; i < 2; i++) {
        Page *page = _pages[index + i];
        CGFloat scale = is_edit ? 1.f : 0.5f;
        CGFloat heightRatio = (CGFloat) page.PageHeight / page.PageWidth;
        CGRect working_rect = CGRectMake(0, i * (is_edit ? 300 : 200) * _heightScale * scale, parentview.frame.size.width, parentview.frame.size.width * heightRatio);

        if (include_bg) {
            parentview.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
            parentview.layer.borderWidth = 1.0;
            parentview.image = nil;
            working_rect = CGRectInset(working_rect, 0, 0);
        }

        UIImageView *pageview = [[UIImageView alloc] init]; // @@@
        pageview.tag = 5001 + i;
        [parentview addSubview:pageview];
        [pageview setFrame:working_rect];

        if (is_edit) {
            UILabel *directionLabel = [[UILabel alloc] init]; // @@@
            CGRect frame = working_rect;

            directionLabel.textAlignment = NSTextAlignmentCenter;
            directionLabel.textColor = [UIColor colorFromHexString:@"#222222"];
            directionLabel.text = i == 0 ? @"[ 앞면 ]" : @"[ 뒷면 ]";
            directionLabel.tag = 10001 + i;
            directionLabel.font = [UIFont systemFontOfSize:30];
            frame.origin.y = working_rect.origin.y + working_rect.size.height + 10 * _heightScale;
            frame.size.height = 13;
            [parentview addSubview:directionLabel];
            directionLabel.frame = frame;
        }

        pageview.image = nil;
        pageview.backgroundColor = [UIColor colorWithRed:page.PageColorR/255.0f green:page.PageColorG/255.0f blue:page.PageColorB/255.0f alpha:page.PageColorA];

        if (page.PageFile.length > 0) {
            pageview.contentMode = UIViewContentModeScaleAspectFit;
            pageview.clipsToBounds = YES;
            pageview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, page.PageFile]];
        }

        NSLog(@"working_rect.size.width : %f", working_rect.size.width);
        NSLog(@"page.PageWidth : %d", page.PageWidth);
        NSLog(@"page.PageHeight : %d", page.PageHeight);
        NSLog(@"_edit_scale : %f", _edit_scale);

        Layer *guideinfo = nil;

        for (Layer *layer in page.layers) {

            if (layer.AreaType == 2) { // 2:text
                UILabel *layerview = [[UILabel alloc] init]; // @@@

                layerview.textAlignment = NSTextAlignmentCenter;
                if ([layer.Halign isEqualToString:@"left"]) {
                    layerview.textAlignment = NSTextAlignmentLeft;
                }
                else if ([layer.Halign isEqualToString:@"right"]) {
                    layerview.textAlignment = NSTextAlignmentRight;
                }

                layerview.textColor = layer.text_color;

                if ([layer.Gid isEqualToString:@"spine"]) {
                    layerview.text = layer.TextDescription;
                    layerview.adjustsFontSizeToFitWidth = YES;
                    [layerview setFont:[UIFont systemFontOfSize:8.0f]];

                    if (layerview.text.length <= 0) {
                        layerview.text = @"제목을 입력해 주세요";
                    }

                    CGFloat margin = 10.f;
                    layerview.layer.anchorPoint = CGPointMake(0,0);
                    //[layerview setFrame: layer_rect];
                    
                    
                    [layerview setFrame:CGRectMake(margin, 0, working_rect.size.height-margin*2, 26*heightRatio)];
                    [layerview setCenter:CGPointMake(working_rect.size.width/2, margin + working_rect.size.height/2)];
                    [layerview setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                    [pageview addSubview:layerview];
                }
                else {
                    layerview.text = layer.TextDescription;
                    if(layer.TextDescription == nil || layer.TextDescription.length <=0 ) {
                        if(_useTitleHint == NO)
                            layerview.text = @"";
                        else
                            layerview.text = @"텍스트 입력";
                    }
                    else
                        layerview.text = layer.TextDescription;
                    if (is_thumbnail) {
                        layerview.font = [UIFont systemFontOfSize:layer.TextFontsize * 1.7 * scale];
                    } else {
                        layerview.font = [UIFont systemFontOfSize:layer.TextFontsize * 0.85 * scale];
                    }
                    if (layer.TextDescription.length <= 0 && is_edit) {

                        layerview.adjustsFontSizeToFitWidth = YES;
                        layerview.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
                        layerview.layer.borderWidth = 1.0;
                    }
                    [layerview setFrame: CGRectMake(layer.MaskX*_widthScale * scale, layer.MaskY*_heightScale * scale, layer.MaskW*_widthScale * scale, layer.MaskH*_heightScale * scale)];
                    [pageview addSubview:layerview];
                }
            }
            else if (layer.AreaType == 1) { // 1:icon
                UIImageView *layerview = [[UIImageView alloc] init];
                [pageview addSubview:layerview];

                layerview.clipsToBounds = YES;
                layerview.contentMode = UIViewContentModeScaleAspectFill;

                layerview.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", _base_folder, layer.Filename]];

                CGRect layer_rect = CGRectMake(layer.MaskX*_widthScale * scale, layer.MaskY*_heightScale * scale, layer.MaskW*_widthScale * scale, layer.MaskH*_heightScale * scale);
                [layerview setFrame: layer_rect];
            }
                // 신규 달력 포맷 : DAY
            else if (layer.AreaType == 14) {

            }
                // 신규 달력 포맷 : YEAR
            else if (layer.AreaType == 11) {

            }
                // 신규 달력 포맷 : MONTH_ENG
            else if (layer.AreaType == 12) {

            }
                // 신규 달력 포맷 : MONTH_NUM
            else if (layer.AreaType == 13) {

            }
            else if (layer.AreaType == 3) {
                // 마그넷 : guideinfo : 아무것도 처리하지 않음
            }
            else {
                PhotoLayerView *layerview = [[PhotoLayerView alloc] init]; // @@@

                [pageview addSubview:layerview];

                CGRect layer_rect = CGRectMake((layer.MaskX + 2)*_widthScale * scale,
                        (layer.MaskY + 2)*_heightScale * scale,
                        (layer.MaskW - 4)*_widthScale * scale,
                        (layer.MaskH - 4)*_heightScale * scale);

                layerview.clipsToBounds = TRUE;


                // 가로모드 디버깅중
                [layerview setFrame: layer_rect];
                /*
                if (_product_type == PRODUCT_DESIGNPHOTO) {
                    //[layerview setFrame: CGRectMake(layerview.frame.origin.x + pageview.frame.origin.x, layerview.frame.origin.y + pageview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height)];
                    [layerview setFrame: CGRectMake(layerview.frame.origin.x + pageview.frame.origin.x, layerview.frame.origin.y + pageview.frame.origin.y, layerview.frame.size.width, layerview.frame.size.height)];
                }
                */


                if( ![layerview setLayerInfo:layer BaseFolder:_base_folder IsEdit:is_edit] )
                {
                    // 2017.11.16 : SJYANG
                    errorExists = TRUE;
                    //[pageview removeFromSuperview];

                    UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                    [layerview addSubview:waring_view];

                    CGRect waring_rect = CGRectZero;
                    waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                    waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                    waring_rect.size.width = 30;
                    waring_rect.size.height = 30;

                    waring_view.image = _warning_image;
                    waring_view.clipsToBounds = TRUE;
                    waring_view.alpha = 0.8f;
                    [waring_view setFrame: waring_rect];
                }
                else {
                    if (layer.is_lowres && is_edit) {
                        //errorExists = TRUE; // 2017.11.16 : SJYANG

                        UIImageView *waring_view = [[UIImageView alloc] init]; // @@@
                        [layerview addSubview:waring_view];

                        CGRect waring_rect = CGRectZero;
                        waring_rect.origin.x = (layer_rect.size.width/2 - 30/2);
                        waring_rect.origin.y = (layer_rect.size.height/2 - 30/2);
                        waring_rect.size.width = 30;
                        waring_rect.size.height = 30;

                        waring_view.image = _warning_image;
                        waring_view.clipsToBounds = TRUE;
                        waring_view.alpha = 0.8f;
                        [waring_view setFrame: waring_rect];
                    }
                }
            }
        }
    }


    if( errorExists ) return FALSE;
    else return TRUE;
}

/*
 포토북은 productoption1, theme1_id, theme2_id가 key
 캘린더는 productcode, theme1_id, theme2_id가 key
 */

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    static NSString *ProductInfo = @"";
    static NSString *theme1_id = @"";
    static NSString *theme2_id = @"";
    static CGRect cover_rect;
    static CGRect inner_rect;
    
    static CGRect cover_backrect;
    static CGRect cover_middlerect;
    static CGRect cover_frontrect;
    static NSString *cover_type = @"";

    if ([elementName isEqualToString:@"productoption1"]) { // photobook case
        ProductInfo = @"";
        theme1_id = @"";
        theme2_id = @"";
        NSString *pid = [attributeDict objectForKey:@"id"];
        if ([_ProductOption1 isEqualToString:pid]) {
            ProductInfo = pid;
        }
    }
    else if ([elementName isEqualToString:@"productcode"]) { // calendar, polaroid, mug case, baby
        ProductInfo = @"";
        theme1_id = @"";
        theme2_id = @"";
        NSString *pid = [attributeDict objectForKey:@"id"];

		if ([_ProductCode isEqualToString:pid] || _product_type == PRODUCT_PHONECASE ||
            ([_ProductCode isEqualToString:@"347064"] && [pid isEqualToString:@"347064"] ) //designphoto 에는 347064인데 theme 에서는 142998이라서 맞지않음 임시 처리
            ) {
			ProductInfo = pid;
		}
    }
    else if ([elementName isEqualToString:@"theme1"]) {
        theme1_id = @"";
        theme2_id = @"";
        if (ProductInfo.length > 0) {
            NSString *tid = [attributeDict objectForKey:@"id"];
           if ([tid isEqualToString:@"skinny"] || [tid isEqualToString:@"catalog"] || [_ThemeName isEqualToString:tid] || _product_type == PRODUCT_PHONECASE || _product_type == PRODUCT_CALENDAR || _product_type == PRODUCT_CARD
                    || _product_type == PRODUCT_POSTER || _product_type == PRODUCT_PAPERSLOGAN || _product_type == PRODUCT_SINGLECARD
                    || _product_type == PRODUCT_TRANSPARENTCARD) { // _ThemeName = theme.theme1_id;
                theme1_id = tid;
            }
        }
    }
    else if ([elementName isEqualToString:@"theme2"]) {
        theme2_id = @"";
        if (theme1_id.length > 0) {
            NSString *tid = [attributeDict objectForKey:@"id"];

            if(_product_type == PRODUCT_PHONECASE) {
                NSString *tsize = [attributeDict objectForKey:@"size"];
                NSString *color = [attributeDict objectForKey:@"color"];
                NSLog(@"_DefaultStyle : %@ / tid : %@ / _Size : %@ / _Color : %@", _DefaultStyle, tid, _Size, _Color);
                if ([_DefaultStyle isEqualToString:tid] ) { // _DefaultStyle = theme.theme2_id;
                    if (tsize != nil && [tsize isEqualToString:_Size] && tsize != nil && [color isEqualToString:_Color]) {
                        _ProductCode = ProductInfo;
                        theme2_id = tid;
                    }
                }
            }
            else if(_product_type == PRODUCT_CARD) {
                NSString *color = [attributeDict objectForKey:@"color"];
                if ([_AddParams isEqualToString:@""] || [_AddParams isEqualToString:color]) {
                    theme2_id = tid;
                }
            }
            else if(_product_type == PRODUCT_POLAROID) {
				if([_DefaultStyle isEqualToString:@"Polaroid"] || [_DefaultStyle isEqualToString:@"MiniPolaroid"]){
					if ([tid isEqualToString:@"Polaroid"] || [tid isEqualToString:@"MiniPolaroid"]) {
						theme2_id = tid;
					}
				}
				else if ([_DefaultStyle isEqualToString:tid]){
                    theme2_id = tid;
                }
            }
            else {
                if ([_DefaultStyle isEqualToString:tid]) { // _DefaultStyle = theme.theme2_id;
                    theme2_id = tid;
                }
            }
        }
    }
    else if ([elementName isEqualToString:@"coverback"]) { // photobookV2 case
        if (theme2_id.length > 0) {
            CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
            CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
            CGFloat w = [[attributeDict objectForKey:@"width"] floatValue];
            CGFloat h = [[attributeDict objectForKey:@"height"] floatValue];
            cover_backrect = CGRectMake(x, y, w, h);
            cover_type = elementName;
        }
    }
    else if ([elementName isEqualToString:@"covermiddle"]) { // photobookV2 case
        if (theme2_id.length > 0) {
            CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
            CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
            CGFloat w = [[attributeDict objectForKey:@"width"] floatValue];
            CGFloat h = [[attributeDict objectForKey:@"height"] floatValue];
            cover_middlerect = CGRectMake(x, y, w, h);
            cover_type = elementName;
        }
    }
    else if ([elementName isEqualToString:@"coverfront"]) { // photobookV2 case
        if (theme2_id.length > 0) {
            CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
            CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
            CGFloat w = [[attributeDict objectForKey:@"width"] floatValue];
            CGFloat h = [[attributeDict objectForKey:@"height"] floatValue];
            cover_frontrect = CGRectMake(x, y, w, h);
            cover_type = elementName;
        }
    }
    else if ([elementName isEqualToString:@"cover"]) { // photobook case
        if (theme2_id.length > 0) {
            CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
            CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
            CGFloat w = [[attributeDict objectForKey:@"width"] floatValue];
            CGFloat h = [[attributeDict objectForKey:@"height"] floatValue];
            cover_rect = _page_rect = CGRectMake(x, y, w, h);
        }
    }
    else if ([elementName isEqualToString:@"innerpages"]) { // photobook case
        if (theme2_id.length > 0) {
            CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
            CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
            CGFloat w = [[attributeDict objectForKey:@"width"] floatValue];
            CGFloat h = [[attributeDict objectForKey:@"height"] floatValue];
            inner_rect = _page_rect = CGRectMake(x, y, w, h); // 포토북의 page_rect는 inner_rect 기억.
        }
    }
    else if ([elementName isEqualToString:@"pages"]) { // calendar,polaroid case
        if (theme2_id.length > 0) {
            CGFloat x = [[attributeDict objectForKey:@"x"] floatValue];
            CGFloat y = [[attributeDict objectForKey:@"y"] floatValue];
            CGFloat w = [[attributeDict objectForKey:@"width"] floatValue];
            CGFloat h = [[attributeDict objectForKey:@"height"] floatValue];
            cover_rect = inner_rect = _page_rect = CGRectMake(x, y, w, h); // calendar,polaroid는 cover, inner 구분 없음.

            NSLog(@"#2 _page_rect.size.width : %f", _page_rect.size.width);
            NSLog(@"#2 _page_rect.size.height : %f", _page_rect.size.height);
        }
    }
    else if ([elementName isEqualToString:@"pageinfo"]) {
        if (theme2_id.length > 0) {

            Page *page = [[Page alloc] init];
            if (page != nil) {
                pageNum++;
                page.idx = [[attributeDict objectForKey:@"idx"] intValue];
                page.PageFile = [attributeDict objectForKey:@"skinfilename"];

                // SJYANG
                // 프리미엄북 : 옵션에 따라 페이지 스킨에 들어가는 이미지 교체
                if( [_ThemeName isEqualToString:@"premium"] && page.idx==0 ) {
                    if( [_AddParams isEqualToString:@"happiness"] )
                        page.PageFile = [page.PageFile stringByReplacingOccurrencesOfString:@"_love_" withString:@"_happiness_"];
                    else if( [_AddParams isEqualToString:@"love"] )
                        page.PageFile = [page.PageFile stringByReplacingOccurrencesOfString:@"_happiness_" withString:@"_love_"];
                }

                page.PageColorA = [[attributeDict objectForKey:@"a"] intValue];
                page.PageColorR = [[attributeDict objectForKey:@"r"] intValue];
                page.PageColorG = [[attributeDict objectForKey:@"g"] intValue];
                page.PageColorB = [[attributeDict objectForKey:@"b"] intValue];

                page.CalendarCommonLayoutType = [attributeDict objectForKey:@"commonlayouttype"];
                page.CalendarYear = [[attributeDict objectForKey:@"year"] intValue];
                page.CalendarMonth = [[attributeDict objectForKey:@"month"] intValue];
                page.Datefile = [attributeDict objectForKey:@"datefile"];

                NSString *layouttype = [attributeDict objectForKey:@"layouttype"] == nil ? cover_type : [attributeDict objectForKey:@"layouttype"];
                
                
                

                // PTODO : 이 코드에 대해 로직을 이해해야 함
                if(_product_type == PRODUCT_POLAROID) {
                    page.CalendarCommonLayoutType = layouttype;
                }

                if ([layouttype isEqualToString:@"cover"]) {
                    page.IsCover = page.IsProlog = page.IsEpilog = page.IsPage = FALSE;
                    page.IsCover = TRUE;
                    page.PageWidth = cover_rect.size.width;
                    page.PageHeight = cover_rect.size.height;
                }
                else if ([layouttype isEqualToString:@"coverback"]) {
                    page.IsCover = page.IsProlog = page.IsEpilog = page.IsPage = FALSE;
                    page.IsCover = TRUE;
                    page.pageLayoutType = layouttype;
                    page.cover_backrect = cover_backrect;
                    page.PageWidth = cover_backrect.size.width;
                    page.PageLeftWidth = cover_backrect.size.width;
                }
                else if ([layouttype isEqualToString:@"covermiddle"]) {
                    page.IsCover = page.IsProlog = page.IsEpilog = page.IsPage = FALSE;
                    page.IsCover = TRUE;
                    page.pageLayoutType = layouttype;
                    page.cover_middlerect = cover_middlerect;
                    page.PageMiddleWidth = cover_middlerect.size.width;
                }
                else if ([layouttype isEqualToString:@"coverfront"]) {
                    page.IsCover = page.IsProlog = page.IsEpilog = page.IsPage = FALSE;
                    page.IsCover = TRUE;
                    page.pageLayoutType = layouttype;
                    page.cover_frontrect = cover_frontrect;
                    page.PageRightWidth = cover_frontrect.size.width;
                }
                else if ([[layouttype lowercaseString] isEqualToString:@"prolog"]) {
                    page.IsCover = page.IsProlog = page.IsEpilog = page.IsPage = FALSE;
                    page.IsProlog = TRUE;
                    page.PageWidth = inner_rect.size.width;
                    page.PageHeight = inner_rect.size.height;
                    page.pageLayoutType = [layouttype lowercaseString];
                    page.PageLeftWidth = inner_rect.size.width;
                }
                else if ([layouttype isEqualToString:@"epilog"]) {
                    page.IsCover = page.IsProlog = page.IsEpilog = page.IsPage = FALSE;
                    page.IsEpilog = TRUE;
                    page.PageWidth = inner_rect.size.width;
                    page.PageHeight = inner_rect.size.height;
                    page.pageLayoutType = layouttype;
                }
                else {
                    page.IsCover = page.IsProlog = page.IsEpilog = page.IsPage = FALSE;
                    page.IsPage = TRUE;
                    page.PageWidth = inner_rect.size.width;
                    page.PageHeight = inner_rect.size.height;
                    page.pageLayoutType = layouttype;
                    page.PageLeftWidth = inner_rect.size.width;
                }
				
				if(_product_type == PRODUCT_CARD) {
					if ([attributeDict objectForKey:@"width"] != nil) {
						page.PageWidth = [[attributeDict objectForKey:@"width"] intValue];
					}
					if ([attributeDict objectForKey:@"height"] != nil) {
						page.PageHeight = [[attributeDict objectForKey:@"height"] intValue];
					}
                }
				
                // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
                if ([_ProductCode isEqualToString:@"300267"] || [_ProductCode isEqualToString:@"300269"] || [_ProductCode isEqualToString:@"300270"] || [[Common info] isGudakBook:_ProductCode]) {
                    if( pageNum <= [self needPhotobookPageCount] )
                        [_pages addObject:page];
                }
                else
                    [_pages addObject:page];
            }
        }
    }
    else if ([elementName isEqualToString:@"imageinfo"]) {
        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
        BOOL bAdd = TRUE;
        if ([_ProductCode isEqualToString:@"300267"] || [_ProductCode isEqualToString:@"300269"] || [_ProductCode isEqualToString:@"300270"] || [[Common info] isGudakBook:_ProductCode]) {
            if( pageNum > [self needPhotobookPageCount] )
                bAdd = FALSE;
        }
        if (theme2_id.length > 0 && bAdd) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];
                layer.AreaType = 0;
                layer.PageIndex = page.idx;
                layer.LayerIndex = [[attributeDict objectForKey:@"idx_image"] intValue];
                layer.MaskX = [[attributeDict objectForKey:@"x"] intValue];
                layer.MaskY = [[attributeDict objectForKey:@"y"] intValue];
                layer.MaskW = [[attributeDict objectForKey:@"width"] intValue];
                layer.MaskH = [[attributeDict objectForKey:@"height"] intValue];
                layer.MaskR = [[attributeDict objectForKey:@"angle"] intValue];
                layer.FrameFilename = [attributeDict objectForKey:@"diagramfilename"];
                // 신규 달력 포맷 : frameinfo
                layer.Frameinfo = [attributeDict objectForKey:@"frameinfo"];
                // 신규 달력 포맷 : FrameFilename
                if(layer.FrameFilename == nil || [layer.FrameFilename isEqualToString:@""])
                    layer.FrameFilename = layer.Frameinfo;
                [page.layers addObject:layer];
            }
        }
    }
    else if ([elementName isEqualToString:@"iconinfo"]) {
        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
        BOOL bAdd = TRUE;
        if ([_ProductCode isEqualToString:@"300267"] || [_ProductCode isEqualToString:@"300269"] || [_ProductCode isEqualToString:@"300270"]) {
            if( pageNum > [self needPhotobookPageCount] )
                bAdd = FALSE;
        }
        if (theme2_id.length > 0 && bAdd) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];
                layer.AreaType = 1;
                layer.PageIndex = page.idx;
                layer.LayerIndex = [[attributeDict objectForKey:@"idx_icon"] intValue];
                layer.MaskX = [[attributeDict objectForKey:@"x"] intValue];
                layer.MaskY = [[attributeDict objectForKey:@"y"] intValue];
                layer.MaskW = [[attributeDict objectForKey:@"width"] intValue];
                layer.MaskH = [[attributeDict objectForKey:@"height"] intValue];
                layer.MaskR = [[attributeDict objectForKey:@"angle"] intValue];
                [page.layers addObject:layer];

                layer.Filename = [attributeDict objectForKey:@"filename"];
                layer.ImageFilename = layer.Filename;
                layer.ImageEditname = layer.Filename;
                layer.Alpha = 255.0;
                layer.FrameAlpha = 255.0;
                layer.MaskAlpha = 255.0;

                // 신규 달력 포맷 : gid 저장
                if([attributeDict objectForKey:@"gid"] != nil)
                    layer.Gid = [attributeDict objectForKey:@"gid"];
                else
                    layer.Gid = @"";
            }
        }
    }
    else if ([elementName isEqualToString:@"textinfo"]) {
        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
        BOOL bAdd = TRUE;
        if ([_ProductCode isEqualToString:@"300267"] || [_ProductCode isEqualToString:@"300269"] || [_ProductCode isEqualToString:@"300270"]) {
            if( pageNum > [self needPhotobookPageCount] )
                bAdd = FALSE;
        }
        if (theme2_id.length > 0 && bAdd) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];
                layer.AreaType = 2;
                layer.PageIndex = page.idx;
                layer.LayerIndex = [[attributeDict objectForKey:@"idx_text"] intValue];
                layer.MaskX = [[attributeDict objectForKey:@"x"] intValue];
                layer.MaskY = [[attributeDict objectForKey:@"y"] intValue];
                layer.MaskW = [[attributeDict objectForKey:@"width"] intValue];
                layer.MaskH = [[attributeDict objectForKey:@"height"] intValue];
                layer.MaskR = [[attributeDict objectForKey:@"angle"] intValue];
                [page.layers addObject:layer];

                layer.Gid = [attributeDict objectForKey:@"gid"];
                layer.TextFontname = [attributeDict objectForKey:@"fontname"];
                layer.TextFontUrl = [attributeDict objectForKey:@"fonturl"];
                layer.TextFontsize = [[attributeDict objectForKey:@"fontsize"] intValue];
                layer.TextItalic = [[attributeDict objectForKey:@"italic"] boolValue];
                layer.TextBold = [[attributeDict objectForKey:@"bold"] boolValue];
                
                @try {
                    layer.Grouping = [attributeDict objectForKey:@"grouping"];
                }
                @catch(NSException *exception) {
                    layer.Grouping = @"";
                }
                
                NSString *color = [attributeDict objectForKey:@"color"];
                if (color.length > 0) {
                    layer.TextFontcolor = 0;
                    NSArray *row_array = [color componentsSeparatedByString:@","];
                    if (row_array.count >= 4) {
                        CGFloat a = [row_array[0] floatValue];
                        CGFloat r = [row_array[1] floatValue];
                        CGFloat g = [row_array[2] floatValue];
                        CGFloat b = [row_array[3] floatValue];
                        layer.text_color = [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
                    }
                }
                layer.Halign = [attributeDict objectForKey:@"halign"];
                layer.TextDescription = @"";
            }
        }
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // 마그넷 : guideinfo
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    else if ([elementName isEqualToString:@"guideinfo"]) {
        if (theme2_id.length > 0) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];

                layer.AreaType = 3;
                layer.PageIndex = page.idx;

                layer.X = [[attributeDict objectForKey:@"x"] intValue];
                layer.Y = [[attributeDict objectForKey:@"y"] intValue];
                layer.W = [[attributeDict objectForKey:@"width"] intValue];
                layer.H = [[attributeDict objectForKey:@"height"] intValue];
                layer.SkinFilename = [attributeDict objectForKey:@"skinfilename"];

                [page.layers addObject:layer];
            }
        }
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // 신규 달력 포맷 S
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    else if ([elementName isEqualToString:@"yearinfo"]) {
        if (theme2_id.length > 0) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];

                layer.AreaType = 11;
                layer.PageIndex = page.idx;
                // 신규 달력 포맷 : TODO : CHECK
                //layer.LayerIndex = [[attributeDict objectForKey:@"idx_text"] intValue];

                layer.X = [[attributeDict objectForKey:@"x"] intValue];
                layer.Y = [[attributeDict objectForKey:@"y"] intValue];
                layer.W = [[attributeDict objectForKey:@"width"] intValue];
                layer.H = [[attributeDict objectForKey:@"height"] intValue];
                layer.Type = [[attributeDict objectForKey:@"type"] intValue];
                layer.Align = [attributeDict objectForKey:@"align"];
                layer.Fontname = [attributeDict objectForKey:@"fontname"];
                layer.Fontsize = [[attributeDict objectForKey:@"fontsize"] intValue];
                layer.Fontcolor = [attributeDict objectForKey:@"fontcolor"];
                layer.Fonturl = [attributeDict objectForKey:@"fonturl"];
                layer.Calid = [attributeDict objectForKey:@"calid"];

                [page.layers addObject:layer];
            }
        }
    }
    else if ([elementName isEqualToString:@"monthenginfo"]) {
        if (theme2_id.length > 0) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];

                layer.AreaType = 12;
                layer.PageIndex = page.idx;

                layer.X = [[attributeDict objectForKey:@"x"] intValue];
                layer.Y = [[attributeDict objectForKey:@"y"] intValue];
                layer.W = [[attributeDict objectForKey:@"width"] intValue];
                layer.H = [[attributeDict objectForKey:@"height"] intValue];
                layer.Type = [[attributeDict objectForKey:@"type"] intValue];
                layer.Align = [attributeDict objectForKey:@"align"];
                layer.Fontname = [attributeDict objectForKey:@"fontname"];
                layer.Fontsize = [[attributeDict objectForKey:@"fontsize"] intValue];
                layer.Fontcolor = [attributeDict objectForKey:@"fontcolor"];
                layer.Fonturl = [attributeDict objectForKey:@"fonturl"];
                layer.Calid = [attributeDict objectForKey:@"calid"];

                [page.layers addObject:layer];
            }
        }
    }
    else if ([elementName isEqualToString:@"monthnuminfo"]) {
        if (theme2_id.length > 0) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];

                layer.AreaType = 13;
                layer.PageIndex = page.idx;

                layer.X = [[attributeDict objectForKey:@"x"] intValue];
                layer.Y = [[attributeDict objectForKey:@"y"] intValue];
                layer.W = [[attributeDict objectForKey:@"width"] intValue];
                layer.H = [[attributeDict objectForKey:@"height"] intValue];
                layer.Type = [[attributeDict objectForKey:@"type"] intValue];
                layer.Align = [attributeDict objectForKey:@"align"];
                layer.Fontname = [attributeDict objectForKey:@"fontname"];
                layer.Fontsize = [[attributeDict objectForKey:@"fontsize"] intValue];
                layer.Fontcolor = [attributeDict objectForKey:@"fontcolor"];
                layer.Fonturl = [attributeDict objectForKey:@"fonturl"];
                layer.Calid = [attributeDict objectForKey:@"calid"];

                [page.layers addObject:layer];
            }
        }
    }
    else if ([elementName isEqualToString:@"dayinfo"]) {
        if (theme2_id.length > 0) {
            Page *page = [_pages lastObject];
            if (page != nil) {
                Layer *layer = [[Layer alloc] init];

                layer.AreaType = 14;
                layer.PageIndex = page.idx;

                layer.X = [[attributeDict objectForKey:@"x"] intValue];
                layer.Y = [[attributeDict objectForKey:@"y"] intValue];
                layer.W = [[attributeDict objectForKey:@"width"] intValue];
                layer.H = [[attributeDict objectForKey:@"height"] intValue];
                layer.Type = [[attributeDict objectForKey:@"type"] intValue];
                layer.Align = [attributeDict objectForKey:@"align"];
                layer.Fontname = [attributeDict objectForKey:@"fontname"];
                layer.Fontsize = [[attributeDict objectForKey:@"fontsize"] intValue];
                layer.Fontcolor = [attributeDict objectForKey:@"fontcolor"];
                layer.Holidaycolor = [attributeDict objectForKey:@"holidaycolor"];
                if(layer.Holidaycolor == nil || layer.Holidaycolor.length <= 0)
                    layer.Holidaycolor = [attributeDict objectForKey:@"holydaycolor"];
                layer.Fonturl = [attributeDict objectForKey:@"fonturl"];
                layer.Calid = [attributeDict objectForKey:@"calid"];
                layer.Anniversary = [attributeDict objectForKey:@"anniversary"];

                [page.layers addObject:layer];
            }
        }
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // 신규 달력 포맷 E
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    //    if ([_parsingElement isEqualToString:@"cartSession"]) {
    //    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //    _parsingElement = @"";
}

- (NSData *)saveData {
    NSMutableData *data = [[NSMutableData alloc] init];

    _TotalPageCount = [self getTotalPageCount];
    // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    if ([_ProductCode isEqualToString:@"300269"]) { // analogue photobook case...
        _TotalPageCount = 16;
    }
    else if ([_ProductCode isEqualToString:@"300270"]) {
        _TotalPageCount = 24;
    }
    else if ([_ProductCode isEqualToString:@"300267"]) {
        _TotalPageCount = 21;
    }

    [[Common info] appendString:_BasketName to:data];
    [[Common info] appendString:_ProductId to:data];
    [[Common info] appendString:_ProductCode to:data];
    [[Common info] appendString:_ProductOption1 to:data];
    [[Common info] appendString:_ProductOption2 to:data];
    [[Common info] appendString:_ExistCover to:data]; //
    [[Common info] appendString:_DefaultCover to:data]; //
    [[Common info] appendString:_ThemeName to:data];
    [[Common info] appendString:_DefaultStyle to:data];
    [[Common info] appendString:_ThemeHangulName to:data];
    [[Common info] appendString:_ProductName to:data]; //
    [[Common info] appendString:_ProductType to:data]; //
    [[Common info] appendString:_ProductSize to:data];
    [[Common info] appendInteger:_ProductPrice to:data];
    [[Common info] appendInteger:_DefaultProductPrice to:data];
    [[Common info] appendInteger:_PricePerPage to:data];
    [[Common info] appendInteger:_MinPage to:data];
    [[Common info] appendInteger:_MaxPage to:data];
    [[Common info] appendString:_CallStyles to:data]; //
    [[Common info] appendString:_Page_PoolLayout to:data]; //
    [[Common info] appendString:_Page_PoolSkin to:data]; //
    [[Common info] appendString:_Cover_PoolLayout to:data]; //
    [[Common info] appendString:_Cover_PoolSkin to:data]; //

    // SJYANG.2018.05 : 이동헌 대리님 옵션 처리
    if ([_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"] ||
        [_ProductCode isEqualToString:@"347063"] || // miniwallet
        [_ProductCode isEqualToString:@"347064"] || // division
        _product_type == PRODUCT_POSTER ||
        _product_type == PRODUCT_PAPERSLOGAN ||
        _product_type == PRODUCT_TRANSPARENTCARD ||
        _product_type == PRODUCT_DIVISIONSTICKER
		//|| _product_type == PRODUCT_CALENDAR
        ) {
        _AddParams = @"";
        _AddParams = [NSString stringWithFormat:@"%@", _AddVal1];
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal2];
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal3];
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal4];
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal5];
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal6];    // 옵션
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal7];    // 레이아웃 [Blackpink]
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal8];
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal9];
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal10];   // 1
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal11];   // 무광
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal12];   // 6.3cm x 17.7cm
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal13];   // defaultdepth1
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal14];   // 레이아웃 [Blackpink]
        _AddParams = [NSString stringWithFormat:@"%@$%@", _AddParams, _AddVal15];
        NSLog(@"saveData _AddParams : %@", _AddParams);
    }

    [[Common info] appendString:_AddParams to:data]; //
    [[Common info] appendBoolean:_Edited to:data];
    [[Common info] appendInteger:_TotalPageCount to:data];
    
    [[Common info] appendString:@"" to:data]; // empty slot aos editedspine value position
    
    [[Common info] appendString:_AddVal1 to:data]; // addval1
    [[Common info] appendString:_AddVal14 to:data]; // addval15
    [[Common info] appendString:_AddVal15 to:data]; // addval15
    
    if([Common info].photobook.depth1_key.length > 0  || [Common info].photobook.ProductType.length > 0 ){
        //photobook v2 append photobook info
        [[Common info] appendString:_depth1_key to:data];
        [[Common info] appendString:_depth2_key to:data];

        // 20 empty loop. change empty loop 18 add depth1_key and depth2_key
        //for (int i = 0; i < 18; i++) {
        
        // added editedspine,addval1,addval15
        for (int i = 0; i < 14; i++) {
            [[Common info] appendString:@"" to:data]; // empty slot
        }
    }else{
        // 20 empty loop. change empty loop 18 add depth1_key and depth2_key
        //for (int i = 0; i < 20; i++) {
        
        // added editedspine,addval1,addval15
        for (int i = 0; i < 16; i++) {
            [[Common info] appendString:@"" to:data]; // empty slot
        }
    }
    // save page
    [[Common info] appendInteger:(int)_pages.count to:data];
    for (Page *page in _pages) {
        [data appendData:[page saveData]];
    }
    return (NSData *)data;
}

- (BOOL)loadData:(NSData *)data IsHeaderOnly:(BOOL)is_headerOnly {
    int offset = 0;
    _BasketName = [[Common info] readString:data From:&offset];
    _ProductId = [[Common info] readString:data From:&offset];
    _ProductCode = [[Common info] readString:data From:&offset];
    _ProductOption1 = [[Common info] readString:data From:&offset];
    _ProductOption2 = [[Common info] readString:data From:&offset];
    _ExistCover = [[Common info] readString:data From:&offset];
    _DefaultCover = [[Common info] readString:data From:&offset];
    _ThemeName = [[Common info] readString:data From:&offset];
    _DefaultStyle = [[Common info] readString:data From:&offset];
    _ThemeHangulName = [[Common info] readString:data From:&offset];
    _ProductName = [[Common info] readString:data From:&offset];
    _ProductType = [[Common info] readString:data From:&offset];
    _ProductSize = [[Common info] readString:data From:&offset];
    _ProductPrice = [[[Common info] readString:data From:&offset] intValue];
    _DefaultProductPrice = [[[Common info] readString:data From:&offset] intValue];
    _PricePerPage = [[[Common info] readString:data From:&offset] intValue];
    _MinPage = [[[Common info] readString:data From:&offset] intValue];
    _MaxPage = [[[Common info] readString:data From:&offset] intValue];
    _CallStyles = [[Common info] readString:data From:&offset];
    _Page_PoolLayout = [[Common info] readString:data From:&offset];
    _Page_PoolSkin = [[Common info] readString:data From:&offset];
    _Cover_PoolLayout = [[Common info] readString:data From:&offset];
    _Cover_PoolSkin = [[Common info] readString:data From:&offset];
    _AddParams = [[Common info] readString:data From:&offset];

    // SJYANG.2018.05 : 이동헌 대리님 옵션 처리
    // cmh 2018.07.02 추가 - 포토카드 때문에 추가함
    if ([_ProductCode isEqualToString:@"347037"] || [_ProductCode isEqualToString:@"347036"] ||
        [_ProductCode isEqualToString:@"347063"] || // miniwallet
        [_ProductCode isEqualToString:@"347064"] || // division
        _product_type == PRODUCT_POSTER ||
        _product_type == PRODUCT_PAPERSLOGAN ||
        _product_type == PRODUCT_TRANSPARENTCARD ||
        _product_type == PRODUCT_DIVISIONSTICKER
		//|| _product_type == PRODUCT_CALENDAR
        ) {
        NSLog(@"loadData _AddParams : %@", _AddParams);
        NSArray *arrs = [_AddParams componentsSeparatedByString: @"$"];
        if(arrs.count > 0) _AddVal1 = [arrs objectAtIndex:0];
        if(arrs.count > 1) _AddVal2 = [arrs objectAtIndex:1];
        if(arrs.count > 2) _AddVal3 = [arrs objectAtIndex:2];
        if(arrs.count > 3) _AddVal4 = [arrs objectAtIndex:3];
        if(arrs.count > 4) _AddVal5 = [arrs objectAtIndex:4];
        if(arrs.count > 5) _AddVal6 = [arrs objectAtIndex:5];
        if(arrs.count > 6) _AddVal7 = [arrs objectAtIndex:6];
        if(arrs.count > 7) _AddVal8 = [arrs objectAtIndex:7];
        if(arrs.count > 8) _AddVal9 = [arrs objectAtIndex:8];
        if(arrs.count > 9) _AddVal10 = [arrs objectAtIndex:9];
        if(arrs.count > 10) _AddVal11 = [arrs objectAtIndex:10];
        if(arrs.count > 11) _AddVal12 = [arrs objectAtIndex:11];
        if(arrs.count > 12) _AddVal13 = [arrs objectAtIndex:12];
        if(arrs.count > 13) _AddVal14 = [arrs objectAtIndex:13];
		if(arrs.count > 14) _AddVal15 = [arrs objectAtIndex:14];

        [Common info].photobook.tmpAddVal6 = _AddVal6;
        [Common info].photobook.tmpAddVal10 = _AddVal10;
        [Common info].photobook.tmpAddVal11 = _AddVal11;
        [Common info].photobook.tmpAddVal12 = _AddVal12;
        [Common info].photobook.tmpAddVal13 = _AddVal13;
        [Common info].photobook.tmpAddVal14 = _AddVal14;

        NSLog(@"_AddVal9 : %@", _AddVal9);
        NSLog(@"_AddVal10 : %@", _AddVal10);
        NSLog(@"_AddVal11 : %@", _AddVal11);
    }

    _Edited = [[[Common info] readString:data From:&offset] boolValue];
    _TotalPageCount = [[[Common info] readString:data From:&offset] intValue];
    
    _product_type = [self productType:_ProductCode];
    if (_product_type == PRODUCT_UNKNOWN) {
        return FALSE;
    }
    _BasketName = [self migrationBasketName:_BasketName FromProductID:_ProductId];

    //if (is_headerOnly) return;
    NSString *dummy = @"";
    
    dummy = [[Common info] readString:data From:&offset]; // empty slot aos editedspine value position
     
    _AddVal1 = [[Common info] readString:data From:&offset]; // addval1
    _AddVal14 = [[Common info] readString:data From:&offset]; // addval14
    _AddVal15 = [[Common info] readString:data From:&offset]; // addval15
    
    //photobook v2 append photobook info
    if([Common info].photobook.depth1_key.length > 0  || [Common info].photobook.ProductType.length > 0 ){
        _depth1_key = [[Common info] readString:data From:&offset];
        _depth2_key = [[Common info] readString:data From:&offset];
        
        // 20 empty loop. change empty loop 18 add depth1_key and depth2_key
        //for (int i = 0; i < 18; i++) {
        
        // added editedspine,addval1,addval14,addval15
        for (int i = 0; i < 14; i++) {
            dummy = [[Common info] readString:data From:&offset];
        }
    }else{
        //for (int i = 0; i < 20; i++) {
        
        // added editedspine,addval1,addval14,addval15
        for (int i = 0; i < 16; i++) {
            dummy = [[Common info] readString:data From:&offset];
        }
    }

    
    // load page
    [_pages removeAllObjects];
    int page_count = [[[Common info] readString:data From:&offset] intValue];
    for (int i = 0; i < page_count; i++) {
        Page *page = [[Page alloc] init];
        [_pages addObject:page];

        [page loadData:data From:&offset];
        _page_rect = CGRectMake(0, 0, page.PageWidth, page.PageHeight); // 마지막 페이지 정보만 기억하면 ok.

        if (is_headerOnly) { // 보관함 목록에서는 전부 읽을 필요가 없다. 커버페이지까지만 읽는다. (책 제목 정보 확인을 위해)
            _title = [self getBookTitle];
            break;
        }
    }
    NSLog(@"end of loadData !!!");
    return TRUE;
}

- (NSString *)migrationBasketName:(NSString *)basketname FromProductID:(NSString *)product_id {
    // 이전 basketname: [포토북] 8x8 포토북 61P -> 2015-12-16 14:33:03 형식으로 변경.
    NSString *temp = [basketname substringWithRange:NSMakeRange(0, 1)];
    if ([temp isEqualToString:@"["]) {
        NSString *year = [product_id substringWithRange:NSMakeRange(0, 2)];
        NSString *month = [product_id substringWithRange:NSMakeRange(2, 2)];
        NSString *day = [product_id substringWithRange:NSMakeRange(4, 2)];
        NSString *hour = [product_id substringWithRange:NSMakeRange(6, 2)];
        NSString *minute = [product_id substringWithRange:NSMakeRange(8, 2)];
        NSString *second = [product_id substringWithRange:NSMakeRange(10, 2)];

        NSString *new_basketname = [NSString stringWithFormat:@"20%@-%@-%@ %@:%@:%@", year, month, day, hour, minute, second];
        return new_basketname;
    }
    return basketname;
}

- (void)clearAddVal {
    _AddVal1 = @"";
    _AddVal2 = @"";
    _AddVal3 = @"";
    _AddVal4 = @"";
    _AddVal5 = @"";
    _AddVal6 = @"";
    _AddVal7 = @"";
    _AddVal8 = @"";
    _AddVal9 = @"";
    _AddVal10 = @"";
    _AddVal11 = @"";
    _AddVal12 = @"";
    _AddVal13 = @"";
    _AddVal14 = @"";
    _AddVal15 = @"";
}

// 2017.11.16 : SJYANG : 포토북에 에러가 없는지 확인하는 함수
- (BOOL)isValid {
    /*
    if(TRUE)
        return TRUE;
    */

    for (Page *page in _pages) {
        for (Layer *layer in page.layers) {
            {
                NSString* filePath = [NSString stringWithFormat:@"%@/org/%@", _base_folder, layer.ImageFilename];
                if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
                    NSLog(@"!!! org_image not exists : %@", filePath);
                    layer.ImageEditname = @"";
                    layer.ImageFilename = @"";
                    return FALSE;
                }
            }

            if (layer.ImageEditname.length > 0) {
                if (layer.edit_image == nil) {
                    if (layer.ImageCropW <= 0 || layer.ImageCropH <= 0) {
                        NSString* filePath = [NSString stringWithFormat:@"%@/edit/%@", _base_folder, layer.ImageEditname];
                        NSLog(@"!!! edit_image : %@", filePath);
                        if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
                            NSLog(@"!!! edit_image not exists");
                            layer.ImageEditname = @"";
                            layer.ImageFilename = @"";
                            return FALSE;
                        }
                    }
                }
            }
        }
    }
    return TRUE;
}



// SJYANG : 2018 달력 : 테스트용 함수
- (UIImage *)imageWithRoundedCornersSize:(CGFloat)cornerRadius usingImage:(UIImage *)original
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:original];

    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);

    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                            cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:imageView.bounds];

    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();

    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();

    return imageView.image;
}

- (UIImage *)imageWithBorderAndRoundCornersWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius {
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
    CGRect rect = CGRectZero;
    rect.size = image.size;
    CGRect pathRect = CGRectInset(rect, lineWidth / 2.0, lineWidth / 2.0);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:cornerRadius];

    CGContextBeginPath(context);
    CGContextAddPath(context, path.CGPath);
    CGContextClosePath(context);
    CGContextClip(context);

    [image drawAtPoint:CGPointZero];

    CGContextRestoreGState(context);

    [[UIColor whiteColor] setStroke];
    path.lineWidth = lineWidth;
    [path stroke];

    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return finalImage;
}



-(NSString *)description {
    NSString *str = [NSString stringWithFormat:@"Photobook : (BasketName : %@)", self.BasketName];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductId : %@)", self.ProductId]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductCode : %@)", self.ProductCode]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductOption1 : %@)", self.ProductOption1]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductOption2 : %@)", self.ProductOption2]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ExistCover : %@)", self.ExistCover]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(DefaultCover : %@)", self.DefaultCover]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ThemeName : %@)", self.ThemeName]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(DefaultStyle : %@)", self.DefaultStyle]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ThemeHangulName : %@)", self.ThemeHangulName]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductName : %@)", self.ProductName]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductType : %@)", self.ProductType]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductSize : %@)", self.ProductSize]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(CallStyles : %@)", self.CallStyles]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Page_PoolLayout : %@)", self.Page_PoolLayout]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Page_PoolSkin : %@)", self.Page_PoolSkin]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Cover_PoolLayout : %@)", self.Cover_PoolLayout]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Cover_PoolSkin : %@)", self.Cover_PoolSkin]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddParams : %@)", self.AddParams]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ScodixParams : %@)", self.ScodixParams]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Size : %@)", self.Size]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(Color : %@)", self.Color]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal1 : %@)", self.AddVal1]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal2 : %@)", self.AddVal2]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal3 : %@)", self.AddVal3]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal4 : %@)", self.AddVal4]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal5 : %@)", self.AddVal5]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal6 : %@)", self.AddVal6]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal7 : %@)", self.AddVal7]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal8 : %@)", self.AddVal8]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal9 : %@)", self.AddVal9]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal10 : %@)", self.AddVal10]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal11 : %@)", self.AddVal11]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal12 : %@)", self.AddVal12]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal13 : %@)", self.AddVal13]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal14 : %@)", self.AddVal14]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(AddVal15 : %@)", self.AddVal15]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(tmpAddVal6 : %@)", self.tmpAddVal6]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(tmpAddVal10 : %@)", self.tmpAddVal10]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(tmpAddVal11 : %@)", self.tmpAddVal11]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(tmpAddVal12 : %@)", self.tmpAddVal12]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(tmpAddVal13 : %@)", self.tmpAddVal13]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(tmpAddVal14 : %@)", self.tmpAddVal14]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(ProductPrice : %i)", self.ProductPrice]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(DefaultProductPrice : %i)", self.DefaultProductPrice]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(PricePerPage : %i)", self.PricePerPage]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(MinPage : %i)", self.MinPage]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(MaxPage : %i)", self.MaxPage]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(TotalPageCount : %i)", self.TotalPageCount]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(realPageMarginX : %i)", self.realPageMarginX]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(realPageWidth : %i)", self.realPageWidth]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(realPageHeight : %i)", self.realPageHeight]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(pageViewWidth : %f)", self.pageViewWidth]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(pageViewHeight : %f)", self.pageViewHeight]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(product_type : %i)", self.product_type]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(minpictures : %i)", self.minpictures]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(start_year : %i)", self.start_year]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(start_month : %i)", self.start_month]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(scale_factor : %f)", self.scale_factor]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"(edit_scale : %f)", self.edit_scale]];

    str = [str stringByAppendingString:[NSString stringWithFormat:@"(pages : %@)", self.pages]];



    return str;
}

- (UIImage *)resizeImage:(UIImage *)image convertToSize:(CGSize)size {
	//UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

// 신규 달력 포맷
- (void)drawCalendarText:(NSString *)text withPage:(Page *)page withLayer:(Layer *)layer inView:(UIImageView *)layerview withHScale:(CGFloat)h_scale withVScale:(CGFloat)v_scale {

    CGFloat x = 0;
    CGFloat y = 0;

    UIImage* image = [self resizeImage:[UIImage imageNamed:@"transparent.png"] convertToSize:CGSizeMake(layer.W*h_scale, layer.H*v_scale)];
    UIFont *font = nil;

	// 2018.11.19
    if(layer.Fontname != nil && layer.Fontname.length > 0 && [_fonts objectForKey:layer.Fontname] != nil) {
        font = [UIFont fontWithName:[_fonts objectForKey:layer.Fontname] size:_FONT_SIZE_RATIO * layer.Fontsize * v_scale];
	}
    if(font == nil) {
        font = [UIFont systemFontOfSize:_FONT_SIZE_RATIO * layer.Fontsize * v_scale weight:UIFontWeightRegular];
		NSLog(@"LOADING FONT : %@ FAILED", [_fonts objectForKey:layer.Fontname]);
	}

    UIColor* fontColor = [self fromArgbString:layer.Fontcolor];
    NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: fontColor};

	CGSize textSize = [text sizeWithAttributes:attr];

	// 2018.11.19
	UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);

    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];

	// 2018.11.18
	//CGFloat topPadding = ceilf(font.ascender - font.capHeight + 1);
	CGFloat topPadding = font.ascender - font.capHeight + 1;

	y = topPadding;

	// 2018.11.19
	/*
    if([layer.Align isEqualToString:@"center"]) {
        x = (layer.W * scale - textSize.width) / 2.f;
        [text drawAtPoint:CGPointMake(x, y) withAttributes:attr];
    }
    else if([layer.Align isEqualToString:@"right"]) {
        x = layer.W * scale - textSize.width;
        [text drawAtPoint:CGPointMake(x, y) withAttributes:attr];
    }
    else
        [text drawAtPoint:CGPointMake(x, y) withAttributes:attr];
	*/
    if([layer.Align isEqualToString:@"center"]) {
        x = (layer.W * h_scale - textSize.width) / 2.f;
        [text drawAtPoint:CGPointMake(round(x), round(y)) withAttributes:attr];
    }
    else if([layer.Align isEqualToString:@"right"]) {
        x = layer.W * h_scale - textSize.width;
        [text drawAtPoint:CGPointMake(round(x), round(y)) withAttributes:attr];
    }
    else
        [text drawAtPoint:CGPointMake(round(x), round(y)) withAttributes:attr];

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    layerview.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    layerview.contentMode = UIViewContentModeScaleAspectFill;
    layerview.image = image;
}

// 신규 달력 포맷
- (int)getNumberOfWeeks:(int)givenYear withMonth:(int)givenMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];

    [components setYear:givenYear];
    [components setMonth:givenMonth];

    NSDate *date = [calendar dateFromComponents:components];
    NSRange weekRange = [calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    int weeksCount=(int)weekRange.length;
    return weeksCount;
}

// 신규 달력 포맷
- (int)getFirstDayOfWeek:(int)givenYear withMonth:(int)givenMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];

    [components setYear:givenYear];
    [components setMonth:givenMonth];

    NSDate *date = [calendar dateFromComponents:components];
    int weekDay = (int)[[calendar components:NSWeekdayCalendarUnit fromDate:date] weekday];

    return weekDay;
}

// 신규 달력 포맷
- (int)getDayOfWeek:(int)givenYear withMonth:(int)givenMonth withDay:(int)givenDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];

    [components setYear:givenYear];
    [components setMonth:givenMonth];
    [components setDay:givenDay];

    NSDate *date = [calendar dateFromComponents:components];
    int weekDay = (int)[[calendar components:NSWeekdayCalendarUnit fromDate:date] weekday];

    return weekDay;
}

// 신규 달력 포맷
- (int)getLastDayOfMonth:(int)givenYear withMonth:(int)givenMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];

    [components setYear:givenYear];
    [components setMonth:givenMonth];

    NSDate *date = [calendar dateFromComponents:components];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];

    return (int)range.length;
}

// 신규 달력 포맷
- (UIColor*)fromArgbString:(NSString*)argbStr {
    UIColor *color = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1];

    @try {
        NSArray *strs = [argbStr componentsSeparatedByString:@","];
        float a = [[strs objectAtIndex:0] floatValue];
        float r = [[strs objectAtIndex:1] floatValue];
        float g = [[strs objectAtIndex:2] floatValue];
        float b = [[strs objectAtIndex:3] floatValue];

        return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
    }
    @catch (NSException *e) {
    }
    return color;
}

// 신규 달력 포맷 : 마스킹
- (UIImage*)transactFrameInfoBitmap:(UIImage*)myImage {
    CGImageRef originalImage    = [myImage CGImage];
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext  =
        CGBitmapContextCreate(NULL,CGImageGetWidth(originalImage),CGImageGetHeight(originalImage),
        8,CGImageGetWidth(originalImage)*4,colorSpace,kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0,
        CGBitmapContextGetWidth(bitmapContext),CGBitmapContextGetHeight(bitmapContext)),
        originalImage);
    UInt8 *data          = CGBitmapContextGetData(bitmapContext);
    int numComponents    = 4;
    int bytesInContext   = (int)(CGBitmapContextGetHeight(bitmapContext) * CGBitmapContextGetBytesPerRow(bitmapContext));

    CGFloat whiteRed = 1, whiteGreen = 1, whiteBlue = 1, whiteAlpha = 1;
    CGFloat redRed = 1, redGreen = 0, redBlue = 0, redAlpha = 1;
    CGFloat clearRed = 0, clearGreen = 0, clearBlue = 0, clearAlpha = 0;

    for (int i = 0; i < bytesInContext; i += numComponents) {
        BOOL whiteChanged = NO;
        if( (double)data[i]/255.0 == whiteRed && (double)data[i+1]/255.0 == whiteGreen && (double)data[i+2]/255.0 == whiteBlue && (double)data[i+3]/255.0 == whiteAlpha ) {

            data[i]    =   redRed * 255;
            data[i+1]  =   redGreen * 255;
            data[i+2]  =   redBlue * 255;
            data[i+3]  =   redAlpha * 255;

            whiteChanged = YES;
        }

		/*
        if( (double)data[i]/255.0 == clearRed && (double)data[i+1]/255.0 == clearGreen && (double)data[i+2]/255.0 == clearBlue && (double)data[i+3]/255.0 == clearAlpha ) {
            data[i]    =   whiteRed * 255;
            data[i+1]  =   whiteGreen * 255;
            data[i+2]  =   whiteBlue * 255;
            data[i+3]  =   whiteAlpha * 255;
        }
		*/

        if( whiteChanged && (double)data[i]/255.0 == redRed && (double)data[i+1]/255.0 == redGreen && (double)data[i+2]/255.0 == redBlue && (double)data[i+3]/255.0 == redAlpha ) {
            data[i]    =   clearRed * 255;
            data[i+1]  =   clearGreen * 255;
            data[i+2]  =   clearBlue * 255;
            data[i+3]  =   clearAlpha * 0;
        }
    }

    CGImageRef outImage =   CGBitmapContextCreateImage(bitmapContext);
    myImage             =   [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return myImage;
}

// 마그넷 : 이미지 마스킹 처리
- (UIImage*)maskImage:(UIImage*)myImage {
    CGImageRef originalImage    = [myImage CGImage];
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext  =
        CGBitmapContextCreate(NULL,CGImageGetWidth(originalImage),CGImageGetHeight(originalImage),
        8,CGImageGetWidth(originalImage)*4,colorSpace,kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0,
        CGBitmapContextGetWidth(bitmapContext),CGBitmapContextGetHeight(bitmapContext)),
        originalImage);
    UInt8 *data          = CGBitmapContextGetData(bitmapContext);
    int numComponents    = 4;
    int bytesInContext   = (int)(CGBitmapContextGetHeight(bitmapContext) * CGBitmapContextGetBytesPerRow(bitmapContext));

    CGFloat whiteRed = 1, whiteGreen = 1, whiteBlue = 1, whiteAlpha = 1;
    CGFloat redRed = 1, redGreen = 0, redBlue = 0, redAlpha = 1;
    CGFloat clearRed = 0, clearGreen = 0, clearBlue = 0, clearAlpha = 0;

    for (int i = 0; i < bytesInContext; i += numComponents) {
        if( (double)data[i]/255.0 == clearRed && (double)data[i+1]/255.0 == clearGreen && (double)data[i+2]/255.0 == clearBlue && (double)data[i+3]/255.0 == clearAlpha ) {
            data[i]    =   whiteRed * 255;
            data[i+1]  =   whiteGreen * 255;
            data[i+2]  =   whiteBlue * 255;
            data[i+3]  =   whiteAlpha * 255;
        }
		else {
            data[i]    =   clearRed * 255;
            data[i+1]  =   clearGreen * 255;
            data[i+2]  =   clearBlue * 255;
            data[i+3]  =   clearAlpha * 0;
        }
    }

    CGImageRef outImage =   CGBitmapContextCreateImage(bitmapContext);
    myImage             =   [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return myImage;
}

// 신규 달력 포맷 : 기념일 로드
- (void)loadMemoriayDays {
    _memorialDays = [[NSMutableArray alloc] init];
    _holidays = [[NSMutableDictionary alloc] init];
    _memorials = [[NSMutableDictionary alloc] init];
    if (_product_type == PRODUCT_CALENDAR) {
        @try {
            NSError *error;
            NSData *jsonData = [NSData dataWithContentsOfURL: [NSURL URLWithString:URL_CALENDAR_MEMORIAL_DAYS]];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:kNilOptions
                                                                   error:&error];
            NSArray *jsonArray = [jsonDict objectForKey:@"memorial_days"];
            for(NSDictionary *item in jsonArray) {
                MemorialDay *memorialDay = [[MemorialDay alloc] init];
                memorialDay.type = [item objectForKey:@"type"];
                memorialDay.date = [item objectForKey:@"date"];
                memorialDay.title = [item objectForKey:@"title"];
                memorialDay.lunar = [item objectForKey:@"lunar"];
                memorialDay.data = [item objectForKey:@"data"];
                [_memorialDays addObject:memorialDay];
            }
        }
        @catch (NSException *e) {
            NSLog(@"MEMORIAL_DAYS : %@", e);
        }
        for (MemorialDay *memorialDay in _memorialDays)
        {
            [_memorials setObject:memorialDay forKey:memorialDay.date];
            if([memorialDay.type isEqualToString:@"holiday"])
                [_holidays setObject:memorialDay forKey:memorialDay.date];
        }
    }
}

// 신규 달력 포맷 : 폰트 로드
- (void)loadFonts {
    for (NSString* fontUrl in _fontUrls) {
		NSString *fontFileName = [[Common info] makeMD5Hash:fontUrl];
		NSURL *url = [NSURL URLWithString:fontUrl];

		CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef) url);
		CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
		CGDataProviderRelease(fontDataProvider);
		CFErrorRef error = nil;
		if(CTFontManagerUnregisterGraphicsFont(newFont, &error)) {
			NSLog(@"FONT :: Unregister Success");
		}
		else {
			NSLog(@"FONT :: Unregister Fail");
		}

		CGFontRelease(newFont);
	}
	[_fonts removeAllObjects];
	[_fontUrls removeAllObjects];

    for (int i = 0; i < _pages.count; i++) {
        Page *page = _pages[i];
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 11 || layer.AreaType == 12 || layer.AreaType == 13 || layer.AreaType == 14) {
                NSString *fontName = layer.Fontname;
                NSString *fontUrl = layer.Fonturl;

                if (fontUrl != nil && fontUrl.length > 0) {
                    if(![_fontUrls containsObject: fontUrl]) {
                        NSString *fontFileName = [[Common info] makeMD5Hash:fontUrl];

                        NSURL *url = [NSURL URLWithString:fontUrl];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/fonts/%@", _base_folder, fontFileName];
                        [[Common info] downloadFile:url ToFile:localpathname];


						// 2018.11.19
                        NSURL *fonturl = [NSURL fileURLWithPath:localpathname];
                        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fonturl);
						/*
						NSData *fontdata = [[NSFileManager defaultManager] contentsAtPath:localpathname];
						CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontdata);
						*/

                        CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
                        NSString * newFontName = (__bridge NSString *)CGFontCopyPostScriptName(newFont);
                        CGDataProviderRelease(fontDataProvider);
                        CFErrorRef fonterror;
                        if(CTFontManagerRegisterGraphicsFont(newFont, &fonterror)) {
							NSLog(@"FONT :: Register Success");
	                        [_fontUrls addObject: fontUrl];
						}
						else {
							NSLog(@"FONT :: Register Fail");
						}

                        if(newFontName != nil) {
                            if([_fonts objectForKey:layer.Fontname] == nil) {
                                [_fonts setObject:newFontName forKey:layer.Fontname];
                            }
                        }

                        CGFontRelease(newFont);
                    }
                }
            }else if (layer.AreaType == 2 && _product_type == PRODUCT_PHOTOBOOK ) {
                NSString *fontName = layer.TextFontname;
                NSString *fontUrl = layer.TextFontUrl;
                
                if (fontUrl != nil && fontUrl.length > 0) {
                    if(![_fontUrls containsObject: fontUrl]) {
                        NSString *fontFileName = [[Common info] makeMD5Hash:fontUrl];
                        
                        NSURL *url = [NSURL URLWithString:fontUrl];
                        NSString *localpathname = [NSString stringWithFormat:@"%@/fonts/%@", _base_folder, fontFileName];
                        [[Common info] downloadFile:url ToFile:localpathname];
                        
                        
                        // 2018.11.19
                        NSURL *fonturl = [NSURL fileURLWithPath:localpathname];
                        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fonturl);
                        /*
                         NSData *fontdata = [[NSFileManager defaultManager] contentsAtPath:localpathname];
                         CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontdata);
                         */
                        
                        CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
                        NSString * newFontName = (__bridge NSString *)CGFontCopyPostScriptName(newFont);
                        CGDataProviderRelease(fontDataProvider);
                        CFErrorRef fonterror;
                        if(CTFontManagerRegisterGraphicsFont(newFont, &fonterror)) {
                            NSLog(@"FONT :: Register Success");
                            [_fontUrls addObject: fontUrl];
                        }
                        else {
                            NSLog(@"FONT :: Register Fail");
                        }
                        
                        if(newFontName != nil) {
                            if([_fonts objectForKey:fontName] == nil) {
                                [_fonts setObject:newFontName forKey:fontName];
                            }
                        }
                        
                        CGFontRelease(newFont);
                    }
                }
            }
        }
    }
}

// 신규 달력 포맷 : 마스킹
- (BOOL)isOuterAlphaImage:(UIImage*)myImage {
    CGImageRef originalImage    = [myImage CGImage];
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext  =
        CGBitmapContextCreate(NULL,CGImageGetWidth(originalImage),CGImageGetHeight(originalImage),
        8,CGImageGetWidth(originalImage)*4,colorSpace,kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0,
        CGBitmapContextGetWidth(bitmapContext),CGBitmapContextGetHeight(bitmapContext)),
        originalImage);
    UInt8 *data          = CGBitmapContextGetData(bitmapContext);
    int numComponents    = 4;
    int bytesInContext   = (int)(CGBitmapContextGetHeight(bitmapContext) * CGBitmapContextGetBytesPerRow(bitmapContext));

    CGFloat clearRed = 0, clearGreen = 0, clearBlue = 0, clearAlpha = 0;

    for (int i = 0; i < bytesInContext; i += numComponents) {
        if( (double)data[i]/255.0 == clearRed && (double)data[i+1]/255.0 == clearGreen && (double)data[i+2]/255.0 == clearBlue && (double)data[i+3]/255.0 == clearAlpha ) {
			return YES;
        }
		if(i > myImage.size.width)
			break;
    }
	return NO;
}

// 마그넷 : guideline : 아웃라인 그리기
- (UIImage*)outlineMaskBitmap:(UIImage*)myImage withR:(int)dstColorR withG:(int)dstColorG withB:(int)dstColorB withA:(int)dstColorA {
    CGImageRef originalImage    = [myImage CGImage];
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext  =
        CGBitmapContextCreate(NULL,CGImageGetWidth(originalImage),CGImageGetHeight(originalImage),
        8,CGImageGetWidth(originalImage)*4,colorSpace,kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(bitmapContext, CGRectMake(0, 0,
        CGBitmapContextGetWidth(bitmapContext),CGBitmapContextGetHeight(bitmapContext)),
        originalImage);
    UInt8 *data          = CGBitmapContextGetData(bitmapContext);
    int numComponents    = 4;
    int bytesInContext   = (int)(CGBitmapContextGetHeight(bitmapContext) * CGBitmapContextGetBytesPerRow(bitmapContext));

    int srcColorR = 255, srcColorG = 255, srcColorB = 255, srcColorA = 255;

	int width = myImage.size.width;
	int height = myImage.size.height;

	for (int y = 0; y < myImage.size.height; ++y) {
        for (int x = 0; x < myImage.size.width; ++x) {
			int index = y * width * 4 + x * 4;
			int index1 = (y + 1) * width * 4 + (x + 1) * 4;
			int index2 = (y + 1) * width * 4 + (x - 1) * 4;
			int index3 = (y - 1) * width * 4 + (x + 1) * 4;
			int index4 = (y - 1) * width * 4 + (x - 1) * 4;

			if (index1 >= 0 && index1 < width * height * 4 && (data[index1] == srcColorR && data[index1 + 1] == srcColorG && data[index1 + 2] == srcColorB && data[index1 + 3] == srcColorA) && !(data[index] == srcColorR && data[index + 1] == srcColorG && data[index + 2] == srcColorB && data[index + 3] == srcColorA)) {
				data[index] = dstColorR;
				data[index + 1] = dstColorG;
				data[index + 2] = dstColorB;
				data[index + 3] = dstColorA;
			}
			if (index2 >= 0 && index2 < width * height * 4 && (data[index2] == srcColorR && data[index2 + 1] == srcColorG && data[index2 + 2] == srcColorB && data[index2 + 3] == srcColorA) && !(data[index] == srcColorR && data[index + 1] == srcColorG && data[index + 2] == srcColorB && data[index + 3] == srcColorA)) {
				data[index] = dstColorR;
				data[index + 1] = dstColorG;
				data[index + 2] = dstColorB;
				data[index + 3] = dstColorA;
			}
			if (index3 >= 0 && index3 < width * height * 4 && (data[index3] == srcColorR && data[index3 + 1] == srcColorG && data[index3 + 2] == srcColorB && data[index3 + 3] == srcColorA) && !(data[index] == srcColorR && data[index + 1] == srcColorG && data[index + 2] == srcColorB && data[index + 3] == srcColorA)) {
				data[index] = dstColorR;
				data[index + 1] = dstColorG;
				data[index + 2] = dstColorB;
				data[index + 3] = dstColorA;
			}
			if (index4 >= 0 && index4 < width * height * 4 && (data[index4] == srcColorR && data[index4 + 1] == srcColorG && data[index4 + 2] == srcColorB && data[index4 + 3] == srcColorA) && !(data[index] == srcColorR && data[index + 1] == srcColorG && data[index + 2] == srcColorB && data[index + 3] == srcColorA)) {
				data[index] = dstColorR;
				data[index + 1] = dstColorG;
				data[index + 2] = dstColorB;
				data[index + 3] = dstColorA;
			}
			if ((x == 0 || x == width - 1 || y == 0 || y == height - 1) && (data[index] == srcColorR && data[index + 1] == srcColorG && data[index + 2] == srcColorB && data[index + 3] == srcColorA)) {
				data[index] = dstColorR;
				data[index + 1] = dstColorG;
				data[index + 2] = dstColorB;
				data[index + 3] = dstColorA;
			}
		}
	}
	for (int y = 0; y < myImage.size.height; ++y) {
        for (int x = 0; x < myImage.size.width; ++x) {
			int index = y * width * 4 + x * 4;

			if (data[index] == srcColorR && data[index + 1] == srcColorG && data[index + 2] == srcColorB && data[index + 2] == srcColorA) {
				data[index] = 0;
				data[index + 1] = 0;
				data[index + 2] = 0;
				data[index + 3] = 0;
			}
		}
	}

    CGImageRef outImage =   CGBitmapContextCreateImage(bitmapContext);
    myImage             =   [UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return myImage;
}

#pragma mark - PhotoContainer
// 테스트후 addPhoto를 내리자.
- (BOOL)addPhotoNew:(PhotoItem *)item Layer:(Layer *)layer PickIndex:(int)pick_index {
	BOOL is_debug = NO;
	
	if (item != nil && layer != nil){
		if (item.positionType == PHOTO_POSITION_LOCAL) {
			LocalItem *photo = (LocalItem *)item;
			if(is_debug) NSLog(@"addPhoto #001");
			if (photo != nil && layer != nil) {
				__block UIImageOrientation ph_orientation = UIImageOrientationUp;
				
				if(is_debug) NSLog(@"addPhoto #002");
				NSString *time_str = [[Common info] timeStringEx];
				NSString *filename = [NSString stringWithFormat:@"%04d.jpg", pick_index];
				
				int randnum = arc4random() % 100;
				NSString *org_filename = [NSString stringWithFormat:@"%@_%03d_%@", time_str, randnum, filename];
				__block NSString *org_pathname = [NSString stringWithFormat:@"%@/org/%@", _base_folder, org_filename];
				
				if(is_debug) NSLog(@"addPhoto #003");
				layer.Filename = @"";
				layer.ImageFilename = org_filename;
				layer.ImageEditname = [NSString stringWithFormat:@"_%@", org_filename];
				if(is_debug) NSLog(@"addPhoto:%@", layer.ImageFilename);
				
				CGFloat rotate = 0;
				UIImage *org_image = nil;
				
				layer.ImageR = 0;
				
				@autoreleasepool
				{
					// HEIF Fix
					@autoreleasepool
					{
						__block NSData *org_data;
						__block NSData *org_data_as_heif;
						
						{
							PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
							options.networkAccessAllowed = YES;
							options.synchronous = YES;
							
							if(is_debug) NSLog(@"addPhoto #004");
							[[PHImageManager defaultManager] requestImageDataForAsset:photo.photo.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
								if(is_debug) NSLog(@"addPhoto #004-1");
								if(![[PHAssetUtility info] isHEIF:photo.photo.asset])
									org_data = [imageData copy];
								if(is_debug) NSLog(@"addPhoto #004-2");
								ph_orientation = orientation;
								//NSLog(@"info : %@", info);
								if(is_debug) NSLog(@"addPhoto : [PHImageManager defaultManager] requestImageDataForAsset");
							}];
						}
						
						if([[PHAssetUtility info] isHEIF:photo.photo.asset]) {
							if(is_debug) NSLog(@"addPhoto : PRE getFastJpegImageDataForAsset");
							org_data_as_heif = [[PHAssetUtility info] getFastJpegImageDataForAsset:photo.photo.asset];
							if(is_debug) NSLog(@"addPhoto : [[PHAssetUtility info] isHEIF:photo.asset] #1");
							
							[photo.photo.asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
								@synchronized(self) {
									if (contentEditingInput.fullSizeImageURL) {
										// 2017.11.16 : SJYANG : @autoreleasepool 추가
										@autoreleasepool
										{
											if(is_debug) NSLog(@"addPhoto : [[PHAssetUtility info] isHEIF:photo.asset] #2");
											CIImage *ciImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
											CIContext *context = [CIContext context];
											NSData* jpgData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
											[jpgData writeToFile:org_pathname atomically:YES];
											if(is_debug) NSLog(@"addPhoto : [[PHAssetUtility info] isHEIF:photo.asset] #3");
										}
									}
								}
							}];
						}
						else {
							[org_data writeToFile:org_pathname atomically:YES];
						}
						
						rotate = 0; // 원본 회전 정보
						
						switch (ph_orientation) {
							case UIImageOrientationUp:    // 0도, 기본값.
							case UIImageOrientationUpMirrored:
								break;
							case UIImageOrientationLeft:  // 90도
							case UIImageOrientationLeftMirrored:
								rotate = 90;
								break;
							case UIImageOrientationRight: // -90도
							case UIImageOrientationRightMirrored:
								rotate = -90;
								break;
							case UIImageOrientationDown:  // 180도
							case UIImageOrientationDownMirrored:
								rotate = 180;
								break;
							default:
								break;
						}
						if(is_debug) NSLog(@"addPhoto #005");
						
						if(org_data != nil)
							org_image = [UIImage imageWithData:org_data];
						else {
							if(org_data_as_heif != nil)
								org_image = [UIImage imageWithData:org_data_as_heif];
						}
					}
					
					CGFloat scale = 1.0f;
					int min_side = (int)MIN(org_image.size.width, org_image.size.height);
					if (min_side > 480) {
						scale = 480.0f / (CGFloat)min_side;
					}
					
					CGSize image_size = CGSizeMake(org_image.size.width * scale, org_image.size.height * scale);
					CGSize canvas_size = image_size;
					if (rotate == 90 || rotate == -90) {
						canvas_size = CGSizeMake(image_size.height, image_size.width);
					}
					
					//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					UIGraphicsBeginImageContext(canvas_size);
					
					if(is_debug) NSLog(@"addPhoto #006");
					CGContextRef context = UIGraphicsGetCurrentContext();
					
					CGContextTranslateCTM(context, canvas_size.width/2, canvas_size.height/2);
					CGContextRotateCTM(context, rotate * M_PI/180);
					
					// mirrored image flip or flop............................................
					switch (ph_orientation) {
						case UIImageOrientationUpMirrored:
						case UIImageOrientationDownMirrored:
							CGContextScaleCTM(context, -1, 1);
							break;
						case UIImageOrientationLeftMirrored:
						case UIImageOrientationRightMirrored:
							CGContextScaleCTM(context, 1, -1);
							break;
						default:
							break;
					} // mirrored image flip or flop..........................................
					
					CGContextTranslateCTM(context, -image_size.width/2, -image_size.height/2);
					
					// org_image 가 쓰이는 부분은 여기까지...
					[org_image drawInRect:CGRectMake(0, 0, image_size.width, image_size.height)];
					
					if(is_debug) NSLog(@"addPhoto #007");
					UIImage *edit_image = UIGraphicsGetImageFromCurrentImageContext();
					UIGraphicsEndImageContext();
					//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					
					CGFloat compressionQuality = 0.1f;
					if (_product_type == PRODUCT_POLAROID) { // 2015.12.21. 이강일팀장 의견(폴라로이드 편집이미지 화질이 너무 떨어진다는..)
						compressionQuality = 0.5f;
					}
					NSData *edit_data = UIImageJPEGRepresentation(edit_image, compressionQuality);
					[edit_data writeToFile:[NSString stringWithFormat:@"%@/edit/%@", _base_folder, layer.ImageEditname] atomically:YES];
					
					if(is_debug) NSLog(@"addPhoto #008");
					// 원본 크기
					layer.ImageOriWidth = [[PHAssetUtility info] getPixelWidth:photo.photo.asset];
					layer.ImageOriHeight = [[PHAssetUtility info] getPixelHeight:photo.photo.asset];
					
					// 편집용 이미지 장축 기록
					layer.EditImageMaxSize = MAX((int)edit_image.size.width, (int)edit_image.size.height);
					
					// 기본 크롭 정보 생성
					CGRect maskRect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
					CGRect cropRect = [[Common info] getDefaultCropRect:maskRect src:edit_image.size];
					layer.ImageCropX = cropRect.origin.x;
					layer.ImageCropY = cropRect.origin.y;
					layer.ImageCropW = cropRect.size.width;
					layer.ImageCropH = cropRect.size.height;
					
					if(is_debug) NSLog(@"addPhoto #009");
					layer.is_lowres = [[Common info] isLowResolution:layer];
					layer.edit_image = nil;
				}
				
				//NSLog(@"org(%dx%d) edit(%.0fx%.0f) rotate(%d)", layer.ImageOriWidth, layer.ImageOriHeight, edit_image.size.width, edit_image.size.height, layer.ImageR);
				//NSLog(@"crop(%d,%d,%d,%d)", layer.ImageCropX, layer.ImageCropY, layer.ImageCropW, layer.ImageCropH);
				return TRUE;
			}
			return FALSE;
		}
		else {
			SocialItem *photo = (SocialItem *)item;
			
			if (photo != nil && layer != nil) {
				
				NSString *time_str = [[Common info] timeStringEx];
				NSString *filename = [NSString stringWithFormat:@"%04d_i.jpg", pick_index];
				
				int randnum = arc4random() % 100;
				NSString *org_filename = [NSString stringWithFormat:@"%@_%03d_%@", time_str, randnum, filename];
				NSString *org_pathname = [NSString stringWithFormat:@"%@/org/%@", _base_folder, org_filename];
				
				layer.Filename = @"";
				layer.ImageFilename = org_filename;
				layer.ImageEditname = [NSString stringWithFormat:@"_%@", org_filename];
				NSLog(@"addPhotoFile:%@", layer.ImageFilename);
				
				// url로부터 복사.
				if (![photo download:org_pathname]) {
					return NO;
				}
				
				// 원본이미지
				UIImage *org_image = [UIImage imageWithContentsOfFile:org_pathname];
				
				// 편집이미지
				CGFloat scale = 1.0f;
				int min_side = (int)MIN(org_image.size.width, org_image.size.height);
				if (min_side > 480) {
					scale = 480.0f / (CGFloat)min_side;
				}
				
				CGSize image_size = CGSizeMake(org_image.size.width * scale, org_image.size.height * scale);
				
				UIGraphicsBeginImageContext(image_size);
				[org_image drawInRect:CGRectMake(0, 0, image_size.width, image_size.height)];
				UIImage *edit_image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				
				CGFloat compressionQuality = 0.5f;
				NSData *edit_data = UIImageJPEGRepresentation(edit_image, compressionQuality);
				[edit_data writeToFile:[NSString stringWithFormat:@"%@/edit/%@", _base_folder, layer.ImageEditname] atomically:YES];
				
				//
				// 원본 크기
				layer.ImageOriWidth = org_image.size.width;
				layer.ImageOriHeight = org_image.size.height;
				
				// 편집용 이미지 장축 기록
				layer.EditImageMaxSize = MAX((int)edit_image.size.width, (int)edit_image.size.height);
				
				// 기본 크롭 정보 생성
				CGRect maskRect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
				CGRect cropRect = [[Common info] getDefaultCropRect:maskRect src:edit_image.size];
				layer.ImageCropX = cropRect.origin.x;
				layer.ImageCropY = cropRect.origin.y;
				layer.ImageCropW = cropRect.size.width;
				layer.ImageCropH = cropRect.size.height;
				
				layer.is_lowres = [[Common info] isLowResolution:layer];
				layer.edit_image = nil;
				
				//NSLog(@"org(%dx%d) edit(%.0fx%.0f) rotate(%d)", layer.ImageOriWidth, layer.ImageOriHeight, edit_image.size.width, edit_image.size.height, layer.ImageR);
				//NSLog(@"crop(%d,%d,%d,%d)", layer.ImageCropX, layer.ImageCropY, layer.ImageCropW, layer.ImageCropH);
				return YES;
			}
			return NO;
		}
	}
	return NO;
}
- (UIColor *)colorWithRGBAInteger:(NSUInteger)RGBAInteger
{
    CGFloat red = ((CGFloat)((RGBAInteger >> 24) & 0xFF)) / 255.0f;
    CGFloat green = ((CGFloat)((RGBAInteger >> 16) & 0xFF)) / 255.0f;
    CGFloat blue = ((CGFloat)((RGBAInteger >> 8) & 0xFF)) / 255.0f;
    CGFloat alpha = ((CGFloat)((RGBAInteger) & 0xFF)) / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
}
- (NSUInteger)rgbaIntegerWithColor:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(NSUInteger)alpha
{
    NSUInteger rgbaIntegerValue;
    
    rgbaIntegerValue = (red << 24) | (green << 16) | (blue << 8) | (alpha);
    
    return rgbaIntegerValue;
    
}
// photobook v2 drawtext
- (void)drawPhotobookText:(NSString *)text withPage:(Page *)page withLayer:(Layer *)layer inView:(UIImageView *)layerview withHScale:(CGFloat)h_scale withVScale:(CGFloat)v_scale {
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    UIImage* image = [self resizeImage:[UIImage imageNamed:@"transparent.png"] convertToSize:CGSizeMake(layer.W*h_scale, layer.H*v_scale)];
    UIFont *font = nil;
    
    
    if(layer.TextFontname != nil && layer.TextFontname.length > 0 && [_fonts objectForKey:layer.TextFontname] != nil) {
        font = [UIFont fontWithName:[_fonts objectForKey:layer.TextFontname] size:_FONT_SIZE_RATIO * layer.TextFontsize * v_scale];
    }
    if(font == nil) {
        font = [UIFont systemFontOfSize:_FONT_SIZE_RATIO * layer.TextFontsize * v_scale weight:UIFontWeightRegular];
        NSLog(@"LOADING FONT : %@ FAILED", [_fonts objectForKey:layer.TextFontname]);
    }
    
    UIColor* fontColor = layer.text_color;
    NSDictionary *attr = @{ NSFontAttributeName:font, NSForegroundColorAttributeName: fontColor};
    
    CGSize textSize = [text sizeWithAttributes:attr];
    
    // 2018.11.19
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    // 2018.11.18
    //CGFloat topPadding = ceilf(font.ascender - font.capHeight + 1);
    CGFloat topPadding = font.ascender - font.capHeight + 1;
    
    y = topPadding;
    
    
    if([layer.Halign isEqualToString:@"center"]) {
        x = (layer.W * h_scale - textSize.width) / 2.f;
        [text drawAtPoint:CGPointMake(round(x), round(y)) withAttributes:attr];
    }
    else if([layer.Halign isEqualToString:@"right"]) {
        x = layer.W * h_scale - textSize.width;
        [text drawAtPoint:CGPointMake(round(x), round(y)) withAttributes:attr];
    }
    else
        [text drawAtPoint:CGPointMake(round(x), round(y)) withAttributes:attr];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    layerview.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    layerview.contentMode = UIViewContentModeScaleAspectFill;
    layerview.image = image;
}


@end
