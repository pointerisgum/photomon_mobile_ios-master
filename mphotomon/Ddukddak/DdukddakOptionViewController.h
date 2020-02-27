//
//  DdukddakOptionViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 9. 30..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface DdukddakOptionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (strong, nonatomic) NSMutableDictionary *thumbs;

@property (strong, nonatomic) NSMutableDictionary *imageViews;
@property (strong, nonatomic) NSMutableDictionary *radioButtons;
@property (strong, nonatomic) UIImage *radioOnImage;
@property (strong, nonatomic) UIImage *radioOffImage;

@property (weak, nonatomic) IBOutlet UIView *menuItem1;
@property (weak, nonatomic) IBOutlet UIView *menuItem2;
@property (weak, nonatomic) IBOutlet UIView *menuItem3;

@property (weak, nonatomic) IBOutlet UIView *bottomInfoView;

@property (weak, nonatomic) IBOutlet UIButton *buttonGotoOrder;

@property (assign) NSInteger selectedMenuIdx;
@property (assign) NSInteger selectedRadioIdx;

@property (assign) BOOL isContentReload;

@property (assign) BOOL isSelectedOption1;
@property (assign) BOOL isSelectedOption2;
@property (assign) BOOL isSelectedOption3;

@property (assign) BOOL isNew;

#pragma temp
- (IBAction)moveNext:(id)sender;

- (IBAction)radioButtonAction:(id)sender;

-(void)changeRadioButtonImage;

-(IBAction)menuItemClick:(id)sender;

@end
NS_ASSUME_NONNULL_END
