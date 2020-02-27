//
//  IDPhotosProductMainViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDPhotosProductMainViewController : UIViewController
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_text1_leading;
//@property (weak, nonatomic) IBOutlet UILabel *lbl1;
//@property (weak, nonatomic) IBOutlet UILabel *lbl2;
//@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)goGuidePage:(id)sender;
- (IBAction)goDetailPage:(id)sender;

- (IBAction)selectPhoto:(id)sender;

@end
