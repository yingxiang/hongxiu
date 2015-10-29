//
//  MenuCollectionViewController.m
//  Hongxiu
//
//  Created by xiang ying on 15/10/17.
//  Copyright © 2015年 xiang ying. All rights reserved.
//

#import "MenuCollectionViewController.h"
#import "MenuCollectionViewCell.h"
#import "BookCollectionViewCell.h"
#import "MenuHeadCollectionReusableView.h"
#import "ListViewController.h"
#import "SearchViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ReadViewController.h"

@interface MenuCollectionViewController ()

nonatomic_strong(NSArray, *dataSource)

@end

@implementation MenuCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = Back_Color;
    
    self.dataSource = @[@{@"title":@"总裁豪门",@"cid":@"103"},
                        @{@"title":@"穿越时空",@"cid":@"108"},
                        @{@"title":@"都市高干",@"cid":@"109"},
                        @{@"title":@"古典架空",@"cid":@"106"},
                        @{@"title":@"白领职场",@"cid":@"102"},
                        @{@"title":@"玄幻仙侠",@"cid":@"110"},
                        @{@"title":@"魔法幻情",@"cid":@"105"},
                        @{@"title":@"青春校园",@"cid":@"101"}];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[MenuCollectionViewCell class] forCellWithReuseIdentifier:@"MenuCollectionViewCell"];
    [self.collectionView registerClass:[BookCollectionViewCell class] forCellWithReuseIdentifier:@"BookCollectionViewCell"];
    [self.collectionView registerClass:[MenuHeadCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MenuHeadCollectionReusableView"];
    // Do any additional setup after loading the view.
    
    [self.navigationItem.rightBarButtonItem setTarget:self];
    [self.navigationItem.rightBarButtonItem setAction:@selector(search)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)search{
    SearchViewController *search = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [bookHistoryEngine shareInstance].historyList.count == 0 ?1:2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.dataSource.count:[bookHistoryEngine shareInstance].historyList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCollectionViewCell" forIndexPath:indexPath];
        NSDictionary *row = self.dataSource[indexPath.row];
        cell.titleLabel.text = row[@"title"];
        return cell;
    }
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookCollectionViewCell" forIndexPath:indexPath];
    BookModel *model = [bookHistoryEngine shareInstance].historyList[indexPath.row];
    cell.titleLabel.text = model.title;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.bookCover]];
    return cell;

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    MenuHeadCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MenuHeadCollectionReusableView" forIndexPath:indexPath];
    header.titleLabel.text = indexPath.section == 0 ? @"   精选分类":@"   最近浏览";
    return header;
}
#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        NSDictionary *row = self.dataSource[indexPath.row];
        ListViewController *list = [[ListViewController alloc] initWithData:row];
        [self.navigationController pushViewController:list animated:YES];
    }else {
        BookModel *model = [bookHistoryEngine shareInstance].historyList[indexPath.row];
        ReadViewController *read = [[ReadViewController alloc] initWithData:model];
        [self.navigationController pushViewController:read animated:YES];
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CGSizeMake(100, 46);
    }
    return CGSizeMake(100, 160);
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
