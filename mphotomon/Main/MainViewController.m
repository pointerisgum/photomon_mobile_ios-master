//
//  MainViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 7. 21..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "MainViewController.h"
//#import "SWRevealViewController.h"
#import "EventViewController.h"
#import "PhotobookDesignViewController.h"
#import "PhotobookProductViewController.h"
#import "LoginViewController.h"
#import "Common.h"
#import "Connection.h"
#import "PhotomonInfo.h"
#import "UIView+Toast.h"
#import "UIButton+Border.h"
#import "WebpageViewController.h"
#import "GiftProductViewController.h"
#import "BabyProductViewController.h"
#import "PhotoProductViewController.h"
#import "CardProductViewController.h"
#import "FancyProductViewController.h"
#import "PHAssetUtility.h"
#import "ZXCRollingBanner.h"
#import "WVCartViewController.h"
#import "FrameWebViewController.h"
#import "AuthView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PhotobookStorageViewController.h"

#import <Contacts/Contacts.h>
#import "SocialLoginViewController.h"
#import "NewWebViewController.h"
#import "LoginMenuViewController.h"
#import "UnloginMenuViewController.h"

#import "TopBannerCell.h"
#import "ImageCell.h"
#import "RecommendCell.h"
#import "NewDesignCell.h"
#import "PopListCell.h"

#import "ProgressView.h"
#import "UIColor+HexString.h"

#import "BaseNavigationController.h"

@interface EventButton: UIButton
@property (nonatomic, strong) NSString *url;
@end

@implementation EventButton
@end

@interface MainViewController () <UIScrollViewDelegate, ZXCRollingBannerDelegate, AuthViewDelegate, LoginMenuDelegate, UnloginMenuDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TopBannerCellDelegate, RecommendCellDelegate, NewDesignCellDelegate, PopListCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcLeadingOfMenuView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UINavigationController *tempVC;
@property (strong, nonatomic) LoginMenuViewController *loginVC;
@property (strong, nonatomic) UnloginMenuViewController *unlLoginVC;
@property (strong, nonatomic) UIButton *backgroundButton;
@property (assign, nonatomic) BOOL isFromOtherTapBar;

@property (strong, nonatomic) MainContents *mainContentsList;
@end

@implementation MainViewController


float event_ui_height = 0.f;

NSTimer* mainDlTimer;
int mainDlTimerRepeated = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFromOtherTapBar = false;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TopBannerCell" bundle:nil] forCellWithReuseIdentifier:@"TopBannerCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"RecommendCell" bundle:nil] forCellWithReuseIdentifier:@"RecommendCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"NewDesignCell" bundle:nil] forCellWithReuseIdentifier:@"NewDesignCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PopListCell" bundle:nil] forCellWithReuseIdentifier:@"PopListCell"];
//    [self.collectionView registerClass:[NewDesignCell class] forCellWithReuseIdentifier:@"NewDesignCell"];
    
    
	// 구닥북 연동 관련
	[self.view setHidden:YES];

	NSLog(@"DEBUG :: FUNCTION : viewDidLoad");
    
	_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_spinner.center = CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f);
	CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
	_spinner.transform = transform;
	[self.view addSubview:_spinner];
	[_spinner startAnimating];
    
//    [[PHAssetUtility info] getUserAlbums];

    _is_first = TRUE;
    _is_connected = FALSE;
    _sel_navibutton = 0;

    // set mainviewcontroller
    [PhotomonInfo sharedInfo].mainViewController = self;
    [Common info].main_controller = self;

    // check connection
    [self checkConnection];

//    @try {
//        SWRevealViewController *revealViewController = self.revealViewController;
//        if (revealViewController) {
//            [revealViewController panGestureRecognizer];
//            [revealViewController tapGestureRecognizer];
////            [self.revealButton addTarget: self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
//        }
//
//        NSLog(@"%@", revealViewController.navigationController);
//        NSLog(@"%@", [PhotomonInfo sharedInfo].mainViewController.navigationController);
//    }
//    @catch (NSException *e) {
//        NSLog(@"MAIN > revealViewController : failed");
//    }

#ifdef PHOTOMON_TESTMODE
    [self.view makeToast:@"TEST MODE\nTEST MODE\nTEST MODE\nTEST MODE\nTEST MODE\n^___________^"];
#endif

	// 구닥북 연동 관련
	if(_deeplinkMoveObserver != nil) {
		[[NSNotificationCenter defaultCenter] removeObserver:_deeplinkMoveObserver];
		_deeplinkMoveObserver = nil;
	}
    _deeplinkMoveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-move-notification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
		NSLog(@"DEBUG :: deeplink-move-notification");
        if([Common info].deeplink_url != nil) {
			[self checkDeeplink];

			[Common info].conn_link_init == NO;
			[Common info].dynamic_link_init == NO;
		}
	}];

	// 2019.01.02 : 구닥북 연동 관련
	/*
	__block int nRepeated = 0;
	[NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
		if([Common info].dynamic_link_init == NO) {
			nRepeated++;
			if([Common info].deeplink_url == nil || [Common info].deeplink_url.length == 0) {
				// 2019.01.03
				if(([Common info].conn_link_init == YES && nRepeated >= 80) || ([Common info].conn_link_init == NO && nRepeated >= 10)) {
					[timer invalidate];
					if(_spinner != nil) [_spinner removeFromSuperview];
					[self.view setHidden:NO];

					[Common info].conn_link_init == NO;
					[Common info].dynamic_link_init == NO;
				}
			}
		}
		else {
			if([Common info].deeplink_url == nil || [Common info].deeplink_url.length == 0) {
				[timer invalidate];
				if(_spinner != nil) [_spinner removeFromSuperview];
				[self.view setHidden:NO];				

				[Common info].conn_link_init == NO;
				[Common info].dynamic_link_init == NO;
			}
		}
    }];
	*/
	mainDlTimerRepeated = 0;
	mainDlTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(mainDlTimerFunc) userInfo:nil repeats:YES];

    // HSJ. 180820 : 스크롤 타이머 이벤트 추가 [S]
    NSInteger imgCount = [[Common info].connection.info_eventui_mainthumburl count];
    
	// SJYANG : 2017.12.04 : 메인화면내 화면큰 폰에서 pan 처럼 UI 가 움직이는 오류 수정
	[self.view setNeedsLayout];
    
    [self loadMainData];
}

