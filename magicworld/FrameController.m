//
//  FrameController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "FrameController.h"
#import "OperationController.h"
#import "MapCellLayout.h"
#import "MapCell.h"
#import "InfoCell.h"
#import "ActionCell.h"
#import "ActionLayout.h"

@interface FrameController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *enterFloatButton;  // 前景浮动功能按钮
@property (strong, nonatomic) IBOutlet UIButton *helpFloatButton;   // 前景帮助功能按钮
@property (weak, nonatomic) IBOutlet UIView *selectedView;
@property (weak, nonatomic) IBOutlet UILabel *selectedViewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@property (strong, nonatomic) IBOutlet UIView *infoPanel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoSpliteWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoSpliteHeight;

@property (strong, nonatomic) UIButton *infoTitle;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationBottom;

@property (strong, nonatomic) IBOutlet UIView *headPanel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headPanelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headPanelTop;

@property (strong, nonatomic) IBOutlet MapDatasource *mapDatasource;

@end

@implementation FrameController
{
    BOOL firstInit;
    CGPoint panLengthPoint;
}

// 视图内容初始化
- (void)viewDidLoad
{
    firstInit = YES;
    
    [super viewDidLoad];
    self.mapDatasource.controller = self;
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.mapCollection addSubview:self.arrowImage];
    [self.mapCollection addSubview:self.selectedView];
    self.arrowImage.hidden = YES;
    self.selectedView.hidden = YES;
    self.arrowImage.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
    
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
    _shouldShowPanel = YES;
    _showPanel = YES;
    self.shouldShowPanel = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

// 视图显示
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

// 完成重布局
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self rotateInfoPanelToSize:CGSizeMake(kScreenWidth, kScreenHeight)];
    [self moveToSelected:nil];

    // 第一次自动执行居中布局
    if (firstInit)
    {
        firstInit = NO;

        MapCellLayout *mapLayout = (MapCellLayout *)self.mapCollection.collectionViewLayout;
        CGSize size = mapLayout.collectionViewContentSize;
        CGPoint targetPoint = CGPointMake(size.width / 2 - kScreenWidth / 2, size.height / 2 - kScreenHeight / 2);
        self.selectedView.frame = CGRectMake(0, 0, mapLayout.cellSize * 1.5f, mapLayout.cellSize * 1.5f);
        self.selectedView.layer.cornerRadius = self.selectedView.frame.size.width / 2;
        [self updateSelection:NO];
        [self.mapCollection setContentOffset:targetPoint];
    }
}

// 视图尺寸变化（包括发生在旋转屏时）
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // 横竖屏的时候重新计算信息面板
    [self rotateInfoPanelToSize:size];
}

// 重载显示状态栏风格
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - User operations

// 用户点击操作
- (IBAction)moveToSelected:(id)sender
{
    if (self.mapDatasource.selectedIndexPath == nil)
        return;
    [self.mapCollection scrollToItemAtIndexPath:self.mapDatasource.selectedIndexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                | UICollectionViewScrollPositionCenteredVertically
                                       animated:YES];
}

// 登出功能
- (IBAction)logOut:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popToRootViewControllerAnimated:YES];
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
                                                        object:(kScreenWidth < 460.0f ?
                                                                @"侬可以把屏幕横过来看嘛，这样俺讲话有点挤呀～\n没事儿记得摸摸俺的头o(>_<)o"
                                                                : @"嗯，不错，舒展多了，么么哒～\n没什么事儿，就摸摸俺的头o(>_<)o")];
}

