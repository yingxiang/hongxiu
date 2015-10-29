//
//  SearchViewController.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UISearchBarDelegate>

nonatomic_strong(UISearchBar, *searchBar)
nonatomic_strong(NSString, *kwords)
nonatomic_assign(NSInteger, currentPage)

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchBar;
    self.tableView.rowHeight = 100;
    weakObject(self)
    self.footer.refreshingBlock = ^{
        weakSelf.currentPage++;
    };
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (UISearchBar*)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        _searchBar.placeholder = @"输入关键字搜索";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (void)setCurrentPage:(NSInteger)currentPage{
    if (_currentPage!=currentPage) {
        _currentPage = currentPage;
    }
    if (currentPage > 0) {
        [self showLoading];
        weakObject(self)
        NSDictionary *parmers = @{@"method":@"store.search",
                                  @"kw":self.kwords,
                                  @"order":@"mvote",
                                  @"page":[NSString stringWithFormat:@"%ld",(long)currentPage],
                                  @"per_page":@"10"};
        request(@"http://pad.hongxiu.com/aspxnovellist/androidclient/androidclientsearch.aspx", @"GET", parmers, ^(AFHTTPRequestOperation *operation, id data) {
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
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text) {
        self.kwords = searchBar.text;
        self.currentPage = 1;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
