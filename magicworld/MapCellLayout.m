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

    // 双层循环处理可视区域内的各个格子
    for (NSInteger row = 0; row < MAP_ROWS; row++)
    for (NSInteger col = 0; col < MAP_COLS; col++)
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
                              (kScreenHeight - CELL_HEIGHT) / 2 + row * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT);
    attr.frame = frame;
    attr.zIndex = indexPath.row;
    attr.transform = CGAffineTransformIdentity;
    NSIndexPath *selectedIndexPath = ((MapDatasource *)self.collectionView.dataSource).selectedIndexPath;
    if (selectedIndexPath != nil && selectedIndexPath.row == indexPath.row)
    {
        attr.zIndex = MAP_ROWS * MAP_COLS;
        attr.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5f, 1.5f);
    }
    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
