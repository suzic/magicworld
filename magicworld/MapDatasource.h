//
//  MapDatasource.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapController;

@interface MapDatasource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) MapController *controller;

@property (assign, nonatomic) NSInteger selectedRowIndex;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (retain, nonatomic) NSIndexPath *autoCenterIndexPath;

- (void)recalculateSections:(CGPoint)offset;

@end
