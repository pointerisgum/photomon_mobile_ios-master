#import "IDPhotosCameraViewController.h"
#import "IDPhotosEditorViewController.h"
#import "IDPhotosCameraPreviewViewController.h"
#import "IDPhotosCameraImageListViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "UIImage+Filtering.h"
#import "UIImage+Rotating.h"
#import "ImageFilter.h"
#import <math.h>
#import "QuartzCore/QuartzCore.h"
#import <AudioToolbox/AudioToolbox.h>

//#define _TEST_MODE_

static BOOL dispatchFlag = false;

@interface IDPhotosCameraViewController ()
@end

@implementation IDPhotosCameraViewController

@synthesize timer;
@synthesize timer_rel;
@synthesize camera_view;
@synthesize sampleBufferCallbackQueue;
@synthesize output;
@synthesize session;

static int timer_count;
static AVCaptureDevice *device;
static AVCaptureVideoPreviewLayer *current_preview_layer;

- (void)viewDidLoad {
	[super viewDidLoad];

	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"camera_shutter_sound" ofType:@"wav"]];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_shutter_sound_id);

	[self popupGuidePage:GUIDE_IDPHOTOS_CAMERA];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	dispatchFlag = false;

	[self.navigationController setNavigationBarHidden:YES animated:NO];

#ifndef _TEST_MODE_
	session = [[AVCaptureSession alloc]init];
	session.sessionPreset = AVCaptureSessionPresetPhoto;
	device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

	if (!input)
		NSLog(@"No Input");

	[session addInput:input];
	output = [[AVCaptureVideoDataOutput alloc] init];
	[session addOutput:output];
	output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };

	AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	camera_view = self.view;
	previewLayer.frame = camera_view.bounds;
	previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

	[self.view.layer addSublayer:previewLayer];
	current_preview_layer = previewLayer;
#endif

	_bsnapshot = NO;

	UITapGestureRecognizer *back_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
	back_tap.numberOfTapsRequired = 1;
	[_btn_back setUserInteractionEnabled:YES];
	[_btn_back addGestureRecognizer:back_tap];

	UITapGestureRecognizer *flash_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFlash:)];
	flash_tap.numberOfTapsRequired = 1;
	[_btn_flash setUserInteractionEnabled:YES];
	[_btn_flash addGestureRecognizer:flash_tap];

	UITapGestureRecognizer *rel_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRel:)];
	rel_tap.numberOfTapsRequired = 1;
	[_btn_rel setUserInteractionEnabled:YES];
	[_btn_rel addGestureRecognizer:rel_tap];

	UITapGestureRecognizer *time_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTime:)];
	time_tap.numberOfTapsRequired = 1;
	[_btn_time setUserInteractionEnabled:YES];
	[_btn_time addGestureRecognizer:time_tap];

	UITapGestureRecognizer *camera_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCamera:)];
	camera_tap.numberOfTapsRequired = 1;
	[_btn_camera setUserInteractionEnabled:YES];
	[_btn_camera addGestureRecognizer:camera_tap];

	UITapGestureRecognizer *snapshot_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSnapshot:)];
	snapshot_tap.numberOfTapsRequired = 1;
	[_btn_snapshot setUserInteractionEnabled:YES];
	[_btn_snapshot addGestureRecognizer:snapshot_tap];

	UITapGestureRecognizer *list_image_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onListImage:)];
	list_image_tap.numberOfTapsRequired = 1;
	[_list_image setUserInteractionEnabled:YES];
	[_list_image addGestureRecognizer:list_image_tap];

	_top_view.layer.zPosition = 9999;
	_bottom_view.layer.zPosition = 9999;

	_frame_line_t.layer.zPosition = 9999;
	_frame_line_m.layer.zPosition = 9999;
	_frame_line_b_container.layer.zPosition = 9998;
	_frame_line_b.layer.zPosition = 9999;
	_frame_line_b_icon_l.layer.zPosition = 10001;
	_frame_line_b_icon_r.layer.zPosition = 10001;
	_frame_line_v.layer.zPosition = 9999;
	_count_view.layer.zPosition = 10000;
	_list_image.layer.zPosition = 10000;

	float c_space_1 = (self.view.frame.size.width - _btn_rel.frame.size.width) / 2.0f - (_btn_back.frame.origin.x + _btn_back.frame.size.width);
	c_space_1 = (c_space_1 - _btn_flash.frame.size.width) / 2.0f;
	_constraints_btn_flash_leading_space.constant = c_space_1;

	float c_space_2 = (self.view.frame.size.width - _btn_camera.frame.size.width) - (self.view.frame.size.width / 2.0f + _btn_rel.frame.size.width / 2.0f);
	c_space_2 = (c_space_2 - _btn_time.frame.size.width) / 2.0f;
	_constraints_btn_time_tailing_space.constant = c_space_2;

	_flash_mode = -1;
	_rel_mode = -1;
	_time_mode = -1;
	_camera_mode = -1;
	_shot_cnt = 0;

	[self onFlash:nil];
	[self onRel:nil];
	[self onTime:nil];
	[self onCamera:nil];

	timer_count = 0;
	_count_view.hidden = YES;

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];


	if(dispatchFlag == false) {
		sampleBufferCallbackQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
		[output setSampleBufferDelegate:self queue:sampleBufferCallbackQueue];

		dispatchFlag = true;
	}

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	NSString *docPath = [[Common info] documentPath];
	NSString *baseFolder = [NSString stringWithFormat:@"%@/idphotos/camera", docPath];

	NSError *error = nil;
	BOOL isDir = YES;
	if( [[NSFileManager defaultManager] fileExistsAtPath:baseFolder isDirectory:&isDir]==NO ) {
		NSLog(@"EXISTS : NO");
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:baseFolder
           withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
		else
            NSLog(@"Success creating directory path");
	}

	NSArray *image_paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:baseFolder error: &error];
	NSLog(@"[image_paths count] : %ld", (unsigned long)[image_paths count]);
	if( [image_paths count]>0 ) {
		NSString* image_path = [NSString stringWithFormat:@"%@/idphotos/camera/%@", [[Common info] documentPath], (NSString*)[image_paths objectAtIndex:[image_paths count]-1]];
		if ([[NSFileManager defaultManager] fileExistsAtPath:image_path]) {
			NSData *imageData = [NSData dataWithContentsOfFile:image_path];            

			UIImage* img = [UIImage imageWithData:imageData];

			_list_image.contentMode = UIViewContentModeScaleAspectFill; 
			_list_image.clipsToBounds = YES;

			_list_image.image = img;
		}
		_list_image.hidden = NO;
	}
	else {
		_list_image.hidden = YES;
	}
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	[session startRunning];
}

