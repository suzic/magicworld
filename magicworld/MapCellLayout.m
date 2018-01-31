//
//  MapCellLayout.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "MapCellLayout.h"
#import "MapDatasource.h"
#import "MapCell.h"

@implementation MapCellLayout

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.visibleAttributes = [NSMutableArray arrayWithCapacity:MAP_COLS * MAP_ROWS];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize
{
    CGSize size = CGSizeMake(CELL_WIDTH * MAP_COLS + kScreenWidth - CELL_WIDTH, CELL_HEIGHT * MAP_ROWS + kScreenHeight - CELL_HEIGHT);
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    [self.visibleAttributes removeAllObjects];
    // NSLog(@"x = %f, y = %f, w = %f, h = %f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    CGPoint point = self.collectionView.contentOffset;
    point.x = point.x - (kScreenWidth - CELL_WIDTH) / 2;
    point.y = point.y - (kScreenHeight - CELL_HEIGHT) / 2;

    // 根据偏移量计算可能显示的所有格子的横竖索引的起始
    NSInteger row_min = ((point.y / CELL_HEIGHT)) - 1;
    NSInteger col_min = ((point.x / CELL_WIDTH)) - 1;
    NSInteger row_max = ((point.y + kScreenHeight) / CELL_HEIGHT) + 1;
    NSInteger col_max = ((point.x + kScreenWidth) / CELL_WIDTH) + 1;

    // 不要越界
    row_min = row_min < 0 ? 0 : row_min;
    col_min = col_min < 0 ? 0 : col_min;
    row_max = (row_max > MAP_ROWS) ? MAP_ROWS : row_max;
    col_max = (col_max > MAP_COLS) ? MAP_COLS : col_max;

    // 双层循环处理可视区域内的各个格子
    for (NSInteger row = row_min; row < row_max; row++)
    for (NSInteger col = col_min; col < col_max; col++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(row * MAP_COLS + col) inSection:0];
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
    
    NSInteger row = (indexPath.row / MAP_ROWS);
    NSInteger col = (indexPath.row % MAP_COLS);
    
    CGRect frame = CGRectMake((kScreenWidth - CELL_WIDTH) / 2 + col * CELL_WIDTH,
                              (kScreenHeight - CELL_HEIGHT) / 2 + row * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);;
    attr.frame = frame;
    attr.zIndex = indexPath.section * MAP_ROWS * MAP_COLS + indexPath.row;
    
    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
