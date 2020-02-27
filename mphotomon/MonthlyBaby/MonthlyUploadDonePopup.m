//
//  MonthlyUploadDonePopup.m
//  PHOTOMON
//
//  Created by 곽세욱 on 07/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MonthlyUploadDonePopup.h"
#import "Common.h"

@interface MonthlyUploadDonePopup ()

@end

@implementation MonthlyUploadDonePopup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	int beforeCount = [MonthlyBaby inst].currentUploadCount;
	
	NSString *curUpCntStr = [NSString stringWithFormat:@"%d", _uploadCount];
	
	[[MonthlyBaby inst] loadData:@"imgcount^deadline"];
	
	int afterCount = [MonthlyBaby inst].currentUploadCount;
	
	int realUploadCount = afterCount - beforeCount;
	int diffCount = _uploadCount - realUploadCount;
	
	if (diffCount > 0) {
		[_diffCountLabel setHidden: NO];
		[_diffDiscriptionLabel setHidden: NO];
		[_diffCountLabel setText:[NSString stringWithFormat:@"%d", diffCount]];
	}
	else {
		[_diffCountLabel setHidden: YES];
		[_diffDiscriptionLabel setHidden: YES];
	}
	
//	NSDictionary *json_data = [self getSubscriptionInfo:@"imgcount^deadline^maxcount^upload_maxcount"];
	NSString *totalUpCntStr = [NSString stringWithFormat:@"%d", [MonthlyBaby inst].currentUploadCount];
	NSString *dealineStr = [[MonthlyBaby inst] deadline];
//	NSString *maxCntPerBookStr = [json_data objectForKey:@"maxcount"];
//	NSString *maxCntForUploadStr = [json_data objectForKey:@"upload_maxcount"];
	
//	if ([dealineStr length] >= 8) {
//		[dealineStr substringWithRange:NSMakeRange(0, 4)];
	
	NSString *yearStr = [dealineStr substringWithRange:NSMakeRange(0, 4)];
	NSString *monthStr = [dealineStr substringWithRange:NSMakeRange(4, 2)];
	NSString *dateStr = [dealineStr substringWithRange:NSMakeRange(6, 2)];
	monthStr = [NSString stringWithFormat:@"%d", [monthStr intValue]];
	dateStr = [NSString stringWithFormat:@"%d", [dateStr intValue]];
//	}
	//238, 189, 59
	
	[_totalUploadCountLabel setText:totalUpCntStr];
	[_currentUploadCountLabel setText:curUpCntStr];
	[_dueDateYearLabel setText:yearStr];
	[_dueDateMonthLabel setText:monthStr];
	[_dueDateDateLabel setText:dateStr];
	
	[_uploadButton.layer setBorderWidth:1];
	
	if([MonthlyBaby inst].currentUploadCount < 23)
	{
		[_makeButton setHidden:YES];
		
		if (_popupView != nil && _saveButton != nil && _uploadButton != nil) {
			CGRect btFrame = _saveButton.frame;
			btFrame.origin.y += 25;
			_saveButton.frame = btFrame;
			
			btFrame = _uploadButton.frame;
			btFrame.origin.y += 25;
			_uploadButton.frame = btFrame;
		}
	}
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSDictionary *) getSubscriptionInfo:(NSString *)getcode {
	NSURL *url = [Common buildQueryURL:URL_GET_SUBSCRIPTION_INFO
									query:@[
											[NSURLQueryItem queryItemWithName:@"userid" value:[Common info].user.mUserid]
											,[NSURLQueryItem queryItemWithName:@"uniquekey" value:[Common info].device_uuid]
											,[NSURLQueryItem queryItemWithName:@"getcode" value:getcode]
											  ]];
	
	NSDictionary *json_data;
	NSData *ret_val = [[Common info] downloadSyncWithURL:url];
	NSError *error;
	
	if (ret_val != nil) {
		json_data = [NSJSONSerialization
					 JSONObjectWithData:ret_val
					 options:kNilOptions
					 error:&error];
		if (error) {
			NSLog(@"error : %@", error.localizedDescription);
		}
		
		return json_data;
	}
	
	return nil;
}

- (IBAction)save:(id)sender {
	[self dismissViewControllerAnimated:NO completion:^{
		[_rootView dismissViewControllerAnimated:NO completion:^{
			if (_delegate) {
				[_delegate saveMidTerm];
			}
		}];
	}];
}

- (IBAction)order:(id)sender {
	[self dismissViewControllerAnimated:NO completion:^{
		[_rootView dismissViewControllerAnimated:NO completion:^{
			if (_delegate) {
				[_delegate orderNow];
			}
		}];
	}];
}

- (IBAction)upload:(id)sender{
	[self dismissViewControllerAnimated:NO completion:^{
		[_rootView dismissViewControllerAnimated:NO completion:^{
			if (_delegate) {
				[_delegate selectPhotos];
			}
		}];
	}];
}

- (IBAction)close:(id)sender {
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)setData:(int)uploadCount delegate:(nonnull id<MonthlyAfterUploadActionDelegate>)delegate rootView:(UIViewController *)rootView {
	_uploadCount = uploadCount;
	_delegate = delegate;
	_rootView = rootView;
}

@end
