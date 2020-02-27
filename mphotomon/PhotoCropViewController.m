//
//  PhotoCropViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 27..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotoCropViewController.h"
#import "Common.h"

@interface PhotoCropViewController ()

@end

@implementation PhotoCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _comment_label.text = @"";
    [self resetButtonState];
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadPhoto];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadCropInfo:(Photobook *)photobook SelectedLayer:(Layer *)sel_layer {
    _photobook = photobook;
    _cur_index = -1;
    
	int npage = 0;
	int nlayer = 0;
    int index = 0;
    _crop_infos = [[NSMutableArray alloc] init];
    for (Page *page in photobook.pages) {
		nlayer = 0;
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0 && layer.ImageFilename.length > 0) {

                PhotoCropInfo *info = [[PhotoCropInfo alloc] init];

				// 마그넷 : guideinfo
				info.npage = npage;
				info.nlayer = nlayer;
				info.layer = layer;

                [_crop_infos addObject:info];

                if (layer.edit_image == nil) {
                    layer.edit_image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/edit/%@", photobook.base_folder, layer.ImageEditname]];
                }
                info.image = layer.edit_image;
                info.rotate_angle = layer.ImageR;
                info.mask_rect = CGRectMake(layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
                info.crop_rect = CGRectMake(layer.ImageCropX, layer.ImageCropY, layer.ImageCropW, layer.ImageCropH);
                info.long_side = layer.EditImageMaxSize;
                
                if ([sel_layer.ImageEditname isEqualToString:layer.ImageEditname]) {
                    _cur_index = index;
                }
                index++;
            }
			nlayer++;
        }
		npage++;
    }
}

- (void)saveCropInfo {
    [_edit_view save];
    
    int index = 0;
    for (Page *page in _photobook.pages) {
        for (Layer *layer in page.layers) {
            if (layer.AreaType == 0 && layer.ImageFilename.length > 0) {
                if (index < _crop_infos.count) {
                    PhotoCropInfo *info = _crop_infos[index];
                    
                    CGRect crop_rect = info.crop_rect;
                    layer.ImageCropX = (int)crop_rect.origin.x;
                    layer.ImageCropY = (int)crop_rect.origin.y;
                    layer.ImageCropW = (int)crop_rect.size.width;
                    layer.ImageCropH = (int)crop_rect.size.height;
                    layer.ImageR = info.rotate_angle;
                    layer.is_lowres = [[Common info] isLowResolution:layer];
                }
                index++;
            }
        }
    }
}

- (void)loadPhoto {
    if (_cur_index >= 0 && _cur_index < _crop_infos.count) {
        _comment_label.text = [NSString stringWithFormat:@"%d / %d", _cur_index+1, (int)_crop_infos.count];
        [_edit_view load:_crop_infos[_cur_index]];
    }
    else {
        [[Common info] alert:self Msg:@"사진을 열 수 없습니다."];
    }
}

- (void)resetButtonState {
    _prev_button.enabled = YES;
    _next_button.enabled = YES;
    if (_cur_index <= 0) {
        _prev_button.enabled = NO;
    }
    if (_cur_index >= _crop_infos.count-1) {
        _next_button.enabled = NO;
    }
}

- (IBAction)prevPhoto:(id)sender {
    [_edit_view save];
    
    if (_cur_index > 0) --_cur_index;
    [self resetButtonState];
    
    [self loadPhoto];
}

- (IBAction)nextPhoto:(id)sender {
    [_edit_view save];
    
    if (_cur_index < _crop_infos.count-1) ++_cur_index;
    [self resetButtonState];
    
    [self loadPhoto];
}

- (IBAction)rotateRight:(id)sender {
    [_edit_view rotateAngle:90];
}

- (IBAction)rotateLeft:(id)sender {
    [_edit_view rotateAngle:-90];
}

- (IBAction)undoAll:(id)sender {
    [_edit_view undoAll];
}

- (IBAction)cancel:(id)sender {
    if (self.delegate) {
        [self.delegate cancelEditPhoto];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self saveCropInfo];
    
    if (self.delegate) {
        [self.delegate didEditPhoto];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