// 定位目标手势
- (IBAction)panTarget:(id)sender
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
            [self drawArrowLengthPoint:CGPointZero];
            break;
            
        case UIGestureRecognizerStateChanged:
            panLengthPoint = [pan translationInView:self.view];
            [self drawArrowLengthPoint:panLengthPoint];
            [self updateTargetHightlight:panLengthPoint];
            break;

        case UIGestureRecognizerStateEnded:
            if (self.mapDatasource.highlightedIndexPath == nil || self.mapDatasource.highlightedIndexPath.section != 0)
                self.arrowImage.hidden = YES;
            else
            {
                MapCell *highlightCell = (MapCell *)[self.mapCollection cellForItemAtIndexPath:self.mapDatasource.highlightedIndexPath];
                CGPoint adjustLengthPoint = CGPointMake(highlightCell.center.x - self.selectedView.center.x,
                                                        highlightCell.center.y - self.selectedView.center.y);
                [self drawArrowLengthPoint:adjustLengthPoint];
            }
            break;

        case UIGestureRecognizerStateCancelled:
            self.arrowImage.hidden = YES;
            break;

        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (void)updateTargetHightlight:(CGPoint)pointTo
{
    CGPoint pointInCollectionView = CGPointMake(pointTo.x + self.selectedView.center.x, pointTo.y + self.selectedView.center.y);
    self.mapDatasource.highlightedIndexPath = [self.mapCollection indexPathForItemAtPoint:pointInCollectionView];
}

- (void)drawArrowLengthPoint:(CGPoint)length
{
    CGFloat angle = 0.0f;
    CGFloat panDistance = sqrt(length.x * length.x + length.y * length.y);
    self.arrowImage.hidden = panDistance < 64.0f;
    if (!self.arrowImage.hidden)
    {
        if (length.x == 0.0f)
            angle = length.y > 0 ? M_PI_2 : -M_PI_2;
        else
            angle = (length.x > 0) ? atan(length.y / length.x) : (M_PI + atan(length.y / length.x));
        // NSLog(@"角度 a = %02.2f 长度 d = %02.2f", angle, panDistance);
        self.arrowImage.transform = CGAffineTransformIdentity;
        [self.arrowImage setFrame:CGRectMake(self.selectedView.center.x, self.selectedView.center.y - 36.0f, panDistance, 72.0f)];
        self.arrowImage.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
    }
}

- (void)updateSelection:(BOOL)autoCenter
{
    self.arrowImage.hidden = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.selectedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7f, 0.7f);
    } completion:^(BOOL finished) {
        self.selectedView.hidden = YES;
        if (self.mapDatasource.selectedIndexPath)
        {
            MapCell *cell = (MapCell *)[self.mapCollection cellForItemAtIndexPath:self.mapDatasource.selectedIndexPath];
            self.selectedView.center = cell.center;
            self.selectedViewLabel.text = cell.indexLabel.text;
            self.selectedView.hidden = NO;
            [UIView animateWithDuration:0.2f animations:^{
                self.selectedView.transform = CGAffineTransformIdentity;
            }];
        }
    }];
    
    if (autoCenter)
        [self moveToSelected:nil];
}

#pragma mark - Properties & inner method

- (void)setShouldShowPanel:(BOOL)shouldShowPanel
{
    if (_shouldShowPanel == shouldShowPanel)
        return;
    _shouldShowPanel = shouldShowPanel;
    
    [self switchPanelShowInfo:shouldShowPanel
                   showHeader:YES
                     showFunc:YES
                       inSize:CGSizeMake(kScreenWidth, kScreenHeight)
                   completion:^(BOOL finished) {
        self.showPanel = shouldShowPanel;
    }];
}

- (void)updateInfoPanelContent
{
    if (self.mapDatasource.selectedIndexPath == nil)
        return;
    [self.infoTitle setTitle:[NSString stringWithFormat:@"%02ld - %02ld",
                              (long)(self.mapDatasource.selectedIndexPath.row / MAP_COLS),
                              (long)(self.mapDatasource.selectedIndexPath.row % MAP_COLS)]
                    forState:UIControlStateNormal];
}

