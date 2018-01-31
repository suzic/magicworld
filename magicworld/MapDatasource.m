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
@property (assign, nonatomic) CGPoint lastOffset;

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
    self.lastOffset = self.controller.mapCollection.contentOffset;
    [self.controller.mapCollection reloadData];
}

- (NSMutableArray *)zoneArray
{
    if (_zoneArray == nil)
        _zoneArray = [NSMutableArray arrayWithCapacity:MAP_ROWS * MAP_COLS];
    return _zoneArray;
}

//- (void)calCenterIndexPath
//{
//    // 根据偏移量计算可能显示的所有格子的横竖索引的起始
//    NSInteger row_c = ((self.lastOffset.y + kScreenHeight / 2.0f) / CELL_HEIGHT);
//    NSInteger col_c = ((self.lastOffset.x + kScreenWidth / 2.0f) / CELL_WIDTH);
//
//    NSInteger section = 0;
//    section += (col_c >= MAP_COLS) ? 1 : 0;
//    section += (row_c >= MAP_ROWS) ? 2 : 0;
//
//    self.autoCenterIndexPath = [NSIndexPath indexPathForItem:(row_c % MAP_ROWS) * MAP_COLS + (col_c % MAP_COLS)
//                                                   inSection:section];
//}

- (void)setLastOffset:(CGPoint)lastOffset
{
    if (_lastOffset.x == lastOffset.x && _lastOffset.y == lastOffset.y)
        return;
    _lastOffset.x = lastOffset.x;
    _lastOffset.y = lastOffset.y;
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
        self.controller.showPanel = NO;
    }
    // 选择一个不同的索引
    else
    {
        _selectedIndexPath = selectedIndexPath;
        [self.controller infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
                [self.controller setNeedsStatusBarAppearanceUpdate];
                self.controller.showPanel = YES;
            }];
        }];
    }
    
    if (_selectedIndexPath != nil)
        [indexPathArray addObject:_selectedIndexPath];
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
    
    cell.cellBackground.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
    if (self.selectedIndexPath != nil && indexPath.row == self.selectedIndexPath.row)
        cell.cellBackground.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.controller showFunctions:YES animated:YES inLandMode:(kScreenWidth > kScreenHeight)];
    if (self.selectedIndexPath != nil)
        [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            [self.controller setNeedsStatusBarAppearanceUpdate];
        }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.controller showFunctions:YES animated:YES inLandMode:(kScreenWidth > kScreenHeight)];
    if (self.selectedIndexPath != nil)
        [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            [self.controller setNeedsStatusBarAppearanceUpdate];
        }];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (self.controller.dontRecalOffset == NO)
//        [self calCenterIndexPath];
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.controller.stopAutoMoveCenter = YES;
    
    if (decelerate)
        return;
    
    [self.controller showFunctions:YES animated:YES inLandMode:(kScreenWidth > kScreenHeight)];
    if (self.selectedIndexPath != nil)
        [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            [self.controller setNeedsStatusBarAppearanceUpdate];
        }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.controller.stopAutoMoveCenter = YES;
    [self.controller showFunctions:NO animated:YES inLandMode:(kScreenWidth > kScreenHeight)];
    [self.controller infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
        [self.controller setNeedsStatusBarAppearanceUpdate];
    }];
}

@end
