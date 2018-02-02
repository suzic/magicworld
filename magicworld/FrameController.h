//
//  FrameController.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapDatasource.h"

@interface FrameController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *mapCollection;
@property (strong, nonatomic) IBOutlet UICollectionView *operationCollection;

@property (assign, nonatomic) BOOL shouldShowPanel;
@property (assign, nonatomic) BOOL showPanel;

- (void)switchPanelShowInfo:(BOOL)showInfo
                 showHeader:(BOOL)showHeader
                   showFunc:(BOOL)showFunc
                     inSize:(CGSize)size
                 completion:(void (^)(BOOL finished))completion;

- (void)updateSelection:(BOOL)autoCenter;

@end
