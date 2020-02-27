//
//  DdukddakProductSelectViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 9. 30..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface DdukddakProductSelectViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *totalUploadCount;

@property (strong, nonatomic) NSMutableArray *radioButtons;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) UIImage *radioOnImage;
@property (strong, nonatomic) UIImage *radioOffImage;

@property (weak, nonatomic) IBOutlet UIView *bottomInfoView;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (assign) int selectdValue;
@property (assign) BOOL isNew;

#pragma temp
- (IBAction)moveNext:(id)sender;

- (IBAction)radioButtonAction:(id)sender;

-(void)changeRadioButtonImage;

@end
NS_ASSUME_NONNULL_END
