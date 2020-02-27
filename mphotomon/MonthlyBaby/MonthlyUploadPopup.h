//
//  MonthlyUploadPopup.h
//  PHOTOMON
//
//  Created by 곽세욱 on 07/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthlyBaby.h"

NS_ASSUME_NONNULL_BEGIN


@interface MonthlyUploadPopup : UIViewController < NSURLConnectionDataDelegate >
#pragma Data
@property (assign) int totalCount;
@property (assign) int uploadCount;
@property (assign) float cur_upload_per;
@property (assign) NSString *svcmode;

@property (assign) UIBackgroundTaskIdentifier backgroundTaskId;

@property (copy) void(^uploadDoneOp)(BOOL, NSString*);

- (void) setData:(int)totalCount svcmode:(NSString *)svcmode uploadDoneOp:(void(^)(BOOL, NSString*))uploadDoneOp;

#pragma UI
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (strong, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadCountLabel;

@end

NS_ASSUME_NONNULL_END
