//
//  ChapterListView.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterListView : UIView

nonatomic_copy(Block_data, selectData)

- (instancetype)initWithData:(id)data;

- (void)show:(BOOL)show;

@end
