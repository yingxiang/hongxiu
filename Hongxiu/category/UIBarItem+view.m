//
//  UIBarItem+view.m
//  HybirdNamibox
//
//  Created by xiang ying on 15/10/5.
//  Copyright © 2015年 Elephant. All rights reserved.
//

#import "UIBarItem+view.h"

@implementation UIBarItem (view)
@dynamic view;

- (UIView*)view{
    return [self valueForKeyPath:@"_view"];
}

- (void)addSubView:(nullable UIView*)subView{
    [self.view addSubview:subView];
}

- (nullable UIView *)viewWithTag:(NSInteger)tag{
    return [self.view viewWithTag:tag];
}

@end
