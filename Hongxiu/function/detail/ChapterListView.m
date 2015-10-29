//
//  ChapterListView.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "ChapterListView.h"
#import "BookModel.h"

#define EDGE_WIDTH 280

@interface ChapterListView () <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

nonatomic_assign(NSInteger, currentSection)
nonatomic_strong(BookModel, *bookModel)
nonatomic_strong(UITableView, *tableView)

@end

@implementation ChapterListView

- (UITableView*)tableView{
    if (!_tableView) {

        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = Back_Color;
        _tableView.rowHeight = 48;
        [self addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(EDGE_WIDTH));
            make.top.equalTo(@20);
            make.bottom.equalTo(@0);
            make.width.equalTo(@(EDGE_WIDTH));
        }];
        
        [_tableView layoutIfNeeded];

        UIView *view = [[UIView alloc] init];
        view.backgroundColor = _tableView.backgroundColor;
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_tableView.mas_right);
            make.width.equalTo(_tableView.mas_width);
            make.height.equalTo(@20);
            make.top.equalTo(@0);
        }];
        [view layoutIfNeeded];
    }
    return _tableView;
}

- (instancetype)initWithData:(BookModel*)model{
    self = [super init];
    if (self) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];

        [self layoutIfNeeded];
        self.bookModel = model;
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipe];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideView)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)hideView{
    [self show:NO];
}

- (void)show:(BOOL)show{
    self.hidden = NO;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(show ? @(0):@(EDGE_WIDTH));
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
        self.backgroundColor = show ? [UIColor colorWithWhite:0 alpha:0.7]:[UIColor clearColor];
    } completion:^(BOOL finished) {
        if (!show) {
            self.hidden = YES;
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == self.bookModel.chapterList.count/30) {
        return self.bookModel.chapterList.count - 30*section;
    }
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.bookModel.chapterList.count/30+1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"第%ld章 --- 第%ld章",section*30+1,(section+1)*30];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chaptercell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"chaptercell"];
        
        cell.backgroundColor = Back_Color;
        UIView *selectView = [[UIView alloc] init];
        selectView.backgroundColor = [UIColor orangeColor];
        cell.selectedBackgroundView = selectView;
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.font = [UIFont systemFontOfSize:13];
        textLabel.textColor = [UIColor grayColor];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.highlightedTextColor = [UIColor whiteColor];
        textLabel.tag = 1;
        [cell.contentView addSubview:textLabel];
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-5);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
            make.width.equalTo(@(60));
        }];
        
        UILabel *detailTextLabel = [[UILabel alloc] init];
        detailTextLabel.textColor = textLabel.textColor;
        detailTextLabel.font = textLabel.font;
        detailTextLabel.textAlignment = NSTextAlignmentLeft;
        detailTextLabel.numberOfLines = 2;
        detailTextLabel.tag = 2;
        detailTextLabel.highlightedTextColor = textLabel.highlightedTextColor;
        [cell.contentView addSubview:detailTextLabel];
        [detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
            make.right.equalTo(textLabel.mas_left).mas_offset(-10);
        }];
    }
    NSInteger row = indexPath.section*30 + indexPath.row;
    ChapterModel *model = self.bookModel.chapterList[row];
    NSString *text = [NSString stringWithFormat:@"第%.3ld章",row + 1];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];

    textLabel.text = text;
    detailTextLabel.text = model.title;
    if (model == self.bookModel.selectChapter) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.section*30 + indexPath.row;
    ChapterModel *model = self.bookModel.chapterList[row];
    if (self.selectData) {
        self.selectData(model);
    }
    [self show:NO];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return touch.view == self;
}

@end