- (void)loadMainData {
    
    NSString *url_str = [NSString stringWithFormat:URL_MAIN];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        if (data == nil) {
            data = [[NSString alloc] initWithData:ret_val encoding:NSEUCKREncoding];
        }
        NSLog(@">> loadMainData Result: %@", data);
        NSError* err = nil;

        MainContents *contents = [[MainContents alloc]initWithString:data error:&err];
        
        self.mainContentsList = contents;
        
        [self.collectionView reloadData];
        
//        _cartLabel.text = [Common info].connection.info_cart_count;
        
        NSLog(@"mainContents %@", contents);
    }
}

- (void)mainDlTimerFunc {
	if([Common info].dynamic_link_init == NO) {
		mainDlTimerRepeated++;
		if([Common info].deeplink_url == nil || [Common info].deeplink_url.length == 0) {
			// 2019.01.03
			if(([Common info].conn_link_init == YES && mainDlTimerRepeated >= 80) || ([Common info].conn_link_init == NO && mainDlTimerRepeated >= 10)) {
				[mainDlTimer invalidate];
				if(_spinner != nil) [_spinner removeFromSuperview];
				[self.view setHidden:NO];

				[Common info].conn_link_init == NO;
				[Common info].dynamic_link_init == NO;
			}
		}
	}
	else {
		if([Common info].deeplink_url == nil || [Common info].deeplink_url.length == 0) {
			[mainDlTimer invalidate];
			if(_spinner != nil) [_spinner removeFromSuperview];
			[self.view setHidden:NO];				

			[Common info].conn_link_init == NO;
			[Common info].dynamic_link_init == NO;
		}
	}
}

// 2019.01.02 : 구닥북 연동 관련
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self collectionView:self.collection_navi didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
//    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    [self.collectionView reloadData];
    
    _sel_navibutton = 0;
    [_collection_navi reloadData];
    
	NSLog(@"DEBUG :: FUNCTION : viewWillAppear");
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([userDefault boolForKey:@"auth"] == false) {
        [AuthView ShowAuthView:self.view.bounds self:self];
    }
    
//    [self.collectionView setNeedsLayout];
//    [self.collectionView layoutIfNeeded];
}

	/*
	if(_deeplinkMoveObserver != nil) {
		[[NSNotificationCenter defaultCenter] removeObserver:_deeplinkMoveObserver];
		_deeplinkMoveObserver = nil;
	}
    _deeplinkMoveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-move-notification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
		NSLog(@"DEBUG :: deeplink-move-notification");
        if([Common info].deeplink_url != nil) {
            [self checkDeeplink];
		}
	}];
	*/


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == self.collectionView && section == 0) {
        return 8;
    }
    
    return 10;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
