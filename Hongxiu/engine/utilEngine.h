//
//  utilEngine.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface utilEngine : NSObject

CGSize stringCalculate(NSString *string, CGFloat width, UIFont *font);

void encodeObject(NSCoder *aCoder, id object);

void decodeObject(NSCoder *aCoder, id object);

id unarchiveObjectForkey(NSString *key);

void archiveObjectForKey(id object, NSString *key);

void archiveRemoveObjectForKey(NSString *key);

@end
