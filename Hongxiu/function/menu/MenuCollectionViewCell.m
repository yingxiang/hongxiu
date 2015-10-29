//
//  MenuCollectionViewCell.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "MenuCollectionViewCell.h"

@implementation MenuCollectionViewCell
@synthesize titleLabel = _titleLabel;

- (UILabel*)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.borderWidth = 1;
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _titleLabel;
}
@end
