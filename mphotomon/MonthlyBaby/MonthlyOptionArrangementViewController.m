//
//  MonthlyOptionArrangementViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 9..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "MonthlyOptionArrangementViewController.h"
#import "Common.h"
#import "MonthlyBaby.h"
#import "MonthlyOptionDesignThemeViewController.h"

@interface MonthlyOptionArrangementViewController ()

@end

@implementation MonthlyOptionArrangementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _radioButtons = [[NSMutableArray alloc] init];
    _radioOnImage = [UIImage imageNamed:@"radio_on.png"];
    _radioOffImage = [UIImage imageNamed:@"radio_off.png"];
    _selectdValue = 1;
	
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"Row2"];
        UIButton *radioButton = [cell.contentView viewWithTag:2];
        [_radioButtons addObject:radioButton];
    }else if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Row1"];
        UIButton *radioButton = [cell.contentView viewWithTag:1];
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
    }
    [MonthlyBaby inst].orderingType = _selectdValue;
    [self changeRadioButtonImage];
    NSLog(@"monthly arrangement select radio clicked selectedValue %d",_selectdValue);
}
- (IBAction)moveNext:(id)sender
{
    [MonthlyBaby inst].orderingType = _selectdValue;
    MonthlyOptionDesignThemeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionDesignThemeViewController"];
    [self.navigationController pushViewController:vc animated:YES ];
    
}

-(void)changeRadioButtonImage
{
    if(_selectdValue == 1){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        [buttonItem0 setImage:_radioOnImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOffImage forState:UIControlStateNormal];
    }else if(_selectdValue == 0){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        [buttonItem0 setImage:_radioOffImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOnImage forState:UIControlStateNormal];
    }
    
}



@end

