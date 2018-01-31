//
//  MapDatasource.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FrameController;

@interface MapDatasource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) FrameController *controller;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSIndexPath *highlightedIndexPath;

@end
