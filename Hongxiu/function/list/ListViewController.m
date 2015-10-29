//
//  ViewController.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "ListViewController.h"
#import "requestEngine.h"
#import "ReadViewController.h"

@interface ListViewController ()

nonatomic_strong(NSString, *cid)
nonatomic_assign(NSInteger, currentPage)

@end

@implementation ListViewController

- (instancetype)initWithData:(NSDictionary*)data{
    self = [super init];
    if (self) {
        self.title = data[@"title"];
        self.cid = data[@"cid"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    weakObject(self)

    self.tableView.header = self.header;
    self.tableView.rowHeight = 100;
    self.header.refreshingBlock = ^{
        weakSelf.currentPage = 1;
    };
    self.currentPage = 1;
    
    self.footer.refreshingBlock = ^{
        weakSelf.currentPage++;
    };
}

- (void)setCurrentPage:(NSInteger)currentPage{
    _currentPage = currentPage;

    if (currentPage > 0) {
        [self showLoading];
        weakObject(self)
        NSDictionary *parmers = @{@"method":@"store.category",
                                  @"cid":self.cid,
                                  @"order":@"mvote",
                                  @"page":[NSString stringWithFormat:@"%ld",(long)currentPage],
                                  @"per_page":@"10"};
        request(@"http://androidclient.api.hongxiu.com/AndroidClient/default.ashx", @"GET", parmers, ^(AFHTTPRequestOperation *operation, id data) {
            if ([data[@"err_code"] integerValue] == 0) {
                if (weakSelf.currentPage == 1) {
                    [weakSelf.dataSource removeAllObjects];
                }
                NSDictionary *respond = data[@"response"];
                NSArray *array = respond[@"data"];
                for (NSDictionary *dic in array) {
                    BookModel *book = [BookModel objectWithKeyValues:dic];
                    if (book) {
                        [weakSelf.dataSource addObject:book];
                    }
                }
                [weakSelf.tableView reloadData];
                if (weakSelf.dataSource.count < [respond[@"total"] integerValue]) {
                    weakSelf.tableView.footer = weakSelf.footer;
                }else{
                    weakSelf.tableView.footer = nil;
                }
            }
            [weakSelf.tableView.header endRefreshing];
            [weakSelf.tableView.footer endRefreshing];
            [weakSelf dismissLoading];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
