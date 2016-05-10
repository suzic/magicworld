//
//  MapCellLayout.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "MapController.h"
#import "MapCellLayout.h"
#import "MapDatasource.h"
#import "MapCell.h"

@implementation MapCellLayout

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.visibleAttributes = [NSMutableArray arrayWithCapacity:200];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize
{
    CGSize size = self.collectionView.frame.size;
    size = CGSizeMake(MAP_WIDTH * MAP_COLS * 2, MAP_HEIGHT * MAP_ROWS * 2);
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    [self.visibleAttributes removeAllObjects];
    // NSLog(@"x = %f, y = %f, w = %f, h = %f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    // 根据偏移量计算可能显示的所有格子的横竖索引的起始
    NSInteger row_min = ((self.collectionView.contentOffset.y / MAP_HEIGHT)) - 1;
    NSInteger col_min = ((self.collectionView.contentOffset.x / MAP_WIDTH)) - 1;
    NSInteger row_max = ((self.collectionView.contentOffset.y + kScreenHeight) / MAP_HEIGHT) + 1;
    NSInteger col_max = ((self.collectionView.contentOffset.x + kScreenWidth) / MAP_WIDTH) + 1;

    // 不要越界
    row_min = row_min < 0 ? 0 : row_min;
    col_min = col_min < 0 ? 0 : col_min;
    row_max = (row_max > MAP_ROWS * 2) ? (MAP_ROWS * 2) : row_max;
    col_max = (col_max > MAP_COLS * 2) ? (MAP_COLS * 2) : col_max;

    // 双层循环处理可视区域内的各个格子
    for (NSInteger row = row_min; row < row_max; row++)
    for (NSInteger col = col_min; col < col_max; col++)
    {
        // section是通过四个区域是否过半计算的
        NSInteger section = 0;
        section += (col >= MAP_COLS) ? 1 : 0;
        section += (row >= MAP_ROWS) ? 2 : 0;
        
        // 转换到四个section的坐标体系并获取对应的属性值
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(row % MAP_ROWS) * MAP_COLS + (col % MAP_COLS) inSection:section];
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        //加入可见属性列表
        [self.visibleAttributes addObject:attr];
    }

    // NSLog(@"Render attributes: %d", self.visibleAttributes.count);
    return self.visibleAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSInteger row = (indexPath.row / MAP_ROWS) + ((indexPath.section / 2) == 0 ? 0 : MAP_ROWS);
    NSInteger col = (indexPath.row % MAP_COLS) + ((indexPath.section % 2) == 0 ? 0 : MAP_COLS);
    
    CGRect frame = CGRectMake(col * MAP_WIDTH, row * MAP_HEIGHT, MAP_WIDTH, MAP_HEIGHT);;
    attr.frame = frame;
    attr.zIndex = indexPath.section * MAP_ROWS * MAP_COLS + indexPath.row;
    
    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
