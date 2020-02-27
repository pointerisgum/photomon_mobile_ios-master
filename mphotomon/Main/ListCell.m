//
//  ListCell.m
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "ListCell.h"
#import "UIImageView+WebCache.h"

@interface ListCell ()
@property (weak, nonatomic) IBOutlet UILabel *lbRanking;
@property (weak, nonatomic) IBOutlet UIImageView *ivThumb;
@property (weak, nonatomic) IBOutlet UILabel *lbCategory;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbLikeCount;

@end

@implementation ListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setListCellWithContents:(Contents *)contents index:(NSInteger)index {
    NSDictionary *data = (NSDictionary *)contents;
    
    self.lbTitle.text = data[@"title"];
    self.lbCategory.text = data[@"category"];
    self.lbLikeCount.text = [data[@"count"] stringValue];
    self.lbRanking.text = [NSString stringWithFormat:@"%zd", index];

    [self.ivThumb sd_setImageWithURL:[NSURL URLWithString:data[@"thumb"]]];
}
@end

