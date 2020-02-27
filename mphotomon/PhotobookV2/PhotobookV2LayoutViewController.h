//
//  PhotobookV2LayoutViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 29..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "BaseViewController.h"

@protocol PhotobookV2LayoutViewControllerDelegate <NSObject>
@optional
- (void)changeLayout:(Layout*)layout;
@end


//
@interface PhotobookV2LayoutViewController : BaseViewController

@property (assign) int filter; // 0:all, 1:1~2구, 2:3~4구, 3:5구이상, 4:현재테마
@property (assign) int selected_layout;
@property (strong, nonatomic) NSString *layouttype;
@property (strong, nonatomic) NSMutableArray *layouts;

@property (strong, nonatomic) id<PhotobookV2LayoutViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIView *buttonbar;
@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;
@property (strong, nonatomic) IBOutlet UIButton *button3;
@property (strong, nonatomic) IBOutlet UIButton *button4;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonbar_constraint;

- (void)updateLayouts;

- (IBAction)onfilter1:(id)sender;
- (IBAction)onfilter2:(id)sender;
- (IBAction)onfilter3:(id)sender;
- (IBAction)onfilter4:(id)sender;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
