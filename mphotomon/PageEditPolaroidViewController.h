//
//  PageEditPolaroidViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "BaseViewController.h"

@protocol PageEditPolaroidViewControllerDelegate <NSObject>
@optional
- (void)changeLayout:(Layout*)layout;
@end


@interface PageEditPolaroidViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UINavigationItem *title_bar;
@property (assign) int selected_layout;
@property (strong, nonatomic) NSString *layouttype;
@property (strong, nonatomic) NSMutableArray *layouts;

@property (strong, nonatomic) id<PageEditPolaroidViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (void)updateLayouts;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
