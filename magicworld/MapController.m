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
@property (assign, nonatomic) BOOL autoChangedNeeded;
@property (assign, nonatomic) BOOL showPanel;
@property (assign, nonatomic) BOOL showPanelLight;

@property (strong, nonatomic) IBOutlet UIView *infoPanel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoPanelHeight;

@property (retain, nonatomic) MapDatasource *datasource;
@property (retain, nonatomic) NSIndexPath *selectedIndexPath;
@property (retain, nonatomic) NSMutableArray *selectedParaCells;

@end

@implementation MapController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:(kScreenWidth > kScreenHeight)];
    
    // 初始化infoPanel
    self.infoPanel.hidden = YES;
    NSLayoutConstraint *animateConstraint = (kScreenWidth < kScreenHeight) ? self.infoPanelBottom : self.infoPanelLeading;
    CGFloat animateLength = (kScreenWidth < kScreenHeight) ? self.infoPanelHeight.constant : self.infoPanelWidth.constant;
    animateConstraint.constant = animateLength;
    self.showPanel = NO;
    self.showPanelLight = NO;
    
    self.datasource = (MapDatasource *)self.mapCollection.dataSource;
    self.datasource.selectedRowIndex = NSNotFound;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.autoChangedNeeded = NO;
    self.lastOffset = self.mapCollection.contentOffset;
    [self recalculateSections:self.mapCollection.contentOffset];
    self.infoPanelWidth.constant = (kScreenWidth < kScreenHeight) ? kScreenWidth : kScreenWidth / 9 * 2;
    self.infoPanelHeight.constant = (kScreenWidth < kScreenHeight) ? kScreenHeight / 9 * 2: kScreenHeight;
}

- (void)rotateMapToSize:(CGSize)size
{
    // 屏幕旋转时交换x, y偏移量即可
    self.autoChangedNeeded = YES;
    [self.mapCollection scrollRectToVisible:CGRectMake(_lastOffset.y, _lastOffset.x,
                                                       self.mapCollection.frame.size.width,
                                                       self.mapCollection.frame.size.height)
                                   animated:NO];
    self.autoChangedNeeded = NO;
    
    self.infoPanelWidth.constant = (size.width < size.height) ? size.width : size.width / 9 * 2;
    self.infoPanelHeight.constant = (size.width < size.height) ? size.height / 9 * 2: size.height;
}

- (void)recalculateSections:(CGPoint)offset
{
    BOOL xDirectionRight = self.lastOffset.x < offset.x;
    BOOL yDirectionDown = self.lastOffset.y < offset.y;
    CGPoint newOffset = CGPointMake(offset.x, offset.y);
    self.autoChangedNeeded = NO;
    
    if (offset.x < MAP_COLS * MAP_WIDTH / 3 && xDirectionRight == NO)
    {
        self.autoChangedNeeded = YES;
        newOffset.x = offset.x + MAP_COLS * MAP_WIDTH;
    }
    else if (offset.x > MAP_COLS * MAP_WIDTH * 1.3 && xDirectionRight == YES)
    {
        self.autoChangedNeeded = YES;
        newOffset.x = offset.x - MAP_COLS * MAP_WIDTH;
    }
    
    if (offset.y < MAP_ROWS * MAP_HEIGHT / 3 && yDirectionDown == NO)
    {
        self.autoChangedNeeded = YES;
        newOffset.y = offset.y + MAP_ROWS * MAP_HEIGHT;
    }
    else if (offset.y > MAP_ROWS * MAP_HEIGHT * 1.3 && yDirectionDown == YES)
    {
        self.autoChangedNeeded = YES;
        newOffset.y = offset.y - MAP_ROWS * MAP_HEIGHT + self.mapCollection.contentInset.top;
    }
    
    if (self.autoChangedNeeded == YES)
    {
        [self.mapCollection scrollRectToVisible:CGRectMake(newOffset.x, newOffset.y,
                                                           self.mapCollection.frame.size.width,
                                                           self.mapCollection.frame.size.height)
                                       animated:NO];
        // NSLog(@"Auto Changed Occured....");
        self.autoChangedNeeded = NO;
    }
    self.lastOffset = newOffset;
}

- (void)setLastOffset:(CGPoint)lastOffset
{
    if (_lastOffset.x == lastOffset.x && _lastOffset.y == lastOffset.y)
        return;
    _lastOffset.x = lastOffset.x;
    _lastOffset.y = lastOffset.y;
    
//    NSInteger irow = (self.lastOffset.y + kScreenHeight / 2) / MAP_HEIGHT;
//    NSInteger icol = (self.lastOffset.x + kScreenWidth / 2) / MAP_WIDTH;
//    
//    NSInteger section = 0;
//    section += (icol >= MAP_COLS) ? 1 : 0;
//    section += (irow >= MAP_ROWS) ? 2 : 0;
    
//    self.centerIndexPath = [NSIndexPath indexPathForRow:(irow % MAP_ROWS) * MAP_COLS + (icol % MAP_COLS) inSection:section];
//    MapCell *cell = (MapCell*)[self.mapCollection cellForItemAtIndexPath:self.centerIndexPath];
//    NSLog(@"Current last Offset is : %f, %f", _lastOffset.x, _lastOffset.y);
//    NSLog(@"Current indexPath.row = %d, indexPath.section = %d", self.centerIndexPath.row, self.centerIndexPath.section);
//    NSLog(@"Current irow = %d, icol = %d, section = %d", irow, icol, section);
//    NSLog(@"Center label is : %@", cell.indexLabel.text);
}

- (void)setShowPanel:(BOOL)showPanel
{
    if (_showPanel == showPanel)
        return;
    _showPanel = showPanel;

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
    [self.infoPanel setFrame:showPanel ? hideRect : showRect];
    [UIView animateWithDuration:0.2f animations:^{
        // 经过动画后达到的目的状态
        [self.infoPanel setFrame:showPanel ? showRect : hideRect];
    } completion:^(BOOL finished) {
        // 非动画达到的目的状态
        if (finished)
        {
            animateConstraint.constant = showPanel ? 0 : -animateLength;
            self.infoPanel.hidden = !showPanel;
        }
    }];
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
        [self.selectedParaCells removeAllObjects];
        _selectedParaCells = nil;
        self.showPanel = NO;
        self.datasource.selectedRowIndex = NSNotFound;
    }
    // 重复一个索引会反选
    else if (_selectedIndexPath != nil && _selectedIndexPath.row == selectedIndexPath.row)
    {
        [self.selectedParaCells removeAllObjects];
        _selectedIndexPath = nil;
        self.showPanel = NO;
        self.datasource.selectedRowIndex = NSNotFound;
    }
    // 选择一个不同的索引
    else
    {
        [self.selectedParaCells removeAllObjects];
        _selectedIndexPath = selectedIndexPath;
        self.showPanel = YES;
        self.datasource.selectedRowIndex = selectedIndexPath.row;
    }
    [self.mapCollection reloadData];
}

- (NSMutableArray *)selectedParaCells
{
    if (_selectedParaCells == nil)
    {
        _selectedParaCells = [NSMutableArray arrayWithCapacity:4];
    }
    return _selectedParaCells;
}

#pragma mark - UICollectionView / UIScrollView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.autoChangedNeeded == NO)
        [self recalculateSections:scrollView.contentOffset];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
