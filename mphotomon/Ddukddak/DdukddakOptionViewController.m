//
//  DdukddakOptionViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 9. 30..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "DdukddakOptionViewController.h"
#import "Common.h"
#import "Ddukddak.h"
#import "UIView+Toast.h"
#import "DdukddakWebViewController.h"

@interface DdukddakOptionViewController ()

@end

@implementation DdukddakOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _radioButtons = [[NSMutableDictionary alloc] init];
    _thumbs = [[NSMutableDictionary alloc] init];
    _imageViews = [[NSMutableDictionary alloc] init];
    _radioOnImage = [UIImage imageNamed:@"radio_on.png"];
    _radioOffImage = [UIImage imageNamed:@"radio_off.png"];
    _selectedMenuIdx = 0;
    _selectedRadioIdx = -1;
    _isContentReload = YES;
    _isNew = YES;
    //[[Ddukddak inst]loadProduct];
    [[Ddukddak inst]loadLayoutCounts:[Ddukddak inst].totSaveCount];
    [Ddukddak inst].arrangeSelectedIdx = -1;
    [Ddukddak inst].sizeSelectedIdx = -1;
    [Ddukddak inst].decoSelectedIdx = -1;
    _buttonGotoOrder.backgroundColor = [UIColor lightGrayColor];
    _bottomInfoView.alpha = 0;
    
    
    UIView * underLine1 = [[UIView alloc]init];
    underLine1.backgroundColor = [UIColor darkGrayColor];
    underLine1.frame = CGRectMake(0, _menuItem1.bounds.size.height-2,_menuItem1.bounds.size.width,2);
    
    [_menuItem1 addSubview: underLine1];
    
    UIView * underLine2 = [[UIView alloc]init];
    underLine2.backgroundColor = [UIColor darkGrayColor];
    underLine2.frame = CGRectMake(0, _menuItem2.bounds.size.height-2,_menuItem2.bounds.size.width,2);
    underLine2.hidden = YES;
    [_menuItem2 addSubview: underLine2];
    
    UIView * underLine3 = [[UIView alloc]init];
    underLine3.backgroundColor = [UIColor darkGrayColor];
    underLine3.frame = CGRectMake(0, _menuItem3.bounds.size.height-2,_menuItem3.bounds.size.width,2);
    underLine3.hidden = YES;
    [_menuItem3 addSubview: underLine3];
    
    
    //NSString *totalUpCntStr = [NSString stringWithFormat:@"%d", [MonthlyBaby inst].currentUploadCount];
    //[_totalUploadCount setText:totalUpCntStr ];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"뒤로" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    //[self changeRadioButtonImage];
    
    
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

- (IBAction)Back
{
    [[Common info] alert:self Title:@"선택 하신 사진이 초기화 됩니다.\n페이지를 이동 하시겠습니까?" Msg:@"" okCompletion:^{
              [self.navigationController popViewControllerAnimated:YES];
              
                  } cancelCompletion:^{
                      
                      
                  } okTitle:@"네" cancelTitle:@"아니오"];
 
}