- (void)updatePanelSize:(CGSize)size
{
    const CGFloat headHeight = 44.0f;
    const CGFloat barHeight = 60.0f;
    CGFloat topFix = self.topLayoutGuide.length;
    CGFloat botFix = self.bottomLayoutGuide.length;
    
    // 计算旋转后的面板尺寸
    self.infoPanelWidth.constant = (size.width < size.height) ? size.width : barHeight + botFix;
    self.infoPanelHeight.constant = (size.width < size.height) ? barHeight + botFix : size.height;
    self.infoSpliteWidth.constant = (size.width < size.height) ? size.width : 0.5f;
    self.infoSpliteHeight.constant = (size.width < size.height) ? 0.5f : size.height;
    
    self.operationLeading.constant = (size.width < size.height) ? 0.0f : botFix;
    self.operationBottom.constant = (size.width < size.height) ? botFix : 0.0f;
    
    self.headPanelHeight.constant = headHeight + topFix;
    
    ActionLayout *layout = (ActionLayout *)self.operationCollection.collectionViewLayout;
    layout.inLandMode = (size.width > size.height);
}

- (void)rotateInfoPanelToSize:(CGSize)size
{
    [self updatePanelSize:size];
    if (self.shouldShowPanel)
    {
        if (self.showPanel)
        {
            [self switchPanelShowInfo:NO showHeader:NO showFunc:NO inSize:size completion:^(BOOL finished) {
                if (!finished) return;
                self.showPanel = NO;
                [self switchPanelShowInfo:YES showHeader:YES showFunc:YES inSize:size completion:^(BOOL finished) {
                    if (!finished) return;
                    self.showPanel = YES;
                }];
            }];
        }
        else
        {
            [self switchPanelShowInfo:YES showHeader:YES showFunc:YES inSize:size completion:^(BOOL finished) {
                if (!finished) return;
                self.showPanel = YES;
            }];
        }
    }
    else
    {
        [self switchPanelShowInfo:NO showHeader:YES showFunc:YES inSize:size completion:^(BOOL finished) {
            if (!finished) return;
            self.showPanel = NO;
        }];
    }
}

- (void)switchPanelShowInfo:(BOOL)showInfo
                 showHeader:(BOOL)showHeader
                   showFunc:(BOOL)showFunc
                     inSize:(CGSize)size
                 completion:(void (^)(BOOL finished))completion
{
    if (self.mapDatasource.selectedIndexPath == nil)
        showInfo = NO;
    
    BOOL inLandMode = size.width > size.height;
    if (inLandMode)
        showHeader = NO;
    
    // 根据显隐要求初始化状态
    if (showInfo)
        [self updateInfoPanelContent];
    
    // 动画移动
    [UIView animateWithDuration:0.3f animations:^{
        if (size.width < size.height)
            self.infoPanel.transform = showInfo
                ? CGAffineTransformIdentity
                : CGAffineTransformTranslate(CGAffineTransformIdentity, 0, self.infoPanel.frame.size.height);
        else
            self.infoPanel.transform = showInfo
                ? CGAffineTransformIdentity
                : CGAffineTransformTranslate(CGAffineTransformIdentity, -self.infoPanel.frame.size.width, 0);
    } completion:completion];
    
    // 标题栏显隐
    [UIView animateWithDuration:0.3f animations:^{
            self.headPanel.transform = showHeader
                ? CGAffineTransformIdentity
                : CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -self.headPanel.frame.size.height);
    }];

    // 功能按钮显隐
    self.enterFloatButton.hidden = !inLandMode;
    self.helpFloatButton.hidden = !inLandMode;
    [UIView animateWithDuration:0.3f animations:^{
        self.enterFloatButton.transform = showFunc ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 60, 0);
        self.helpFloatButton.transform = showFunc ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 60, 0);
    }];
}

- (void)showOperator:(FrameController *)controller withType:(NSInteger)opType
{
//  self.operationLayer.alpha = 0.0f;
//  self.operationLayer.hidden = NO;
//  [UIView animateWithDuration:0.5f animations:^{
//      self.operationLayer.alpha = 1.0f;
//  } completion:^(BOOL finished) {
//      [self.opearationController scrollToIndex:19];
//  }];
}

- (void)showZoneInformation:(FrameController *)controller withX:(NSInteger)x withY:(NSInteger)y
{
//    [self performSegueWithIdentifier:@"showZone" sender:controller];
}

#pragma mark - Action collectionView Datasource & Delegate

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
