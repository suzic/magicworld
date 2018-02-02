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
        self.visibleAttributes = [NSMutableArray arrayWithCapacity:MAP_COLS * MAP_ROWS + 1];
        self.cellSize = 0.0f;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
}

- (CGFloat)cellSize
{
    if (_cellSize <= 0.0f)
    {
        CGFloat spaceSize = kScreenWidth < kScreenHeight ? kScreenWidth : kScreenHeight;
        CGFloat minSize = 60.0f;
        CGFloat maxSize = 69.0f;
        int maxCount = (int)(spaceSize / minSize);
        int minCount = (int)(spaceSize / maxSize);
        int selCount = minCount < 5 ? maxCount : minCount;
        _cellSize = spaceSize / selCount;        
    }
    return _cellSize;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = CGSizeZero;
    size.width = fmax(self.cellSize * MAP_COLS + self.cellSize * 3, kScreenWidth + self.cellSize * 2);
    size.height = fmax(self.cellSize * MAP_ROWS + self.cellSize * 3, kScreenHeight + self.cellSize * 2);
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    [self.visibleAttributes removeAllObjects];

    for (NSInteger row = 0; row < MAP_ROWS; row++)
    for (NSInteger col = 0; col < MAP_COLS; col++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(row * MAP_COLS + col) inSection:0];
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.visibleAttributes addObject:attr];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
    [self.visibleAttributes addObject:attr];
    return self.visibleAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        NSInteger row = (indexPath.row / MAP_ROWS);
        NSInteger col = (indexPath.row % MAP_COLS);
        CGRect frame = CGRectMake((self.collectionViewContentSize.width - self.cellSize * MAP_COLS) / 2  + col * self.cellSize,
                                  (self.collectionViewContentSize.height - self.cellSize * MAP_ROWS) / 2 + row * self.cellSize,
                                  self.cellSize, self.cellSize);
        attr.frame = frame;
        attr.zIndex = indexPath.row + 1;
        attr.transform = CGAffineTransformIdentity;
    }
    else
    {
        attr.frame = CGRectMake((self.collectionViewContentSize.width - self.cellSize * MAP_COLS) / 2 - 2,
                                (self.collectionViewContentSize.height - self.cellSize * MAP_ROWS) / 2 - 2,
                                self.cellSize * MAP_COLS + 4, self.cellSize * MAP_ROWS + 4);
        attr.zIndex = 0;
        attr.transform = CGAffineTransformIdentity;
    }

    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
