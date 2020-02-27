//
//  IDPhotosProductMainViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosProductMainViewController.h"
#import "Common.h"
#import "UIView+Toast.h"

@interface IDPhotosProductMainViewController () <SelectPhotoDelegate>

@end

@implementation IDPhotosProductMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"IDPhotosProductMain"];

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosProductMain" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    _scrollview.contentSize = CGSizeMake(320, 900);
}

- (void)viewWillAppear:(BOOL)animated {
//    //_constraint_text1_leading.constant = self.view.frame.size.width * 0.057;
//    _lbl1.text = @"・ 가로 3.5cm, 세로 4.5cm 규격 / 6개월 이내 촬영한 사진";
//    _lbl2.text = @"・ 사진 내 머리길이(정수리부터 턱까지) 3.2~3.6cm";
//    _lbl3.text = @"・ 양쪽 귀, 눈썹 노출된 정면사진 / 사진배경은 흰색";
//    {
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: _lbl1.attributedText];
//
//        [text addAttribute:NSForegroundColorAttributeName 
//                     value:[UIColor blackColor] 
//                     range:NSMakeRange(0, [text length])];
//
//        [text addAttribute:NSForegroundColorAttributeName 
//                     value:[UIColor redColor] 
//                     range:NSMakeRange(2, 30)];
//        [_lbl1 setAttributedText: text];
//    }
//    {
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: _lbl2.attributedText];
//
//        [text addAttribute:NSForegroundColorAttributeName 
//                     value:[UIColor blackColor] 
//                     range:NSMakeRange(0, [text length])];
//
//        [text addAttribute:NSForegroundColorAttributeName 
//                     value:[UIColor redColor] 
//                     range:NSMakeRange(7, 25)];
//        [_lbl2 setAttributedText: text];
//    }
//    {
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: _lbl3.attributedText];
//
//        [text addAttribute:NSForegroundColorAttributeName 
//                     value:[UIColor blackColor] 
//                     range:NSMakeRange(0, [text length])];
//
//        [text addAttribute:NSForegroundColorAttributeName 
//                     value:[UIColor redColor] 
//                     range:NSMakeRange(2, 11)];
//
//        [text addAttribute:NSForegroundColorAttributeName 
//                     value:[UIColor redColor] 
//                     range:NSMakeRange(20, 10)];
//        [_lbl3 setAttributedText: text];
//    }
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	/*
    if ([segue.identifier isEqualToString:@"IDPhotosProductMainSegue"]) {
        IDPhotosProductMainViewController *vc = [segue destinationViewController];
        if (vc) {
        }
    }
	*/
}

- (IBAction)goGuidePage:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.passport.go.kr/issue/photo.php"]];
}

- (IBAction)goDetailPage:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.passport.go.kr/issue/photo.php"]];

}

- (IBAction)selectPhoto:(id)sender {
	[Common info].photobook.product_type = PRODUCT_IDPHOTO;
	[[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
}

#pragma mark - SelectPhotoDelegate methods
- (void)selectPhotoDone:(BOOL)is_singlemode {
	[self performSegueWithIdentifier:@"PhotosSelectItemSegue" sender:self];
}

- (void)selectPhotoCancel:(BOOL)is_singlemode {
	if (is_singlemode) {
	}
	else {
		//		[self.navigationController popViewControllerAnimated:NO];
	}
	//	[self clearSelectedInfo];
}
@end
