//
//  SCENavCollectionViewCell.m
//  PHOTOMON
//
//  Created by cmh on 2018. 7. 10..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import "SCENavCollectionViewCell.h"




@implementation SCENavCollectionViewCell

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.clickedLocation = [touch locationInView:touch.view.superview];
}

@end