/*- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}*/
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(_selectedMenuIdx == 0){
        return [Ddukddak inst].arrange.details.count;
    }else if(_selectedMenuIdx == 1){
        return [Ddukddak inst].size.details.count;
    }else if(_selectedMenuIdx == 2){
        return [Ddukddak inst].deco.details.count;
    }
    return 0;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell101" forIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell101" forIndexPath:indexPath ];
    
    NSString *imgfullpath;
    NSString *title;
    NSString *desc;
    
    if(_selectedMenuIdx == 0){
        
        imgfullpath = [NSString stringWithFormat:@"%@", [Ddukddak inst].arrange.details[indexPath.row].thumb];
        title = [NSString stringWithFormat:@"%@", [Ddukddak inst].arrange.details[indexPath.row].title];
        desc = [NSString stringWithFormat:@"%@", [Ddukddak inst].arrange.details[indexPath.row].desc];
        
    }else if(_selectedMenuIdx == 1){
        imgfullpath = [NSString stringWithFormat:@"%@", [Ddukddak inst].size.details[indexPath.row].thumb];
        title = [NSString stringWithFormat:@"%@", [Ddukddak inst].size.details[indexPath.row].title];
        desc = [NSString stringWithFormat:@"%@", [Ddukddak inst].size.details[indexPath.row].desc];
        
    }else if(_selectedMenuIdx == 2){
        imgfullpath = [NSString stringWithFormat:@"%@", [Ddukddak inst].deco.details[indexPath.row].thumb];
        title = [NSString stringWithFormat:@"%@", [Ddukddak inst].deco.details[indexPath.row].title];
        desc = [NSString stringWithFormat:@"%@", [Ddukddak inst].deco.details[indexPath.row].desc];
        
    }
    UIButton *radioBtn = (UIButton *)[cell viewWithTag:101];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *descLabel = (UILabel *)[cell viewWithTag:103];
    
    [titleLabel setText: title];
    if(_selectedMenuIdx == 1){
        if(indexPath.row == 0){
            desc = [desc stringByReplacingOccurrencesOfString:@"{l_size_layout_count}" withString:[NSString stringWithFormat:@"%ld", [Ddukddak inst].layoutCounts[indexPath.row+2].layoutCount]];
        }else if(indexPath.row == 1){
            desc = [desc stringByReplacingOccurrencesOfString:@"{m_size_layout_count}" withString:[NSString stringWithFormat:@"%ld", [Ddukddak inst].layoutCounts[indexPath.row].layoutCount]];
        }else if(indexPath.row == 2){
            desc = [desc stringByReplacingOccurrencesOfString:@"{s_size_layout_count}" withString:[NSString stringWithFormat:@"%ld", [Ddukddak inst].layoutCounts[indexPath.row-2].layoutCount]];
        }
        
        
        [descLabel setText: desc];
    }else{
        [descLabel setText: desc];
    }
    [descLabel setText: desc];
    //[radioBtn setTag: indexPath.row];
    
    NSArray *radioContainObjects = [_radioButtons allValues];
    if(![radioContainObjects containsObject: radioBtn]){
        if(_selectedRadioIdx != indexPath.row)
        {
            [radioBtn setImage:_radioOffImage forState:UIControlStateNormal];
        }
        else{
            [radioBtn setImage:_radioOnImage forState:UIControlStateNormal];
        }
        
        [_radioButtons setObject:radioBtn
                          forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
    }
    
    if (indexPath.row < _thumbs.count && [_thumbs objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]] != nil) {
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
        imageview.image = [_thumbs objectForKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
                
        [imageview.layer setBorderColor:[[UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1] CGColor]];
        
        if(_selectedRadioIdx != indexPath.row){
            [imageview.layer setBorderWidth:0];
        }
        else{
            [imageview.layer setBorderWidth:3];
        }
        
        NSArray *imageViewContainObjects = [_imageViews allValues];
        if(![imageViewContainObjects containsObject: imageview]){
            [_imageViews setObject:imageview
            forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
        }
    }
    else {
        NSString *url = [imgfullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
        
        NSArray *imageViewContainObjects = [_imageViews allValues];
        
        if(![imageViewContainObjects containsObject: imageview]){
            [_imageViews setObject:imageview
            forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
        }
        
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                //UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
                
                [imageview.layer setBorderColor:[[UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1] CGColor]];
                
                if(self.selectedRadioIdx != indexPath.row){
                    [imageview.layer setBorderWidth:0];
                }
                else{
                    [imageview.layer setBorderWidth:3];
                }
                
                if(imageview.image != nil){
                    [self.thumbs setObject:imageview.image
                    forKey:[NSString stringWithFormat:@"%ld", indexPath.row]];
                }
               
                //_thumbs[idx] = imageview.image;
            }
            else {
                NSLog(@"theme-detail's thumbnail_image is not downloaded.");
            }
        }];
    }
    
   
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = collectionView.bounds.size.width - 40;
    CGFloat height = collectionView.bounds.size.height - 20;
    
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedRadioIdx = indexPath.row;
    [self changeRadioButtonImage];
    
}

