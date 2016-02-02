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

@interface MapController () <UICollectionViewDelegate>

@property (assign, nonatomic) CGPoint lastOffset;
@property (assign, nonatomic) BOOL dontRecalOffset;
@property (assign, nonatomic) BOOL showPanel;
@property (assign, nonatomic) BOOL showPanelLight;

@property (strong, nonatomic) IBOutlet UIView *infoPanel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelHeight;
@property (strong, nonatomic) IBOutlet UIButton *infoTitle;

@property (retain, nonatomic) MapDatasource *datasource;
@property (retain, nonatomic) NSIndexPath *selectedIndexPath;
@property (retain, nonatomic) NSIndexPath *autoCenterIndexPath;

@end

@implementation MapController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lastOffset = self.mapCollection.contentOffset;
    self.dontRecalOffset = NO;
    self.stopAutoMoveCenter = NO;
    
    // 初始化infoPanel
    self.infoPanel.hidden = YES;
    NSLayoutConstraint *animateConstraint = (kScreenWidth < kScreenHeight) ? self.infoPanelBottom : self.infoPanelLeading;
    CGFloat animateLength = (kScreenWidth < kScreenHeight) ? self.infoPanelHeight.constant : self.infoPanelWidth.constant;
    animateConstraint.constant = -animateLength;
    self.showPanel = NO;
    self.showPanelLight = NO;

    // 关联datasource对象
    self.datasource = (MapDatasource *)self.mapCollection.dataSource;
    self.datasource.selectedRowIndex = NSNotFound;
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
    
    [self recalculateSections:self.mapCollection.contentOffset];

    self.infoPanelWidth.constant = (kScreenWidth < kScreenHeight) ? kScreenWidth : kScreenWidth / 9 * 1.5;
    self.infoPanelHeight.constant = (kScreenWidth < kScreenHeight) ? kScreenHeight / 9 * 1.5: kScreenHeight;
    
    if (self.stopAutoMoveCenter == YES)
        self.stopAutoMoveCenter = NO;
    else
    {
        self.dontRecalOffset = YES;
        [self.mapCollection scrollToItemAtIndexPath:self.autoCenterIndexPath
                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                                           animated:NO];
        self.dontRecalOffset = NO;
    }
}

#pragma mark - Private functions

- (IBAction)moveToSelected:(id)sender
{
    if (self.selectedIndexPath == nil)
        return;
    
    self.dontRecalOffset = YES;
    [self.mapCollection scrollToItemAtIndexPath:self.selectedIndexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                                   animated:YES];
}

- (void)setupInfoPanelData
{
    MapCell *cell = (MapCell*)[self.mapCollection cellForItemAtIndexPath:self.selectedIndexPath];
    [self.infoTitle setTitle:cell.indexLabel.text forState:UIControlStateNormal];
}

- (void)rotateMapToSize:(CGSize)size
{
    // 计算旋转后的面板尺寸和根据显隐调整控制方式
    self.infoPanelWidth.constant = (size.width < size.height) ? size.width : size.width / 9 * 2;
    self.infoPanelHeight.constant = (size.width < size.height) ? size.height / 9 * 2: size.height;
    
    if (size.width < size.height)
    {
        self.infoPanelBottom.constant = self.showPanel ? 0 : -self.infoPanelHeight.constant;
        self.infoPanelLeading.constant = 0;
    }
    else
    {
        self.infoPanelBottom.constant = 0;
        self.infoPanelLeading.constant = self.showPanel ? 0 : -self.infoPanelWidth.constant;
    }
}

- (void)recalculateSections:(CGPoint)offset
{
    BOOL xDirectionRight = self.lastOffset.x < offset.x;
    BOOL yDirectionDown = self.lastOffset.y < offset.y;
    CGPoint newOffset = CGPointMake(offset.x, offset.y);
    self.dontRecalOffset = NO;
    
    if (offset.x < MAP_COLS * MAP_WIDTH / 3 && xDirectionRight == NO)
    {
        self.dontRecalOffset = YES;
        newOffset.x = offset.x + MAP_COLS * MAP_WIDTH;
        NSLog(@">>>>>> Auto Moved Right....");
    }
    else if (offset.x > MAP_COLS * MAP_WIDTH * 1.67 && xDirectionRight == YES)
    {
        self.dontRecalOffset = YES;
        newOffset.x = offset.x - MAP_COLS * MAP_WIDTH;
        NSLog(@"<<<<<< Auto Moved Left....");
    }
    
    if (offset.y < MAP_ROWS * MAP_HEIGHT / 3 && yDirectionDown == NO)
    {
        self.dontRecalOffset = YES;
        newOffset.y = offset.y + MAP_ROWS * MAP_HEIGHT;
        NSLog(@"vvvvvv Auto Moved Down....");
    }
    else if (offset.y > MAP_ROWS * MAP_HEIGHT * 1.67 && yDirectionDown == YES)
    {
        self.dontRecalOffset = YES;
        newOffset.y = offset.y - MAP_ROWS * MAP_HEIGHT;
        NSLog(@"^^^^^^ Auto Moved Up....");
    }
    
    if (self.dontRecalOffset == YES)
    {
        [self.mapCollection scrollRectToVisible:CGRectMake(newOffset.x, newOffset.y,
                                                           self.mapCollection.frame.size.width,
                                                           self.mapCollection.frame.size.height)
                                       animated:NO];
        [self calCenterIndexPath];
        self.dontRecalOffset = NO;
    }
    self.lastOffset = newOffset;
}

