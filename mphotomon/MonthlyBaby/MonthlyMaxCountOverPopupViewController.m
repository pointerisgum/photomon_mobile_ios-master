//
//  MonthlyMaxCountOverPopupViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 08/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MonthlyMaxCountOverPopupViewController.h"
#import "Common.h"

@interface MonthlyMaxCountOverPopupViewController ()

@end

@implementation MonthlyMaxCountOverPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_selectOptionIdx = 0;
	[self updateOptionStr];
	
	[_totalUploadCountLabel setText:[NSString stringWithFormat:@"%d", [MonthlyBaby inst].currentUploadCount]];
	
	[_maxUploadCountLabel setText:[NSString stringWithFormat:@"%d", [MonthlyBaby inst].maxUploadCountPerBook]];
	
	[_optionButton.layer setBorderWidth:1];
	
}

-(void)updateOptionStr {
	if (_selectOptionIdx == 0)
	{
		[_descriptionLabel setText:@"월간포토몬을\r\n2권의 앨범으로 나누어 제작합니다."];
		[_optionMainLabel setText:@"네. 2권으로 나누어 만들래요. (+5,000원)"];
		int perBookCount = ceil([MonthlyBaby inst].currentUploadCount / 2.0);
		[_optionSubLabel setText:[NSString stringWithFormat:@"(1권당 %d장의 사진이 들어갑니다.)", perBookCount]];
//		int perPageCount = perBookCount / 23;
//		[_optionSubLabel setText:[NSString stringWithFormat:@"(1권당 %d장 / 1p당 %d장의 사진이 들어갑니다.)", perBookCount, perPageCount]];
	}
	else {
		[_descriptionLabel setText:@"월간포토몬을\r\n1권의 앨범으로 제작합니다."];
		[_optionMainLabel setText:@"아니오. 1권으로 만들래요."];
		[_optionSubLabel setText:[NSString stringWithFormat:@"(%d장 까지 사진이 올라가고 초과된 사진은 삭제됩니다.)", [MonthlyBaby inst].maxUploadCountPerBook]];
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

- (IBAction)selectOption:(id)sender {
	UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *alert_action = nil;
	alert_action = [UIAlertAction actionWithTitle:@"2권 제작" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		
		self->_selectOptionIdx = 0;
		
		[self updateOptionStr];
		[vc dismissViewControllerAnimated:YES completion:nil];
	}];
	[vc addAction:alert_action];
	
	alert_action = [UIAlertAction actionWithTitle:@"1권 제작" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		
		self->_selectOptionIdx = 1;
		
		[self updateOptionStr];
		[vc dismissViewControllerAnimated:YES completion:nil];
	}];
	[vc addAction:alert_action];
	
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
	[vc addAction:cancel];
	
	[self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)confirm:(id)sender {
	// 정보 저장
	[MonthlyBaby inst].isSeperated = _selectOptionIdx == 0;
	[self dismissViewControllerAnimated:NO completion:^{
		[self notifySelectOption];
	}];
}

- (IBAction)close:(id)sender {
	[MonthlyBaby inst].isSeperated = NO;
	[self dismissViewControllerAnimated:NO completion:^{
		[self notifySelectOption];
	}];
}

- (void)notifySelectOption {
	if ([MonthlyBaby inst].currentUploadCount > [MonthlyBaby inst].maxUploadCountPerBook)
	{
		NSString *title;
		if ([MonthlyBaby inst].isSeperated) {
			title = @"2권으로 나누어 제작합니다.";
		}
		else {
			title = @"1권만 제작됩니다.\n441장 이후의 사진은 제작되지 않습니다.";
		}
		
		[[Common info] alert:self Msg:title];
	}
}
@end