- (IBAction)onFlash:(id)sender {
	_flash_mode++;
	if( _flash_mode>2 ) 
		_flash_mode = 0;

	if( _flash_mode==0 ) {
		_btn_flash.image = [UIImage imageNamed: @"btn_fls_1_180x180.png"];
		[self turnTorchOn:NO];
	}
	else if( _flash_mode==1 ) {
		_btn_flash.image = [UIImage imageNamed: @"btn_fls_2_180x180.png"];
		[self turnTorchOn:YES];
	}
	else if( _flash_mode==2 ) {
		_btn_flash.image = [UIImage imageNamed: @"btn_fls_3_180x180.png"];
		[self turnTorchOn:YES];
	}
}

- (IBAction)onRel:(id)sender {
	_rel_mode++;
	if( _rel_mode>3 ) 
		_rel_mode = 0;

	if( _rel_mode==0 ) 
		_btn_rel.image = [UIImage imageNamed: @"btn_rel_1_180x180.png"];
	else if( _rel_mode==1 ) 
		_btn_rel.image = [UIImage imageNamed: @"btn_rel_2_180x180.png"];
	else if( _rel_mode==2 ) 
		_btn_rel.image = [UIImage imageNamed: @"btn_rel_3_180x180.png"];
	else if( _rel_mode==3 ) 
		_btn_rel.image = [UIImage imageNamed: @"btn_rel_4_180x180.png"];
}

- (IBAction)onTime:(id)sender {
	_time_mode++;
	if( _time_mode>3 ) 
		_time_mode = 0;

	NSLog(@"onTime");
	if( _time_mode==0 )
		_btn_time.image = [UIImage imageNamed: @"btn_time1_180x180.png"];
	else if( _time_mode==1 ) 
		_btn_time.image = [UIImage imageNamed: @"btn_time2_180x180.png"];
	else if( _time_mode==2 ) 
		_btn_time.image = [UIImage imageNamed: @"btn_time3_180x180.png"];
	else if( _time_mode==3 ) 
		_btn_time.image = [UIImage imageNamed: @"btn_time4_180x180.png"];
}

