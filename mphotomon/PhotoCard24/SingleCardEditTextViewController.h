//
//  CardEditTextViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 6. 30..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@protocol SingleCardEditTextDelegate <NSObject>
//@optional
- (void)editTextDone:(NSString *)oriText withFmtText:(NSString* )fmtText withAlignment:(int)alignment;
@end

@interface SingleCardEditTextViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (assign) CGFloat edittext_width;
@property (assign) CGFloat edittext_height;
@property (weak, nonatomic) IBOutlet UIView *contentview;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (assign) CGFloat fontsize;
@property (assign) int alignment;
@property (strong, nonatomic) NSString* textcontents;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_edittext_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_edittext_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_contentview_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_contentview_bottomspace;
@property (strong, nonatomic) id<SingleCardEditTextDelegate> delegate;
- (IBAction)alignLeft:(id)sender;
- (IBAction)alignCenter:(id)sender;
- (IBAction)alignRight:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onCancel:(id) sender;
@end
