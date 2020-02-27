//
//  FrameUploadViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 2. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PhotobookUpload.h"

@protocol FrameUploadDelegate <NSObject>
@optional
- (void)completeUpload;
@end

@interface FrameUploadViewController : BaseViewController <NSURLConnectionDataDelegate, PhotobookDelegate>

@property (strong, nonatomic) NSMutableArray *photofilelist;
@property (strong, nonatomic) id<FrameUploadDelegate> delegate;

@property (assign) UIBackgroundTaskIdentifier backgroundTaskId;

@property (strong, nonatomic) PhotobookUpload *uploader;
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
