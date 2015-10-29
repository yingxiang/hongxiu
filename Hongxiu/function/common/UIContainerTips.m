//
//  UIContainerTips.m
//  HybirdNamibox
//
//  Created by xiangying on 15/8/25.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIContainerTips.h"

@interface UIContainerTips ()

nonatomic_strong(UILabel    , *tipsLabel)
nonatomic_assign(CGFloat, max_width)

@end

@implementation UIContainerTips

- (void)dealloc{
    NSLog(@"[%@ dealloc]",[self class]);
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.translucent = YES;
        self.layer.cornerRadius = 3;
        self.barStyle = UIBarStyleBlack;
        
        self.font = [UIFont systemFontOfSize:13];
        self.position = TIP_POSITION_BOTTOM;
        self.max_width = frame.size.width;
        if (self.max_width <= 0) {
            self.max_width = 200;
        }
        
        self.autoHide = YES;
    }
    return self;
    
}

- (UILabel*)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = _obj_alloc(UILabel);
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipsLabel];
        
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.right.equalTo(@(-10));
            make.top.equalTo(@10);
            make.bottom.equalTo(@-10);
        }];
    }
    return _tipsLabel;
}

- (void)setFont:(UIFont *)font{
    _font = font;
    self.tipsLabel.font = font;
}

- (void)toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    CGAffineTransform transform = self.transform;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            transform= CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            transform= CGAffineTransformMakeRotation(-M_PI/2);
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            transform= CGAffineTransformMakeRotation(M_PI/2);
        }
            break;
        case UIInterfaceOrientationPortrait:
            transform= CGAffineTransformMakeRotation(M_PI*0);
            break;
        default:
            break;
    }
    self.transform = transform;
}


- (void)showTips:(NSString*)message inView:(UIView*)view{
    if (message && message.length!=0) {
        
        [view addSubview:self];
        weakObject(self)
        
        CGSize titleSize = stringCalculate(message, self.max_width-20, weakSelf.font);

        CGFloat width = self.max_width - 20;
        CGFloat height = ceilf(titleSize.height);
        if (titleSize.width < width) {
            width = ceilf(titleSize.width);
        }
        
        weakSelf.alpha = 0;
        weakSelf.tipsLabel.text = message;
        
        if (weakSelf.constraints) {
            [weakSelf mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(@0);
                make.width.equalTo(@(width+20));
                make.height.equalTo(@(height+20));
                if (weakSelf.position == TIP_POSITION_TOP) {
                    make.top.equalTo(@100);
                }else if (weakSelf.position == TIP_POSITION_CENTER){
                    make.centerY.equalTo(@0);
                }else if (weakSelf.position == TIP_POSITION_BOTTOM){
                    make.bottom.equalTo(@-80);
                }else{
                    CGFloat centerY = self.center.y - self.superview.center.y;
                    centerY = centerY + ((height + 20) - self.frame.size.height)/2;
                    make.centerY.equalTo(@(centerY));
                }
            }];
        }else{
            [weakSelf mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(@0);
                make.width.equalTo(@(width+20));
                make.height.equalTo(@(height+20));
                if (weakSelf.position == TIP_POSITION_TOP) {
                    make.top.equalTo(@100);
                }else if (weakSelf.position == TIP_POSITION_CENTER){
                    make.centerY.equalTo(@0);
                }else if (weakSelf.position == TIP_POSITION_BOTTOM){
                    make.bottom.equalTo(@-80);
                }else{
                    make.top.equalTo(@100);
                }
            }];
        }
                
        [UIView animateWithDuration:0.8 animations:^{
            weakSelf.alpha = 1;
        } completion:^(BOOL finished) {
            if (weakSelf.autoHide) {
                [weakSelf hide];
            }
        }];
    }
}

- (void)hide{
    if (self.superview) {
        [UIView animateWithDuration:0.8 delay:1.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self removeFromSuperview];
            }
        }];
    }
}

void showTips(id message){
    if (!message) {
        return;
    }
    NSString *msg = [NSString stringWithFormat:@"%@",message];
    if (msg.length!=0) {
        UIContainerTips *tips = [[UIContainerTips alloc] init];
        [tips showTips:msg inView:[[UIApplication sharedApplication].delegate window]];
    }
}

@end