//    if (collectionView == self.collectionView) {
//        return 8;
//    }
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        UICollectionViewCell *cell= nil;
    
        NSLog(@"indexPath : %ld", indexPath.row);
        
        switch (indexPath.row) {
            case 0: {
                TopBannerCell *topCell = (TopBannerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TopBannerCell" forIndexPath:indexPath];
                
                [topCell setCellWithDataList:self.mainContentsList.homebanner self:self];

                cell = topCell;
            }break;
                
            case 1: {
                ImageCell *imageCell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
                
                NSDictionary *data = nil;
                
                if ([Common info].user.mUserid.length < 1) {
                    data = (NSDictionary *)self.mainContentsList.members;
                    data = data[@"guest"];
                    
                    [imageCell setTitle:@"포토몬 앱에서만 드려요!" image:data[@"thumb"]];

                } else {
                    data = (NSDictionary *)self.mainContentsList.members;
                    data = data[@"member"];
                    
                    [imageCell setTitle:@"더 가깝게 만나는 포토몬" image:data[@"thumb"]];

                }
                
                cell = imageCell;
            }break;
                
            case 2: {
                RecommendCell *recommendCell = (RecommendCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"RecommendCell" forIndexPath:indexPath];
                
                [recommendCell setRecommentList:self.mainContentsList.recommend self:self];
                
                cell = recommendCell;
            }break;

            case 3: {
                ImageCell *imageCell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
                
                Contents *data = self.mainContentsList.onlyapp;
                
                [imageCell setTitle:@"포토몬 앱에서만 만들 수 있어요!" image:data.thumb];
                
                cell = imageCell;
            }break;
                
            case 4: {
                
                NewDesignCell *newDesignCell = (NewDesignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NewDesignCell" forIndexPath:indexPath];
                
                [newDesignCell setNewDesignCellWithDataList:self.mainContentsList.newdesign isNewDesignType:true self:self];
                
                cell = newDesignCell;
            }break;
                
            case 5: {
                NewDesignCell *newDesignCell = (NewDesignCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NewDesignCell" forIndexPath:indexPath];
                
                NSLog(@"self.mainContentsList %@", self.mainContentsList);
                
                newDesignCell.tag = indexPath.row;

                [newDesignCell setNewDesignCellWithDataList:self.mainContentsList.goods isNewDesignType:false self:self];
                
                cell = newDesignCell;
                
            }break;
            case 6: {
                PopListCell *popListCell = (PopListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PopListCell" forIndexPath:indexPath];
                
                [popListCell setPopListWithData:self.mainContentsList.ranking self:self];
                cell = popListCell;
                
            }break;
                
            case 7: {
                ImageCell *imageCell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];

                [imageCell setImage:@"ban_deliveryinfo"];
                
                cell = imageCell;
                
            }break;
            default:
                break;
        }
        
        
        return cell;
        
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NaviCell" forIndexPath:indexPath];
    
    UILabel *bar = (UILabel *)[cell viewWithTag:101];
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    switch (indexPath.row) {
        case 0:
            label.text = @"홈";
            break;
        case 1:
            label.text = @"포토북";
            break;
        case 2:
            label.text = @"사진인화";
            break;
        case 3:
            label.text = @"달력";
            break;
        case 4:
            label.text = @"액자";
            break;
        case 5:
            label.text = @"카드";
            break;
        case 6:
            label.text = @"굿즈";
            break;
        case 7:
            label.text = @"베이비";
            break;
        case 8:
            label.text = @"팬시";
            break;
        case 9:
            label.text = @"선물가게";
            break;
    }
    
    if (_sel_navibutton == indexPath.row) {
        bar.hidden = NO;
        label.textColor = [UIColor colorFromHexString:@"ff9c00"];
    }
    else {
        bar.hidden = YES;
        label.textColor = [UIColor darkGrayColor];
    }
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        CGFloat height = 0.0f;
        
        switch (indexPath.row) {
            case 0: // 메인 베너
                height = 294.0f;
                break;
            case 1: // 더 가깝게 만나는 포토몬
                height = 259.0f;
                break;
            case 2: // 추천 상품
                height = 335.0f;
                break;
            case 3: // 포토몬 앱에서 만날 수 있어요
                height = 315.5;
                break;
            case 4: // 새로 나온 디자인
                height = 273.5f;;
                height = 0.0f;
                break;
            case 5: // 굿즈
                height = 460.0f;
                break;
            case 6: // 인기순위
                height = 620.0f;
                height = 570.0f;
                break;
            case 7: // 하단베너
                height = 115.0f;
                break;
            default:
                break;
        }
        
        return CGSizeMake(width, height);
    }
    
    NSString *s;
    
    switch (indexPath.row) {
        case 0:
            s = @"홈";
            break;
        case 1:
            s = @"포토북";
            break;
        case 2:
            s = @"사진인화";
            break;
        case 3:
            s = @"달력";
            break;
        case 4:
            s = @"액자";
            break;
        case 5:
            s = @"카드";
            break;
        case 6:
            s = @"굿즈";
            break;
        case 7:
            s = @"베이비";
            break;
        case 8:
            s = @"팬시";
            break;
        case 9:
            s = @"선물가게";
            break;
    }
    
    
    CGSize calCulateSizze =[s sizeWithAttributes:NULL];
    calCulateSizze.width = calCulateSizze.width + 30;
    calCulateSizze.height = 40;
    return calCulateSizze;
    
}

#pragma mark - CollectionView Cell Delegate

- (void)didTouchCellWithData:(Contents *)contents {
    
    NSLog(@"didTouchCellWithData data : %@", contents);
    
    NSString *type, *title, *link;
    
    @try {
        
        NSDictionary *data = (NSDictionary *)contents;

        type = data[@"target"];
        link = data[@"link"];
        title = data[@"title"];
        

    } @catch (NSException *exception) {
        
        type = contents.target;
        title = contents.title;
        link = contents.link;
        
    } @finally {
        
        if ([type isEqualToString:@"deeplink"]) {
            [Common info].deeplink_url = link;
            [self checkDeeplink];
            
        } else if ([type isEqualToString:@"weburl"]) {
            if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:link]]) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:link]];
            }
            
        } else if ([type isEqualToString:@"webview"]) {
            NewWebViewController *newWebVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-newWebVC"];
            
            [newWebVC setType:WebViewTypeCustom];
            newWebVC.urlString = link;
            newWebVC.titleString = title;
            
            [self.navigationController pushViewController:newWebVC animated:true];
            
        }
    }
}

#pragma mark - AuthViewDelegate

- (void)didTouchComfirmButton {
    NSLog(@"didTouchComfirmButton");
	
//	[[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setBool:true forKey:@"auth"];
        [userDefault synchronize];
        
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"granted \(granted)");
            
        }];

        
    }else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                CNContactStore *store = [[CNContactStore alloc] init];
                [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    NSLog(@"granted \(granted)");
                }];

            } else {
				dispatch_async(dispatch_get_main_queue(), ^{
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"사진 접근 권한" message:@"[필수] 포토몬 상품 제작을 위해서 포토라이브러리 사용이 반드시 필요합니다.\n확인 버튼을 누르면 설정화면으로 이동합니다." preferredStyle: UIAlertControllerStyleAlert];
					
					[alert addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//						[[NSNotificationCenter defaultCenter]addObserver:self
//						selector:@selector(didTouchComfirmButton)
//							name:UIApplicationDidBecomeActiveNotification
//						  object:nil];
//
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
								  options:@{}
						completionHandler:nil];
					}]];
					
					[self presentViewController:alert animated:true completion:nil];
				});
                
            }
        }];
    }
}

#pragma mark - User Action

- (IBAction)didTouchMenuButton:(UIButton *)sender {
    
    if (self.backgroundButton==nil){
        CGSize size = [UIScreen mainScreen].bounds.size;
        
        self.backgroundButton = [[UIButton alloc]initWithFrame:CGRectMake(320, 0, size.width -320, size.height)];
        [self.backgroundButton addTarget:self action:@selector(didTouchCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:self.backgroundButton aboveSubview:self.collectionView];
    }
    
    if ([Common info].user.mUserid.length > 0) {
        //로그인
        self.loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-loginedMenu"];
        self.loginVC.delegate = self;
        [self addChildViewController:self.loginVC];
        
        self.loginVC.view.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
        
        [self.menuView addSubview:self.loginVC.view];


    } else {
        //비로그인
        self.unlLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-unloginedMenu"];
        self.unlLoginVC.delegate = self;
        self.unlLoginVC.view.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);

        [self.menuView addSubview:self.unlLoginVC.view];
        
        [self addChildViewController:self.unlLoginVC];

    }
    
    self.alcLeadingOfMenuView.constant = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];

}

#pragma mark - Menu Deleagte

