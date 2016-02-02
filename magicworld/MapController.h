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

@end

@interface MapController : UIViewController

- (void)rotateMapToSize:(CGSize)size;

@property (strong, nonatomic) IBOutlet UICollectionView *mapCollection;
@property(nonatomic, assign) id<MapControllerDelegate> delegate;

@end
