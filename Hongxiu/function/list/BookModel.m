//
//  BookModel.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "BookModel.h"

@implementation BookModel

- (void)setBid:(NSString *)bid{
    _bid = bid;
    self.bookCover =  [NSString stringWithFormat:@"http://pic.hxcdn.net/bookcover/160x200/%@.jpg",bid];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    encodeObject(aCoder, self);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    if (self) {
        decodeObject(aDecoder, self);
    }
    return self;
}

@end
