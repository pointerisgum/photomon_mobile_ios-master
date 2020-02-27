//
//  MainContents.h
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol Contents

@end

@interface Contents : JSONModel

@property (nonatomic) NSString *thumb;
@property (nonatomic) NSString *link;
@property (nonatomic) NSString *target;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *count;

@end

@protocol Members

@end

@interface Members : JSONModel

@property (nonatomic) Contents *guest;
@property (nonatomic) Contents *member;

@end

@protocol Ranking

@end

@interface Ranking : JSONModel

@property (nonatomic) NSString *taptitle;
@property (nonatomic) NSArray <Contents *> *taplist;

@end

@protocol RankingObject

@end

@interface RankingObject : JSONModel

@property (nonatomic) Ranking *ranktap1;
@property (nonatomic) Ranking *ranktap2;


@end

@protocol MainContents

@end

@interface MainContents : JSONModel

@property (nonatomic) NSArray <Contents *> *homebanner;
@property (nonatomic) Members *members;
@property (nonatomic) NSArray <Contents *> *recommend;
@property (nonatomic) Contents *onlyapp;
@property (nonatomic) NSArray <Contents *> *newdesign;
@property (nonatomic) NSArray <Contents *> *goods;
@property (nonatomic) RankingObject *ranking;

@end




