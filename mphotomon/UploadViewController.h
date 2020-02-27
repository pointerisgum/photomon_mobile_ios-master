//
//  UploadViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadViewController : UIViewController <NSURLConnectionDataDelegate>

@property (assign) UIBackgroundTaskIdentifier backgroundTaskId;

@property (assign) BOOL is_canceled;
@property (assign) int upload_index;
@property (strong, nonatomic) NSMutableArray *uploadPhotos;

@property (strong, nonatomic) IBOutlet UIImageView *thumbView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressPhoto;
@property (strong, nonatomic) IBOutlet UIProgressView *progressTotal;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (void)initState;
- (IBAction)cancel:(id)sender;

@end
