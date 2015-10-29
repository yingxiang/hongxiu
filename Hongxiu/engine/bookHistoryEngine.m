//
//  bookHistoryEngine.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "bookHistoryEngine.h"

@implementation bookHistoryEngine
@synthesize historyList = _historyList;

DECLARE_SINGLETON(bookHistoryEngine)

- (instancetype)init{
    self = [super init];
    _historyList = [NSMutableArray array];
    
    NSString *dir = [_HYBIRD_PATH_DATA stringByAppendingPathComponent:@"History"];
    
    if (file_exist(dir)) {
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir
                                                                             error:nil];
        if (files) {
            for (NSString *name in files) {
                NSString *key = [NSString stringWithFormat:@"History/%@",name];
                BookModel *data = unarchiveObjectForkey(key);
                [_historyList addObject:data];
            }
        }
    }else{
        file_createDirectory(dir);
    }
    return self;
}

- (void)collect:(BookModel*)model{
    if ([self.historyList containsObject:model]) {
        return;
    }else {
        for (BookModel *book in self.historyList) {
            if ([book.bid isEqualToString:model.bid]) {
                return;
            }
        }
        [self.historyList insertObject:model atIndex:0];
        archiveObjectForKey(model, [NSString stringWithFormat:@"History/%@",model.bid]);
    }
}

@end
