//
//  MonthlyOptionDateViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 8..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MonthlyOptionDateViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *totalUploadCount;

@property (strong, nonatomic) NSMutableArray *radioButtons;
@property (strong, nonatomic) UIImage *radioOnImage;
@property (strong, nonatomic) UIImage *radioOffImage;

@property (assign) int selectdValue;
@property (assign) BOOL isNew;

#pragma temp
- (IBAction)moveNext:(id)sender;

- (IBAction)radioButtonAction:(id)sender;

-(void)changeRadioButtonImage;

@end
NS_ASSUME_NONNULL_END
