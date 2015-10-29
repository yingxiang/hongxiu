//
//  BookModel.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChapterModel.h"

@interface BookModel : NSObject <NSCoding>

//"bid": "1167393",
//"title": "一个约定，那个十年？",
//"sort_tag": "言情",
//"intro_short": "一个约定，一个十年。他们在树下的约定真的实现？十年他们真的在一起了吗？",
//"vipbook": "0",
//"pubtime": "1445067081",
//"bookstatus": "连载中",
//"bytes": "87603",
//"favs": "1",
//"hits": "278",
//"texts": "65",
//"vote": "0"

nonatomic_strong(NSString, *bid)
nonatomic_strong(NSString, *title)
nonatomic_strong(NSString, *sort_tag)
nonatomic_strong(NSString, *intro_short)
nonatomic_strong(NSString, *vipbook)
nonatomic_strong(NSString, *pubtime)
nonatomic_strong(NSString, *bookstatus)
nonatomic_strong(NSString, *bytes)
nonatomic_strong(NSString, *favs)
nonatomic_strong(NSString, *hits)
nonatomic_strong(NSString, *texts)
nonatomic_strong(NSString, *vote)

nonatomic_strong(NSString, *bookCover)

//chapter
nonatomic_strong(NSArray, *chapterList)
nonatomic_weak(ChapterModel, *selectChapter)

@end
