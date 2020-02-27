//
//  IDPhotosUploadViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 14..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDPhotosUpload.h"

@interface IDPhotosUploadViewController : UIViewController <NSURLConnectionDataDelegate, PhotobookDelegate>

@property (assign) UIBackgroundTaskIdentifier backgroundTaskId;

@property (strong, nonatomic) UIImage *upload_image;
@property (strong, nonatomic) IDPhotosUpload *uploader;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *wait_indicator;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;
@property (assign) BOOL is_canceled;
@property (assign) int upload_index;

@property (strong, nonatomic) IBOutlet UIImageView *thumbView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressPhoto;
@property (strong, nonatomic) IBOutlet UIProgressView *progressTotal;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

- (void)initState;
- (IBAction)cancel:(id)sender;

@end
