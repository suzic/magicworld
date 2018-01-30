//
//  FrameController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "FrameController.h"
#import "MapController.h"
#import "OperationController.h"

@interface FrameController () <MapControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapLayer;            // 主地图层对象
@property (strong, nonatomic) IBOutlet UIButton *enterFloatButton;  // 前景浮动功能按钮
@property (strong, nonatomic) IBOutlet UIButton *helpFloatButton;   // 前景帮助功能按钮

@property (retain, nonatomic) MapController *mapController;         // 主地图控制器引用

@end

@implementation FrameController

// 视图内容初始化
- (void)viewDidLoad
{
    [super viewDidLoad];

    // 订制前景浮动功能按钮外观
    self.enterFloatButton.hidden = YES;
    self.enterFloatButton.layer.cornerRadius = 25.0f;
    self.enterFloatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.enterFloatButton.layer.borderWidth = 1.0f;
    self.helpFloatButton.hidden = YES;
    self.helpFloatButton.layer.cornerRadius = 25.0f;
    self.helpFloatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.helpFloatButton.layer.borderWidth = 1.0f;
}

// 视图将要显示
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 初始化的时候显示功能层
    [self showFunctions:YES animated:NO inLandMode:(kScreenWidth > kScreenHeight)];
}

// 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 视图尺寸变化（包括发生在旋转屏时）
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // 根据横竖屏尺寸信息决定初始化的时候是否显示功能层
    [self showFunctions:YES animated:NO inLandMode:(size.width > size.height)];
}

#pragma mark - Functions

// 显示或隐藏功能层
- (void)showFunctions:(BOOL)show animated:(BOOL)animated inLandMode:(BOOL)inLandMode
{
    // 系统状态栏和导航在横屏时不显示，竖屏时根据show来决定显隐，并套用是否动画演示效果
    [self.navigationController setNavigationBarHidden:(inLandMode || !show) animated:animated];
    
    // 浮动工具栏在竖屏时不显示，横屏总是显示（但会以动画方式进入／离开屏幕区域）
    self.enterFloatButton.hidden = !inLandMode;
    self.helpFloatButton.hidden = !inLandMode;
    [UIView animateWithDuration:(animated ? 0.5f : 0.0f) animations:^{
        self.enterFloatButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 60, 0);
        self.helpFloatButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 60, 0);
    }];
}

// 登出功能
- (IBAction)logOut:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Log Out"
                                                    message:@"Do you really want to Log Out ?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}

// 进入功能
- (IBAction)rightPress:(id)sender
{
//    [self performSegueWithIdentifier:@"showZone" sender:sender];
}

// 呼叫帮助
- (IBAction)helpPress:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotiShowGuideInfo
                                                        object:(kScreenWidth < kScreenHeight ?
                                                                @"侬可以把屏幕横过来看嘛，这样俺就可说更多字了～\n没事儿记得摸摸俺的头o(>_<)o"
                                                                : @"嗯，这样不错，俺的位置不会太碍事儿～\n如果没什么事儿，就摸摸俺的头o(>_<)o")];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - MapController Delegate

- (void)startDrag:(MapController *)controller
{
    controller.stopAutoMoveCenter = YES;
    
    [self showFunctions:NO animated:YES inLandMode:(kScreenWidth > kScreenHeight)];
}

- (void)endDrag:(MapController *)controller
{
    controller.stopAutoMoveCenter = YES;
    
    [self showFunctions:YES animated:YES inLandMode:(kScreenWidth > kScreenHeight)];
}

- (void)showOperator:(MapController *)controller withType:(NSInteger)opType
{
    //    self.operationLayer.alpha = 0.0f;
    //    self.operationLayer.hidden = NO;
    //    [UIView animateWithDuration:0.5f animations:^{
    //        self.operationLayer.alpha = 1.0f;
    //    } completion:^(BOOL finished) {
    //        [self.opearationController scrollToIndex:19];
    //    }];
}

- (void)showZoneInformation:(MapController *)controller withX:(NSInteger)x withY:(NSInteger)y
{
//    [self performSegueWithIdentifier:@"showZone" sender:controller];
}

#pragma mark - Navigation

// 导航时处理
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 嵌入的地图控制器
    if ([segue.identifier isEqualToString:@"mapSegue"])
    {
        self.mapController = (MapController *)[segue destinationViewController];
        self.mapController.delegate = self;
    }
    // 行进到区域内部控制器
    else if ([segue.identifier isEqualToString:@"showZone"])
    {
        UINavigationController *nc = [segue destinationViewController];
        OperationController *opearationController = (OperationController *)[nc topViewController];
        opearationController.frameController = self;
    }
}

@end
