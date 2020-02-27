//
//  PhotobookV2LayoutViewController.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 29..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "PhotobookV2LayoutViewController.h"
#import "UIView+Toast.h"
#import "Common.h"

@interface PhotobookV2LayoutViewController ()

@end

@implementation PhotobookV2LayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _buttonbar.hidden = NO;
    _selected_layout = -1;
    _layouts = [[NSMutableArray alloc] init];
    
    // SJYANG : 2016.06.03 : 에필로그 추가
    if ([_layouttype isEqualToString:@"cover"] || [_layouttype isEqualToString:@"prolog"] || [_layouttype isEqualToString:@"epilogue"] || [Common info].photobook.product_type == PRODUCT_MAGNET
        || [Common info].photobook.product_type == PRODUCT_POSTER || [Common info].photobook.product_type == PRODUCT_PAPERSLOGAN
        || [Common info].photobook.product_type == PRODUCT_TRANSPARENTCARD) {
        _buttonbar_constraint.constant = 0;
        _buttonbar.hidden = YES;
    }
    else {
        [_button1 setTitle:@"1-2장" forState:UIControlStateNormal];
        [_button2 setTitle:@"3-4장" forState:UIControlStateNormal];
        [_button3 setTitle:@"5장이상" forState:UIControlStateNormal];
        [_button4 setTitle:@"현재" forState:UIControlStateNormal];
    }
    
    if(([Common info].photobook != NULL && [[Common info].photobook.ProductCode isEqualToString:@"347037"]) ||
       ([Common info].photobook != NULL && [[Common info].photobook.ProductCode isEqualToString:@"347036"]) ||
       ([Common info].photobook != NULL && [[Common info].photobook.ProductCode isEqualToString:@"347063"]) ||  //미니지갑 사진 추가
       ([Common info].photobook != NULL && [[Common info].photobook.ProductCode isEqualToString:@"347064"]) || //분할사진 추가
       ([Common info].photobook.product_type == PRODUCT_DIVISIONSTICKER) //분할 스티커 추가
       ) {
        //self.navigationController.navigationBar.topItem.title = @"YourTitle";
        self.navigationItem.title = @"디자인 변경";
        //self.navigationController.topViewController.title = @"info";
        
        /*
         UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
         titleView.backgroundColor = [UIColor clearColor];
         //titleView.font = [UIFont boldSystemFontOfSize:20.0];
         titleView.text = @"title string......";
         self.navigationItem.titleView = titleView;
         */
        //((UILabel*)(_navigationItem.titleView)).text = @"AAA";
        
        _buttonbar_constraint.constant = 0;
        _buttonbar.hidden = YES;
    }
    
    switch (_filter) {
        case 1: [self onfilter1:nil]; break;
        case 2: [self onfilter2:nil]; break;
        case 3: [self onfilter3:nil]; break;
        case 4: [self onfilter4:nil]; break;
        default: break;
    }
    
    for (Layout *layout in [Common info].layout_pool.layouts) {
        //레이아웃 전체를 가져오는 문제가 있음... 일단 아래와 같이 처리
        if([[Common info].photobook.ProductCode isEqualToString:@"347037"] || //4cut
           [[Common info].photobook.ProductCode isEqualToString:@"347063"] || //miniwallet
           [[Common info].photobook.ProductCode isEqualToString:@"347064"] || // division
           [Common info].photobook.product_type == PRODUCT_DIVISIONSTICKER
           )
        {
            if(([[Common info].photobook.ProductCode isEqualToString:@"347037"] && [layout.parentElement isEqualToString:@"DesignPhototype_Life4Cut"]) ||
               ([[Common info].photobook.ProductCode isEqualToString:@"347063"] && [layout.parentElement isEqualToString:@"DesignPhototype_wallet"]) ||
               ([[Common info].photobook.ProductCode isEqualToString:@"347064"] && [layout.parentElement isEqualToString:@"DesignPhototype_division"]) ||
               ([Common info].photobook.product_type == PRODUCT_DIVISIONSTICKER && [layout.parentElement isEqualToString:@"fancytype_divisionsticker"] &&
                [[Common info].photobook.ProductCode isEqualToString:layout.productcode] )
               ){
                //            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].layout_pool.thumb_url, layout.thumbnail];
                //            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *url = [Common makeURLString:layout.thumbnail host:[Common info].layout_pool.thumb_url];
                [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                    if (succeeded) {
                        layout.image = [UIImage imageWithData:imageData];
                        [_collection_view reloadData];
                    }
                    else {
                        NSLog(@"layout's thumbnail_image is not downloaded.");
                    }
                }];
                
            }
        }else{
            //            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].layout_pool.thumb_url, layout.thumbnail];
            //            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *url = [Common makeURLString:layout.thumbnail host:[Common info].layout_pool.thumb_url];
            [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                if (succeeded) {
                    layout.image = [UIImage imageWithData:imageData];
                    [_collection_view reloadData];
                }
                else {
                    NSLog(@"layout's thumbnail_image is not downloaded.");
                }
            }];
            
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateLayouts];
}

