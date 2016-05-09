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

@end

@implementation MapDatasource

- (instancetype)init
{
    if (self = [super init])
    {
//        DataManager *dataManager = [DataManager defaultInstance];
//        [dataManager insertIntoCoreData:@"Zone"];
    }
    return self;
}

- (void)setSelectedRowIndex:(NSInteger)selectedRowIndex
{
    if (_selectedRowIndex == selectedRowIndex)
        return;
    _selectedRowIndex = selectedRowIndex;
}

- (NSMutableArray *)zoneArray
{
    if (_zoneArray == nil)
        _zoneArray = [NSMutableArray arrayWithCapacity:MAP_ROWS * MAP_COLS];
    return _zoneArray;
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
        ? [UIColor colorWithWhite:0.5f alpha:0.5f] : [UIColor colorWithWhite:0.1f alpha:0.8f];
    return cell;
}


@end
