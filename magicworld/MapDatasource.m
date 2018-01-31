//
//  MapDatasource.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "MapController.h"
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
    }
    return self;
}

- (void)setSelectedRowIndex:(NSInteger)selectedRowIndex
{
    if (_selectedRowIndex == selectedRowIndex)
        return;
    _selectedRowIndex = selectedRowIndex;
}

- (void)setController:(MapController *)controller
{
    _controller = controller;
    self.selectedRowIndex = NSNotFound;
    self.lastOffset = self.controller.mapCollection.contentOffset;
    [self.controller.mapCollection reloadData];
}

- (NSMutableArray *)zoneArray
{
    if (_zoneArray == nil)
        _zoneArray = [NSMutableArray arrayWithCapacity:MAP_ROWS * MAP_COLS];
    return _zoneArray;
}

- (void)recalculateSections:(CGPoint)offset
{
    BOOL xDirectionRight = self.lastOffset.x < offset.x;
    BOOL yDirectionDown = self.lastOffset.y < offset.y;
    CGPoint newOffset = CGPointMake(offset.x, offset.y);
    self.controller.dontRecalOffset = NO;
    
    if (offset.x < MAP_COLS * MAP_WIDTH / 3 && xDirectionRight == NO)
    {
        self.controller.dontRecalOffset = YES;
        newOffset.x = offset.x + MAP_COLS * MAP_WIDTH;
        //        if (_selectedIndexPath != nil)
        //        {
        //            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section - 1)];
        //            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //        }
        //        NSLog(@">>>>>> Auto Moved Right....");
    }
    else if (offset.x > MAP_COLS * MAP_WIDTH * 1.67 && xDirectionRight == YES)
    {
        self.controller.dontRecalOffset = YES;
        newOffset.x = offset.x - MAP_COLS * MAP_WIDTH;
        //        if (_selectedIndexPath != nil)
        //        {
        //            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section + 1)];
        //            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //        }
        //        NSLog(@"<<<<<< Auto Moved Left....");
    }
    
    if (offset.y < MAP_ROWS * MAP_HEIGHT / 3 && yDirectionDown == NO)
    {
        self.controller.dontRecalOffset = YES;
        newOffset.y = offset.y + MAP_ROWS * MAP_HEIGHT;
        //        if (_selectedIndexPath != nil)
        //        {
        //            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section - 2)];
        //            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //        }
        //        NSLog(@"vvvvvv Auto Moved Down....");
    }
    else if (offset.y > MAP_ROWS * MAP_HEIGHT * 1.67 && yDirectionDown == YES)
    {
        self.controller.dontRecalOffset = YES;
        newOffset.y = offset.y - MAP_ROWS * MAP_HEIGHT;
        //        if (_selectedIndexPath != nil)
        //        {
        //            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section + 2)];
        //            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
        //        }
        //        NSLog(@"^^^^^^ Auto Moved Up....");
    }
    
    if (self.controller.dontRecalOffset == YES)
    {
        [self.controller.mapCollection scrollRectToVisible:CGRectMake(newOffset.x, newOffset.y,
                                                                      self.controller.mapCollection.frame.size.width,
                                                                      self.controller.mapCollection.frame.size.height)
                                                  animated:NO];
        [self calCenterIndexPath];
        self.controller.dontRecalOffset = NO;
    }
    self.lastOffset = newOffset;
}

- (void)calCenterIndexPath
{
    // 根据偏移量计算可能显示的所有格子的横竖索引的起始
    NSInteger row_c = ((self.lastOffset.y + kScreenHeight / 2.0f) / MAP_HEIGHT);
    NSInteger col_c = ((self.lastOffset.x + kScreenWidth / 2.0f) / MAP_WIDTH);
    
    NSInteger section = 0;
    section += (col_c >= MAP_COLS) ? 1 : 0;
    section += (row_c >= MAP_ROWS) ? 2 : 0;
    
    self.autoCenterIndexPath = [NSIndexPath indexPathForItem:(row_c % MAP_ROWS) * MAP_COLS + (col_c % MAP_COLS)
                                                   inSection:section];
}

- (void)setLastOffset:(CGPoint)lastOffset
{
    if (_lastOffset.x == lastOffset.x && _lastOffset.y == lastOffset.y)
        return;
    _lastOffset.x = lastOffset.x;
    _lastOffset.y = lastOffset.y;
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    // 选择空
    if (selectedIndexPath == nil)
    {
        _selectedIndexPath = nil;
        self.controller.showPanel = NO;
        self.selectedRowIndex = NSNotFound;
    }
    // 重复一个索引会反选
    else if (_selectedIndexPath != nil && _selectedIndexPath.row == selectedIndexPath.row)
    {
        _selectedIndexPath = nil;
        self.controller.showPanel = NO;
        self.selectedRowIndex = NSNotFound;
    }
    // 选择一个不同的索引
    else
    {
        if (_selectedIndexPath == nil)
        {
            _selectedIndexPath = selectedIndexPath;
            self.controller.showPanel = YES;
        }
        else
        {
            [self.controller infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
                _selectedIndexPath = selectedIndexPath;
                [self.controller infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
                    [self.controller setNeedsStatusBarAppearanceUpdate];
                }];
            }];
        }
        self.selectedRowIndex = selectedIndexPath.row;
    }
    [self.controller.mapCollection reloadData];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MAP_ROWS * MAP_COLS;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"zoneCell" forIndexPath:indexPath];
    [cell setIndexNumberIn:indexPath.row / MAP_COLS andCol:indexPath.row % MAP_COLS];
    cell.cellBackground.backgroundColor = indexPath.row == self.selectedRowIndex
        ? [UIColor colorWithWhite:0.5f alpha:1.0f] : [UIColor colorWithWhite:0.4f alpha:1.0f];
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.controller.dontRecalOffset = NO;
    [self recalculateSections:scrollView.contentOffset];
    [self calCenterIndexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.controller.dontRecalOffset == NO)
    {
        [self recalculateSections:scrollView.contentOffset];
        [self calCenterIndexPath];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.controller.delegate respondsToSelector:@selector(endDrag:)])
        [self.controller.delegate endDrag:self.controller];
    
    if (self.selectedIndexPath != nil)
        self.controller.showPanel = YES;
    // self.showPanelLight = NO;
    
    if (decelerate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSLog(@"STOP ANIMATION...");
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        });
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.controller.delegate respondsToSelector:@selector(startDrag:)])
        [self.controller.delegate startDrag:self.controller];
    
    self.controller.showPanel = NO;
    // self.showPanelLight = YES;
}

@end
