//
//  BaseTableViewController.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/18.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ReadViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BaseTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation BaseTableViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (MJRefreshNormalHeader*)header{
    if (!_header) {
        _header = [MJRefreshNormalHeader headerWithRefreshingBlock:nil];
        _header.lastUpdatedTimeLabel.hidden = YES;
        _header.stateLabel.hidden = YES;
    }
    return _header;
}

- (MJRefreshAutoNormalFooter*)footer{
    if (!_footer) {
        _footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:nil];
        _footer.refreshingTitleHidden = YES;
    }
    return _footer;
}

- (UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = Back_Color;
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = tableView.backgroundColor;
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = view;
        
        UIImageView *image = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.2];
        image.tag = 1;
        [cell.contentView addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(@0);
            make.width.equalTo(@(80*153/200));
            make.height.equalTo(@(80));
        }];
        
        UILabel *title = [[UILabel alloc] init];
        title.tag = 2;
        title.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:title];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(image.mas_right).mas_offset(@10);
            make.top.equalTo(image.mas_top);
            make.right.equalTo(@(-10));
            make.height.equalTo(@16);
        }];
        
        UILabel *detail = [[UILabel alloc] init];
        detail.tag = 3;
        detail.numberOfLines = 3;
        detail.font = [UIFont systemFontOfSize:13];
        [cell.contentView addSubview:detail];
        [detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(image.mas_right).mas_offset(@10);
            make.top.equalTo(title.mas_bottom).mas_offset(@2);
            make.right.equalTo(@(-10));
            make.bottom.equalTo(image.mas_bottom);
        }];
        
    }
    BookModel *model = self.dataSource[indexPath.row];
    [(UIImageView*)[cell viewWithTag:1] sd_setImageWithURL:[NSURL URLWithString:model.bookCover]];
    ((UILabel*)[cell viewWithTag:2]).text = model.title;
    ((UILabel*)[cell viewWithTag:3]).text = model.intro_short;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BookModel *model = self.dataSource[indexPath.row];
    ReadViewController *read = [[ReadViewController alloc] initWithData:model];
    [self.navigationController pushViewController:read animated:YES];
}

@end
