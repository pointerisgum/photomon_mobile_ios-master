//
//  MonthlyConfirmOrderPopup.m
//  PHOTOMON
//
//  Created by 곽세욱 on 09/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MonthlyConfirmOrderPopup.h"
#import "MonthlyBaby.h"
#import "Common.h"
#import "UIView+Toast.h"

@interface MonthlyConfirmOrderPopup ()

@end

@implementation MonthlyConfirmOrderPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	[_uploadCountLabel setText:[@([MonthlyBaby inst].currentUploadCount) stringValue]];
	
	if ([MonthlyBaby inst].markDate) {
		[_markDateLabel setText:@"날짜 표기"];
	}
	else {
		[_markDateLabel setText:@"날짜 미표기"];
	}
	
	[_titleLabel setText:[MonthlyBaby inst].mainTitle];
	
	switch ([MonthlyBaby inst].designTheme) {
		case 0:
			[_themeLabel setText:@"심플"];
			break;
		case 1:
			[_themeLabel setText:@"디자인 & 패턴"];
			break;
		case 2:
			[_themeLabel setText:@"컬러"];
			break;
	}
	
	switch ([MonthlyBaby inst].orderingType) {
		case 0:
			[_orderingTypeLabel setText:@"스타일"];
			break;
		case 1:
			[_orderingTypeLabel setText:@"스토리"];
			break;
	}
	
	NSString *addProduct = @"";
	
	for (MonthlyAddProductInfo *info in [MonthlyBaby inst].selectedAddProduct) {
		if (addProduct.length > 0) {
			addProduct = [addProduct stringByAppendingString:@", "];
		}
		addProduct = [addProduct stringByAppendingString:info.pkgname];
	}
	
	if ([addProduct length] > 0 ) {
		[_addProductLabel setText:addProduct];
	}
	else {
		[_addProductLabel setText:@"선택없음"];
	}
	
	if ([MonthlyBaby inst].isSeperated) {
		[_divisionLabel setText:@"네"];
	}
	else {
		[_divisionLabel setText:@"아니오"];
	}
	
	int orderBookCount = [MonthlyBaby inst].isSeperated ? 2 : 1;
	orderBookCount *= [MonthlyBaby inst].orderBookCount;
	
	[_orderBookCountLabel setText:[@(orderBookCount) stringValue]];
}

- (void) setData:(nonnull id<MonthlyConfirmOrderDelegate>) delegate
{
	_delegate = delegate;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)order:(id)sender {
	// 최종 주문
	
//	[self sendToServer];
	
	NSURL *url = [Common buildQueryURL:URL_MONTHLY_ADD_CARD query:@[]];
	
	// prepare params
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	
	[params setObject:[Common info].user.mUserid forKey:@"userid"];
	
	if ([MonthlyBaby inst].markDate) {
		[params setObject:@"Y" forKey:@"dateDisplay"];
	} else {
		[params setObject:@"N" forKey:@"dateDisplay"];
	}
	
	switch ([MonthlyBaby inst].designTheme) {
		case 0:
			[params setObject:@"simple" forKey:@"designTheme"];
			break;
		case 1:
			[params setObject:@"design" forKey:@"designTheme"];
			break;
		case 2:
			[params setObject:@"color" forKey:@"designTheme"];
			break;
	}
	
	switch ([MonthlyBaby inst].orderingType) {
		case 0:
			[params setObject:@"style" forKey:@"layout"];
			break;
		case 1:
			[params setObject:@"layout" forKey:@"layout"];
			break;
	}
	
	[params setObject:[MonthlyBaby inst].coverImageKey forKey:@"coverimgkey"];
	[params setObject:[MonthlyBaby inst].trimInfo forKey:@"covertriminfo"];
	
	[params setObject:[MonthlyBaby inst].mainTitle forKey:@"bookTitle"];
	[params setObject:[MonthlyBaby inst].subTitle forKey:@"bookSubTitle"];
	
	NSString *addProductStr = @"";
	
	for (MonthlyAddProductInfo *info in [MonthlyBaby inst].selectedAddProduct) {
		if ([addProductStr length] > 0)
			addProductStr =[addProductStr stringByAppendingString:@"||"];
		
		addProductStr = [addProductStr stringByAppendingString:[NSString stringWithFormat:@"%@^%@^%@", info.intnum, info.seq, info.price]];
	}
	
	[params setObject:addProductStr forKey:@"addProductInfo"];
	
	[params setObject:@([MonthlyBaby inst].orderBookCount) forKey:@"bookCount"];
	
	if ([MonthlyBaby inst].isSeperated) {
		[params setObject:@(2) forKey:@"divBook"];
	} else {
		[params setObject:@(1) forKey:@"divBook"];
	}
	
	[[MonthlyBaby inst] sendToServer:url params:params delegate:self];
}

- (IBAction)close:(id)sender {
	// 그냥 닫음
	[[MonthlyBaby inst].selectedAddProduct removeAllObjects];
	[MonthlyBaby inst].orderBookCount = 1;
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	//	NSLog(@"--> %.5f complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSError *error;
	
	NSDictionary *json_data = [NSJSONSerialization
							   JSONObjectWithData:data
							   options:kNilOptions
							   error:&error];
	if (error) {
		NSLog(@"error : %@", error.localizedDescription);
		[self.view makeToast:@"주문 도중 오류가 발생하였습니다."];
//		[self dismissViewControllerAnimated:NO completion:^{
//			if (_delegate) {
//				[_delegate confirmOrder:NO url:error.localizedDescription];
//			}
//		}];
	} else {
		NSString *code = [json_data objectForKey:@"code"];
		NSString *msg = [json_data objectForKey:@"msg"];
		NSString *url = [json_data objectForKey:@"moveurl"];
		
		if ([code isEqualToString:@"0000"]) {
			[self dismissViewControllerAnimated:NO completion:^{
				if (_delegate) {
					[_delegate confirmOrder:YES url:url];
				}
			}];
		} else {
			[self.view makeToast:msg];
			[self dismissViewControllerAnimated:NO completion:^{
				if (_delegate) {
					[_delegate confirmOrder:NO url:url];
				}
			}];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// A response has been received, this is where we initialize the instance var you created
	// so that we can append data to it in the didReceiveData method
	// Furthermore, this method is called each time there is a redirect so reinitializing it
	// also serves to clear it
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[connection cancel];
	//에러처리 필요
	//	[_delegate uploadPhotoDone:NO];
	[self.view makeToast:@"주문 도중 오류가 발생하였습니다."];
//	[self dismissViewControllerAnimated:NO completion:^{
//		if (_delegate) {
//			[_delegate confirmOrder:NO url:@"Error"];
//		}
//	}];
}
@end
