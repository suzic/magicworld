//
//  MapController.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#define MAP_ROWS    100
#define MAP_COLS    100
#define MAP_WIDTH   40.0f
#define MAP_HEIGHT  40.0f


#import <UIKit/UIKit.h>

@interface MapController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *mapCollection;

@end
