//
//  PhotoCropViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 27..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Photobook.h"
#import "PhotoCropEditView.h"


// delegate
@protocol PhotoCropViewControllerDelegate <NSObject>
@optional
- (void)didEditPhoto;
- (void)cancelEditPhoto;
@end


// controller
@interface PhotoCropViewController : BaseViewController

@property (strong, nonatomic) Photobook *photobook;

@property (assign) int cur_index;
@property (strong, nonatomic) NSMutableArray *crop_infos;
@property (strong, nonatomic) id<PhotoCropViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet PhotoCropEditView *edit_view;
@property (strong, nonatomic) IBOutlet UILabel *comment_label;
@property (strong, nonatomic) IBOutlet UIButton *prev_button;
@property (strong, nonatomic) IBOutlet UIButton *next_button;

- (void)loadCropInfo:(Photobook *)photobook SelectedLayer:(Layer *)sel_layer;
- (void)saveCropInfo;

- (IBAction)prevPhoto:(id)sender;
- (IBAction)nextPhoto:(id)sender;
- (IBAction)rotateRight:(id)sender;
- (IBAction)rotateLeft:(id)sender;
- (IBAction)undoAll:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
