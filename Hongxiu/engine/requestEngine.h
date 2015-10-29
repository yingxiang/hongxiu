//
//  requestEngine.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fileEngine.h"

@interface requestEngine : NSObject

AFHTTPRequestOperation* request (NSString *url, NSString *method , id parmeters, FinishBlock completeBlock);

void obj_msgSend(id self, SEL op, ...);

@end
