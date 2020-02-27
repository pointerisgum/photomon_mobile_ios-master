//
//  FrameDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 25..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "CollageEditViewController.h"

@interface FrameDetailViewController : UIViewController <CollageEditDelegate>

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (assign) int option_idx; // 메탈액자의 표면마감을 처리하기 위해서 제품사이즈를 저장할 필요가 있음.
@property (assign) int frame_idx; // 메탈액자 를 위함.

@property (strong, nonatomic) NSString *option_str;
@property (strong, nonatomic) NSString *surface_str;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (weak, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *material;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UIButton *product_size;
@property (strong, nonatomic) IBOutlet UILabel *useLabel;
@property (strong, nonatomic) IBOutlet UILabel *materialLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (strong, nonatomic) IBOutlet UILabel *surface;
@property (strong, nonatomic) IBOutlet UIButton *surface_button;
@property (strong, nonatomic) IBOutlet UIButton *surface_arrowButton;

- (void)updateTheme;

- (IBAction)selectSize:(id)sender;
- (IBAction)selectSurface:(id)sender;

- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)popupFullFrame:(id)sender;
- (IBAction)popupCollageFrame:(id)sender;

@end