- (IBAction)onCamera:(id)sender {
	_camera_mode++;
	if( _camera_mode>1 ) 
		_camera_mode = 0;

#ifndef _TEST_MODE_
	[session stopRunning];

	session = [[AVCaptureSession alloc]init];
	session.sessionPreset = AVCaptureSessionPresetPhoto;

	if( _camera_mode==0 )
		device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	else
		device = [self frontCamera];

	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

	[session addInput:input];

	output = [[AVCaptureVideoDataOutput alloc] init];

	[session addOutput:output];

	output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };

	//Preview Layer
	AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	camera_view = self.view;
	previewLayer.frame = camera_view.bounds;
	previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

	current_preview_layer = nil;
	[self.view.layer addSublayer:previewLayer];
	current_preview_layer = previewLayer;

	sampleBufferCallbackQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[output setSampleBufferDelegate:self queue:sampleBufferCallbackQueue];
	[session startRunning];
#endif
}

- (IBAction)onSnapshot:(id)sender {
#ifndef _TEST_MODE_
	_bsnapshot = NO;
	timer_count = 0;
	if( _time_mode>0 ) {
		if( _time_mode==1 ) {
			_bsnapshot = NO;
			timer_count = 3;
			timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
		}
		else if( _time_mode==1 ) {
			_bsnapshot = NO;
			timer_count = 5;
			timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
		}
		else if( _time_mode==1 ) {
			_bsnapshot = NO;
			timer_count = 10;
			timer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
		}
	}
	else {
		[self doShot:nil];
	}
#else
	_capture_image = [UIImage imageNamed:@"main_polaroid.jpg"];
	_image_path = [[NSBundle mainBundle] pathForResource:@"main_polaroid" ofType:@"jpg"];
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[self performSegueWithIdentifier:@"IDPhotosCameraPreviewSegue" sender:self];
#endif
}

- (IBAction)onTimer:(id)sender {
	if( timer_count<=0 ) {
		[timer invalidate];
		timer = nil;
		_count_view.hidden = YES;
		[self doShot:nil];
	} else {
		_count_view.hidden = NO;
	}

	_count_label.text = [NSString stringWithFormat:@"%d", timer_count];

	timer_count--;
	if( timer_count<=0 )
		timer_count = 0;

}

- (IBAction)doShot:(id)sender {
	_shot_cnt++;
	_bsnapshot = YES;
	NSLog(@"doShot : %d", _shot_cnt);
	timer_rel =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatShot:) userInfo:nil repeats:YES];
}

- (IBAction)repeatShot:(id)sender {
	if( (_rel_mode==0 && _shot_cnt==1) || (_rel_mode==1 && _shot_cnt==3) || (_rel_mode==2 && _shot_cnt==5) || (_rel_mode==3 && _shot_cnt==10) ) {
		NSLog(@"repeatShot cancel");
		[timer_rel invalidate];
		timer_rel = nil;
	} 
	else {
		_shot_cnt++;
		_bsnapshot = YES;
		NSLog(@"doShot : %d", _shot_cnt);
	}
}

- (IBAction)onListImage:(id)sender {
#ifndef _TEST_MODE_
	[session stopRunning];
#endif
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		[self performSegueWithIdentifier:@"IDPhotosCameraImageListSegue" sender:self];
	});
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
#ifndef _TEST_MODE_
	if( _bsnapshot==YES ) {
		_bsnapshot = NO;
		_capture_image = [self imageFromSampleBuffer:sampleBuffer];
		if( _camera_mode==1 ) {
			_capture_image = [_capture_image verticalFlip];
		}

		AudioServicesPlaySystemSound(1108);

		{
			NSString *cameraPhotoFolder = [NSString stringWithFormat:@"%@/idphotos/camera", [[Common info] documentPath]];
			NSError *error = nil;
			BOOL isDir = YES;

			if( [[NSFileManager defaultManager] fileExistsAtPath:cameraPhotoFolder isDirectory:&isDir]==NO ) {
				NSLog(@"EXISTS : NO");
				NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
																 forKey:NSFileProtectionKey];
				[[NSFileManager defaultManager] createDirectoryAtPath:cameraPhotoFolder
				   withIntermediateDirectories:YES
									attributes:attr
										 error:&error];
				if (error)
					NSLog(@"Error creating directory path: %@", [error localizedDescription]);
				else
					NSLog(@"Success creating directory path");
			}
		}

		NSData *image_data = UIImageJPEGRepresentation(_capture_image, 1.0f);
		NSString *docPath = [[Common info] documentPath];  // 도큐먼트 폴더 찾기
		NSString *baseFolder = [NSString stringWithFormat:@"%@/idphotos", docPath];
		_image_path = [NSString stringWithFormat:@"%@/camera/%ld.jpg", baseFolder, (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970])];
		[image_data writeToFile:_image_path atomically:YES];

		NSLog(@"captureOutput : _shot_cnt : %d", _shot_cnt);
		NSLog(@"captureOutput : _rel_mode : %d", _rel_mode);
		if( (_rel_mode==0 && _shot_cnt==1) || (_rel_mode==1 && _shot_cnt==3) || (_rel_mode==2 && _shot_cnt==5) || (_rel_mode==3 && _shot_cnt==10) ) {
			[session stopRunning];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.navigationController setNavigationBarHidden:NO animated:NO];
				//[self performSegueWithIdentifier:@"IDPhotosEditorSegue" sender:self];
				[self performSegueWithIdentifier:@"IDPhotosCameraPreviewSegue" sender:self];
			});
		}
	}
