//
//  MonthlyOptionDesignThemeViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 9..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "MonthlyOptionDesignThemeViewController.h"
#import "Common.h"
#import "MonthlyBaby.h"
#import "MonthlyAddProductPopup.h"
#import "MonthlyOrderBookCount.h"
#import "MonthlyConfirmOrderPopup.h"
#import "MonthlyBabyWebViewController.h"

@interface MonthlyOptionDesignThemeViewController () <MonthlySelectAddProductDoneDelegate, MonthlySelectOrderCountDoneDelegate, MonthlyConfirmOrderDelegate>

@end

@implementation MonthlyOptionDesignThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _radioButtons = [[NSMutableArray alloc] init];
    _radioOnImage = [UIImage imageNamed:@"radio_on.png"];
    _radioOffImage = [UIImage imageNamed:@"radio_off.png"];
    _selectdValue = 0;
    
	int uploadCnt = [MonthlyBaby inst].currentUploadCount;
	int bookCnt = [MonthlyBaby inst].isSeperated ? 2 : 1;
	if (false == [MonthlyBaby inst].isSeperated && uploadCnt > [MonthlyBaby inst].maxUploadCountPerBook) {
		uploadCnt = [MonthlyBaby inst].maxUploadCountPerBook;
	}
	NSString *uploadInfoStr = [NSString stringWithFormat:@"%d장 / %d권", uploadCnt, bookCnt ];
    [_uploadInfoLabel setText:uploadInfoStr ];
    
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self changeRadioButtonImage];
}

#pragma mark -
#pragma mark TableView
//테이블뷰 행수 처리
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 250;
    
    //return UITableViewAutomaticDimension;
}


//내부 셀 처리
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    /*if (cell == nil) {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }*/
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Row1"];
        UIButton *radioButton = [cell.contentView viewWithTag:1];
        [_radioButtons addObject:radioButton];
    }else if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Row2"];
        UIButton *radioButton = [cell.contentView viewWithTag:2];
        [_radioButtons addObject:radioButton];
    }else if(indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Row3"];
        UIButton *radioButton = [cell.contentView viewWithTag:3];
        [_radioButtons addObject:radioButton];
    }else{
        cell = [[UITableViewCell alloc] init];
    }
    
    return cell;
}


#pragma mark - Radio btn event
- (IBAction)radioButtonAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if(button.tag == 1){
        _selectdValue = 0;
    }else if(button.tag == 2){
        _selectdValue = 1;
    }else if(button.tag == 3){
        _selectdValue = 2;
    }
    [MonthlyBaby inst].designTheme = _selectdValue;
    [self changeRadioButtonImage];
    NSLog(@"monthly designtheme select radio clicked selectedValue %d",_selectdValue);
}

- (IBAction)moveNext:(id)sender
{
	MonthlyAddProductPopup *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonthlyAddProductPopup"];
	
	if (vc) {
		[vc setData:self];
		[self presentViewController:vc animated:NO completion:nil];
	}
}

- (void) selectAddProductDone
{
	MonthlyOrderBookCount *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonthlyOrderBookCount"];
	
	if (vc) {
		[vc setData:self];
		[self presentViewController:vc animated:NO completion:nil];
	}
}

- (void) selectOrderCountDone
{
	MonthlyConfirmOrderPopup *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonthlyConfirmOrderPopup"];
	
	if (vc) {
		[vc setData:self];
		[self presentViewController:vc animated:NO completion:nil];
	}
}

- (void) confirmOrder:(BOOL)isSuccess url:(NSString *)url
{
	// 최종 주문 후 홈으로
//	[self dismissViewControllerAnimated:YES completion:^{
//	}];
//	[MonthlyBaby inst].mainWebView.url = URL_MONTHLY_ADD_CARD;
	[MonthlyBaby inst].mainWebView.url = url;
	[self.navigationController popToViewController:[MonthlyBaby inst].mainWebView animated:YES];

//	MonthlyOrderBookCount *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonthlyOrderBookCount"];
//
//	if (vc) {
//		[vc setData:self];
//		[self presentViewController:vc animated:YES completion:nil];
//	}
}

-(void)changeRadioButtonImage
{
    if(_selectdValue == 0){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        UIButton *buttonItem2 = _radioButtons[2];
        [buttonItem0 setImage:_radioOnImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOffImage forState:UIControlStateNormal];
        [buttonItem2 setImage:_radioOffImage forState:UIControlStateNormal];
    }else if(_selectdValue == 1){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        UIButton *buttonItem2 = _radioButtons[2];
        [buttonItem0 setImage:_radioOffImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOnImage forState:UIControlStateNormal];
        [buttonItem2 setImage:_radioOffImage forState:UIControlStateNormal];
    }else if(_selectdValue == 2){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        UIButton *buttonItem2 = _radioButtons[2];
        [buttonItem0 setImage:_radioOffImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOffImage forState:UIControlStateNormal];
        [buttonItem2 setImage:_radioOnImage forState:UIControlStateNormal];
    }
    
}



@end