- (void)viewWillAppear:(BOOL)animated {
    /*
     if([Common info].photobook != NULL && [[Common info].photobook.ProductCode isEqualToString:@"347037"]) {
     self.navigationItem.title = @"디자인 변경";
     self.navigationController.topViewController.title = @"info";
     _buttonbar_constraint.constant = 0;
     _buttonbar.hidden = YES;
     }
     */
}

- (void)updateLayouts {
    _selected_layout = -1;
    [_layouts removeAllObjects];
    
    if (_layouttype.length > 0) {
        for (Layout *layout in [Common info].layout_pool.layouts) {
            if([[Common info].photobook.ProductCode isEqualToString:@"347037"] ||
               [[Common info].photobook.ProductCode isEqualToString:@"347063"] ||
               [[Common info].photobook.ProductCode isEqualToString:@"347064"] ||
               [Common info].photobook.product_type == PRODUCT_DIVISIONSTICKER
               )
            {
                if(!(([[Common info].photobook.ProductCode isEqualToString:@"347037"] && [layout.parentElement isEqualToString:@"DesignPhototype_Life4Cut"]) ||
                     ([[Common info].photobook.ProductCode isEqualToString:@"347063"] && [layout.parentElement isEqualToString:@"DesignPhototype_wallet"]) ||
                     ([[Common info].photobook.ProductCode isEqualToString:@"347064"] && [layout.parentElement isEqualToString:@"DesignPhototype_division"]) ||
                     ([Common info].photobook.product_type == PRODUCT_DIVISIONSTICKER && [layout.parentElement isEqualToString:@"fancytype_divisionsticker"] &&
                      [[Common info].photobook.ProductCode isEqualToString:layout.productcode] )
                     )){
                    
                    continue;
                }
            }
            if ([_layouttype isEqualToString:@"designphoto"]) {
                [_layouts addObject:layout];
            }
            else {
                if ([layout.type isEqualToString:_layouttype]) {
                    // SJYANG : 2016.06.03 : 에필로그 추가
                    if ([_layouttype isEqualToString:@"cover"] || [_layouttype isEqualToString:@"prolog"] || [_layouttype isEqualToString:@"epilogue"]) { // cover/prolog/epilogue일 경우, 모두 추가
                        [_layouts addObject:layout];
                    }
                    else if ([_layouttype isEqualToString:@"page"]) {   // page일 경우,
                        if (_filter == 0) {
                            if ([layout.theme_id isEqualToString:@"common"]) { // filter==0일 경우, 모두 추가
                                [_layouts addObject:layout];
                            }else {
                                [_layouts addObject:layout];
                            }
                        }
                        else if (_filter == 1) {
                            if (layout.imgcnt <= 2) {
                                [_layouts addObject:layout];
                            }
                        }
                        else if (_filter == 2) {
                            if (layout.imgcnt >= 3 && layout.imgcnt <= 4) {
                                [_layouts addObject:layout];
                            }
                        }
                        else if (_filter == 3) {
                            if (layout.imgcnt >= 5) {
                                [_layouts addObject:layout];
                            }
                        }
                        else if (_filter == 4) { // 현재 테마
                            if (![layout.theme_id isEqualToString:@"common"]) {
                                [_layouts addObject:layout];
                            }else {
                                [_layouts addObject:layout];
                            }
                        }
                    }
                }
            }
        }
        NSLog(@"layout count: %d", (int)_layouts.count);
        if(!([Common info].photobook != NULL && ([[Common info].photobook.ProductCode isEqualToString:@"347037"] || //4cut
                                                 [[Common info].photobook.ProductCode isEqualToString:@"347036"] || //photocard
                                                 [[Common info].photobook.ProductCode isEqualToString:@"347063"] || //miniwallet
                                                 [[Common info].photobook.ProductCode isEqualToString:@"347064"] || //division
                                                 [Common info].photobook.product_type == PRODUCT_MAGNET ||
                                                 [Common info].photobook.product_type == PRODUCT_POSTER ||
                                                 [Common info].photobook.product_type == PRODUCT_PAPERSLOGAN ||
                                                 [Common info].photobook.product_type == PRODUCT_TRANSPARENTCARD ||
                                                 [Common info].photobook.product_type == PRODUCT_DIVISIONSTICKER))
           ) {
            if (_layouts.count <= 0) {
                [self.view makeToast:@"사용 가능한 레이아웃이 없습니다."];
            }
        }
        [_collection_view reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _layouts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PageEditCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    //    var pinch = UIPinchGestureRecognizer(target: self, action: Selector("handlePinchGesture:"))
    //    cell.addGestureRecognizer(pinch)
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [cell addGestureRecognizer:pinch];
    
    Layout *layout = _layouts[indexPath.row];
    if (layout) {
        if (layout.image != nil) {
            UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
            imageview.image = layout.image;
        }
        UIImageView *selimageview = (UIImageView *)[cell viewWithTag:101];
        selimageview.hidden = (indexPath.row != _selected_layout);
    }
    return cell;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)reco {
    
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Layout *layout = _layouts[indexPath.row];
    if (layout != nil && _selected_layout != (int)indexPath.row) {
        _selected_layout = (int)indexPath.row;
        [_collection_view reloadData];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 10.0;
    CGFloat size = (collectionView.bounds.size.width - spacing*3) / 2;
    if (([Common info].photobook.product_type == PRODUCT_SINGLECARD)) {
        return CGSizeMake(size, size);
    } else {
        return CGSizeMake(size, size/2);
    }
    
}

- (IBAction)onfilter1:(id)sender {
    [_button1 setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button4 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    if (_filter != 1) {
        _filter = 1;
        [self updateLayouts];
    }
}

- (IBAction)onfilter2:(id)sender {
    [_button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button2 setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [_button3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button4 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    if (_filter != 2) {
        _filter = 2;
        [self updateLayouts];
    }
}

- (IBAction)onfilter3:(id)sender {
    [_button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button3 setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [_button4 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    if (_filter != 3) {
        _filter = 3;
        [self updateLayouts];
    }
}

- (IBAction)onfilter4:(id)sender {
    [_button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_button4 setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    if (_filter != 4) {
        _filter = 4;
        [self updateLayouts];
    }
}

- (IBAction)done:(id)sender {
    if (_selected_layout < 0) {
        [[Common info] alert:self Msg:@"페이지 레이아웃을 선택해 주세요."];
    }
    else {
        Layout *layout = _layouts[_selected_layout];
        if (layout != nil) {
            NSLog(@"[self.delegate changeLayout:layout];");
            [self.delegate changeLayout:layout];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
