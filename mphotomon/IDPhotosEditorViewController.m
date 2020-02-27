//
//  IDPhotosEditorViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosEditorViewController.h"
#import "IDPhotosPreviewViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "UIImage+Filtering.h"
#import "UIImage+Rotating.h"
#import "ImageFilter.h"
#import <math.h>
#import "QuartzCore/QuartzCore.h"

@interface IDPhotosEditorViewController ()

@end

@implementation IDPhotosEditorViewController

static BOOL image_view_resize = NO;
static CGRect image_view_rect;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)];

    _rotatedegrees = 0;

    if( _fromCamera )
    {
        NSData* data = [self dataByRemovingExif:UIImagePNGRepresentation(_original_image)];
        _original_image = [UIImage imageWithData:data];
        _original_image = [_original_image rotateInDegrees:-90];
    }

    _frame_width = self.view.bounds.size.width * 0.6f;
    if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239051"] )
        _frame_height = _frame_width / 2.5f * 3.0f;
    else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239052"] )
        _frame_height = _frame_width / 3.0f * 4.0f;
    else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239053"] )
        _frame_height = _frame_width / 3.5f * 4.5f;
    else if( [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239054"] )
        _frame_height = _frame_width / 5.0f * 7.0f;
    else
        _frame_height = _frame_width / 3.5f * 5.0f;

    _start_x = (self.view.bounds.size.width - _frame_width) / 2.0f;
    _start_y = [UIApplication sharedApplication].statusBarFrame.size.height + (self.view.bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - _adjust_view.bounds.size.height - _frame_height) / 2.0f + [self statusBarHeight];


    CGFloat frame_val;

	// SJYANG : 2017.12.08 : 증명사진내 png 이미지 가이드 표시 (앨범선택해서 편집하는 경우 반명함사진과 여권/수능사진만)
    if(([[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239052"] || [[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239053"]) && !_fromCamera) {
		_frame_top_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x, _start_y, _frame_width, 2)];
		_frame_top_line.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_top_line];

		_frame_bottom_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x, _start_y + (_frame_height - 2), _frame_width, 2)];
		_frame_bottom_line.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_bottom_line];

		_frame_left_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x, _start_y, 2, _frame_height)];
		_frame_left_line.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_left_line];

		_frame_right_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x + (_frame_width - 2), _start_y, 2, _frame_height)];
		_frame_right_line.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_right_line];


		UIImage *image = nil;
		if([[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239052"]) 
			image = [UIImage imageNamed:@"m_photoprint_30x40_guide.png"];
		else if([[Common info].idphotos.idphotos_product.product.item_product_code isEqualToString:@"239053"]) 
			image = [UIImage imageNamed:@"m_photoprint_35x45_guide.png"];

		if(image != nil) {
			UIImageView *imageView = [[UIImageView alloc] init];
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			imageView.clipsToBounds = YES;
			imageView.image = image;
			[self.view addSubview:imageView];
			int iv_width = (int)((CGFloat)_frame_height / (CGFloat)image.size.height * (CGFloat)image.size.width);
			imageView.frame = CGRectMake(_start_x - (iv_width - _frame_width) / 2.f, _start_y, iv_width, _frame_height);
		}
	}
	else {
		_frame_top_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x, _start_y, _frame_width, 2)];
		_frame_top_line.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_top_line];

		_frame_bottom_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x, _start_y + (_frame_height - 2), _frame_width, 2)];
		_frame_bottom_line.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_bottom_line];

		_frame_left_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x, _start_y, 2, _frame_height)];
		_frame_left_line.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_left_line];

		_frame_right_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x + (_frame_width - 2), _start_y, 2, _frame_height)];
		_frame_right_line.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:_frame_right_line];


		UIView* frame_vt_line = [[UIView alloc] initWithFrame: CGRectMake ( _start_x + _frame_width / 2.0f - 1.0f, _start_y, 2, _frame_height)];
		frame_vt_line.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:frame_vt_line];

		frame_val = _frame_width * 0.25f;
		UIView* frame_mid_line_1 = [[UIView alloc] initWithFrame: CGRectMake ( _start_x + (_frame_width - frame_val) / 2.0f, _start_y + _frame_height * 0.15f, frame_val, 2)];
		frame_mid_line_1.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:frame_mid_line_1];

		frame_val = _frame_width * 0.50f;
		UIView* frame_mid_line_2 = [[UIView alloc] initWithFrame: CGRectMake ( _start_x + (_frame_width - frame_val) / 2.0f, _start_y + _frame_height * 0.4f, frame_val, 2)];
		frame_mid_line_2.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:frame_mid_line_2];

		frame_val = _frame_width * 1.00f;
		UIView* frame_mid_line_3 = [[UIView alloc] initWithFrame: CGRectMake ( _start_x + (_frame_width - frame_val) / 2.0f, _start_y + _frame_height * 0.78f, frame_val, 2)];
		frame_mid_line_3.backgroundColor = [UIColor colorWithRed:254.0f/255.0f green:254.0f/255.0f blue:0.0f alpha:1.0f];
		[self.view addSubview:frame_mid_line_3];
	}

    _nbrightness = 0.5;
    _nsaturation = 0.5;
    _ncontrast = 0.5;

    [_slider_brightness addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [_slider_saturation addTarget:self action:@selector(saturationChanged:) forControlEvents:UIControlEventValueChanged];
    [_slider_contrast addTarget:self action:@selector(contrastChanged:) forControlEvents:UIControlEventValueChanged];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];

    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];

    _adjust_view.layer.zPosition = 20000;
    _slider_brightness.layer.zPosition = 20001;
    _slider_saturation.layer.zPosition = 20001;
    _slider_contrast.layer.zPosition = 20001;

    [Analysis log:@"IDPhotosEditorViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    _image_view.hidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [Analysis firAnalyticsWithScreenName:@"IDPhotosEditorViewController" ScreenClass:[self.classForCoder description]];
    [self loadData];
}

