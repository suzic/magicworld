//
//  FrameController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "FrameController.h"
#import "OperationController.h"
#import "MapCell.h"
#import "InfoCell.h"
#import "ActionCell.h"

@interface FrameController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign, nonatomic) BOOL guideInShown;

@property (strong, nonatomic) IBOutlet UIButton *enterFloatButton;  // 前景浮动功能按钮
@property (strong, nonatomic) IBOutlet UIButton *helpFloatButton;   // 前景帮助功能按钮

@property (strong, nonatomic) IBOutlet UIView *infoPanel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoSpliteWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoSpliteHeight;

@property (strong, nonatomic) UIButton *infoTitle;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationBottom;

@property (strong, nonatomic) IBOutlet MapDatasource *mapDatasource;

@end

@implementation FrameController

// 视图内容初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapDatasource.controller = self;
    self.automaticallyAdjustsScrollViewInsets = YES;

    // 订制前景浮动功能按钮外观
    self.enterFloatButton.hidden = YES;
    self.enterFloatButton.layer.cornerRadius = 25.0f;
    self.enterFloatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.enterFloatButton.layer.borderWidth = 1.0f;
    self.helpFloatButton.hidden = YES;
    self.helpFloatButton.layer.cornerRadius = 25.0f;
    self.helpFloatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.helpFloatButton.layer.borderWidth = 1.0f;
    
    // 初始化infoPanel
    self.guideInShown = NO;
    self.showPanel = NO;
    self.stopAutoMoveCenter = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGuideInformation:) name:NotiShowGuideInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideGuideInformation:) name:NotiHideGuideInfo object:nil];
}

// 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 视图将要显示
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 初始化的时候显示功能层
    [self showFunctions:YES animated:NO inLandMode:(kScreenWidth > kScreenHeight)];
}

// 完成重布局
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // 重新计算消息面板
    [self updatePanelSize:CGSizeMake(kScreenWidth, kScreenHeight)];
    if (kScreenWidth < kScreenHeight)
        self.infoPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.infoPanel.frame.size.height);
    else
        self.infoPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.infoPanel.frame.size.width, 0);
    
    //    if (self.stopAutoMoveCenter == YES)
    //        self.stopAutoMoveCenter = NO;
    //    else
    //    {
    //        self.dontRecalOffset = YES;
    //        [self.mapCollection scrollToItemAtIndexPath:self.mapDatasource.autoCenterIndexPath
    //                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
    //                                           animated:NO];
    //        self.dontRecalOffset = NO;
    //    }
}

// 视图尺寸变化（包括发生在旋转屏时）
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // 根据横竖屏尺寸信息决定初始化的时候是否显示功能层
    [self showFunctions:YES animated:NO inLandMode:(size.width > size.height)];
    
    // 横竖屏的时候重新计算信息面板
    [self rotateInfoPanelToSize:size];
}

// 重载显示状态栏风格
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

// 重载是否显示状态栏，这里保持与导航栏显示隐藏一致即可
- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

#pragma mark - User operations

// 用户点击操作
- (IBAction)moveToSelected:(id)sender
{
    if (self.mapDatasource.selectedIndexPath == nil)
        return;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.mapCollection scrollToItemAtIndexPath:self.mapDatasource.selectedIndexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                | UICollectionViewScrollPositionCenteredVertically
                                       animated:YES];
}

// 登出功能
- (IBAction)logOut:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 进入功能
- (IBAction)rightPress:(id)sender
{
    // [self performSegueWithIdentifier:@"showZone" sender:sender];
}

// 呼叫帮助
- (IBAction)helpPress:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotiShowGuideInfo
                                                        object:(kScreenWidth < kScreenHeight ?
                                                                @"侬可以把屏幕横过来看嘛，这样俺就可说更多字了～\n没事儿记得摸摸俺的头o(>_<)o"
                                                                : @"嗯，这样不错，俺的位置不会太碍事儿～\n如果没什么事儿，就摸摸俺的头o(>_<)o")];
}

#pragma mark - Properties & inner method

