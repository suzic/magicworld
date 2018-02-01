//
//  ActionLayout.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#define ACTION_UNIT_SIZE 60.0f

#import "ActionLayout.h"

@implementation ActionLayout

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.visibleAttributes = [NSMutableArray arrayWithCapacity:5];
        _inLandMode = YES;
        self.inLandMode = NO;
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize
{
    return self.collectionView.frame.size;
}

- (void)setInLandMode:(BOOL)inLandMode
{
    if (_inLandMode == inLandMode)
        return;
    _inLandMode = inLandMode;
    [self invalidateLayout];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    [self.visibleAttributes removeAllObjects];

    for (NSInteger i = 0; i < 5; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        //加入可见属性列表
        [self.visibleAttributes addObject:attr];
    }

    return self.visibleAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat unitSpaceSize = (self.inLandMode ? kScreenHeight : kScreenWidth) / 5;
    CGRect frame = CGRectZero;
    if (indexPath.row == 0)
    {
        frame = CGRectMake(0.0f, 0.0f,
                           self.inLandMode ? ACTION_UNIT_SIZE : unitSpaceSize,
                           self.inLandMode ? unitSpaceSize : ACTION_UNIT_SIZE);
    }
    else
    {
        frame = CGRectMake(self.inLandMode ? 0.0f : unitSpaceSize * indexPath.row,
                           self.inLandMode ? unitSpaceSize * indexPath.row : 0.0f,
                           self.inLandMode ? ACTION_UNIT_SIZE : unitSpaceSize,
                           self.inLandMode ? unitSpaceSize : ACTION_UNIT_SIZE);
    }

    attr.frame = frame;
    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