- (void)didTouchCloseButton {
    
    [self loadMainData];
    
    if (self.backgroundButton) {
        [self.backgroundButton removeFromSuperview];
        self.backgroundButton = nil;
    }
    
    if (self.loginVC) {
        [self.loginVC.view removeFromSuperview];
        [self.loginVC removeFromParentViewController];
        self.loginVC = nil;
    }
    
    if (self.unlLoginVC) {
        [self.unlLoginVC.view removeFromSuperview];
        [self.unlLoginVC removeFromParentViewController];
        self.unlLoginVC = nil;
    }

    self.alcLeadingOfMenuView.constant = - 320;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didTouchJoinButton {
    [self didTouchCloseButton];
    [self performSegueWithIdentifier:@"sgMoveToJoinVC" sender:self];
}

- (void)didTouchFindIdButton {
    [self didTouchCloseButton];
    [self performSegueWithIdentifier:@"sgMoveToFindIdVC" sender:self];
}

- (void)didtouchFindPwButton {
    [self didTouchCloseButton];
    [self performSegueWithIdentifier:@"sgMoveToFindPwVC" sender:self];
}

- (void)didTouchViewNomemberOrderButton {
    [self didTouchCloseButton];
    [self performSegueWithIdentifier:@"sgMoveToViewNonmemberOrderVC" sender:self];
}

- (void)didTouchSocialLogin:(NSString *)type {
    
    SocialLoginViewController *socialLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-socialLoginVC"];
    
    socialLoginVC.agent = type;
    
    [self presentViewController:socialLoginVC animated:true completion:nil];
    
    [self didTouchCloseButton];
}

- (void)didTouchSettingButton {
    UIViewController *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-settingVC"];
    
    [self presentViewController:settingVC animated:true completion:nil];
}

- (void)didTouchMenuCategory:(NSInteger)categoryNum {
    // 0 장바구니 1 주문배송 2 보관함
    // 3 쿠폰관리 4 1:1문의 5 공지사항
    NSString *stid;
	NSString *sbid;
    
//    if (categoryNum == 2) {
//        [self performSegueWithIdentifier:@"sgMoveToStoreVC" sender:self];
//        return;
//    }
    
    switch (categoryNum) {
        case 0:
            stid = @"stid-cartBaseVC";
			sbid = @"Main";
            break;
        case 1:
            stid = @"stid-OrderListBaseVC";
			sbid = @"Main";
            break;
        case 2:
            stid = @"stid-PhotobookStorageVC";
			sbid = @"Main";
            break;
        case 3:
            stid = @"CouponPage";
			sbid = @"Main";
            break;
        case 4:
            stid = @"stid-ContactusVC";
			sbid = @"Main";
            break;
        case 5:
            stid = @"stid-NoticeBaseVC";
			sbid = @"Main";
            break;
		case 6:
            // 홈버튼
            break;
		case 7:
            // 이벤트
            break;
		case 8:
            // 시안게시판
			sbid = @"Ddukddak";
			stid = @"DdukddakSianBoard";
            break;
            
        default:
            break;
    }

    if (categoryNum == 2) {
		UIStoryboard *sb = [UIStoryboard storyboardWithName:sbid bundle:nil];
		UIViewController *vc = [sb instantiateViewControllerWithIdentifier:stid];
		
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
		navi.modalPresentationStyle = UIModalPresentationFullScreen;
        
        PhotobookStorageViewController *temp = (PhotobookStorageViewController *)vc;
        
        temp.isFromMain = true;
        [self presentViewController:navi animated:true completion:nil];

	} else if (categoryNum == 6) {
		// 홈버튼이라 아무거도 안함
	} else if (categoryNum == 7) {
		[self clickEvent:nil];
	}else if (categoryNum == 8) {
		UIStoryboard *sb = [UIStoryboard storyboardWithName:sbid bundle:nil];
		UIViewController *vc = [sb instantiateViewControllerWithIdentifier:stid];
		
		UINavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:vc];
		navi.modalPresentationStyle = UIModalPresentationFullScreen;
		
        [self presentViewController:navi animated:true completion:nil];
	}
	else {
		
		UIStoryboard *sb = [UIStoryboard storyboardWithName:sbid bundle:nil];
		UIViewController *vc = [sb instantiateViewControllerWithIdentifier:stid];
		
        [self presentViewController:vc animated:true completion:nil];
    }
    
    [self didTouchCloseButton];
    
}

- (void)didTouchBackButton {
    [self.tempVC dismissViewControllerAnimated:true completion:nil];
}

- (void)didTouchLogoutButton {
    
    if ([[Common info].login_info sendLogout]) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject: @"" forKey:@"userID"];
        [userDefaults setObject: @"" forKey:@"userPassword"];
        [userDefaults setObject: @"" forKey:@"loginType"];
        [userDefaults synchronize];
        
        //[Common info].login_status_changed = YES;
        [[Common info].connection loadVersionInfo_v2];
        [[Common info] alert:self Msg:@"로그아웃되었습니다."];
        [Common info].user = nil;

        NSLog(@"postNotificationName");
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *vc  = [mainStoryboard instantiateViewControllerWithIdentifier: @"MainViewController"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshViewController" object:nil userInfo:nil];
        
        [self didTouchCloseButton];
        [self loadMainData];
        
    }
    else {
        [[Common info] alert:self Msg:@"로그아웃에 실패했습니다."];
    }
}

BOOL refresh_observer_added = NO;

