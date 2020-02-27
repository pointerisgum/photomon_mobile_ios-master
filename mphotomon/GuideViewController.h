//
//  GuideViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 22..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol GuideDelegate <NSObject>
@optional
- (void)closeGuide;
@end

@interface GuideViewController : BaseViewController

@property (strong, nonatomic) id<GuideDelegate> delegate;

@property (strong, nonatomic) NSString *guide_id;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIButton *checkDontShow;

- (IBAction)clickDontShow:(id)sender;
- (IBAction)close:(id)sender;
@end
