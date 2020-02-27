//
//  MainContents.m
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "MainContents.h"

@implementation MainContents

@end


@implementation Contents

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"count"] || [propertyName isEqualToString:@"category"])
        return YES;
    
    return NO;
}

@end