#pragma mark -
#pragma mark TableView
//테이블뷰 행수 처리
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 500;
    
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
        //UIButton *radioButton = [cell.contentView viewWithTag:2];
        UICollectionView *collectionView = [cell.contentView viewWithTag:10];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView reloadData];
        //_collection_view = collectionView;
        [collectionView performBatchUpdates:^{} completion:^(BOOL finished) {
            NSLog(@"finished performbatch %d",finished ? 1:0);
            //if(self.isContentReload){
                
            //[self changeRadioButtonImage];
            NSInteger rowindex = [self getSelectedRadioIdx:self.selectedMenuIdx];
            [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(rowindex < 0 ? 0 : rowindex) inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
                self.isContentReload = NO;
            //}
        }];
        
        
    }
    else{
        cell = [[UITableViewCell alloc] init];
    }
    
    return cell;
}

/*-(void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    //[self changeRadioButtonImage];
    //[_collection_view scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self getSelectedRadioIdx:self.selectedMenuIdx] inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
    
}*/


#pragma mark - Radio btn event
- (IBAction)radioButtonAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    for(NSString* radioBtnKey in _radioButtons){
        
        if(button == [_radioButtons objectForKey:radioBtnKey]){
            _selectedRadioIdx = [radioBtnKey integerValue];
            break;
        }
       
    }
    
    [self changeRadioButtonImage];
    NSLog(@"ddukddak select radio clicked selectedRadioIdx %d",_selectedRadioIdx);
}
- (IBAction)moveNext:(id)sender
{
    /*MonthlyOptionCoverEditViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"monthlyOptionCoverEditViewController"];
     [self.navigationController pushViewController:vc animated:YES ];
     */
    if(!([Ddukddak inst].arrangeSelectedIdx > -1 && [Ddukddak inst].sizeSelectedIdx > -1 && [Ddukddak inst].decoSelectedIdx > -1)){
        [self showToast:_bottomInfoView toastText:@"모든 옵션을 선택하신 후 주문하실수 있습니다."];
    }else{
        //goto order
        DdukddakAddCartReturn *retObj  = [[Ddukddak inst] addToCart];
        if([retObj.code isEqualToString:@"0000"]){
             DdukddakWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ddukddakWebViewController"];
            if (vc) {
                vc.isIntro = NO;
                vc.url = retObj.moveURL;
                /*vc.selected_theme = [self findTheme:product.pid theme2ID:@"DefaultTheme"];
                [vc updateTheme];*/
            }
            [self.navigationController pushViewController:vc animated:YES];

        }
        else{
            [self showToast:_bottomInfoView toastText:[NSString stringWithFormat:@"error return msg %@", retObj.msg]];
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
    if(_radioButtons.count > 0)
    {
        NSArray *radioContainObjects = [_radioButtons allValues];
        for(UIButton* radioBtnItem in radioContainObjects){
                [radioBtnItem setImage:_radioOffImage forState:UIControlStateNormal];
        }
        
        if(_selectedRadioIdx >= 0){
            UIButton *targetButton = (UIButton*)[_radioButtons objectForKey:[NSString stringWithFormat:@"%ld", _selectedRadioIdx]];
            
            [targetButton setImage:_radioOnImage forState:UIControlStateNormal];
        }
        
        NSArray *imageViewContainObjects = [_imageViews allValues];
        
        for(UIImageView* imageViewItem in imageViewContainObjects){
            [imageViewItem.layer setBorderWidth:0];
        }
        
        if(_selectedRadioIdx >= 0){
            UIImageView *targetImageView = (UIImageView*)[_imageViews objectForKey:[NSString stringWithFormat:@"%ld", _selectedRadioIdx]];
        
            [targetImageView.layer setBorderColor:[[UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1] CGColor]];
            [targetImageView.layer setBorderWidth:3];
        }
        
        
        if(_selectedMenuIdx == 0){
            [Ddukddak inst].arrangeSelectedIdx = _selectedRadioIdx;
        }else if (_selectedMenuIdx == 1){
            [Ddukddak inst].sizeSelectedIdx = _selectedRadioIdx;
        }else if (_selectedMenuIdx == 2){
            [Ddukddak inst].decoSelectedIdx = _selectedRadioIdx;
        }
        
        if(!([Ddukddak inst].arrangeSelectedIdx > -1 && [Ddukddak inst].sizeSelectedIdx > -1 && [Ddukddak inst].decoSelectedIdx > -1)){
            //[self showToast:_bottomInfoView];
            _buttonGotoOrder.backgroundColor = [UIColor lightGrayColor];
           
        }else{
            _buttonGotoOrder.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0 alpha:1];
        }
       
    }
    
}
-(IBAction)menuItemClick:(id)sender{
    UIButton *menuButton = (UIButton*)sender;
    
    if(_selectedMenuIdx == 0 && [Ddukddak inst].arrangeSelectedIdx < 0){
        [self showToast:_bottomInfoView toastText:@"사진 정리 방식을 선택해 주세요."];
        return;
    }
    else if(_selectedMenuIdx == 1 && [Ddukddak inst].sizeSelectedIdx < 0){
        [self showToast:_bottomInfoView toastText:@"사진 사이즈를 선택해 주세요"];
        return;
    }
    else if(_selectedMenuIdx == 2 && [Ddukddak inst].decoSelectedIdx < 0){
        [self showToast:_bottomInfoView toastText:@"스티커&장식 옵션을 선택해 주세요"];
        return;
    }
    
    if(menuButton.tag == 1){
        
        _selectedMenuIdx = 0;
        _selectedRadioIdx = [self getSelectedRadioIdx:_selectedMenuIdx];
        [_thumbs removeAllObjects];
        [_imageViews removeAllObjects];
        [_radioButtons removeAllObjects];
        //_isContentReload = YES;
        [_tableView reloadData];
        [_descLabel setText: [Ddukddak inst].arrange.desc];
        UIView * underline1 = [_menuItem1.subviews lastObject];
        UIView * underline2 = [_menuItem2.subviews lastObject];
        UIView * underline3 = [_menuItem3.subviews lastObject];
        
        underline1.hidden = NO;
        underline2.hidden = YES;
        underline3.hidden = YES;
        
        _isSelectedOption1 = YES;
    }else if(menuButton.tag == 2){
        _selectedMenuIdx = 1;
        _selectedRadioIdx = [self getSelectedRadioIdx:_selectedMenuIdx];
        [_thumbs removeAllObjects];
        [_imageViews removeAllObjects];
        [_radioButtons removeAllObjects];
        //_isContentReload = YES;
        [_tableView reloadData];
        [_descLabel setText: [Ddukddak inst].size.desc];
        UIView * underline1 = [_menuItem1.subviews lastObject];
        UIView * underline2 = [_menuItem2.subviews lastObject];
        UIView * underline3 = [_menuItem3.subviews lastObject];
        
        underline1.hidden = YES;
        underline2.hidden = NO;
        underline3.hidden = YES;
        
        _isSelectedOption2 = YES;
        
    }else if(menuButton.tag == 3){
        _selectedMenuIdx = 2;
        _selectedRadioIdx = [self getSelectedRadioIdx:_selectedMenuIdx];
        [_thumbs removeAllObjects];
        [_imageViews removeAllObjects];
        [_radioButtons removeAllObjects];
        //_isContentReload = YES;
        [_tableView reloadData];
        [_descLabel setText: [Ddukddak inst].deco.desc];
        UIView * underline1 = [_menuItem1.subviews lastObject];
        UIView * underline2 = [_menuItem2.subviews lastObject];
        UIView * underline3 = [_menuItem3.subviews lastObject];
        
        underline1.hidden = YES;
        underline2.hidden = YES;
        underline3.hidden = NO;
        
        _isSelectedOption3 = YES;
       
    }
    
}
-(NSInteger)getSelectedRadioIdx:(NSInteger)selectedMenuIdx{
    
    if(selectedMenuIdx == 0){
        return [Ddukddak inst].arrangeSelectedIdx;
    }
    else if(selectedMenuIdx == 1){
        return [Ddukddak inst].sizeSelectedIdx;
    }
    else if(selectedMenuIdx == 2){
        return [Ddukddak inst].decoSelectedIdx;
    }
    
    return 0;
    
}


@end

