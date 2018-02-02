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
        [self.controller switchPanelShowInfo:NO
                                  showHeader:YES
                                    showFunc:YES
                                      inSize:CGSizeMake(kScreenWidth, kScreenHeight)
                                  completion:^(BOOL finished) {
                                      if (!finished) return;
                                      self.controller.showPanel = NO;
                                      [self.controller switchPanelShowInfo:YES
                                                                showHeader:YES
                                                                  showFunc:YES
                                                                    inSize:CGSizeMake(kScreenWidth, kScreenHeight)
                                                                completion:^(BOOL finished) {
                                                                    if (!finished) return;
                                                                    self.controller.showPanel = YES;
                                                                }];
                                  }];
    }
    else
    {
        [self.controller switchPanelShowInfo:NO
                                  showHeader:YES
                                    showFunc:YES
                                      inSize:CGSizeMake(kScreenWidth, kScreenHeight)
                                  completion:^(BOOL finished) {
                                      if (!finished) return;
                                      self.controller.showPanel = NO;
                                  }];
    }

    if (_selectedIndexPath != nil)
        [indexPathArray addObject:_selectedIndexPath];
    [self.controller.mapCollection reloadItemsAtIndexPaths:indexPathArray];
    [self.controller updateSelection:YES];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
        return MAP_ROWS * MAP_COLS;
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        MapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"zoneCell" forIndexPath:indexPath];
        [cell setIndexNumberIn:indexPath.row / MAP_COLS andCol:indexPath.row % MAP_COLS];
        cell.highlight = (self.highlightedIndexPath != nil && indexPath.row == self.highlightedIndexPath.row);
        return cell;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"backgroundCell" forIndexPath:indexPath];
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        self.selectedIndexPath = indexPath;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.controller switchPanelShowInfo:YES showHeader:YES showFunc:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
        self.controller.showPanel = YES;
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.controller switchPanelShowInfo:YES showHeader:YES showFunc:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
        self.controller.showPanel = YES;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (self.controller.dontRecalOffset == NO)
//        [self calCenterIndexPath];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self.controller switchPanelShowInfo:YES showHeader:YES showFunc:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
            self.controller.showPanel = YES;
        }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.controller.showPanel = NO;
    [self.controller switchPanelShowInfo:NO showHeader:NO showFunc:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) { }];
}

@end
