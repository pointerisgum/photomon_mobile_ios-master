//
//  PhotoEditViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 21..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotoEditViewController.h"

@interface PhotoEditViewController ()

@end

@implementation PhotoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initPhoto];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if (_layer) {
        [_editView updatePreview];
    }
}

- (void)initPhoto {
    CGRect mask_rect = CGRectMake(_layer.MaskX, _layer.MaskY, _layer.MaskW, _layer.MaskH);
    CGRect crop_rect = CGRectMake(_layer.ImageCropX, _layer.ImageCropY, _layer.ImageCropW, _layer.ImageCropH);
    
    [_editView setImageInfo:_layer MaskRect:mask_rect CropRect:crop_rect];

    _rotate_angle = _layer.ImageR;
    //[self rotateAngle:_rotate_angle];
}

- (void)rotateAngle:(int)angle {
    [_editView rotateAngle:angle];
    
    _rotate_angle = _rotate_angle + angle;
    //_rotate_angle %= 360;
    if (labs(_rotate_angle) >= 360) _rotate_angle = 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)undoAll:(id)sender {
    [self initPhoto];
    [_editView updatePreview];
}

- (IBAction)rotateLeft:(id)sender {
    [self rotateAngle:-90];
}

- (IBAction)rotateRight:(id)sender {
    [self rotateAngle:90];
}

- (IBAction)done:(id)sender {
    _layer.ImageR = _rotate_angle;

    CGRect crop_rect = [_editView getImageCropRect:(CGFloat)_layer.EditImageMaxSize];
    _layer.ImageCropX = (int)crop_rect.origin.x;
    _layer.ImageCropY = (int)crop_rect.origin.y;
    _layer.ImageCropW = (int)crop_rect.size.width;
    _layer.ImageCropH = (int)crop_rect.size.height;
    
    _layer.is_lowres = [[Common info] isLowResolution:_layer];

    [self.delegate didEditPhoto];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self.delegate cancelEditPhoto];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