- (void)setShowPanel:(BOOL)showPanel
{
    if (_showPanel == showPanel)
        return;
    _showPanel = showPanel;
    
    [self infoPanelToShow:showPanel inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)updateInfoPanelContent
{
    [self.infoTitle setTitle:[NSString stringWithFormat:@"%02ld - %02ld",
                              (long)(self.mapDatasource.selectedIndexPath.row / MAP_COLS),
                              (long)(self.mapDatasource.selectedIndexPath.row % MAP_COLS)]
                    forState:UIControlStateNormal];
}

- (void)updatePanelSize:(CGSize)size
{
    const CGFloat barHeight = 60.0f;
    CGFloat vFix = self.bottomLayoutGuide.length;   // 34.0f;
    CGFloat hFix = self.bottomLayoutGuide.length / 2;   //20.0f;
    
    // 计算旋转后的面板尺寸
    self.infoPanelWidth.constant = (size.width < size.height) ? size.width : barHeight + vFix;
    self.infoPanelHeight.constant = (size.width < size.height) ? barHeight + vFix : size.height;
    self.infoSpliteWidth.constant = (size.width < size.height) ? size.width : 0.5f;
    self.infoSpliteHeight.constant = (size.width < size.height) ? 0.5f : size.height;
    
    self.operationLeading.constant = (size.width < size.height) ? 8.0f : vFix;
    self.operationTop.constant = (size.width < size.height) ? 0.0f : hFix;
    self.operationBottom.constant = (size.width < size.height) ? 0.0f : hFix;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.operationCollection.collectionViewLayout;
    layout.scrollDirection = (size.width < size.height) ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
}

- (void)rotateInfoPanelToSize:(CGSize)size
{
    [self updatePanelSize:size];
    if (self.showPanel)
    {
        [self infoPanelToShow:NO inSize:size completion:^(BOOL finished) {
            [self infoPanelToShow:YES inSize:size completion:^(BOOL finished) {
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }];
    }
}

- (void)infoPanelToShow:(BOOL)show inSize:(CGSize)size completion:(void (^)(BOOL finished))completion
{
    // 根据显隐要求初始化状态
    if (show)
        [self updateInfoPanelContent];
    
    // 动画移动
    [UIView animateWithDuration:0.3f animations:^{
        if (size.width < size.height)
            self.infoPanel.transform = show ? CGAffineTransformIdentity
                : CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.infoPanel.frame.size.height);
        else
            self.infoPanel.transform = show ? CGAffineTransformIdentity
                : CGAffineTransformTranslate(CGAffineTransformIdentity, -self.infoPanel.frame.size.width, 0);
    } completion:completion];
}

- (void)showGuideInformation:(NSNotification *)notification
{
    self.guideInShown = YES;
//    // 强制隐藏infoPanel
//    [self infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:nil];
}

- (void)hideGuideInformation:(NSNotification *)notification
{
    self.guideInShown = NO;
//    // 还原infoPanel的显隐状态
//    [self infoPanelToShow:self.showPanel inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:nil];
}

// 显示或隐藏功能层
- (void)showFunctions:(BOOL)show animated:(BOOL)animated inLandMode:(BOOL)inLandMode
{
    // 系统状态栏和导航在横屏时不显示，竖屏时根据show来决定显隐，并套用是否动画演示效果
    [self.navigationController setNavigationBarHidden:(inLandMode || !show) animated:YES];
    
    // 浮动工具栏在竖屏时不显示，横屏总是显示（但会以动画方式进入／离开屏幕区域）
    self.enterFloatButton.hidden = !inLandMode;
    self.helpFloatButton.hidden = !inLandMode;
    [UIView animateWithDuration:(animated ? 0.5f : 0.0f) animations:^{
        self.enterFloatButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 60, 0);
        self.helpFloatButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 60, 0);
    }];
}

//- (void)showOperator:(MapController *)controller withType:(NSInteger)opType
//{
//  self.operationLayer.alpha = 0.0f;
//  self.operationLayer.hidden = NO;
//  [UIView animateWithDuration:0.5f animations:^{
//      self.operationLayer.alpha = 1.0f;
//  } completion:^(BOOL finished) {
//      [self.opearationController scrollToIndex:19];
//  }];
//}

//- (void)showZoneInformation:(MapController *)controller withX:(NSInteger)x withY:(NSInteger)y
//{
////    [self performSegueWithIdentifier:@"showZone" sender:controller];
//}

#pragma mark - UICollectionView Datasource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (indexPath.row == 0)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"infoCell" forIndexPath:indexPath];
        InfoCell *infoCell = (InfoCell *)cell;
        self.infoTitle = infoCell.cellIndex;
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"actionCell" forIndexPath:indexPath];
        ActionCell *actionCell = (ActionCell *)cell;
        actionCell.actionType = indexPath.row - 1;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.operationCollection)
    {
        if (indexPath.row == 2)
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiShowGuideInfo
                                                                object:@"呀吼～俺来啦！\n侬素不素点了Attack？要打架了～算俺一个！（好熟悉的台词）"];
        else
        {
            //  if ([self.delegate respondsToSelector:@selector(showOperator:withType:)])
            //      [self.delegate showOperator:self withType:0];
            //  if ([self.delegate respondsToSelector:@selector(showZoneInformation:withX:withY:)])
            //      [self.delegate showZoneInformation:self withX:0 withY:0];
        }
    }
}

#pragma mark - Navigation

// 导航时处理
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 行进到区域内部控制器
    if ([segue.identifier isEqualToString:@"showZone"])
    {
        UINavigationController *nc = [segue destinationViewController];
        OperationController *opearationController = (OperationController *)[nc topViewController];
        opearationController.frameController = self;
    }
}

@end
