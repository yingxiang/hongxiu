//
//  UIBarItem+view.h
//  HybirdNamibox
//
//  Created by xiang ying on 15/10/5.
//  Copyright © 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarItem (view)

nonatomic_weak    (UIView ,           *view);

- (void)addSubView:(nullable UIView*)subView;

- (nullable UIView *)viewWithTag:(NSInteger)tag;

@end
