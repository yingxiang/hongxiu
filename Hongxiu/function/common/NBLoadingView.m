//
//  NBLoadingView.m
//  HybirdNamibox
//
//  Created by xiang ying on 15/10/2.
//  Copyright © 2015年 Elephant. All rights reserved.
//

#import "NBLoadingView.h"

@interface NBLoadingView ()

nonatomic_strong(UIActivityIndicatorView, *loadingView)
nonatomic_strong(UILabel, *statusLabel)

@end

@implementation NBLoadingView

- (instancetype)initWithSuperView:(UIView*)superView{
    self = [self init];
    if (self) {
        self.hidden = YES;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        self.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
        self.layer.borderWidth = 1/[UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        
        [superView addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@0);
            make.centerY.equalTo(@0);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
        }];
        [self layoutIfNeeded];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - set & get
- (UIActivityIndicatorView*)loadingView{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(@0);
        }];
        [_loadingView layoutIfNeeded];
    }
    return _loadingView;
}

- (UILabel*)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:13];
        _statusLabel.numberOfLines = 0;
        _statusLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.loadingView.mas_right).mas_offset(5);
            make.right.equalTo(@(-10));
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
        [_statusLabel layoutIfNeeded];
    }
    return _statusLabel;
}

#pragma mark - public method

- (void)showLoading:(NSString*)status{
    CGSize size = stringCalculate(status, 200 - 60, self.statusLabel.font);
    self.statusLabel.text = status;
    [self.loadingView startAnimating];
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(ceilf(size.width)+50));
        make.height.equalTo(@(ceilf(size.height)+24));
    }];
    self.alpha = 1;
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    [self layoutIfNeeded];
}

- (void)dismiss{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
        [self.loadingView stopAnimating];
    }];
}

@end
