//
//  PhotoLayerView.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 13..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotoLayerView.h"
#import "Common.h"

@implementation PhotoLayerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _photoView = [[UIImageView alloc] init];
    [self addSubview:_photoView];
    
    _photoView.clipsToBounds = TRUE;
    //_photoView.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    //_photoView.layer.borderWidth = 1.0;
}

// 2017.11.13 : 양성진 수정 : 포토북에 오류가 있는지 확인하고 리턴하도록 수정(edit 파일이 존재하지 않을 경우)
- (BOOL)setLayerInfo:(Layer *)layer BaseFolder:(NSString *)base_folder IsEdit:(BOOL)is_edit {
    _photoView.hidden = YES;
    if (layer.ImageEditname.length > 0) {
        _photoView.contentMode = UIViewContentModeScaleAspectFit;

        if (layer.edit_image != nil) {
            _photoView.image = layer.edit_image;
        }
        else {
			// SJYANG : 2017.11.07 : CRASH 오류 수정 : _photoView.image.size 가 0, 0 이라서 크래시 발생
			NSString* filePath = [NSString stringWithFormat:@"%@/edit/%@", base_folder, layer.ImageEditname];
			if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
				NSLog(@"[ERROR!!] edit_image : %@", filePath);
				NSLog(@"[ERROR!!] edit_image not exists");
			}

			NSString* org_filePath = [NSString stringWithFormat:@"%@/org/%@", base_folder, layer.ImageFilename];
			if( ![[NSFileManager defaultManager] fileExistsAtPath:org_filePath] ) {
				NSLog(@"[ERROR!!] org_image : %@", org_filePath);
				NSLog(@"[ERROR!!] org_image not exists");
			}

            _photoView.image = [UIImage imageWithContentsOfFile:filePath];
            layer.edit_image = _photoView.image;
        }

        // 회전 (추후 교체할 것.)
        [_photoView setFrame:CGRectMake(0, 0, _photoView.image.size.width, _photoView.image.size.height)];
        _photoView.transform = CGAffineTransformRotate(_photoView.transform, layer.ImageR * (2.0 * M_PI / 360.0));

        if (layer.ImageCropW <= 0 || layer.ImageCropH <= 0) {
            CGRect maskRect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
			// SJYANG : 2017.11.07 : CRASH 오류 수정 : _photoView.image.size 가 0, 0 이라서 크래시 발생
			if(_photoView.image.size.width == 0 && _photoView.image.size.height == 0) return FALSE;

            CGRect cropRect = [[Common info] getDefaultCropRect:maskRect src:_photoView.image.size];
            layer.ImageCropX = cropRect.origin.x;
            layer.ImageCropY = cropRect.origin.y;
            layer.ImageCropW = cropRect.size.width;
            layer.ImageCropH = cropRect.size.height;
        }
        layer.is_lowres = [[Common info] isLowResolution:layer];

        CGRect crop_rect = CGRectMake(layer.ImageCropX, layer.ImageCropY, layer.ImageCropW, layer.ImageCropH);
        NSLog(@"layer: %.0f %.0f %.0f %.0f", crop_rect.origin.x, crop_rect.origin.y, crop_rect.size.width, crop_rect.size.height);
        CGRect rect = [self calcImageRectWithMask:self.bounds Crop:crop_rect ImageSize:_photoView.image.size Rotate:layer.ImageR];
        [_photoView setFrame:rect]; 
    }
    else {
        if (is_edit) {
            self.layer.borderColor = [UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:0.5f].CGColor;
            self.layer.borderWidth = 0.5f;

            _photoView.contentMode = UIViewContentModeScaleAspectFit;
            int product_type = [Common info].photobook.product_type;
            if (product_type == PRODUCT_SINGLECARD) {
                _photoView.image = [UIImage imageNamed:@"btn_img_add.png"];
                CGFloat icon_size = 50;//MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f;
                CGRect empty_rect = CGRectMake(self.bounds.size.width/2-icon_size/2, self.bounds.size.height/2-icon_size/2, icon_size, icon_size);
                [_photoView setFrame:empty_rect];
            } else {
                _photoView.image = [UIImage imageNamed:@"photobook_addphoto.png"];
                CGFloat icon_size = 28;//MIN(self.bounds.size.width, self.bounds.size.height) / 2.0f;
                CGRect empty_rect = CGRectMake(self.bounds.size.width/2-icon_size/2, self.bounds.size.height/2-icon_size/2, icon_size, icon_size);
                [_photoView setFrame:empty_rect];
            }
        }
    }
	// 신규 달력 포맷 : 2018.11.12
	if ([Common info].photobook.product_type != PRODUCT_CALENDAR) {
		if (layer.FrameFilename.length > 0 && (layer.Frameinfo == nil || layer.Frameinfo.length == 0)) {
			UIImage *maskImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/temp/%@", base_folder, layer.FrameFilename]];
			
			// TODO : 마그넷 : 여기서 maskImage 를 마스크 영역만큼 잘라내 주면, 될 것 같은데...

			CALayer *mask = [CALayer layer];
			mask.contents = (id)[maskImage CGImage];
			mask.frame = self.bounds;
			self.layer.mask = mask;
			self.layer.masksToBounds = YES;
		}
	}
	// 신규 달력 포맷 : 마스킹
	if ([Common info].photobook.product_type == PRODUCT_CALENDAR) {
		if(layer.Frameinfo != nil && layer.Frameinfo.length > 0) {
			NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", base_folder];

			NSString *frameInfoFile = @"";
			NSString *cutFrameInfoFile = @"";

			NSArray *tarr = [layer.Frameinfo componentsSeparatedByString:@"^"];
			frameInfoFile = [tarr objectAtIndex:0];
			if([tarr count] > 1)
				cutFrameInfoFile = [tarr objectAtIndex:1];

			if(frameInfoFile.length > 0) {
				NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, frameInfoFile];
				UIImage *maskImage = [UIImage imageWithContentsOfFile:localpathname];

				if([self isOuterAlphaImage:maskImage]) {
					CALayer *mask = [CALayer layer];
					mask.contents = (id)[maskImage CGImage];
					mask.frame = self.bounds;
					self.layer.mask = mask;
					self.layer.masksToBounds = YES;
				}
				else {
					UIImageView *view = [[UIImageView alloc] init];
					[self addSubview:view];

					CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
					[view setFrame:rect];

					// FIX : 2019.03.07 : 신규 달력 포맷 : 마스킹 : 대형벽걸이 > 그린리프 마스킹 오류 수정
					//view.contentMode = UIViewContentModeScaleAspectFit;
					view.contentMode = UIViewContentModeScaleToFill;
					view.image = maskImage;
				}
			}
			if(cutFrameInfoFile != nil && cutFrameInfoFile.length > 0) {
				NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, cutFrameInfoFile];
				UIImage *cutFrameInfoImage = [UIImage imageWithContentsOfFile:localpathname];

				UIImageView *view = [[UIImageView alloc] init];
				[self addSubview:view];

				CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
				[view setFrame:rect];

				// FIX : 2019.03.07 : 신규 달력 포맷 : 마스킹 : 대형벽걸이 > 그린리프 마스킹 오류 수정
				//view.contentMode = UIViewContentModeScaleAspectFill;
				view.contentMode = UIViewContentModeScaleToFill;
				view.image = cutFrameInfoImage;
			}
		}
	}
    _photoView.hidden = NO;

	return TRUE;
}

- (CGRect)calcImageRectWithMask:(CGRect)mask_rect Crop:(CGRect)crop_rect ImageSize:(CGSize)image_size Rotate:(int)angle {
    CGFloat scale = mask_rect.size.width / crop_rect.size.width;

    CGSize size = [[Common info] getRotatedSize:image_size Rotate:angle];
    CGPoint offset = CGPointMake(-crop_rect.origin.x, -crop_rect.origin.y);

    return CGRectMake(offset.x * scale, offset.y * scale, size.width * scale, size.height * scale);
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

@end
