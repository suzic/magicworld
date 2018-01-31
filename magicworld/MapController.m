//
//  MapController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "MapController.h"
#import "MapDatasource.h"
#import "MapCell.h"
#import "InfoCell.h"

@interface MapController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (assign, nonatomic) BOOL guideInShown;

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

@implementation MapController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.mapCollection.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MAPBG"]];
    
    // 初始化infoPanel
    self.guideInShown = NO;
    self.showPanel = NO;
    self.showPanelLight = NO;
    self.dontRecalOffset = NO;
    self.stopAutoMoveCenter = NO;

    self.mapDatasource.controller = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGuideInformation:) name:NotiShowGuideInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideGuideInformation:) name:NotiHideGuideInfo object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // 重新计算消息面板
    [self initPanelSize:CGSizeMake(kScreenWidth, kScreenHeight)];
    if (kScreenWidth < kScreenHeight)
        self.infoPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.infoPanel.frame.size.height);
    else
        self.infoPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.infoPanel.frame.size.width, 0);

    // 通过Datasource控制map的重算和自动定位功能
    [self.mapDatasource recalculateSections:self.mapCollection.contentOffset];
    if (self.stopAutoMoveCenter == YES)
        self.stopAutoMoveCenter = NO;
    else
    {
        self.dontRecalOffset = YES;
        [self.mapCollection scrollToItemAtIndexPath:self.mapDatasource.autoCenterIndexPath
                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                                           animated:NO];
        self.dontRecalOffset = NO;
    }
}

// 视图尺寸变化（包括发生在旋转屏时）
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self rotateInfoPanelToSize:size];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

#pragma mark - Private functions

- (IBAction)moveToSelected:(id)sender
{
    if (self.mapDatasource.selectedIndexPath == nil)
        return;
    self.dontRecalOffset = YES;
    [self.mapCollection scrollToItemAtIndexPath:self.mapDatasource.selectedIndexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                                   animated:YES];
}

- (void)setupInfoPanelData
{
    [self.infoTitle setTitle:[NSString stringWithFormat:@"%02ld - %02ld",
                              (long)(self.mapDatasource.selectedIndexPath.row / MAP_COLS),
                              (long)(self.mapDatasource.selectedIndexPath.row % MAP_COLS)]
                    forState:UIControlStateNormal];
}

- (void)initPanelSize:(CGSize)size
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
    [self initPanelSize:size];
    if (self.showPanel)
    {
        [self infoPanelToShow:NO inSize:size completion:^(BOOL finished) {
            [self infoPanelToShow:YES inSize:size completion:^(BOOL finished) {
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }];
    }
}

- (void)infoPanelToShow:(BOOL)show inSize:(CGSize)size completion:(void (^ __nullable)(BOOL finished))completion
{
    // 根据显隐要求初始化状态
    if (show) [self setupInfoPanelData];
    
    // 动画移动
    [UIView animateWithDuration:0.3f animations:^{
        if (size.width < size.height)
            self.infoPanel.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.infoPanel.frame.size.height);
        else
            self.infoPanel.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, -self.infoPanel.frame.size.width, 0);
    } completion:completion];
}

- (void)showGuideInformation:(NSNotification *)notification
{
    self.guideInShown = YES;
    
    // 强制隐藏infoPanel
    //[self infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:nil];
}

- (void)hideGuideInformation:(NSNotification *)notification
{
    self.guideInShown = NO;
    
    // 还原infoPanel的显隐状态
    //[self infoPanelToShow:self.showPanel inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:nil];
}

#pragma mark - Properties settings

- (void)setShowPanel:(BOOL)showPanel
{
    if (_showPanel == showPanel)
        return;
    _showPanel = showPanel;

    [self infoPanelToShow:showPanel inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)setShowPanelLight:(BOOL)showPanelLight
{
    if (_showPanelLight == showPanelLight)
        return;
    _showPanelLight = showPanelLight;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.infoPanel.alpha = showPanelLight ? 0.5f : 1.0f;
    }];
}

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
    switch (indexPath.row)
    {
        case 0:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"infoCell" forIndexPath:indexPath];
            InfoCell *infoCell = (InfoCell *)cell;
            self.infoTitle = infoCell.cellIndex;
        }
            break;
        case 1:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"action1" forIndexPath:indexPath];
            break;
        case 2:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"action2" forIndexPath:indexPath];
            break;
        case 3:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"action3" forIndexPath:indexPath];
            break;
        case 4:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"action4" forIndexPath:indexPath];
            break;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.operationCollection)
    {
        if (indexPath.row == 2)
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiShowGuideInfo object:@"呀吼～俺来啦！\n侬素不素点了Attack？要打架了～算俺一个！（好熟悉的台词）"];
        else
        {
            if ([self.delegate respondsToSelector:@selector(showOperator:withType:)])
                [self.delegate showOperator:self withType:0];
//            if ([self.delegate respondsToSelector:@selector(showZoneInformation:withX:withY:)])
//                [self.delegate showZoneInformation:self withX:0 withY:0];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
