#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GuideViewController.h"

@interface IDPhotosCameraViewController : UIViewController<UIImagePickerControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, GuideDelegate> {
    NSTimer *timer;
    NSTimer *timer_rel;
    UIView *cameraView;
    dispatch_queue_t sampleBufferCallbackQueue;
    AVCaptureVideoDataOutput *output;
    AVCaptureSession *session;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timer_rel;
@property (nonatomic, strong) UIView *camera_view;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, readonly) dispatch_queue_t sampleBufferCallbackQueue;
@property (nonatomic, readonly) AVCaptureVideoDataOutput *output;
@property (weak, nonatomic) IBOutlet UIImageView *btn_back;
@property (weak, nonatomic) IBOutlet UIImageView *btn_flash;
@property (weak, nonatomic) IBOutlet UIImageView *btn_rel;
@property (weak, nonatomic) IBOutlet UIImageView *btn_time;
@property (weak, nonatomic) IBOutlet UIImageView *btn_camera;
@property (weak, nonatomic) IBOutlet UIImageView *btn_snapshot;
@property (weak, nonatomic) IBOutlet UIView *top_view;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (weak, nonatomic) IBOutlet UIView *frame_line_t;
@property (weak, nonatomic) IBOutlet UIView *frame_line_m;
@property (weak, nonatomic) IBOutlet UIView *frame_line_b_container;
@property (weak, nonatomic) IBOutlet UIView *frame_line_b;
@property (weak, nonatomic) IBOutlet UIView *frame_line_v;
@property (weak, nonatomic) IBOutlet UIView *count_view;
@property (weak, nonatomic) IBOutlet UILabel *count_label;
@property (weak, nonatomic) IBOutlet UIImageView *list_image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_frame_line_top_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_frame_line_bottom_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_frame_line_m_top_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_btn_flash_leading_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_btn_time_tailing_space;
@property (weak, nonatomic) IBOutlet UIImageView *frame_line_b_icon_l;
@property (weak, nonatomic) IBOutlet UIImageView *frame_line_b_icon_r;

@property (nonatomic) BOOL bsnapshot;
@property (nonatomic, strong) UIImage *capture_image;

@property (nonatomic) SystemSoundID shutter_sound_id;

@property (nonatomic) int flash_mode;
@property (nonatomic) int rel_mode;
@property (nonatomic) int time_mode;
@property (nonatomic) int camera_mode;
@property (nonatomic) int shot_cnt;
@property (strong, nonatomic) NSString *image_path;

- (IBAction)cancel:(id)sender;
- (IBAction)onFlash:(id)sender;
- (IBAction)onRel:(id)sender;
- (IBAction)onTime:(id)sender;
- (IBAction)onCamera:(id)sender;
- (IBAction)onSnapshot:(id)sender;
- (IBAction)onListImage:(id)sender;

@end

