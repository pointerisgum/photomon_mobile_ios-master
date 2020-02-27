//
//  PageBackgroundViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "BaseViewController.h"

@protocol PageBackgroundViewControllerDelegate <NSObject>
@optional
- (void)changeBackground:(Background*)background;
@end


@interface PageBackgroundViewController : BaseViewController

@property (assign) int filter;
@property (assign) int selected_background;
@property (strong, nonatomic) NSString *sel_pagetype;
@property (strong, nonatomic) NSMutableArray *backgrounds;

@property (weak, nonatomic) IBOutlet UIView *buttonbar;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonbar_constraint;

@property (strong, nonatomic) id<PageBackgroundViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (void)updateBackgrounds;

- (IBAction)onfilter1:(id)sender;
- (IBAction)onfilter2:(id)sender;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
