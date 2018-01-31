//
//  MapController.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapController;

/**
 *  @abstract 地图控制器代理方法
 */
@protocol MapControllerDelegate <NSObject>

@optional

- (void)startDrag:(MapController *)controller;
- (void)endDrag:(MapController *)controller;
- (void)showOperator:(MapController *)controller withType:(NSInteger)opType;
- (void)showZoneInformation:(MapController *)controller withX:(NSInteger)x withY:(NSInteger)y;

@end

/**
 *  @abstract 地图控制器
 */
@interface MapController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *mapCollection;
@property (strong, nonatomic) IBOutlet UICollectionView *operationCollection;
@property (assign, nonatomic) id<MapControllerDelegate> delegate;

- (void)infoPanelToShow:(BOOL)show inSize:(CGSize)size completion:(void (^)(BOOL finished))completion;

@property (assign, nonatomic) BOOL showPanel;
@property (assign, nonatomic) BOOL showPanelLight;
@property (assign, nonatomic) BOOL stopAutoMoveCenter;
@property (assign, nonatomic) BOOL dontRecalOffset;

@end
