//
//  IntroViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 04/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "IntroViewController.h"
#import "MainViewController.h"

#import "Common.h"

@interface IntroViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *ivLaunchImage;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ivLaunchImage.image = [UIImage imageNamed:@"launchImage_photo"];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:false block:^(NSTimer * _Nonnull timer) {
        
        [self performSegueWithIdentifier:@"sgMoveToMain" sender:self];
        
    }];
}




@end
