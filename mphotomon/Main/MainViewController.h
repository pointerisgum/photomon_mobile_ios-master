//
//  MainViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 7. 21..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "MainContents.h"

@interface MainViewController : UIViewController

@property (assign) BOOL is_first;
@property (assign) BOOL is_connected;

@property (strong, nonatomic) Reachability *internetReachability;

@property (strong, nonatomic) IBOutlet UIButton *revealButton;
@property (strong, nonatomic) IBOutlet UILabel *cartLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_event_button_1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_event_button_2;
@property (weak, nonatomic) IBOutlet UIButton *event_button;

@property (assign) int sel_navibutton;
@property (assign) float content_view_height;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_navi;

@property (strong, nonatomic) IBOutlet UIButton *photobook_button;
@property (strong, nonatomic) IBOutlet UIButton *card_button;
@property (strong, nonatomic) IBOutlet UIButton *calendar_button;
@property (strong, nonatomic) IBOutlet UIButton *frame_button;
@property (strong, nonatomic) IBOutlet UIButton *polaroid_button;
@property (strong, nonatomic) IBOutlet UIButton *fancy_button;
@property (strong, nonatomic) IBOutlet UIButton *gift_button;
@property (strong, nonatomic) IBOutlet UIButton *baby_button;
@property (strong, nonatomic) IBOutlet UIButton *photo_button;
@property (weak, nonatomic) IBOutlet UIButton *goods_button;
@property (weak, nonatomic) IBOutlet UIView *content_view;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_content_view_height;

@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) dispatch_group_t loopForGroup;

@property (strong, nonatomic) UIImageView* deeplink_imageview;
@property (strong, nonatomic) NSLayoutConstraint* aspectRatioConstraint;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (strong, nonatomic) id deeplinkMoveObserver;

- (void)checkDeeplink;
- (void)checkUpdate;
- (void)checkConnection;
- (void)popupEventPage;
- (void)onCartviaExternalController;

- (IBAction)clickEvent:(id)sender;
- (IBAction)clickLogo:(id)sender;

- (IBAction)photobookDetail:(id)sender;
- (IBAction)cardDetail:(id)sender;
- (IBAction)calendarDetail:(id)sender;
- (IBAction)frameDetail:(id)sender;
- (IBAction)polaroidDetail:(id)sender;
- (IBAction)fancyDetail:(id)sender;
- (IBAction)giftDetail:(id)sender;
- (IBAction)babyDetail:(id)sender;
- (IBAction)photoDetail:(id)sender;

- (void)loadMainData;
- (IBAction)onEventButton:(id)sender;
- (IBAction)didTouchMenuButton:(UIButton *)sender;
- (void)didTouchJoinButton;
- (void)moveToTargetTabBar:(int)index;
- (void)didTouchCloseButton;
- (void)didTouchCellWithData:(Contents *)contents;
- (void)didTouchMenuCategory:(NSInteger)categoryNum;

@end
