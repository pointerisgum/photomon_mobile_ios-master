//
//  DdukddakUploadPopupViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 2019/10/12.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DdukddakUploadPopupViewController : UIViewController < NSURLConnectionDataDelegate >
#pragma Data
@property (assign) int totalCount;
@property (assign) int uploadCount;
@property (assign) float cur_upload_per;
@property (assign) NSString *svcmode;
@property (assign) NSString *uploadURL;

@property (assign) UIBackgroundTaskIdentifier backgroundTaskId;

@property (copy) void(^uploadDoneOp)(BOOL, NSString*);

- (void) setData:(int)totalCount uploadURL:(NSString *)url svcmode:(NSString *)svcmode uploadDoneOp:(void(^)(BOOL, NSString*))uploadDoneOp;

#pragma UI
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadCountLabel;

@end

NS_ASSUME_NONNULL_END
