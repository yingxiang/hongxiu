//
//  BaseTableViewController.h
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "BaseViewController.h"
#import "BookModel.h"

#define pageSize 10

@interface BaseTableViewController : BaseViewController

nonatomic_strong(NSMutableArray, *dataSource)

nonatomic_strong(MJRefreshAutoNormalFooter, *footer)
nonatomic_strong(MJRefreshNormalHeader, *header)
nonatomic_strong(UITableView, *tableView)

@end
