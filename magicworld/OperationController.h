//
//  OperationController.h
//  magicworld
//
//  Created by 苏智 on 16/4/21.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OperationController : UIViewController

@property (strong, nonatomic) NSMutableArray *operationArray;
@property (assign, nonatomic) NSInteger selectedIndex;

- (void)scrollToIndex:(NSInteger)index;

@end
