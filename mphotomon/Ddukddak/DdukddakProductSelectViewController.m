//
//  DdukddakProductSelectViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 9. 30..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "DdukddakProductSelectViewController.h"
#import "Common.h"
#import "Ddukddak.h"
#import "DdukddakDesignSelectViewController.h"


@interface DdukddakProductSelectViewController ()

@end

@implementation DdukddakProductSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _radioButtons = [[NSMutableArray alloc] init];
    _radioOnImage = [UIImage imageNamed:@"radio_on.png"];
    _radioOffImage = [UIImage imageNamed:@"radio_off.png"];
    _selectdValue = -1;
    _isNew = YES;
    _imageViews = [[NSMutableArray alloc] init];
    _bottomInfoView.alpha = 0;
    //NSString *totalUpCntStr = [NSString stringWithFormat:@"%d", [MonthlyBaby inst].currentUploadCount];
    //[_totalUploadCount setText:totalUpCntStr ];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self changeRadioButtonImage];
    //    if(_isNew)
    {
        /*if([MonthlyBaby inst].currentUploadCount >= [MonthlyBaby inst].maxUploadCountPerBook)
        {
            MonthlyMaxCountOverPopupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MaxCountOverPopup"];
            [self presentViewController:vc animated:NO completion:nil];
        }*/
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
        UIImageView *imageView = [cell.contentView viewWithTag:101];
        [imageView.layer setBorderColor:[[UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1] CGColor]];
        [imageView.layer setBorderWidth:0];
        [_imageViews addObject:imageView ];
    }else if(indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"Row2"];
        UIButton *radioButton = [cell.contentView viewWithTag:4];
        [_radioButtons addObject:radioButton];
        UIImageView *imageView = [cell.contentView viewWithTag:102];
        [imageView.layer setBorderColor:[[UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1] CGColor]];
        [imageView.layer setBorderWidth:0];
        [_imageViews addObject:imageView ];
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
        [Ddukddak inst].productSelectedIdx = 0;
    }else if(button.tag == 4){
        _selectdValue = 1;
        [Ddukddak inst].productSelectedIdx = 1;
    }
    [self changeRadioButtonImage];
    NSLog(@"monthly date select radio clicked selectedValue %d",_selectdValue);
}
- (IBAction)moveNext:(id)sender
{
    /*MonthlyOptionCoverEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionCoverEditViewController"];
    [self.navigationController pushViewController:vc animated:YES ];
     */
    if(_selectdValue < 0){
        [self showToast:_bottomInfoView toastText:@"상품을 선택해주세요."];
    }else{
        //goto order
        //UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotobookV2" bundle:nil];
        DdukddakDesignSelectViewController *navi = [self.storyboard instantiateViewControllerWithIdentifier:@"ddukddakDesignSelectViewController"];
               if (navi) {
                   navi.product_type = PRODUCT_PHOTOBOOK;
                   [self.navigationController pushViewController:navi animated:YES ];
                   //[self presentViewController:navi animated:YES completion:nil];
               }
    }
}
- (void)showToast:(UIView *)toast toastText:(NSString*)toastText {
    UILabel * toastTextView = [toast viewWithTag:1];
    [toastTextView setText:toastText];
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(toastTimerDidFinish:) userInfo:toast repeats:NO];
                         // associate the timer with the toast view
                         //objc_setAssociatedObject (toast, &CSToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         //objc_setAssociatedObject (toast, &CSToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}
- (void)hideToast:(UIView *)toast {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Events

- (void)toastTimerDidFinish:(NSTimer *)timer {
    [self hideToast:(UIView *)timer.userInfo];
}

-(void)changeRadioButtonImage
{
    if(_selectdValue == 0){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        [buttonItem0 setImage:_radioOnImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOffImage forState:UIControlStateNormal];
        
        [((UIImageView*)_imageViews[0]).layer setBorderWidth:3];
        [((UIImageView*)_imageViews[1]).layer setBorderWidth:0];
        _buttonNext.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1];
        
    }else if(_selectdValue == 1){
        UIButton *buttonItem0 = _radioButtons[0];
        UIButton *buttonItem1 = _radioButtons[1];
        [buttonItem0 setImage:_radioOffImage forState:UIControlStateNormal];
        [buttonItem1 setImage:_radioOnImage forState:UIControlStateNormal];
        
        [((UIImageView*)_imageViews[0]).layer setBorderWidth:0];
        [((UIImageView*)_imageViews[1]).layer setBorderWidth:3];
        _buttonNext.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1];
    }else{
        _buttonNext.backgroundColor = [UIColor lightGrayColor];
       
    }
    
}



@end

