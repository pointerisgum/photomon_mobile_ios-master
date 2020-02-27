//
//  MonthlyOptionDateViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 8..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "MonthlyOptionDateViewController.h"
#import "Common.h"
#import "MonthlyBaby.h"
#import "MonthlyMaxCountOverPopupViewController.h"
#import "MonthlyOptionCoverEditViewController.h"

@interface MonthlyOptionDateViewController ()

@end

@implementation MonthlyOptionDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _radioButtons = [[NSMutableArray alloc] init];
    _radioOnImage = [UIImage imageNamed:@"radio_on.png"];
    _radioOffImage = [UIImage imageNamed:@"radio_off.png"];
    _selectdValue = 0;
	_isNew = YES;
    
    NSString *totalUpCntStr = [NSString stringWithFormat:@"%d", [MonthlyBaby inst].currentUploadCount];
    [_totalUploadCount setText:totalUpCntStr ];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self changeRadioButtonImage];
//	if(_isNew)
	{
		if([MonthlyBaby inst].currentUploadCount >= [MonthlyBaby inst].maxUploadCountPerBook)
		{
			MonthlyMaxCountOverPopupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MaxCountOverPopup"];
			[self presentViewController:vc animated:NO completion:nil];
		}
		_isNew = NO;
	}
}

#pragma mark -
#pragma mark TableView
//테이블뷰 행수 처리
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
    
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
        UIButton *radioButton = [cell.contentView viewWithTag:2];
        [_radioButtons addObject:radioButton];
    }else if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Row2"];
        UIButton *radioButton = [cell.contentView viewWithTag:4];
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
    if(button.tag == 2){
        _selectdValue = 0;
        [MonthlyBaby inst].markDate = YES;
    }else if(button.tag == 4){
        _selectdValue = 1;
        [MonthlyBaby inst].markDate = NO;
    }
    [self changeRadioButtonImage];
    NSLog(@"monthly date select radio clicked selectedValue %d",_selectdValue);
}
- (IBAction)moveNext:(id)sender
{
    MonthlyOptionCoverEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionCoverEditViewController"];
    [self.navigationController pushViewController:vc animated:YES ];
    
}

-(void)changeRadioButtonImage
{
    if(_selectdValue == 0){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        [buttonItem0 setImage:_radioOnImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOffImage forState:UIControlStateNormal];
    }else if(_selectdValue == 1){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        [buttonItem0 setImage:_radioOffImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOnImage forState:UIControlStateNormal];
    }
    
}



@end

