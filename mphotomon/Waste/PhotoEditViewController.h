//
//  PhotoEditViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 21..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photobook.h"
#import "PhotoEditView.h"

@protocol PhotoEditViewControllerDelegate <NSObject>
@optional
- (void)didEditPhoto;
- (void)cancelEditPhoto;
@end


@interface PhotoEditViewController : UIViewController

@property (assign) int rotate_angle;
@property (strong, nonatomic) Layer *layer;

@property (strong, nonatomic) IBOutlet PhotoEditView *editView;
@property (strong, nonatomic) id<PhotoEditViewControllerDelegate> delegate;

- (void)initPhoto;
- (void)rotateAngle:(int)angle;
- (IBAction)undoAll:(id)sender;
- (IBAction)rotateLeft:(id)sender;
- (IBAction)rotateRight:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
