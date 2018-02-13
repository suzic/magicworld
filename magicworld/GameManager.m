//
//  GameManager.m
//  magicworld
//
//  Created by 苏智 on 2018/2/6.
//  Copyright © 2018年 Suzic. All rights reserved.
//

#import "GameManager.h"

@implementation GameManager

// 单例模式下的默认实例的创建
+ (instancetype)defaultInstance
{
    static GameManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

@end
