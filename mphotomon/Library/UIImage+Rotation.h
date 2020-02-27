#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@interface UIImage (Rotation)

+ (UIImage *)rotateImage:(UIImage *)image Rotation:(int)angle;

@end

