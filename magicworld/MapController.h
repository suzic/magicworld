//
//  MapController.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapController;

@protocol MapControllerDelegate <NSObject>

@optional

- (void)startDrag:(MapController *)controller;
- (void)endDrag:(MapController *)controller;
- (void)showOperator:(MapController *)controller withType:(NSInteger)opType;
- (void)showZoneInformation:(MapController *)controller withX:(NSInteger)x withY:(NSInteger)y;

@end

@interface MapController : UIViewController

- (void)rotateMapToSize:(CGSize)size;

@property (assign, nonatomic) BOOL stopAutoMoveCenter;

@property (strong, nonatomic) IBOutlet UICollectionView *mapCollection;
@property (strong, nonatomic) IBOutlet UICollectionView *operationCollection;
@property (assign, nonatomic) id<MapControllerDelegate> delegate;

@end