- (void)refreshViewController:(NSNotification *)notification {
	NSLog(@"refreshViewController");
	[self checkConnection];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"viewDidAppear");

	if(refresh_observer_added == NO) {
		NSLog(@"refresh_observer_added");
		[[NSNotificationCenter defaultCenter] removeObserver:@"RefreshViewController"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewController:) name:@"RefreshViewController" object:nil];
		refresh_observer_added = YES;
	}


	if([Common info].login_status_changed == YES ) {
		[Common info].login_status_changed = NO;
		//_is_first = FALSE;
	    //[self popupEventPage];
	}
	[self checkConnection];


	if (_is_first) {
		_is_first = FALSE;
		[self popupEventPage];
	}

    [self checkUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 딥링크 관련 코드
- (void)checkDeeplink {
	if([[Common info].deeplink_url rangeOfString:@"mobile_main"].location != NSNotFound) {
		// 2019.01.25 : 양성진 mobile_main 수정
		if(_spinner != nil) [_spinner removeFromSuperview];
		[self.view setHidden:NO];
		[Common info].deeplink_url= nil;
		return;
	}
	// !!! 완료
    else if ( [[Common info].deeplink_url rangeOfString:@"mobile_printmain"].location != NSNotFound
            || [[Common info].deeplink_url rangeOfString:@"mobile_print"].location != NSNotFound
            || [[Common info].deeplink_url rangeOfString:@"mobile_idphoto"].location != NSNotFound
            || [[Common info].deeplink_url rangeOfString:@"mobile_miniwallet"].location != NSNotFound
            || [[Common info].deeplink_url rangeOfString:@"mobile_divisionphoto"].location != NSNotFound
             || [[Common info].deeplink_url containsString:@"mobile_photobooth"]
             
             ) {
        [self performSegueWithIdentifier:@"ProductPhotoSegue" sender:self];
    }
	// !!! 완료
    else if ( [[Common info].deeplink_url rangeOfString:@"mobile_photobookmain"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_designphotobook"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_premiumphotobook"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_writingphotobook"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_instaphotobook"].location != NSNotFound
             || [[Common info].deeplink_url rangeOfString:@"mobile_skinnyphotobook"].location != NSNotFound
             || [[Common info].deeplink_url rangeOfString:@"mobile_cataloga4photobook"].location != NSNotFound
              || [[Common info].deeplink_url rangeOfString:@"mobile_gudakbook"].location != NSNotFound ) { // HSJ. 180827. 구닥북 딥링크 추가
        //cmh : 앱 이 두번 실행 되는 듯한 문제 해결
        [self performSegueWithIdentifier:@"ProductPhotobookSegue" sender:self];
    }
	// !!! 완료
    else if ( [[Common info].deeplink_url rangeOfString:@"mobile_calendar"].location != NSNotFound  ) {
        [self performSegueWithIdentifier:@"ProductCalendarSegue" sender:self];
    }
	// !!! 완료 -> 좀 애매함. 액자는 PRODUCT LIST 로 별도의 ViewController 를 가지지 않고, PhotoDesignViewController 를 가지고 있어서 딥링크가 약간 꼬일 수 있음. 테스트 필요
    else if ( [[Common info].deeplink_url rangeOfString:@"_mobile_photoframe"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_photoframe"].location != NSNotFound
             || [[Common info].deeplink_url containsString:@"mobile_metalframe"]
             ) {
        [self performSegueWithIdentifier:@"ProductFrameSegue" sender:self];
    }
	// !!! 완료
    else if ( [[Common info].deeplink_url rangeOfString:@"mobile_photocard"].location != NSNotFound
             || [[Common info].deeplink_url containsString:@"mobile_photocardmain"]
             || [[Common info].deeplink_url containsString:@"mobile_photocard_xmas"]
             || [[Common info].deeplink_url containsString:@"mobile_photocard_thanks"]
             || [[Common info].deeplink_url containsString:@"mobile_photocard_love"]
             || [[Common info].deeplink_url containsString:@"mobile_photocard_newyear"]
             ) {
        [self performSegueWithIdentifier:@"ProductCardSegue" sender:self];
    }
	// !!! 완료 -> 많이 애매함. 폴라로이드는 PRODUCT LIST 로 별도의 ViewController 를 가지지 않고, 중간 경로의 의미로 PhotoDesignViewController 를 가지고 있어서 딥링크가 약간 꼬일 수 있음. 테스트 필요
    else if ( [[Common info].deeplink_url rangeOfString:@"_mobile_squaresetpolaroid"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_squaresetpolaroid"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"_mobile_woodpolaroid"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_woodpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidmain"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_polaroidmain"].location != NSNotFound)
    {
        [self performSegueWithIdentifier:@"ProductPhotoSegue" sender:self];
    }
	// !!! 완료
    else if ( [[Common info].deeplink_url rangeOfString:@"mobile_gift"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_giftmain"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_mug"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_postcard"].location != NSNotFound ||
              [[Common info].deeplink_url rangeOfString:@"mobile_phonecase"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_photomagnet"].location != NSNotFound) {
        [self performSegueWithIdentifier:@"ProductGiftSegue" sender:self];
    }
	// !!! 완료
    else if ( [[Common info].deeplink_url rangeOfString:@"mobile_baby"].location != NSNotFound ||
			 [[Common info].deeplink_url containsString:@"monthlybaby"]) {
        [self performSegueWithIdentifier:@"ProductBabySegue" sender:self];
    }
    // daypark
    else if ( [[Common info].deeplink_url rangeOfString:@"mobile_fancy"].location != NSNotFound
             || [[Common info].deeplink_url rangeOfString:@"mobile_fancymain"].location != NSNotFound
             || [[Common info].deeplink_url rangeOfString:@"mobile_namesticker"].location != NSNotFound
             || [[Common info].deeplink_url rangeOfString:@"mobile_divisionsticker"].location != NSNotFound
             ) {
        [self performSegueWithIdentifier:@"ProductFancySegue" sender:self];
    }
    else if ([[Common info].deeplink_url rangeOfString:@"mobile_fanbook"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_poster"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_paperslogan"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_transparentcard"].location != NSNotFound ||
            [[Common info].deeplink_url rangeOfString:@"mobile_goodsmain"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_goodsphotocard"].location != NSNotFound) {
        [self performSegueWithIdentifier:@"ProductGoodsSegue" sender:self];
    }
}

// SJYANG : 2016.06.30
- (void)loadMainButtonImage:(NSString*)imageUrl TargetObj:(UIButton*)targetObj {
    dispatch_group_async(_loopForGroup, _queue, ^{
        @try {
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            if (img != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [targetObj setImage:img forState:UIControlStateNormal];
                });
            }
        }
        @catch (NSException *e) {
            NSLog(@"loadMainButtonImage failed");
        }
    });
}

// SJYANG : 2016.06.30
- (void)loadEventButtonImage {
    NSLog(@"loadEventButtonImage");
	@try {

        [_event_button setImage:nil forState:UIControlStateNormal];
        
        NSInteger imgCount = [[Common info].connection.info_eventui_mainthumburl count];
        
        
        NSLog(@"[Common info].connection.info_eventui_mainthumburl : %@", [Common info].connection.info_eventui_mainthumburl);
        
        ZXCRollingBanner *oldBannerContainer = [self.view viewWithTag:7767];
        
        if (oldBannerContainer) {
            [oldBannerContainer removeFromSuperview];
        }

        CGRect f = _event_button.frame;

        
        CGFloat width =  [UIScreen mainScreen].bounds.size.width;
        ZXCRollingBanner * sc = [[ZXCRollingBanner alloc]initWithFrame:CGRectMake(0, 0,f.size.width, f.size.height)];
        sc.tag = 7767;
        sc.delegate = self;
        [sc setImageWithUrlArr:[Common info].connection.info_eventui_mainthumburl];
        [self.content_view addSubview:sc];
        
        
        NSString *imgURL = [[Common info].connection.info_eventui_mainthumburl objectAtIndex:0];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
//        CGRect f = _event_button.frame;
//        CGRect newF = CGRectMake(i * f.size.width, f.origin.y, f.size.width, f.size.height);

        /*
                newEventButton.url = [[Common info].connection.info_eventui_deeplink objectAtIndex:i];
                [newEventButton addTarget:self action:@selector(onEventButton:) forControlEvents:UIControlEventTouchDown];
        }
         */
        
	}
	@catch (NSException *e) {
		NSLog(@"loadMainButtonImage failed");
	}

	/*
    dispatch_group_async(_loopForGroup, _queue, ^{
        @try {
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[Common info].connection.info_eventui_mainthumburl]]];
            if (img != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_event_button setImage:img forState:UIControlStateNormal];
                });
            }
        }
        @catch (NSException *e) {
            NSLog(@"loadMainButtonImage failed");
        }
    });
	*/
}
#pragma mark - zxcAdScrollViewDelegate

-(void)scrollToIndex:(NSInteger)index{
//    NSLog(@"scroll : %ld",index);
}

-(void)tapAtIndex:(NSInteger)index{
    NSLog(@"tap : %ld",index);
    if ([[[Common info].connection.info_eventui_deeplink objectAtIndex:index] length] > 0) {
        [Common info].inner_deeplink = YES;
        [Common info].deeplink_url = [[Common info].connection.info_eventui_deeplink objectAtIndex:index];
        NSLog(@"DEBUG :: tapAtIndex : %@", [Common info].deeplink_url);
        [self checkDeeplink];
    } else if ([[Common info].connection.info_eventui_weburl[index] length] > 0){
        FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
        frameWebView.webviewUrl = [Common info].connection.info_eventui_weburl[index];
        [self presentViewController:frameWebView animated:YES completion:nil];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView {

}

// SJYANG : 2016.06.30 : 많은 작업을 MainThread 에서 처리하다보니 Crash 가 나는 경우가 있어서, Background Thread 로 분리
- (void)loadMainPage {
	// 디버그
	/*
	if ([Common info].login_info.user_id.length < 1) 
		[Common info].connection.info_eventui_enable = @"";
	else
		[Common info].connection.info_eventui_enable = @"true";
	*/

	_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _loopForGroup = dispatch_group_create();

	NSLog(@"loadMainPage : %@", [Common info].connection.info_eventui_enable);

    // HSJ. 180820 : 스크롤 페이지 추가 [S]
    [self loadEventButtonImage];
    
    BOOL hasEvent = NO;
    
    for (NSString *b in [Common info].connection.info_eventui_enable) {
        if ([b isEqualToString:@"true"]) {
            hasEvent = YES;
        }
    }
    // HSJ. 180820 : 스크롤 페이지 추가 [E]
    
    if (hasEvent) {
		_constraint_event_button_1.constant = 8;

		[_event_button setTranslatesAutoresizingMaskIntoConstraints:NO];
		if(_aspectRatioConstraint != nil) 
			[_event_button removeConstraint:_aspectRatioConstraint];
		_aspectRatioConstraint = [NSLayoutConstraint
										  constraintWithItem:_event_button
										  attribute:NSLayoutAttributeHeight
										  relatedBy:NSLayoutRelationEqual
										  toItem:_event_button
										  attribute:NSLayoutAttributeWidth
										  multiplier:89.f / 160.f
										  constant:0];
		[_event_button addConstraint: self.aspectRatioConstraint];

		[self loadEventButtonImage];
	}
	else {
		_constraint_event_button_1.constant = 0;

		[_event_button setTranslatesAutoresizingMaskIntoConstraints:NO];
		if(_aspectRatioConstraint != nil) 
			[_event_button removeConstraint:_aspectRatioConstraint];
		_aspectRatioConstraint = [NSLayoutConstraint
										  constraintWithItem:_event_button
										  attribute:NSLayoutAttributeHeight
										  relatedBy:NSLayoutRelationEqual
										  toItem:_event_button
										  attribute:NSLayoutAttributeWidth
										  multiplier:0
										  constant:0];
		[_event_button addConstraint: self.aspectRatioConstraint];
	}

    [self loadMainButtonImage:URL_MAIN_BUTTON01 TargetObj:_photobook_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON03 TargetObj:_calendar_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON04 TargetObj:_frame_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON05 TargetObj:_polaroid_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON07 TargetObj:_photo_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON06 TargetObj:_gift_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON08 TargetObj:_baby_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON09 TargetObj:_card_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON10 TargetObj:_fancy_button];
    [self loadMainButtonImage:URL_MAIN_BUTTON11 TargetObj:_goods_button];

    dispatch_group_wait(_loopForGroup, DISPATCH_TIME_FOREVER);

    CGRect screenRect = [[UIScreen mainScreen] bounds];

    _content_view_height = 0;
    _content_view_height+=_photobook_button.bounds.size.height + 8;
    _content_view_height+=_calendar_button.bounds.size.height + 8;
    _content_view_height+=_photo_button.bounds.size.height + 8;
    _content_view_height+=_frame_button.bounds.size.height + 8;
    _content_view_height+=_polaroid_button.bounds.size.height + 8;
    _content_view_height+=_fancy_button.bounds.size.height + 8;
    _content_view_height+=_gift_button.bounds.size.height + 8;
    _content_view_height+=_baby_button.bounds.size.height + 8;
    _content_view_height+=_card_button.bounds.size.height + 8;
    _content_view_height+=_goods_button.bounds.size.height + 8;
    
    
    // HSJ. 180820 : 스크롤 페이지 추가 [S]
	if (hasEvent) {
		if(_card_button.bounds.size.height > 0.f) {
			event_ui_height = _card_button.bounds.size.height;
		}
		_content_view_height+= event_ui_height + 8;
	}

	// 이벤트 처리를 할 것인지?
	
    dispatch_async(dispatch_get_main_queue(), ^{
        _constraints_content_view_height.constant = _content_view_height;

		{
			CGRect frm = _content_view.frame;
			frm.size.width = 320;
			_content_view.frame = frm;
		}
		[_scroll_view setContentSize:CGSizeMake(320, _content_view_height)];
		[self.view setNeedsLayout];
	});
    // HSJ. 180820 : 스크롤 페이지 추가 [E]
}

- (void)popupEventPage {
    NSString *url = [Common info].connection.event_url; //[PhotomonInfo sharedInfo].eventUrl;
    NSString *show = [Common info].connection.event_show; //[PhotomonInfo sharedInfo].eventShow;
    if ([show isEqualToString:@"Y"] && url.length > 0) {
        EventViewController *evc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventPage"];
        evc.eventType = 0;
        [self presentViewController:evc animated:YES completion:nil];
    }
}

- (IBAction)clickEvent:(id)sender {
    NSString *url = [Common info].connection.main_event_url;
    if (url.length > 0) {
#if 0
        if ([Common info].user.mUserid.length < 1) {
            [[Common info] alert:self Title:@"로그인을 해주세요." Msg:@"" completion:^{
                [self didTouchMenuButton:nil];
            }];

            return;
        }
#endif
        EventViewController *evc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventPage"];
        evc.eventType = 1;
        [self presentViewController:evc animated:YES completion:nil];
    }
    else {
        [[Common info] alert:self Msg:@"진행중인 이벤트가 없습니다."];
    }
}

- (void)popupDetailPage:(NSString *)intnum {
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, @""];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)photobookDetail:(id)sender {
    [self popupDetailPage:@"300"];
}
- (IBAction)cardDetail:(id)sender {
    [self popupDetailPage:@"376"];
}
- (IBAction)calendarDetail:(id)sender {
    [self popupDetailPage:@"277"];
}
- (IBAction)frameDetail:(id)sender {
    [self popupDetailPage:@"350"];
}
- (IBAction)fancyDetail:(id)sender {
    [self popupDetailPage:@"347"];
}
- (IBAction)giftDetail:(id)sender {
    [self popupDetailPage:@"357"];
}
- (IBAction)babyDetail:(id)sender {
    [self popupDetailPage:@"366"];
}
- (IBAction)photoDetail:(id)sender {
    [self popupDetailPage:@"239"];
}

- (IBAction)clickLogo:(id)sender {
}


//
- (void)onCartviaExternalController {
    [self performSegueWithIdentifier:@"CartSegue" sender:self];
}

// check update
- (void)checkUpdate {
    NSLog(@"checkUpdate");
    // 2016.06.30 : SJYANG : Thread 처리
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        if ([[Common info].connection needUpdate]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Common info] alert:self Title:@"업데이트가 필요합니다." Msg:@"" completion:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Common info].connection.appstore_url]];//[PhotomonInfo sharedInfo].appUrl]];
                    exit(0);
                }];
            });
        }
    });
}

