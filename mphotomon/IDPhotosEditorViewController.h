//
//  IDPhotosEditorViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface IDPhotosEditorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *image_view;
@property (weak, nonatomic) IBOutlet UISlider *slider_brightness;
@property (weak, nonatomic) IBOutlet UISlider *slider_saturation;
@property (weak, nonatomic) IBOutlet UISlider *slider_contrast;
@property (weak, nonatomic) IBOutlet UILabel *lb_brightness;
@property (weak, nonatomic) IBOutlet UILabel *lb_saturation;
@property (weak, nonatomic) IBOutlet UILabel *lb_contrast;
@property (weak, nonatomic) IBOutlet UIView *adjust_view;

@property (strong, nonatomic) UIView *frame_left_line;
@property (strong, nonatomic) UIView *frame_top_line;
@property (strong, nonatomic) UIView *frame_right_line;
@property (strong, nonatomic) UIView *frame_bottom_line;

@property (strong, nonatomic) UIImage* original_image;
@property (strong, nonatomic) UIImage* edit_image;
@property (nonatomic) CGFloat nbrightness;
@property (nonatomic) CGFloat nsaturation;
@property (nonatomic) CGFloat ncontrast;
@property (nonatomic) CGFloat scale;

@property (nonatomic) CGFloat frame_width;
@property (nonatomic) CGFloat frame_height;
@property (nonatomic) CGFloat start_x;
@property (nonatomic) CGFloat start_y;

@property (nonatomic) BOOL fromCamera;
@property (nonatomic) int rotatedegrees;

- (IBAction)rotateLeft:(id)sender;
- (IBAction)rotateRight:(id)sender;
- (IBAction)initImage:(id)sender;

@end
