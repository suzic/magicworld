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
        self.visibleAttributes = [NSMutableArray arrayWithCapacity:4 * MAP_ROWS * MAP_COLS];
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
    
    [self layoutMapCells];
    
    return self.visibleAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark - Private functions

- (void)layoutMapCells
{
    CGFloat topInset = self.collectionView.contentInset.top;
    CGPoint scrollPosition = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + topInset);
    CGFloat viewWidth = self.collectionView.frame.size.width;
    CGFloat viewHeight = self.collectionView.frame.size.height;
    CGFloat lastSectionOffsetX = scrollPosition.x + viewWidth;
    CGFloat lastSectionOffsetY = scrollPosition.y + viewHeight - topInset;

    // 数据区格式计算
    for (int section = 0; section < [self.collectionView numberOfSections]; section++)
    for (int row = 0; row < MAP_ROWS; row++)
    for (int col = 0; col < MAP_COLS; col++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row * MAP_COLS + col inSection:section];
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        // 判断是否需要提前结束
        NSInteger irow = (section % 2 == 0) ? row : MAP_ROWS + row;
        NSInteger icol = (section / 2 == 0) ? col : MAP_COLS + col;
        if ((icol + 1) * MAP_WIDTH < scrollPosition.x || (icol - 1) * MAP_WIDTH > lastSectionOffsetX ||
            (irow + 1) * MAP_HEIGHT < scrollPosition.y - topInset || (irow - 1) * MAP_HEIGHT > lastSectionOffsetY)
            continue;

        CGRect frame = CGRectMake(icol * MAP_WIDTH, irow * MAP_HEIGHT, MAP_WIDTH, MAP_HEIGHT);;
        attr.frame = frame;
        attr.zIndex = irow * MAP_COLS + icol;
        [self.visibleAttributes addObject:attr];
    }
}

@end
