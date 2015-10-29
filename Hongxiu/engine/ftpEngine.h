//
//  ftpEngine.h
//  HybirdNamibox
//
//  Created by xiang ying on 15/9/10.
//  Copyright (c) 2015年 Elephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ftpEngine : NSObject

nonatomic_copy(Block_progress, blockProgress)
nonatomic_copy(Block_complete, blockComplete)

DECLARE_AS_SINGLETON(ftpEngine)

- (void)uploadUrl:(NSString*)fileUrl filePath:(NSString*)filePath;

@end
