//
//  MapCellLayout.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapCellLayout : UICollectionViewLayout

@property (retain, nonatomic) NSMutableArray *visibleAttributes;
@property (assign, nonatomic) CGFloat cellSize;

@end
