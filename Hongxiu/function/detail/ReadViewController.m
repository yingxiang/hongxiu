//
//  ReadViewController.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "ReadViewController.h"
#import "BookModel.h"
#import "UIColor+hex.h"
#import "ChapterListView.h"
#import "CALayer+animation.h"

@interface ReadViewController ()

nonatomic_strong(BookModel, *bookModel)
nonatomic_weak(AFHTTPRequestOperation, *operation)
nonatomic_assign(ChapterModel, *currentChapter)
nonatomic_strong(NSString, *content)
nonatomic_strong(UITextView, *textView)
nonatomic_strong(UIBarButtonItem, *menuItem)
nonatomic_strong(ChapterListView, *chapterListView)
nonatomic_strong(UILabel, *titleLabel)

@end

@implementation ReadViewController

- (void)dealloc{
    if (_chapterListView) {
        [self.chapterListView removeFromSuperview];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (instancetype)initWithData:(BookModel*)data{
    self = [super init];
    if (self) {
        //
        self.bookModel = data;
        [[bookHistoryEngine shareInstance] collect:data];
        NSString *bookPath = [_HYBIRD_PATH_DOCUMENT stringByAppendingPathComponent:data.bid];
        file_createDirectory(bookPath);
        self.navigationItem.titleView = self.titleLabel;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (UILabel*)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}

- (void)setCurrentChapter:(ChapterModel *)currentChapter{
    if (_currentChapter!=nil) {
        BOOL directionNext = currentChapter.index > _currentChapter.index;
        [self.view.layer animationWithType:animTypeReveal subType:directionNext ? animSubtypesFromRight:animSubtypesFromLeft curve:animCurveEaseInEaseOut duration:1.0 repeatsCount:1 completion:nil];
    }
    _currentChapter = currentChapter;
    NSString *bookPath = [_HYBIRD_PATH_DOCUMENT stringByAppendingPathComponent:self.bookModel.bid];
    NSString *chapter = [bookPath stringByAppendingPathComponent:currentChapter.tid];
    if (file_exist(chapter)) {
        NSDictionary *content = file_read(chapter);
        self.content = content[currentChapter.tid][@"chapter_content"];
    }else{
        [self showLoading];
        weakObject(self)
        NSString *url = [NSString stringWithFormat:@"http://novel.hongxiu.com/AndroidClient140401/book_chapter_get/%@_%@.json",self.bookModel.bid,currentChapter.tid];
        self.operation = request(url, @"GET", nil, ^(AFHTTPRequestOperation *operation, id data) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                if ([data[@"err_code"] integerValue] == 0) {
                    NSDictionary *content = data[@"response"];
                    if (content) {
                        file_write(content, chapter);
                        weakSelf.content = content[currentChapter.tid][@"chapter_content"];
                    }
                }else{
                    [self dismissLoading];
                    showTips([data[@"err_msg"] length]!=0 ? data[@"err_msg"]:@"加载失败");
                }
            }else {
                [self dismissLoading];
                showTips(@"网络请求失败");
            }
        });
    }
    NSString *title = [NSString stringWithFormat:@"%@\n%@",self.bookModel.title,currentChapter.title];
    self.titleLabel.text = title;
    self.bookModel.selectChapter = currentChapter;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentChapter.index] forKey:[NSString stringWithFormat:@"%@_chapter",self.bookModel.bid]];

}

- (void)setContent:(NSString *)content{
    if (_content!=content) {
        _content = content;
        [self.textView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        style.paragraphSpacing = self.textView.font.pointSize;
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName:self.textView.textColor,
                                     NSParagraphStyleAttributeName:style,
                                     NSFontAttributeName:self.textView.font};
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:content attributes:attributes];
        self.textView.attributedText = string;
        [self dismissLoading];
    }
}

- (UITextView*)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:20];
        _textView.editable = NO;
        _textView.textColor = [UIColor brownColor];
        _textView.backgroundColor = [UIColor colorWithHexString:@"#C7EDCC"];
        [self.view addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _textView;
}

- (UIBarButtonItem*)menuItem{
    if (!_menuItem) {
        _menuItem = [[UIBarButtonItem alloc] initWithTitle:@"目录" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    }
    return _menuItem;
}

- (ChapterListView*)chapterListView{
    if (!_chapterListView) {
        weakObject(self)
        _chapterListView = [[ChapterListView alloc] initWithData:self.bookModel];
        _chapterListView.selectData = ^(ChapterModel *model){
            weakSelf.currentChapter = model;
        };
    }
    return _chapterListView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.menuItem;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(turnPage:)];
    [self.textView addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnPage:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.textView addGestureRecognizer:swipe];
    
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnPage:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.textView addGestureRecognizer:swipe];
    
    if (!self.bookModel.chapterList) {
        //请求章节列表
        NSString *url = [NSString stringWithFormat:@"http://novel.hongxiu.com/AndroidClient140401/book_chapter_list/%@.json",self.bookModel.bid];
        [self showLoading];
        if ([self.operation isExecuting]) {
            [self.operation cancel];
            self.operation = nil;
        }
        self.operation = request(url, @"GET", nil, ^(AFHTTPRequestOperation *operation, id data) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                if ([data[@"err_code"] integerValue] == 0) {
                    NSArray *list = data[@"response"];
                    NSMutableArray *array = [NSMutableArray array];
                    NSInteger i = 0;
                    for (NSDictionary *dic in list) {
                        ChapterModel *model = [ChapterModel objectWithKeyValues:dic];
                        model.index = i;
                        i++;
                        [array addObject:model];
                    }
                    self.bookModel.chapterList = array;
                    NSNumber *currentChapter = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_chapter",self.bookModel.bid]];
                    if (currentChapter) {
                        self.currentChapter = self.bookModel.chapterList[[currentChapter integerValue]];
                    }else{
                        self.currentChapter = self.bookModel.chapterList[0];
                    }
                }else{
                    [self dismissLoading];
                    showTips([data[@"err_msg"] length]!=0 ? data[@"err_msg"]:@"加载失败");
                }
            }else{
                if (!operation.isCancelled) {
                    [self dismissLoading];
                    showTips(@"网络请求失败");
                }
            }
        });
    }else{
        NSNumber *currentChapter = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_chapter",self.bookModel.bid]];
        if (currentChapter) {
            self.currentChapter = self.bookModel.chapterList[[currentChapter integerValue]];
        }else{
            self.currentChapter = self.bookModel.chapterList[0];
        }
    }
}

- (void)showMenu{
    [self.chapterListView show:YES];
}

- (void)turnPage:(UIGestureRecognizer*)gesture{
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint point = [gesture locationInView:self.view];
        
        if (point.x > self.view.frame.size.width/2+40) {
            [self nextPage];
        }else if(point.x < self.view.frame.size.width/2-40){
            [self prePage];
        }else{
            [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
        }
    }else{
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)gesture;
        if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
            [self nextPage];
        }else{
            [self prePage];
        }
    }
}

- (void)nextPage{
    //下一页
    NSInteger index = self.currentChapter.index+1;
    if (index < self.bookModel.chapterList.count) {
        self.currentChapter = self.bookModel.chapterList[index];
    }else{
        showTips(@"已是最后一章");
    }
}

- (void)prePage{
    //上一页
    NSInteger index = self.currentChapter.index - 1;
    if (index >= 0) {
        self.currentChapter = self.bookModel.chapterList[index];
    }else{
        showTips(@"已是第一章");
    }
}
@end
