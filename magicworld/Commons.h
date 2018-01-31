//
//  Commons.h
//  magicworld
//
//  Created by 苏智 on 16/1/8.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#ifndef Commons_h
#define Commons_h

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenHeightVisable (kScreenHeight - [UIScreen main)

#define MAP_ROWS    100
#define MAP_COLS    100
#define MAP_WIDTH   (kScreenWidth < kScreenHeight ? (int)(kScreenWidth / 5.0f) : (int)(kScreenHeight / 5.0f))
#define MAP_HEIGHT  MAP_WIDTH //(kScreenWidth < kScreenHeight ? (int)(kScreenHeight / 9.0f) : (int)(kScreenHeight / 5.0f))


// Notification flags
#define NotiShowGuideInfo           @"NotiShowGuideInfo"
#define NotiHideGuideInfo           @"NotiHideGuideInfo"
//#define NotiBackToMain          @"NotiBackToMain"
//#define NotiLocationChanged     @"NotiLocationChanged"
//#define NotiShowMap             @"NotiShowMap"

#import "DataManager.h"

#endif /* Commons_h */
