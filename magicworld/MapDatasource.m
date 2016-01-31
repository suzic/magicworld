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

@implementation MapDatasource

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
    return cell;
}


@end
