//
//  UIButton+method.h
//  HybirdNamibox
//
//  Created by 相颖 on 15/9/17.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (method)

nonatomic_copy(Block_data, blockSelector)
nonatomic_strong(NSMutableDictionary, *colors)

+(instancetype)buttonClick:(Block_data)block;

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end