- (void)loadData {
    if( _original_image==nil ) {
        UIImage *image = [UIImage imageNamed:@"main_polaroid.jpg"];
        _original_image = image;
        _image_view.image = image;
        [self initImage:nil];
    }
    else {
        _image_view.image = _original_image;
        [self initImage:nil];
    }
}


static float prev_scale_factor = 1.0;

- (void)pinch:(UIPinchGestureRecognizer *)sender
{
    //NSLog(@"sender.scale : %f", sender.scale);

    float scale_factor = sender.scale;

    CGAffineTransform otransform = _image_view.transform;
    CGRect obounds = _image_view.bounds;

    static CGRect initbounds;
    if (sender.state == UIGestureRecognizerStateBegan) 
        initbounds = _image_view.bounds;

    CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, sender.scale, sender.scale);
    _image_view.bounds = CGRectApplyAffineTransform(initbounds, zt);

    if( sender.scale < 1.0f && (_image_view.bounds.size.width <= _frame_width || _image_view.bounds.size.height <= _frame_height) ) {

        float width = _image_view.bounds.size.width;
        float height = _image_view.bounds.size.height;

        if( (_image_view.bounds.size.height / _image_view.bounds.size.width) > (_frame_height / _frame_width)) {
            width = _frame_width;
            height = _image_view.bounds.size.height * (_frame_width / _image_view.bounds.size.width);
        }
        else {
            height = _frame_height;
            width = _image_view.bounds.size.width * (_frame_height / _image_view.bounds.size.height);
        }

        _image_view.bounds = CGRectMake(0, 0, width, height);

        CGRect rect = _image_view.frame;
        if( rect.origin.y > [_frame_top_line frame].origin.y ) {
            float diff = rect.origin.y - [_frame_top_line frame].origin.y;
            [_image_view setCenter:CGPointMake([_image_view center].x, [_image_view center].y - diff)];
        }
        if( rect.origin.x > [_frame_left_line frame].origin.x ) {
            float diff = rect.origin.x - [_frame_left_line frame].origin.x;
            [_image_view setCenter:CGPointMake([_image_view center].x - diff, [_image_view center].y)];
        }
        if( rect.origin.y + rect.size.height < [_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height ) {
            float diff = ([_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height) - (rect.origin.y + rect.size.height);
            [_image_view setCenter:CGPointMake([_image_view center].x, [_image_view center].y + diff)];
        }
        if( rect.origin.x + rect.size.width < [_frame_right_line frame].origin.x + [_frame_right_line frame].size.width ) {
            float diff = ([_frame_right_line frame].origin.x + [_frame_right_line frame].size.width) - (rect.origin.x + rect.size.width);
            [_image_view setCenter:CGPointMake([_image_view center].x + diff, [_image_view center].y)];
        }

        return;
    }
    
    // 양성진 수정/추가
    // 하자보수 이슈 :  iOS 증명사진에서, 사진 선택 후 편집화면내에서 사진이 엄청 확대되는 오류
    //if( sender.scale > 1.0f && (_image_view.bounds.size.width >= _frame_width * 3 && _image_view.bounds.size.height >= _frame_height * 3) ) {
    if( sender.scale > 1.0f && (_image_view.bounds.size.width >= _frame_width * 2 && _image_view.bounds.size.height >= _frame_height * 2) ) {
        _image_view.transform = otransform;
        _image_view.bounds = obounds;
        return;
    }

    CGRect rect = _image_view.frame;
    if( rect.origin.y > [_frame_top_line frame].origin.y ) {
        float diff = rect.origin.y - [_frame_top_line frame].origin.y;
        [_image_view setCenter:CGPointMake([_image_view center].x, [_image_view center].y - diff)];
    }
    if( rect.origin.x > [_frame_left_line frame].origin.x ) {
        float diff = rect.origin.x - [_frame_left_line frame].origin.x;
        [_image_view setCenter:CGPointMake([_image_view center].x - diff, [_image_view center].y)];
    }
    if( rect.origin.y + rect.size.height < [_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height ) {
        float diff = ([_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height) - (rect.origin.y + rect.size.height);
        [_image_view setCenter:CGPointMake([_image_view center].x, [_image_view center].y + diff)];
    }
    if( rect.origin.x + rect.size.width < [_frame_right_line frame].origin.x + [_frame_right_line frame].size.width ) {
        float diff = ([_frame_right_line frame].origin.x + [_frame_right_line frame].size.width) - (rect.origin.x + rect.size.width);
        [_image_view setCenter:CGPointMake([_image_view center].x + diff, [_image_view center].y)];
    }

    prev_scale_factor = scale_factor;

    image_view_rect = [self correctifyImageViewRect:_image_view.frame];
    image_view_resize = YES;
    [_image_view setNeedsLayout];
}

- (void)move:(id)sender {
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];

    static CGFloat firstCenterX = 0;
    static CGFloat firstCenterY = 0;

    CGPoint currentlocation = [(UIPanGestureRecognizer*)sender locationInView:self.view];
    if( currentlocation.y >= [_adjust_view frame].origin.y )
        return;

    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstCenterX = [_image_view center].x;
        firstCenterY = [_image_view center].y;
    }

    translatedPoint = CGPointMake(firstCenterX+translatedPoint.x, firstCenterY+translatedPoint.y);

    CGRect imageViewFrame = [_image_view frame];
    CGFloat leftVal = translatedPoint.x - imageViewFrame.size.width / 2.0f;
    CGFloat rightVal = translatedPoint.x + imageViewFrame.size.width / 2.0f;
    CGFloat topVal = translatedPoint.y - imageViewFrame.size.height / 2.0f;
    CGFloat bottomVal = translatedPoint.y + imageViewFrame.size.height / 2.0f;

    if( leftVal > [_frame_left_line frame].origin.x )
        translatedPoint.x = [_frame_left_line frame].origin.x + imageViewFrame.size.width / 2.0f;
    if( rightVal < [_frame_right_line frame].origin.x + [_frame_right_line frame].size.width )
        translatedPoint.x = [_frame_right_line frame].origin.x + [_frame_right_line frame].size.width - imageViewFrame.size.width / 2.0f;
    if( topVal > [_frame_top_line frame].origin.y )
        translatedPoint.y = [_frame_top_line frame].origin.y + imageViewFrame.size.height / 2.0f;
    if( bottomVal < [_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height )
        translatedPoint.y = [_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height - imageViewFrame.size.height / 2.0f;

    [_image_view setCenter:translatedPoint];
}

- (IBAction)brightnessChanged:(UISlider *)sender {
    image_view_rect = [_image_view frame];

    _nbrightness = sender.value;
    [self processImage:nil];
    _lb_brightness.text = [NSString stringWithFormat:@"%d", (int)(_nbrightness * 100)];

    image_view_resize = YES;
    [_image_view setNeedsLayout];
}

- (IBAction)saturationChanged:(UISlider *)sender {
    image_view_rect = [_image_view frame];

    _nsaturation = sender.value;
    [self processImage:nil];
    _lb_saturation.text = [NSString stringWithFormat:@"%d", (int)(_nsaturation * 100)];

    image_view_resize = YES;
    [_image_view setNeedsLayout];
}

- (IBAction)contrastChanged:(UISlider *)sender {
    image_view_rect = [_image_view frame];

    _ncontrast = sender.value;
    [self processImage:nil];
    _lb_contrast.text = [NSString stringWithFormat:@"%d", (int)(_ncontrast * 100)];

    image_view_resize = YES;
    [_image_view setNeedsLayout];
}

- (IBAction)initImage:(id)sender {

    UIImage* image = _original_image;

    float width = image.size.width;
    float height = image.size.height;
    if( image.size.width / image.size.height < _frame_width / _frame_height ) {
        width = _frame_width;
        height = _frame_width * (image.size.height / image.size.width);
    }
    else {
        height = _frame_height;
        width = _frame_height * (image.size.width / image.size.height);
    }

    _scale = height / _original_image.size.height;
    image_view_rect = CGRectMake(_frame_left_line.frame.origin.x - (width - _frame_width) / 2.0f, _frame_top_line.frame.origin.y - (height - _frame_height) / 2.0f, width, height);

    image_view_resize = YES;
    [_image_view setNeedsLayout];

    _image_view.hidden = NO;
}

- (IBAction)processImage:(id)sender {
    UIImage* image = [_original_image brightenWithValue:(_nbrightness - 0.5) * 100];
    image = [image saturate:(_nsaturation + 0.5)];
    image = [image contrastAdjustmentWithValue:(_ncontrast - 0.5) * 100];
    _image_view.image = image;
}

-(void)viewDidLayoutSubviews {
    if( image_view_resize==YES ) {
        image_view_resize = NO;
        _image_view.frame = image_view_rect;
    }
}

- (CGRect)correctifyImageViewRect:(CGRect)rect {
    if( rect.origin.y > [_frame_top_line frame].origin.y ) {
        float diff = rect.origin.y - [_frame_top_line frame].origin.y;
        rect = CGRectMake(rect.origin.x, rect.origin.y - diff, rect.size.width, rect.size.height);
    }
    if( rect.origin.x > [_frame_left_line frame].origin.x ) {
        float diff = rect.origin.x - [_frame_left_line frame].origin.x;
        rect = CGRectMake(rect.origin.x - diff, rect.origin.y, rect.size.width, rect.size.height);
    }
    if( rect.origin.y + rect.size.height < [_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height ) {
        float diff = ([_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height) - (rect.origin.y + rect.size.height);
        rect = CGRectMake(rect.origin.x, rect.origin.y + diff, rect.size.width, rect.size.height);
    }
    if( rect.origin.x + rect.size.width < [_frame_right_line frame].origin.x + [_frame_right_line frame].size.width ) {
        float diff = ([_frame_right_line frame].origin.x + [_frame_right_line frame].size.width) - (rect.origin.x + rect.size.width);
        rect = CGRectMake(rect.origin.x + diff, rect.origin.y, rect.size.width, rect.size.height);
    }
    return(rect);
}

- (IBAction)rotateLeft:(id)sender {
    _original_image = [_original_image rotateInDegrees:90];
    _rotatedegrees += 90;

    UIImage* image = [_original_image brightenWithValue:(_nbrightness - 0.5) * 100];
    image = [image saturate:(_nsaturation + 0.5)];
    image = [image contrastAdjustmentWithValue:(_ncontrast - 0.5) * 100];
    _image_view.image = image;

    image_view_rect = CGRectMake(_image_view.frame.origin.x, _image_view.frame.origin.y, _image_view.frame.size.height, _image_view.frame.size.width);

    float width = image.size.width;
    float height = image.size.height;

    /*
    if( image_view_rect.size.width < _frame_width ) {
        width = _frame_width;
        height = image_view_rect.size.height * (_frame_width / image_view_rect.size.width);
        image_view_rect = CGRectMake(_image_view.frame.origin.x, _image_view.frame.origin.y, width, height);
        prev_scale_factor = 1.0f;
    }
    else if( image_view_rect.size.height < _frame_height ) {
        height = _frame_height;
        width = image_view_rect.size.width * (_frame_height / image_view_rect.size.height);
        image_view_rect = CGRectMake(_image_view.frame.origin.x, _image_view.frame.origin.y, width, height);
        prev_scale_factor = 1.0f;
    }
    */

    if( image_view_rect.size.width < _frame_width || image_view_rect.size.height < _frame_height ) {
        if( (image_view_rect.size.height / image_view_rect.size.width) > (_frame_height / _frame_width)) {
            width = _frame_width;
            height = image_view_rect.size.height * (_frame_width / image_view_rect.size.width);
        }
        else {
            height = _frame_height;
            width = image_view_rect.size.width * (_frame_height / image_view_rect.size.height);
        }
        image_view_rect = CGRectMake(_image_view.frame.origin.x, _image_view.frame.origin.y, width, height);
        prev_scale_factor = 1.0f;
    }

    image_view_rect = [self correctifyImageViewRect:image_view_rect];

    image_view_resize = YES;
    [_image_view setNeedsLayout];
}

- (IBAction)rotateRight:(id)sender {
    _original_image = [_original_image rotateInDegrees:-90];
    _rotatedegrees += -90;

    UIImage* image = [_original_image brightenWithValue:(_nbrightness - 0.5) * 100];
    image = [image saturate:(_nsaturation + 0.5)];
    image = [image contrastAdjustmentWithValue:(_ncontrast - 0.5) * 100];
    _image_view.image = image;

    image_view_rect = CGRectMake(_image_view.frame.origin.x, _image_view.frame.origin.y, _image_view.frame.size.height, _image_view.frame.size.width);

    float width = image.size.width;
    float height = image.size.height;

    if( image_view_rect.size.width < _frame_width || image_view_rect.size.height < _frame_height ) {
        if( (image_view_rect.size.height / image_view_rect.size.width) > (_frame_height / _frame_width)) {
            width = _frame_width;
            height = image_view_rect.size.height * (_frame_width / image_view_rect.size.width);
        }
        else {
            height = _frame_height;
            width = image_view_rect.size.width * (_frame_height / image_view_rect.size.height);
        }
        image_view_rect = CGRectMake(_image_view.frame.origin.x, _image_view.frame.origin.y, width, height);
        prev_scale_factor = 1.0f;
    }

    image_view_rect = [self correctifyImageViewRect:image_view_rect];

    image_view_resize = YES;
    [_image_view setNeedsLayout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IDPhotosPreviewSegue"]) {
        IDPhotosPreviewViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.image = _edit_image;
        }
    }
}

- (NSData *)dataByRemovingExif:(NSData *)data
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    NSMutableData *mutableData = nil;

    if (source) {
        CFStringRef type = CGImageSourceGetType(source);
        size_t count = CGImageSourceGetCount(source);
        mutableData = [NSMutableData data];

        CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)mutableData, type, count, NULL);

        NSDictionary *removeExifProperties = @{(id)kCGImagePropertyExifDictionary: (id)kCFNull,
                                               (id)kCGImagePropertyGPSDictionary : (id)kCFNull};

        if (destination) {
            for (size_t index = 0; index < count; index++) {
                CGImageDestinationAddImageFromSource(destination, source, index, (__bridge CFDictionaryRef)removeExifProperties);
            }

            if (!CGImageDestinationFinalize(destination)) {
                NSLog(@"CGImageDestinationFinalize failed");
            }

            CFRelease(destination);
        }

        CFRelease(source);
    }

    return mutableData;
}

- (IBAction)done:(id)sender {
    CGImageRef newCgIm = CGImageCreateCopy(_original_image.CGImage);
    UIImage *org_image = [UIImage imageWithCGImage:newCgIm scale:_original_image.scale orientation:_original_image.imageOrientation];

    switch (org_image.imageOrientation) {
        case UIImageOrientationUp:    // 0도, 기본값.
        case UIImageOrientationUpMirrored:
            break;
        case UIImageOrientationDown:  // 180도
        case UIImageOrientationDownMirrored:
            org_image = [org_image rotateInDegrees:180];
            break;
        case UIImageOrientationLeft:  // 90도
        case UIImageOrientationLeftMirrored:
            org_image = [org_image rotateInDegrees:90];
            break;
        case UIImageOrientationRight: // -90도
        case UIImageOrientationRightMirrored:
            org_image = [org_image rotateInDegrees:-90];
            break;
    }
    NSData* data = [self dataByRemovingExif:UIImagePNGRepresentation(org_image)];
    org_image = [UIImage imageWithData:data];

    _edit_image = [UIImage imageWithData:UIImageJPEGRepresentation(org_image, 100)];
    _edit_image = [_edit_image brightenWithValue:(_nbrightness - 0.5) * 100];
    _edit_image = [_edit_image saturate:(_nsaturation + 0.5)];
    _edit_image = [_edit_image contrastAdjustmentWithValue:(_ncontrast - 0.5) * 100];

    CGFloat frame_width = [_frame_right_line frame].origin.x + [_frame_right_line frame].size.width - [_frame_left_line frame].origin.x;
    CGFloat frame_height = [_frame_bottom_line frame].origin.y + [_frame_bottom_line frame].size.height - [_frame_top_line frame].origin.y;

    CGRect _image_view_frame = [_image_view frame];

    CGFloat startx = [_frame_left_line frame].origin.x - _image_view_frame.origin.x;
    CGFloat starty = [_frame_top_line frame].origin.y - _image_view_frame.origin.y;
    CGFloat ratio = _edit_image.size.width / _image_view_frame.size.width;

    CGRect cropRect = CGRectMake(startx * ratio, starty * ratio, frame_width * ratio, frame_height * ratio);
    CGImageRef imageRef = CGImageCreateWithImageInRect([_edit_image CGImage], cropRect);
    _edit_image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [self performSegueWithIdentifier:@"IDPhotosPreviewSegue" sender:self];
}

- (float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

@end