// check connection
- (void)checkConnection {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    _internetReachability = [Reachability reachabilityForInternetConnection];
    [_internetReachability startNotifier];
    [self updateInterfaceWithReachability: _internetReachability];
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReachability = [note object];
    NSParameterAssert([curReachability isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability: curReachability];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    if (reachability == _internetReachability) {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        NSString* statusString = @"";
        switch (netStatus) {
            case ReachableViaWWAN:
                _is_connected = TRUE;
                statusString = @"Reachable WWAN.. OK!!";
                break;
            case ReachableViaWiFi:
                _is_connected = TRUE;
                statusString = @"Reachable WiFi.. OK!!";
                break;
            case NotReachable:
            default:
                _is_connected = FALSE;
                statusString = NSLocalizedString(@"errorNetworkConnection", nil);
                break;
        }

    if (_is_connected) {
            [[Common info].login_info checkLogin];
            [[Common info].connection loadVersionInfo_v2];

			dispatch_async(dispatch_get_main_queue(), ^{
				//_cartLabel.text = [NSString stringWithFormat:@"%d", (int)[PhotomonInfo sharedInfo].cartList.count];
		        if ([Common info].user.mUserid.length < 1)
                    _cartLabel.text = [NSString stringWithFormat:@"%d", (int)[PhotomonInfo sharedInfo].cartList.count];
				else
					_cartLabel.text = [Common info].connection.info_cart_count;
				_eventLabel.text = [Common info].connection.main_event_count;
				_constraints_content_view_height.constant = _content_view_height;
			});

            // 2016.06.30 : SJYANG : Thread 처리
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                [[PhotomonInfo sharedInfo] loadCartSession];
                [[PhotomonInfo sharedInfo] loadCartList];     // 장바구니 목록 개수를 보여주기 위해 미리 호출함. (productinfo, cartsession의 정보 요구됨)

				/*
                dispatch_async(dispatch_get_main_queue(), ^{
                    _cartLabel.text = [NSString stringWithFormat:@"%d", (int)[PhotomonInfo sharedInfo].cartList.count];
                });
				*/
            });

//            [self loadMainPage];
            [self checkUpdate];

            _eventLabel.text = [Common info].connection.main_event_count;
        }
        else {
            [self.view makeToast:statusString];
        }
	}
	// SJYANG : 2017.12.04 : 메인화면내 화면큰 폰에서 pan 처럼 UI 가 움직이는 오류 수정
	[self.view setNeedsLayout];
}

