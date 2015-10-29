//
//  BaseViewController.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

nonatomic_strong(NBLoadingView, *loading)

- (void)showLoading;

- (void)dismissLoading;

@end
