//
//  MapDatasource.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "FrameController.h"
#import "MapDatasource.h"
#import "MapCell.h"

@interface MapDatasource ()

@property (retain, nonatomic) NSMutableArray *zoneArray;

@end

@implementation MapDatasource

- (instancetype)init
{
    if (self = [super init])
    {
        // DataManager *dataManager = [DataManager defaultInstance];
        // [dataManager insertIntoCoreData:@"Zone"];
        self.selectedIndexPath = nil;
        self.highlightedIndexPath = nil;
    }
    return self;
}

- (void)setController:(FrameController *)controller
{
    _controller = controller;
    self.selectedIndexPath = [NSIndexPath indexPathForRow:MAP_ROWS * MAP_COLS / 2 inSection:0];
    [self.controller.mapCollection reloadData];
}

- (NSMutableArray *)zoneArray
{
    if (_zoneArray == nil)
        _zoneArray = [NSMutableArray arrayWithCapacity:MAP_ROWS * MAP_COLS];
    return _zoneArray;
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    NSMutableArray *indexPathArray = [NSMutableArray arrayWithCapacity:2];
    
    if (_selectedIndexPath != nil)
        [indexPathArray addObject:_selectedIndexPath];

    // 选择空、重复一个索引会反选
    if (selectedIndexPath == nil
        || (_selectedIndexPath != nil && _selectedIndexPath.row == selectedIndexPath.row))
    {
        _selectedIndexPath = nil;
        self.controller.shouldShowPanel = NO;
    }
    // 选择一个不同的索引
    else
    {
        _selectedIndexPath = selectedIndexPath;
        self.controller.shouldShowPanel = YES;
    }
    
    if (self.controller.shouldShowPanel)
    {
        [self.controller infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            self.controller.showPanel = NO;
            [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
                self.controller.showPanel = YES;
            }];
        }];
    }
    else
    {
        [self.controller infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            self.controller.showPanel = NO;
        }];
    }
    
    if (_selectedIndexPath != nil)
        [indexPathArray addObject:_selectedIndexPath];
    [self.controller moveToSelected:nil];
    [self.controller.mapCollection reloadItemsAtIndexPaths:indexPathArray];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MAP_ROWS * MAP_COLS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"zoneCell" forIndexPath:indexPath];
    [cell setIndexNumberIn:indexPath.row / MAP_COLS andCol:indexPath.row % MAP_COLS];
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    MapCell *mapCell = (MapCell *)cell;
    mapCell.isSelected = (self.selectedIndexPath != nil && indexPath.row == self.selectedIndexPath.row);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.controller.shouldShowPanel)
        [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            self.controller.showPanel = YES;
        }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.controller.shouldShowPanel)
        [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            self.controller.showPanel = YES;
        }];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (self.controller.dontRecalOffset == NO)
//        [self calCenterIndexPath];
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
        return;
    if (self.controller.shouldShowPanel && !decelerate)
        [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            self.controller.showPanel = YES;
        }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.controller infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
        self.controller.showPanel = NO;
    }];
}

@end
