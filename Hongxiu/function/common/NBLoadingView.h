//
//  NBLoadingView.h
//  HybirdNamibox
//
//  Created by xiang ying on 15/10/2.
//  Copyright © 2015年 Elephant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NBLoadingView : UIView

- (instancetype)initWithSuperView:(UIView*)superView;

- (void)showLoading:(NSString*)status;

- (void)dismiss;

@end
