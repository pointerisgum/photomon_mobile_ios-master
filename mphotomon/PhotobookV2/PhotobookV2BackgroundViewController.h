//
//  PhotobookV2BackgroundViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 29..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "BaseViewController.h"

@protocol PhotobookV2BackgroundViewControllerDelegate <NSObject>
@optional
- (void)changeBackground:(Background*)background;
@end


@interface PhotobookV2BackgroundViewController : BaseViewController

@property (assign) int filter;
@property (assign) int selected_background;
@property (strong, nonatomic) NSString *sel_pagetype;
@property (strong, nonatomic) NSMutableArray *backgrounds;

@property (weak, nonatomic) IBOutlet UIView *buttonbar;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonbar_constraint;

@property (strong, nonatomic) id<PhotobookV2BackgroundViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (void)updateBackgrounds;

- (IBAction)onfilter1:(id)sender;
- (IBAction)onfilter2:(id)sender;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
