//
//  GiftPostcardDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface GiftPostcardDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) NSMutableArray *thumbs;
@property (strong, nonatomic) IBOutlet UILabel *booksize;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UILabel *material;
@property (strong, nonatomic) IBOutlet UIButton *pagecount_button;
@property (strong, nonatomic) IBOutlet UIButton *includebox_button;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;

@property (assign) int pagecount_idx;
@property (assign) int includebox_idx;

- (void)updateTheme;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectPagecount:(id)sender;
- (IBAction)selectIncludebox:(id)sender;

@end
