//
//  GameManager.h
//  magicworld
//
//  Created by 苏智 on 2018/2/6.
//  Copyright © 2018年 Suzic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FrameController.h"
#import "MWGame+CoreDataClass.h"
#import "MWRound+CoreDataClass.h"

@interface GameManager : NSObject

@property (weak, nonatomic) FrameController *stageController;

@property (strong, nonatomic) MWGame *currentGame;
@property (strong, nonatomic) MWRound *currentRound;

// 单例模式的数据管理器
+ (instancetype)defaultInstance;

- (MWGame *)startNewGame;

- (MWRound *)enterNewRound:(MWGame *)game;

- (BOOL)submitPreparation:(MWRound *)round;

- (BOOL)executeActions:(MWRound *)round completion:(void (^)(BOOL finished))completion;

- (NSInteger)testEnd:(MWRound *)round;

- (BOOL)endGame:(MWGame *)game completion:(void (^)(BOOL finished)) completion;

@end