// SJYANG : 2017.12.04 : 메인화면내 화면큰 폰에서 pan 처럼 UI 가 움직이는 오류 수정
- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	dispatch_async(dispatch_get_main_queue(), ^{
		_scroll_view.alwaysBounceHorizontal = NO;
		_scroll_view.bounces = YES;
		_scroll_view.alwaysBounceVertical = YES;

		{
			CGRect frm = _content_view.frame;
			frm.size.width = 320;
			_content_view.frame = frm;
		}
		[_scroll_view setContentSize:CGSizeMake(320, _content_view_height)];
	});
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (!_is_connected) {
        [[Common info] alert:self Msg: NSLocalizedString(@"errorNetworkConnection", nil)];
        return NO;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProductPhotobookSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        PhotobookDesignViewController *vc = (PhotobookDesignViewController *)navi.topViewController;
        if (vc) {
            vc.product_type = PRODUCT_PHOTOBOOK;
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductCalendarSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        PhotobookProductViewController *vc = (PhotobookProductViewController *)navi.topViewController;
        if (vc) {
            vc.product_type = PRODUCT_CALENDAR;
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductPolaroidSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        PhotobookDesignViewController *vc = (PhotobookDesignViewController *)navi.topViewController;
        if (vc) {
            vc.product_type = PRODUCT_POLAROID;
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductFrameSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        PhotobookDesignViewController *vc = (PhotobookDesignViewController *)navi.topViewController;
        if (vc) {
            vc.product_type = PRODUCT_FRAME;
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductPhotosSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        PhotoProductViewController *vc = (PhotoProductViewController *)navi.topViewController;
        if (vc) {
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductGiftSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        GiftProductViewController *vc = (GiftProductViewController *)navi.topViewController;
        if (vc) {
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductBabySegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        BabyProductViewController *vc = (BabyProductViewController *)navi.topViewController;
        if (vc) {
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductCardSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        CardProductViewController *vc = (CardProductViewController *)navi.topViewController;
        if (vc) {
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductFancySegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        FancyProductViewController *vc = (FancyProductViewController *)navi.topViewController;
        if (vc) {
        }
    }
    else if ([segue.identifier isEqualToString:@"ProductGoodsSegue"]) {
        UINavigationController *navi = [segue destinationViewController];
        FancyProductViewController *vc = (FancyProductViewController *)navi.topViewController;
        if (vc) {
        }
    }
    else if ([segue.identifier isEqualToString:@"CartSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        WVCartViewController *viewController = navController.viewControllers[0];

        viewController.callerViewController = self;
    }
}

////
////

- (void)moveToTargetTabBar:(int)index {
    self.isFromOtherTapBar = true;
    [self collectionView:self.collection_navi didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_is_connected) {
        [[Common info] alert:self Msg: NSLocalizedString(@"errorNetworkConnection", nil)];
        return;
    }
    
    if (collectionView == self.collectionView) {
        
        if (indexPath.row == 1) {
            NSDictionary *data = (NSDictionary *)self.mainContentsList.members;

            if ([Common info].user.mUserid.length < 1) {
                [self performSegueWithIdentifier:@"sgMoveToJoinVC" sender:self];
                return;
                
            } else {
                data = data[@"member"];
                [self didTouchCellWithData:(Contents *)data];
            }
            
            
        } else if (indexPath.row == 3) {
            [self didTouchCellWithData:self.mainContentsList.onlyapp];
        } else if (indexPath.row == 7) {
            NewWebViewController *newWebVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-newWebVC"];
            
            [newWebVC setType:WebViewTypeDeliver];
            
            [self.navigationController pushViewController:newWebVC animated:true];

        }
        return;
    }
    
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        return;
    }
    
    row -= 1;
    
    if (!self.isFromOtherTapBar) {
        [Common info].mainTabBarOffset = self.collection_navi.contentOffset;
    }
    
    switch (row) {
        case 0:
            [self performSegueWithIdentifier:@"ProductPhotobookSegue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"ProductPhotoSegue" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"ProductCalendarSegue" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"ProductFrameSegue" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"ProductCardSegue" sender:self];
            break;
        case 5:
            [self performSegueWithIdentifier:@"ProductGoodsSegue" sender:self];
            break;
        case 6:
            [self performSegueWithIdentifier:@"ProductBabySegue" sender:self];
            break;
        case 7:
            [self performSegueWithIdentifier:@"ProductFancySegue" sender:self];
            break;
        case 8:
            [self performSegueWithIdentifier:@"ProductGiftSegue" sender:self];
            break;
    }
	
    if (!self.isFromOtherTapBar) {
        
        _sel_navibutton = (int)indexPath.row;
        [self.collection_navi performBatchUpdates:^{
            [self.collection_navi reloadData];
            
        } completion:^(BOOL finished) {
            [self.collection_navi scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
        }];

    }
    
    self.isFromOtherTapBar = false;
}

- (IBAction)onEventButton:(EventButton *)sender {
    [Common info].inner_deeplink = YES;
    [Common info].deeplink_url = sender.url;
    NSLog(@"%@", sender.url);
    [self checkDeeplink];
}

@end