- (void)infoPanelToShow:(BOOL)show completion:(void (^ __nullable)(BOOL finished))completion
{
    // 根据屏幕横竖状态来定义将要改变的constraint，动画距离以及显隐位置
    NSLayoutConstraint *animateConstraint = (kScreenWidth < kScreenHeight) ? self.infoPanelBottom : self.infoPanelLeading;
    CGFloat animateLength = (kScreenWidth < kScreenHeight) ? self.infoPanelHeight.constant : self.infoPanelWidth.constant;
    CGRect showRect = (kScreenWidth < kScreenHeight) ?
        CGRectMake(0, kScreenHeight - animateLength, kScreenWidth, animateLength) :
        CGRectMake(0, 0, animateLength, kScreenHeight);
    CGRect hideRect = (kScreenWidth < kScreenHeight) ?
        CGRectMake(0, kScreenHeight, kScreenWidth, animateLength) :
        CGRectMake(-animateLength, 0, animateLength, kScreenHeight);
    
    // 根据显隐要求初始化状态
    self.infoPanel.hidden = NO;
    [self.infoPanel setFrame:show ? hideRect : showRect];
    if (show) [self setupInfoPanelData];
    if (completion == nil)
    {
        [UIView animateWithDuration:0.2f animations:^{
            // 经过动画后达到的目的状态
            [self.infoPanel setFrame:show ? showRect : hideRect];
        } completion:^(BOOL finished) {
            // 非动画达到的目的状态
            if (finished)
            {
                animateConstraint.constant = show ? 0 : -animateLength;
                self.infoPanel.hidden = !show;
            }
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            // 经过动画后达到的目的状态
            [self.infoPanel setFrame:show ? showRect : hideRect];
        } completion:completion];
    }
}

- (void)calCenterIndexPath
{
    // 根据偏移量计算可能显示的所有格子的横竖索引的起始
    NSInteger row_c = ((self.lastOffset.y + kScreenHeight / 2.0f) / MAP_HEIGHT);
    NSInteger col_c = ((self.lastOffset.x + kScreenWidth / 2.0f) / MAP_WIDTH);
    
    NSInteger section = 0;
    section += (col_c >= MAP_COLS) ? 1 : 0;
    section += (row_c >= MAP_ROWS) ? 2 : 0;
    
    self.autoCenterIndexPath = [NSIndexPath indexPathForItem:(row_c % MAP_ROWS) * MAP_COLS + (col_c % MAP_COLS)
                                                   inSection:section];
}

#pragma mark - Properties settings

- (void)setLastOffset:(CGPoint)lastOffset
{
    if (_lastOffset.x == lastOffset.x && _lastOffset.y == lastOffset.y)
        return;
    _lastOffset.x = lastOffset.x;
    _lastOffset.y = lastOffset.y;
}

- (void)setShowPanel:(BOOL)showPanel
{
    if (_showPanel == showPanel)
        return;
    _showPanel = showPanel;

    [self infoPanelToShow:showPanel completion:nil];
}

- (void)setShowPanelLight:(BOOL)showPanelLight
{
    if (_showPanelLight == showPanelLight)
        return;
    _showPanelLight = showPanelLight;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.infoPanel.alpha = showPanelLight ? 0.3f : 1.0f;
    }];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    // 选择空
    if (selectedIndexPath == nil)
    {
        _selectedIndexPath = nil;
        self.showPanel = NO;
        self.datasource.selectedRowIndex = NSNotFound;
    }
    // 重复一个索引会反选
    else if (_selectedIndexPath != nil && _selectedIndexPath.row == selectedIndexPath.row)
    {
        _selectedIndexPath = nil;
        self.showPanel = NO;
        self.datasource.selectedRowIndex = NSNotFound;
    }
    // 选择一个不同的索引
    else
    {
        if (_selectedIndexPath == nil)
        {
            _selectedIndexPath = selectedIndexPath;
            self.showPanel = YES;
        }
        else
        {
            [self infoPanelToShow:NO completion:^(BOOL finished) {
                _selectedIndexPath = selectedIndexPath;
                [self infoPanelToShow:YES completion:nil];
            }];
        }
        self.datasource.selectedRowIndex = selectedIndexPath.row;
    }
    [self.mapCollection reloadData];
}

#pragma mark - UICollectionView / UIScrollView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.dontRecalOffset = NO;
    [self recalculateSections:scrollView.contentOffset];
    [self calCenterIndexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.dontRecalOffset == NO)
    {
        [self recalculateSections:scrollView.contentOffset];
        [self calCenterIndexPath];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(endDrag:)])
        [self.delegate endDrag:self];

    self.showPanelLight = NO;;
    
    if (decelerate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSLog(@"STOP ANIMATION...");
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        });
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(startDrag:)])
        [self.delegate startDrag:self];
   
    self.showPanelLight = YES;;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