#endif
}

// Create a UIImage from sample buffer data
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	CGImageRef quartzImage = CGBitmapContextCreateImage(context);

	CVPixelBufferUnlockBaseAddress(imageBuffer,0);

	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);

	UIImage *image =  [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];

	CGImageRelease(quartzImage);

	return (image);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IDPhotosEditorSegue"]) {
        IDPhotosEditorViewController *vc = [segue destinationViewController];
        if (vc) {
			vc.fromCamera = YES;
			vc.original_image = _capture_image;
        }
    }
    else if ([segue.identifier isEqualToString:@"IDPhotosCameraPreviewSegue"]) {
        IDPhotosCameraPreviewViewController *vc = [segue destinationViewController];
        if (vc) {
			vc.image_path = _image_path;
        }
    }	
    else if ([segue.identifier isEqualToString:@"IDPhotosCameraImageListSegue"]) {
        IDPhotosCameraImageListViewController *vc = [segue destinationViewController];
        if (vc) {
        }
    }	
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

- (void)turnTorchOn:(bool)on {
	// check if flashlight available
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) {
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		if ([device hasTorch] && [device hasFlash]){

			[device lockForConfiguration:nil];
			if (on) {
				[device setTorchMode:AVCaptureTorchModeOn];
				[device setFlashMode:AVCaptureFlashModeOn];
				//torchIsOn = YES; //define as a variable/property if you need to know status 
			} else {
				[device setTorchMode:AVCaptureTorchModeOff];
				[device setFlashMode:AVCaptureFlashModeOff];
				//torchIsOn = NO;            
			}
			[device unlockForConfiguration];
		}
	} 
}

- (void)move:(id)sender {
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];

    static CGFloat firstCenterX = 0;
    static CGFloat firstCenterY = 0;

    CGPoint currentlocation = [(UIPanGestureRecognizer*)sender locationInView:self.view];
    if( currentlocation.y >= ([_frame_line_b_container frame].origin.y + [_frame_line_b_container frame].size.height) || currentlocation.y < [_frame_line_b_container frame].origin.y )
        return;

    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstCenterX = [_frame_line_b_container center].x;
        firstCenterY = [_frame_line_b_container center].y;
    }

    translatedPoint = CGPointMake(firstCenterX, firstCenterY+translatedPoint.y);

    BOOL bMovable = YES;
	if( translatedPoint.y < [_frame_line_v frame].origin.y + ([_frame_line_v frame].size.height * 0.45) )
		bMovable = NO;
	if( translatedPoint.y > [_frame_line_v frame].origin.y + ([_frame_line_v frame].size.height * 0.92) )
		bMovable = NO;

    if( bMovable==YES )
	    [_frame_line_b_container setCenter:translatedPoint];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - GuideDelegate methods

- (void)popupGuidePage:(NSString *)guide_id {
    if ([[Common info] checkGuideUserDefault:guide_id]) {
        GuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GuidePage"];
        if (vc) {
            vc.guide_id = guide_id;
            vc.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)closeGuide {
}

- (void)viewWillLayoutSubviews {
	float space = self.view.bounds.size.height * 0.1f;
	_constraints_frame_line_top_space.constant = _top_view.frame.size.height + space;
	_constraints_frame_line_bottom_space.constant = _bottom_view.frame.size.height + space;

	float height = self.view.bounds.size.height - _constraints_frame_line_top_space.constant + _constraints_frame_line_bottom_space.constant;
	_constraints_frame_line_m_top_space.constant = height * 0.15f;

}

@end