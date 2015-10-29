//
//  bookHistoryEngine.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookModel.h"

@interface bookHistoryEngine : NSObject

nonatomic_strong_readonly(NSMutableArray, *historyList)
DECLARE_AS_SINGLETON(bookHistoryEngine)

- (void)collect:(BookModel*)model;

@end
