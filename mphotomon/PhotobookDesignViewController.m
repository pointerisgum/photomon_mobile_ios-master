//
//  PhotobookDesignViewController.m
//  
//
//  Created by photoMac on 2015. 9. 16..
//
//

#import "PhotobookDesignViewController.h"
#import "PhotobookDetailViewController.h"
#import "PhotobookV2DetailViewController.h"
#import "CalendarDetailViewController.h"
#import "PolaroidDetailViewController.h"
#import "FrameDetailViewController.h"
#import "WebpageViewController.h"
#import "FrameWebViewController.h"
#import "Common.h"
#import "GudakPhotobookDetailViewController.h"
#import "MainTabBar.h"

@interface PhotobookDesignViewController ()<MainTabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *tabBaseView;
@property (strong, nonatomic) MainTabBar *tabBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcHeightOfTabBaseview;

@end

@implementation PhotobookDesignViewController

// 딥링크 관련 코드
static int deeplink_idx = -1; 
static UIImageView* deeplink_imageview;

static NSString * const reuseIdentifier = @"PhotobookDesignCell";
static NSString * const reuseNaviIdentifier = @"PhotobookNaviCell";
static NSArray * naviKeyword;
static NSArray * naviComment;

- (void)didTouchTabBarWithNaviIndex:(int)index {
    
    if(_product_type == PRODUCT_PHOTOBOOK && _photobook_type == 0){
        _sel_navibutton = index;
        [self filterThemes];
        [_collection_view reloadData];
    }
    else{
    [self dismissViewControllerAnimated:false completion:^{
        [Common info].mainTabBarOffset = [self.tabBar collectionViewOffset];
        [[Common info].main_controller moveToTargetTabBar:index];
    }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	int tabbarIndex = 4;
    
    // 딥링크 관련 코드
    deeplink_idx = -1; 
    deeplink_imageview = nil;

    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_designphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_premiumphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_writingphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_instaphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_gudakbook"].location != NSNotFound) {   // HSJ. 180827. 구닥북 딥링크 추가
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
			tabbarIndex = 2;
        }
        else if ( [[Common info].deeplink_url rangeOfString:@"_mobile_photoframe"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"mobile_photoframe"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
            [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification" 
                                                              object:nil 
                                                               queue:[NSOperationQueue mainQueue] 
                                                          usingBlock:^(NSNotification *note) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }];
        }
        else if( [[Common info].deeplink_url containsString:@"mobile_metalframe"]){
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            deeplink_imageview = [[Common info] showDeepLinkLaunchScreen:self.view];
        }
        else if( [[Common info].deeplink_url containsString:@"mobile_skinnyphotobook"] || [[Common info].deeplink_url containsString:@"mobile_cataloga4photobook"] ){
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            //deeplink_imageview = [[Common info] showDeepLinkLaunchScreen:self.view];
        }
        else if ( [[Common info].deeplink_url rangeOfString:@"_mobile_squaresetpolaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"mobile_squaresetpolaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidmain"].location != NSNotFound ||
                  [[Common info].deeplink_url rangeOfString:@"mobile_polaroidmain"].location != NSNotFound ) {
            [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification" 
                                                              object:nil 
                                                               queue:[NSOperationQueue mainQueue] 
                                                          usingBlock:^(NSNotification *note) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }];
            if ( (([[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
                   [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound ||
                   [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidmain"].location != NSNotFound ||
                   [[Common info].deeplink_url rangeOfString:@"mobile_polaroidmain"].location != NSNotFound) &&
				   [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location == NSNotFound &&
				   [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location == NSNotFound)) {
                [self.navigationController setNavigationBarHidden:NO animated:NO];
                [Common info].deeplink_url= nil;
            }
            else {
                [self.navigationController setNavigationBarHidden:false animated:YES];
//                deeplink_imageview = [[Co mmon info] showDeepLinkLaunchScreen:self.view];
            }
			tabbarIndex = 2;
        }
		else if ( [[Common info].deeplink_url rangeOfString:@"mobile_calendar"].location != NSNotFound) {
			[self.navigationController setNavigationBarHidden:NO animated:NO];
			[Common info].deeplink_url= nil;
			tabbarIndex = 3;
		}
    }
    
    _thumbCache = [[NSCache alloc] init];
    
    float height = 0;

    switch (_product_type) {
        case PRODUCT_PHOTOBOOK: {
            // SJYANG : 제품 선택에서 넘어온 포토북 제품 타입에 따라 해당 제품의 테마 리스트를 표시
            if( _photobook_type==0 ){
                //height = 42;
                tabbarIndex = 0;
                [self onPhotobook:nil];
            }
            else if( _photobook_type==1 )
                [self onInstabook:nil];
            else if( _photobook_type==2 )
                [self onAnalogBook:nil];
            else if( _photobook_type==3 )
                [self onPremiumBook:nil];
            else if( _photobook_type==4 ) // SJYANG : 스키니북
                [self onSkinnyBook:nil];
            else if( _photobook_type==5 ) // SJYANG : 카달로그
                [self onCatalogBook:nil];
            else if( _photobook_type==6 ) // cmh : 구닥북
                [self onGudakBook:nil];
            
            if( _photobook_type != 0 ){
                //height = 42;
                tabbarIndex = 1;
                
            }

            [Analysis log:@"PhotobookDesign"]; break;
        }
        case PRODUCT_CALENDAR:
            [Analysis log:@"CalendarDesign"];
            tabbarIndex = 3;
            break;
        case PRODUCT_POLAROID: [Analysis log:@"PolaroidDesign"]; break;
        case PRODUCT_FRAME: [Analysis log:@"FrameDesign"]; break;
        default: NSAssert(NO, @"Invalid Product Type !!"); break;
    }
    _collection_navi.hidden = height > 0 ? NO : YES;
    _naviHeight.constant = height;

    if (_product_type == PRODUCT_FRAME) {
        [self setTitle:@"제품 선택"];
    }
    [Common info].photobook_root_controller = self;
	
    if (_product_type == PRODUCT_PHOTOBOOK && _photobook_type == 0 ) {
       // _hideTapBar = true;
        //[self loadPhotobookStyle];
        if (naviKeyword == nil || naviComment == nil)
        {
            //naviKeyword = [NSArray arrayWithObjects: @"all", @"best", @"baby", @"kids", @"graduate", @"couple", @"wedding", @"season", @"family", @"religion", @"silver", @"simple", @"emotion", @"calli", @"illust", @"travel", nil];
            //naviComment = [NSArray arrayWithObjects: @"전체", @"베스트", @"베이비", @"키즈", @"졸업", @"커플", @"웨딩", @"시즌", @"가족", @"종교", @"실버", @"심플", @"감성", @"캘리", @"일러", @"여행", nil];
            [[Common info].photobook_theme.depth_list insertObject:@"all" atIndex:0];
            [[Common info].photobook_theme.depth_list_str insertObject:@"전체" atIndex:0];
            naviKeyword = [NSArray arrayWithArray:[Common info].photobook_theme.depth_list];
            naviComment = [NSArray arrayWithArray:[Common info].photobook_theme.depth_list_str];
                                          
        }

    }
    
	if (self.hideTapBar) {
		self.alcHeightOfTabBaseview.constant = 0.0f;
		
	} else {
        if( _product_type == PRODUCT_PHOTOBOOK && _photobook_type == 0 ){
            self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tabBaseView.bounds naviIndex:tabbarIndex delegate:self naviComments:[[NSMutableArray alloc]initWithArray:naviComment]];
            
            [self.tabBaseView addSubview:self.tabBar];
        }else{
            self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tabBaseView.bounds naviIndex:tabbarIndex delegate:self];
            
            [self.tabBaseView addSubview:self.tabBar];
            
            
        }
        
		
		
	}
    
    _sel_navibutton = 0;
    
    if( _product_type != PRODUCT_PHOTOBOOK || (_product_type == PRODUCT_PHOTOBOOK && _photobook_type != 0 )){
        [self loadPhotobookTheme];
    }
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// SJYANG : 코드상으로 처리하는데, IB 에서 처리할 수 있도록 수정해야 함
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    switch (_product_type) {
        case PRODUCT_PHOTOBOOK:[Analysis firAnalyticsWithScreenName:@"PhotobookDesign" ScreenClass:[self.classForCoder description]];
            break;
        case PRODUCT_CALENDAR: [Analysis firAnalyticsWithScreenName:@"CalendarDesign" ScreenClass:[self.classForCoder description]];
            break;
        case PRODUCT_POLAROID: [Analysis firAnalyticsWithScreenName:@"PolaroidDesign" ScreenClass:[self.classForCoder description]];
            break;
        case PRODUCT_FRAME: [Analysis firAnalyticsWithScreenName:@"FrameDesign" ScreenClass:[self.classForCoder description]];
            break;
        default: NSAssert(NO, @"Invalid Product Type !!"); break;
    }
    
    _collection_view.hidden = NO;

}

- (void)viewDidLayoutSubviews {
    
}

// SJYANG
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _collection_view.hidden = YES;
    [self.tabBar updateCollectionViewOffset];

    if( _product_type==PRODUCT_PHOTOBOOK || _product_type==PRODUCT_CALENDAR )
        self.navigationItem.leftBarButtonItem = nil; 

    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"_mobile_squaresetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_squaresetpolaroid"].location != NSNotFound ) {
            int idx = [self getIdxOfProduct:@"347003"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ( [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ) {
            int idx = [self getIdxOfProduct:@"347001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ( [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound ) {
            int idx = [self getIdxOfProduct:@"347002"];
            if(idx != -1) deeplink_idx = idx;
        }

        if(deeplink_idx > -1) {
            [UIView setAnimationsEnabled:NO];
            [self performSegueWithIdentifier:@"PolaroidDetailSegue" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];         
                [UIView setAnimationsEnabled:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }
        
        if ( [[Common info].deeplink_url containsString:@"mobile_metalframe"] ) {
            int idx = [self getIdxOfProduct:@"436001"];
            if(idx != -1) deeplink_idx = idx;
            [UIView setAnimationsEnabled:NO];
            [self performSegueWithIdentifier:@"FrameDetailSegue" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];
                [UIView setAnimationsEnabled:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }else if ( [[Common info].deeplink_url containsString:@"mobile_skinnyphotobook"] || [[Common info].deeplink_url containsString:@"mobile_cataloga4photobook"]  ) {
            int idx = [self getIdxOfProduct:@"300180"];
            if(idx != -1) deeplink_idx = idx;
            [UIView setAnimationsEnabled:NO];
            [self performSegueWithIdentifier:@"PhotobookDetailSegue" sender:self];
            //[self performSegueWithIdentifier:@"FrameDetailSegue" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];
                [UIView setAnimationsEnabled:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }
            
    }
    
    deeplink_imageview = nil;
}

// 딥링크 관련 코드
- (int)getIdxOfProduct:(NSString *)productCode {
    int idx = 0;
    int theme_count = (int)[Common info].photobook_theme.themes.count;
    for (int i = 0; i <= theme_count-1 ; i++) {
        Theme *theme = [Common info].photobook_theme.themes[i];
        if([theme.book_infos count] > 0) {
            BookInfo *bookinfo = theme.book_infos[0];
            if ( [bookinfo.productcode isEqualToString:productCode] )
                return(idx);
        }
        idx++;
    }
    return(-1);
}
- (void)loadPhotobookStyle {
    
    [[Common info].photobook_theme.themes removeAllObjects];
    if ([[Common info].photobook_theme loadPhotobookStyle:_product_type]) {
        if (_product_type == PRODUCT_PHOTOBOOK) {
            int theme_count = (int)[Common info].photobook_theme.themes.count;
            for (int i = theme_count-1; i >= 0; i--) {
                Theme *theme = [Common info].photobook_theme.themes[i];
                
                // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
                // SJYANG : 스키니북/카탈로그북 추가
                
                //                if ([theme.theme1_id isEqualToString:@"gudak"]) {
                //                    if (![_product_code isEqualToString:theme.productcode])
                //                        [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                //                }/Users/kimkihwan/photomonios2nd/mphotomon/PhotobookDesignViewController.m
                //
                if ([_product_code isEqualToString:@"300267"] || [_product_code isEqualToString:@"300268"] || [_product_code isEqualToString:@"300269"] || [_product_code isEqualToString:@"300270"]) {
                    NSLog(@"ASDF IN %d", _photobook_type);
                    if (![_product_code isEqualToString:theme.productcode])
                        [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                }
                else {
                    NSLog(@"ASDF NOT %d", _photobook_type);
                    if (_photobook_type == 1) {
                        if (![theme.theme1_id isEqualToString:@"insta"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    else if (_photobook_type == 2) {
                        if (![theme.theme1_id isEqualToString:@"analogue"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    // SJYANG : 프리미엄북
                    else if (_photobook_type == 3) {
                        if (![theme.theme1_id isEqualToString:@"premium"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    // SJYANG : 스키니북
                    else if (_photobook_type == 4) {
                        if (![theme.theme1_id isEqualToString:@"skinny"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    // SJYANG : 카달로그북
                    else if (_photobook_type == 5) {
                        if (![theme.theme1_id isEqualToString:@"catalog"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    else {  // 포토북 분기 (포토북과 구닥북은 공존한다.)
                        if ([[Common info] isGudakBook:_product_code]) {    // 구닥북일 경우 구닥북 이외의 테마는 모두 제거
                            if (![theme.theme1_id isEqualToString:@"gudak"]) {
                                [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                            }
                        } else {    // 포토북일 경우 구닥북을 제외한 디자인 제거
                            if ([theme.theme1_id isEqualToString:@"insta"] || [theme.theme1_id isEqualToString:@"analogue"] || [theme.theme1_id isEqualToString:@"premium"] || [theme.theme1_id isEqualToString:@"skinny"] || [theme.theme1_id isEqualToString:@"catalog"] ||
                                [theme.theme1_id isEqualToString:@"gudak"]) {
                                [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                            }
                        }
                    }
                }
            }
        }
        else if (_product_type == PRODUCT_CALENDAR) {
            int theme_count = (int)[Common info].photobook_theme.themes.count;
            for (int i = theme_count-1; i >= 0; i--) {
                Theme *theme = [Common info].photobook_theme.themes[i];
                
                if (![theme.theme1_id isEqualToString:_product_id]) {
                    [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                }
            }
        }
    }
    [self filterThemes];
    [_collection_view reloadData];
}
- (void)loadPhotobookTheme {
    [[Common info].photobook_theme.themes removeAllObjects];
    if ([[Common info].photobook_theme loadTheme:_product_type]) {
        if (_product_type == PRODUCT_PHOTOBOOK) {
            int theme_count = (int)[Common info].photobook_theme.themes.count;
            for (int i = theme_count-1; i >= 0; i--) {
                Theme *theme = [Common info].photobook_theme.themes[i];
                
                // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
				// SJYANG : 스키니북/카탈로그북 추가
                
//                if ([theme.theme1_id isEqualToString:@"gudak"]) {
//                    if (![_product_code isEqualToString:theme.productcode])
//                        [[Common info].photobook_theme.themes removeObjectAtIndex:i];
//                }/Users/kimkihwan/photomonios2nd/mphotomon/PhotobookDesignViewController.m
//
                if ([_product_code isEqualToString:@"300267"] || [_product_code isEqualToString:@"300268"] || [_product_code isEqualToString:@"300269"] || [_product_code isEqualToString:@"300270"]) {
                    NSLog(@"ASDF IN %d", _photobook_type);
                    if (![_product_code isEqualToString:theme.productcode]) 
                        [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                }
                else {
                    NSLog(@"ASDF NOT %d", _photobook_type);
                    if (_photobook_type == 1) {
                        if (![theme.theme1_id isEqualToString:@"insta"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    else if (_photobook_type == 2) {
                        if (![theme.theme1_id isEqualToString:@"analogue"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    // SJYANG : 프리미엄북
                    else if (_photobook_type == 3) {
                        if (![theme.theme1_id isEqualToString:@"premium"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    // SJYANG : 스키니북
                    else if (_photobook_type == 4) {
                        if (![theme.theme1_id isEqualToString:@"skinny"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    // SJYANG : 카달로그북
                    else if (_photobook_type == 5) {
                        if (![theme.theme1_id isEqualToString:@"catalog"]) {
                            [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                        }
                    }
                    else {  // 포토북 분기 (포토북과 구닥북은 공존한다.)
                        if ([[Common info] isGudakBook:_product_code]) {    // 구닥북일 경우 구닥북 이외의 테마는 모두 제거
                            if (![theme.theme1_id isEqualToString:@"gudak"]) {
                                [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                            }
                        } else {    // 포토북일 경우 구닥북을 제외한 디자인 제거
                            if ([theme.theme1_id isEqualToString:@"insta"] || [theme.theme1_id isEqualToString:@"analogue"] || [theme.theme1_id isEqualToString:@"premium"] || [theme.theme1_id isEqualToString:@"skinny"] || [theme.theme1_id isEqualToString:@"catalog"] ||
                                [theme.theme1_id isEqualToString:@"gudak"] || [theme.theme1_id isEqualToString:@"fanbook"]) {
                                [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                            }
                        }
                    }
                }
            }
        }
        else if (_product_type == PRODUCT_CALENDAR) {
            int theme_count = (int)[Common info].photobook_theme.themes.count;
            for (int i = theme_count-1; i >= 0; i--) {
                Theme *theme = [Common info].photobook_theme.themes[i];
                
                if (![theme.theme1_id isEqualToString:_product_id]) {
                    [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                }
            }
        }
    }
    [self filterThemes];
    [_collection_view reloadData];
}

- (void)filterThemes {
    if (_photobook_themes == nil) {
        _photobook_themes = [[NSMutableArray alloc] init];
    }
    
    [_photobook_themes removeAllObjects];
    
    for (Theme* theme in [Common info].photobook_theme.themes)
    {
        if (_sel_navibutton == 0 || [theme.depth1_key isEqualToString:naviKeyword[_sel_navibutton]]) {
            [_photobook_themes addObject:theme];
        }
        /*else if(_sel_navibutton == 1)
        {
            // 베스트 테마 선택 부분 - 필요하다면 theme1_id도 추가로 검증해야함
            if ([theme.theme2_id isEqualToString:@"Hellojeju"]
                || [theme.theme2_id isEqualToString:@"MocaLatte"]
            )
            {
                [_photobook_themes addObject:theme];
            }
        }*/
    }
    
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

- (IBAction)onPhotobook:(id)sender {
    _photobook_type = 0;
    //[self loadPhotobookTheme];
    [self loadPhotobookStyle];
}

- (IBAction)onInstabook:(id)sender {
    _photobook_type = 1;
    [self loadPhotobookTheme];
}

- (IBAction)onAnalogBook:(id)sender {
    _photobook_type = 2;
    [self loadPhotobookTheme];
}

// SJYANG : 프리미엄북
- (IBAction)onPremiumBook:(id)sender {
    _photobook_type = 3;
    [self loadPhotobookTheme];
}

// SJYANG : 스키니북
- (IBAction)onSkinnyBook:(id)sender {
    _photobook_type = 4;
    [self loadPhotobookTheme];
}

// SJYANG : 카달로그북
- (IBAction)onCatalogBook:(id)sender {
    _photobook_type = 5;
    [self loadPhotobookTheme];
}

// cmh : 구닥북
- (IBAction)onGudakBook:(id)sender {
    _photobook_type = 6;
    [self loadPhotobookTheme];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PhotobookDetailSegue"]) {
        PhotobookDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.selected_theme = _photobook_themes[indexPath.row];
            switch (_photobook_type) {
                case 0:
                    vc.select_size = @"8x8";
                    break;
                case 1:
                    vc.select_size = @"5.5x5.5";
                    break;
                case 2:
                    vc.select_size = @"A5w";
                    break;
                // SJYANG : 프리미엄북
                case 3:
                    vc.select_size = @"8x8";
                    break;
            }
            [vc updateTheme];
        }
    }
    else if ([segue.identifier isEqualToString:@"CalendarDetailSegue"]) {
        CalendarDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.selected_theme = _photobook_themes[indexPath.row];
            [vc updateTheme];
        }
    }
    else if ([segue.identifier isEqualToString:@"PolaroidDetailSegue"]) {
        PolaroidDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];

            // 딥링크 관련 코드
            int idx = (int)indexPath.row;
            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            vc.selected_theme = _photobook_themes[idx];

            [vc updateTheme];
        }
    }
    else if ([segue.identifier isEqualToString:@"FrameDetailSegue"]) {
        FrameDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            int idx = (int) indexPath.row;
            if ([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            vc.selected_theme = _photobook_themes[idx];
            [vc updateTheme];
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(collectionView.tag == 2){
        return 16;
    }
    
    return _photobook_themes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView.tag == 2){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseNaviIdentifier forIndexPath:indexPath];
        
        UILabel *bar = (UILabel *)[cell viewWithTag:201];
        UILabel *label = (UILabel *)[cell viewWithTag:200];
        
        label.text = naviComment[indexPath.row];
        
        if (_sel_navibutton == indexPath.row) {
            bar.hidden = NO;
            label.textColor = [UIColor redColor];
        }
        else {
            bar.hidden = YES;
            label.textColor = [UIColor blackColor];
        }
        return cell;
    }
    
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    Theme *theme = _photobook_themes[indexPath.row];
    
    if(_product_type == PRODUCT_PHOTOBOOK && _photobook_type == 0){
        if (theme) {
            
            // 썸네일 fullurl
            NSString *fullpath = @"";
            if([theme.element_content containsString:@"://"])
                fullpath = theme.element_content;
            else
                fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, theme.main_thumb];
            
            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            UIImage *cachedImage = [_thumbCache objectForKey:url];
            
            if (cachedImage)
            {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = cachedImage;
                imageview.contentMode = UIViewContentModeScaleAspectFit;
                imageview.backgroundColor = UIColor.whiteColor;
               
            }
            else
            {
                [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                    if (succeeded) {
                        UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                        
                        imageview.contentMode = UIViewContentModeScaleAspectFit;
                        imageview.backgroundColor = UIColor.whiteColor;
                        UIImage *cachedImage = [[UIImage alloc] initWithData:imageData];
                        if (cachedImage){
                            [[self thumbCache] setObject:cachedImage forKey:url];
                        }
                        imageview.image = cachedImage;
                    }
                    else {
                        NSLog(@"theme's thumbnail_image is not downloaded.");
                    }
                }];
            }
            
            // SJYANG
            // 사진 액자에서 상세보기 팝업 버튼 숨김
            UILabel *label1 = (UILabel *)[cell viewWithTag:102];
            UIButton *detail_btn1 = (UIButton *)[cell viewWithTag:101];
            UIButton *detail_btn2 = (UIButton *)[cell viewWithTag:110];
            detail_btn1.hidden = YES;
            detail_btn2.hidden = YES;
            
                label1.translatesAutoresizingMaskIntoConstraints = NO;
                NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0f constant:38];
                [cell addConstraint:constraint];
                
                detail_btn1.hidden = NO;
          
            
            NSString *price = [[Common info] toCurrencyString:[theme.price intValue]];
            NSString *discount = [[Common info] toCurrencyString:[theme.discount intValue]];
            
            label1.text = theme.depth2_str;
            
                UILabel *label2 = (UILabel *)[cell viewWithTag:103];
                label2.text = [NSString stringWithFormat:@"%@원", price];
                
                UILabel *label3 = (UILabel *)[cell viewWithTag:104];
                label3.text = [NSString stringWithFormat:@"%@원", discount];
           
            
            if ([price isEqualToString:discount]) {
                UILabel *label_price = (UILabel *)[cell viewWithTag:103];
                UILabel *label_strikeout = (UILabel *)[cell viewWithTag:105];
                label_price.hidden = YES;
                label_strikeout.hidden = YES;
            }
            
        }
    }
    else{
        if (theme) {

		// 썸네일 fullurl
        NSString *fullpath = @"";
		if([theme.main_thumb containsString:@"://"])                              
			fullpath = theme.main_thumb;
		else
			fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, theme.main_thumb];

        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        UIImage *cachedImage = [_thumbCache objectForKey:url];

        if (cachedImage)
        {
            UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
            imageview.image = cachedImage;
            if([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 ){
                imageview.contentMode = UIViewContentModeScaleAspectFit;
            }
        }
        else
        {
            [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                if (succeeded) {
                    UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                    if([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 ){
                        imageview.contentMode = UIViewContentModeScaleAspectFit;
                    }
                    UIImage *cachedImage = [[UIImage alloc] initWithData:imageData];
                    if (cachedImage){
                        [[self thumbCache] setObject:cachedImage forKey:url];
                    }
                    imageview.image = cachedImage;
                }
                else {
                    NSLog(@"theme's thumbnail_image is not downloaded.");
                }
            }];
        }

        // SJYANG
        // 사진 액자에서 상세보기 팝업 버튼 숨김
        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        UIButton *detail_btn1 = (UIButton *)[cell viewWithTag:101];
        UIButton *detail_btn2 = (UIButton *)[cell viewWithTag:110];
        detail_btn1.hidden = YES;
        detail_btn2.hidden = YES;
        if( _product_type==PRODUCT_FRAME ) {
            label1.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0f constant:11];
            [cell addConstraint:constraint];

	        if([theme.book_infos count] > 0) {
		        detail_btn2.hidden = NO;
			}
        }
        else {
            label1.translatesAutoresizingMaskIntoConstraints = NO;
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0f constant:38];
            [cell addConstraint:constraint];

            detail_btn1.hidden = NO;
        }

        NSString *price = [[Common info] toCurrencyString:[theme.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[theme.discount intValue]];
        
        label1.text = theme.theme_name;
        if (_product_type == PRODUCT_POLAROID) {
            NSAssert(theme.book_infos.count > 0, @"polaroid's book_info is not founded");
            BookInfo *book_info = theme.book_infos[0]; // 폴라로이드는 1개 only.
            
            UILabel *label2 = (UILabel *)[cell viewWithTag:103];
            label2.text = [NSString stringWithFormat:@"%@p", book_info.minpictures];
            UILabel *label_strikeout = (UILabel *)[cell viewWithTag:105];
            label_strikeout.hidden = YES;
            
            UILabel *label3 = (UILabel *)[cell viewWithTag:104];
            label3.text = [NSString stringWithFormat:@"%@원", discount];
        }
        else if (_product_type == PRODUCT_FRAME) {
            UILabel *label2 = (UILabel *)[cell viewWithTag:103];
            label2.hidden = YES;
            UILabel *label_strikeout = (UILabel *)[cell viewWithTag:105];
            label_strikeout.hidden = YES;
            
            UILabel *label3 = (UILabel *)[cell viewWithTag:104];
            label3.text = [NSString stringWithFormat:@"%@원~", discount];
        }
        else {
            UILabel *label2 = (UILabel *)[cell viewWithTag:103];
            label2.text = [NSString stringWithFormat:@"%@원", price];
            
            UILabel *label3 = (UILabel *)[cell viewWithTag:104];
            label3.text = [NSString stringWithFormat:@"%@원", discount];
        }
        
        if ([price isEqualToString:discount]) {
            UILabel *label_price = (UILabel *)[cell viewWithTag:103];
            UILabel *label_strikeout = (UILabel *)[cell viewWithTag:105];
            label_price.hidden = YES;
            label_strikeout.hidden = YES;
        }
        
    }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 2)
    {
        _sel_navibutton = (int)indexPath.row;
        [self filterThemes];
        
        [_collection_navi reloadData];
        [_collection_view reloadData];
        
    }
    else
    {
        //openurl,webviewurl 처리 추가.
        Theme *theme = _photobook_themes[indexPath.row];
        
        BOOL bOpen = NO;
        if (theme != nil && theme.openurl != nil && ![theme.openurl isEqualToString:@""]) {
            bOpen = YES;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theme.openurl]];
        }
        if (theme != nil && theme.webviewurl != nil && ![theme.webviewurl isEqualToString:@""]) {
            bOpen = YES;
            FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
            frameWebView.webviewUrl = theme.webviewurl;
            [self presentViewController:frameWebView animated:YES completion:nil];
        }
        if(!bOpen){
            BookInfo *book_info;
            NSString *productcode = @"";
            if([theme.book_infos count] > 0){
                book_info = theme.book_infos[0];
                productcode = book_info.productcode;
            }
            if (_product_type == PRODUCT_PHOTOBOOK) {
                if ([[Common info] isGudakBook:productcode]) {
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GudakBook" bundle:nil];
                    GudakPhotobookDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"GudakPhotobookDetailViewController"];
                    
                    if (vc) {
                        NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
                        vc.selected_theme = _photobook_themes[indexPath.row];
                        switch (_photobook_type) {
                            case 0:
                                vc.select_size = @"8x8";
                                break;
                            case 1:
                                vc.select_size = @"5.5x5.5";
                                break;
                            case 2:
                                vc.select_size = @"A5w";
                                break;
                                // SJYANG : 프리미엄북
                            case 3:
                                vc.select_size = @"8x8";
                                break;
                        }
                        [vc updateTheme];
                    }
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    Theme *selectedTheme = _photobook_themes[indexPath.row];
                    
                    if(selectedTheme.depth1_key.length > 0){
                        //[self performSegueWithIdentifier:@"PhotobookDetailSegue" sender:self];
                        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotobookV2" bundle:nil];
                        PhotobookV2DetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PhotobookDetailViewController"];
                        if (vc) {
                            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
                            vc.selected_theme = _photobook_themes[indexPath.row];
                            
                            
                            //[[Common info].photobook_theme loadPhotobookTheme:_product_type paramDepth1Key:vc.selected_theme.depth1_key paramDepth2Key:vc.selected_theme.depth2_key paramProductType:@"designphotobook"];
                            [[Common info].photobook_theme loadPhotobookTheme:_product_type paramDepth1Key:vc.selected_theme.depth1_key paramDepth2Key:vc.selected_theme.depth2_key paramProductType:@"designphotobook" selectedTheme:vc.selected_theme];
                            
                            [Common info].photobook_theme.selected_theme = nil;
                            switch (_photobook_type) {
                                case 0:
                                    //vc.select_size = @"8x8";
                                    vc.select_size = vc.selected_theme.book_sizes[0];
                                    vc.selected_covertype = ((SelectOption*)vc.selected_theme.sel_covertypes[0]).comment;
                                    break;
                                case 1:
                                    vc.select_size = @"5.5x5.5";
                                    break;
                                case 2:
                                    vc.select_size = @"A5w";
                                    break;
                                    // SJYANG : 프리미엄북
                                case 3:
                                    vc.select_size = @"8x8";
                                    break;
                            }
                            
                            
                            [vc updateTheme];
                            //[self.navigationController presentViewController:vc animated:YES completion:nil ];
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                            
                    }else{
                        [self performSegueWithIdentifier:@"PhotobookDetailSegue" sender:self];
                    }
                    
                }
            }
            else if (_product_type == PRODUCT_CALENDAR) {
                [self performSegueWithIdentifier:@"CalendarDetailSegue" sender:self];
            }
            else if (_product_type == PRODUCT_POLAROID) {
                [self performSegueWithIdentifier:@"PolaroidDetailSegue" sender:self];
            }
            else if (_product_type == PRODUCT_FRAME) {
                [self performSegueWithIdentifier:@"FrameDetailSegue" sender:self];
            }
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 2){
        return CGSizeMake(60, 42);
    }
        
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    if (_product_type == PRODUCT_POLAROID) {
        height = width / 2.65f;
    }
    return CGSizeMake(width, height + 40);
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}
*/

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// SJYANG
// 테마 상세보기 팝업 처리
- (IBAction)popupMore:(id)sender {
    NSString *url;
    if( _product_type==PRODUCT_FRAME || _product_type==PRODUCT_POLAROID ) {
        UICollectionViewCell* cell ;
        UIButton* button = (UIButton*)sender;
        NSIndexPath *indexPath;

        @try {
            cell = (UICollectionViewCell*)[[button superview]superview];
            indexPath = [_collection_view indexPathForCell:cell];
        } 
        @catch (NSException *e) {
            @try {
                cell = (UICollectionViewCell*)[[[button superview]superview]superview];
                indexPath = [_collection_view indexPathForCell:cell];
            }
            @catch (NSException *e) {
                cell = (UICollectionViewCell*)[button superview];
                indexPath = [_collection_view indexPathForCell:cell];
            }
        }

        Theme *theme = _photobook_themes[indexPath.row];
        BookInfo *book_info = theme.book_infos[0];
        NSString* productcode = book_info.productcode;
        NSString *intnum = @"";
        NSString *seqnum = @"";
        if (productcode.length == 6) {
            intnum = [productcode substringWithRange:NSMakeRange(0, 3)];
	            seqnum = [productcode substringWithRange:NSMakeRange(3, 3)];
        }
        url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    } else {
        NSString *intnum = @"";
        NSString *seqnum = @"";
        if (_product_code.length == 6) {
            intnum = [_product_code substringWithRange:NSMakeRange(0, 3)];
            seqnum = [_product_code substringWithRange:NSMakeRange(3, 3)];
        }
        url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    }
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self.navigationController popToViewController:self animated:NO];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
