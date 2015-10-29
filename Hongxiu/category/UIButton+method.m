//
//  UIButton+method.m
//  HybirdNamibox
//
//  Created by 相颖 on 15/9/17.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import "UIButton+method.h"
#import <objc/runtime.h>

static const void *blockKey = &blockKey;
static const void *colorsKey = &colorsKey;

@implementation UIButton (method)

- (void)setBlockSelector:(Block_data)blockSelector{
    objc_setAssociatedObject(self, blockKey, blockSelector, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (Block_data)blockSelector{
    return objc_getAssociatedObject(self, blockKey);
}

+ (instancetype)buttonClick:(Block_data)block{
    UIButton *button = [[UIButton alloc] init];
    button.blockSelector = block;
    [button addTarget:button action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)clickButton:(id)sender{
    if (self.blockSelector) {
        weakObject(self)
        self.blockSelector(weakSelf);
    }
}

- (NSMutableDictionary*)colors{
    return objc_getAssociatedObject(self, colorsKey);
}

- (void)setColors:(NSMutableDictionary *)colors{
    objc_setAssociatedObject(self, colorsKey, colors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state{
    if (!self.colors) {
        self.colors = [NSMutableDictionary dictionary];
    }
    switch (state) {
        case UIControlStateNormal:
            [self.colors setObject:color forKey:@"UIControlStateNormal"];
            break;
        case UIControlStateHighlighted:
            [self.colors setObject:color forKey:@"UIControlStateHighlighted"];
            break;
        case UIControlStateSelected:
            [self.colors setObject:color forKey:@"UIControlStateSelected"];
            break;
        default:
            break;
    }
    [self setColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    if (!self.colors) {
        [self.colors setObject:backgroundColor forKey:@"UIControlStateNormal"];
    }
}

- (void)setHBHighlighted:(BOOL)highlighted{
    [self setHBHighlighted:highlighted];
    [self setColor];
}

- (void)setHBSelected:(BOOL)selected{
    [self setHBSelected:selected];
    [self setColor];
}

- (void)setColor{
    switch (self.state) {
        case UIControlStateSelected:{
            UIColor *color = self.colors[@"UIControlStateSelected"];
            if (!color) {
                color = self.colors[@"UIControlStateNormal"];
                if (!color) {
                    color = self.backgroundColor ? self.backgroundColor : [UIColor clearColor];
                    [self.colors setObject:color forKey:@"UIControlStateNormal"];
                }
            }
            super.backgroundColor = color;
        }
            break;
        case UIControlStateHighlighted:{
            UIColor *color = self.colors[@"UIControlStateHighlighted"];
            if (!color) {
                color = self.colors[@"UIControlStateNormal"];
                if (!color) {
                    color = self.backgroundColor ? self.backgroundColor : [UIColor clearColor];
                    [self.colors setObject:color forKey:@"UIControlStateNormal"];
                }
            }
            super.backgroundColor = color;
        }
            break;
        default:{
            UIColor *color = self.colors[@"UIControlStateNormal"];
            if (!color) {
                color = self.backgroundColor ? self.backgroundColor : [UIColor clearColor];
                [self.colors setObject:color forKey:@"UIControlStateNormal"];
            }
            super.backgroundColor = color;
        }
            break;
    }
}
@end
