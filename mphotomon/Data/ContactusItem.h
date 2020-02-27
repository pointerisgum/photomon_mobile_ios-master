//
//  ContactusItem.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 10..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactusItem : NSObject

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *security;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userName;

@end

@interface ContactusListItem : NSObject

@property (strong, nonatomic) NSString *idx;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *writedate;
@property (strong, nonatomic) NSString *security;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *re_step;
@property (strong, nonatomic) NSString *body;

@end
