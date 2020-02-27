//
//  PrintOptionViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PhotoPrint.h"
#import "BaseViewController.h"

@interface PrintOptionViewController : BaseViewController <UIScrollViewDelegate>

@property (strong, nonatomic) PrintItem *photoItem;
@property (strong, nonatomic) NSString *currentPrintSize;

@property (strong, nonatomic) IBOutlet UIView *backView; // 배경 뷰
@property (strong, nonatomic) UIScrollView *paperView; // 인화지 뷰
@property (strong, nonatomic) UIImageView *photoView;  // 사진 뷰

@property (strong, nonatomic) IBOutlet UILabel *printAmount;
@property (strong, nonatomic) IBOutlet UIButton *printSize;
@property (strong, nonatomic) IBOutlet UISegmentedControl *printFullType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *printBorder;
@property (strong, nonatomic) IBOutlet UISegmentedControl *printSurfaceType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *printRevise;

- (void)updatePreview:(BOOL)is_load;
- (NSString *)getCurrentTrimInfo;

- (IBAction)clickMinus:(id)sender;
- (IBAction)clickPlus:(id)sender;
- (IBAction)clickPrintSize:(id)sender;
- (IBAction)changedFullType:(id)sender;
- (IBAction)changedBorder:(id)sender;
- (IBAction)changedSurfaceType:(id)sender;
- (IBAction)changedRevise:(id)sender;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end

