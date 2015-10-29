//
//  ChapterModel.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChapterModel : NSObject

//tid": "11275092",
//"viptext": "0",
//"title": "\u4e09\u5e74\u524d\u7684\u4e0d\u901f\u4e4b\u5ba2",
//"bytes": "1860",
//"dateline": "1434902400"

nonatomic_strong(NSString, *tid)
nonatomic_strong(NSString, *viptext)
nonatomic_strong(NSString, *title)
nonatomic_strong(NSString, *bytes)
nonatomic_strong(NSString, *dateline)

nonatomic_assign(NSInteger, index)
@end
