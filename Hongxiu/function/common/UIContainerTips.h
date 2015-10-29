//
//  UIContainerTips.h
//  HybirdNamibox
//
//  Created by xiangying on 15/8/25.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TIP_POSITION_BOTTOM, //default
    TIP_POSITION_CENTER,
    TIP_POSITION_TOP,
    TIP_POSITION_CUSTOM
}TIP_POSITION;

@interface UIContainerTips : UIToolbar

nonatomic_assign(TIP_POSITION, position)
nonatomic_assign(BOOL, autoHide)
nonatomic_strong(UIFont, *font)

void showTips(id message);

- (void)showTips:(NSString*)message inView:(UIView*)view;

- (void)hide;

@end
