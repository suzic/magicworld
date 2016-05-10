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

@interface MapController () <UICollectionViewDataSource, UICollectionViewDelegate>

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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *operationTop;

@property (retain, nonatomic) MapDatasource *datasource;
@property (retain, nonatomic) NSIndexPath *selectedIndexPath;
@property (retain, nonatomic) NSIndexPath *autoCenterIndexPath;

@end

@implementation MapController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapCollection.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MAPBG"]];
    
    self.lastOffset = self.mapCollection.contentOffset;
    self.dontRecalOffset = NO;
    self.stopAutoMoveCenter = NO;
    
    // 初始化infoPanel
    self.showPanel = NO;
    self.showPanelLight = NO;
    [self initPanelSize:CGSizeMake(kScreenWidth, kScreenHeight)];

    // 关联datasource对象
    self.datasource = (MapDatasource *)self.mapCollection.dataSource;
    self.datasource.selectedRowIndex = NSNotFound;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
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
    
    //NSLog(@"Re layout....");
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
    // MapCell *cell = (MapCell*)[self.mapCollection cellForItemAtIndexPath:self.selectedIndexPath];
    [self.infoTitle setTitle:[NSString stringWithFormat:@"%02ld - %02ld", (long)(self.selectedIndexPath.row / MAP_COLS), (long)(self.selectedIndexPath.row % MAP_COLS)]
                    forState:UIControlStateNormal];
}

- (void)initPanelSize:(CGSize)size
{
    // 计算旋转后的面板尺寸
    self.infoPanelWidth.constant = (size.width < size.height) ? size.width : 80.0f;
    self.infoPanelHeight.constant = (size.width < size.height) ? 80.0f: size.height;
    
    if (size.width < size.height)
    {
        [self.infoPanel setFrame:CGRectMake(0, size.height, size.width, self.infoPanelHeight.constant)];
        self.infoPanelBottom.constant = -self.infoPanelHeight.constant;
        self.infoPanelLeading.constant = 0;
        self.operationLeading.constant = 80.0f;
        self.operationTop.constant = 4.0f;
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.operationCollection.collectionViewLayout;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    else
    {
        [self.infoPanel setFrame:CGRectMake(-self.infoPanelWidth.constant, 0, self.infoPanelWidth.constant, size.height)];
        self.infoPanelBottom.constant = 0;
        self.infoPanelLeading.constant = -self.infoPanelWidth.constant;
        self.operationLeading.constant = 4.0f;
        self.operationTop.constant = 80.0f;
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.operationCollection.collectionViewLayout;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    self.infoPanel.hidden = YES;
}

- (void)rotateMapToSize:(CGSize)size
{
    [self initPanelSize:size];
    if (self.showPanel)
    {
        [self infoPanelToShow:NO inSize:size completion:^(BOOL finished) {
            [self infoPanelToShow:YES inSize:size completion:nil];
        }];
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
//        if (_selectedIndexPath != nil)
//        {
//            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section - 1)];
//            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//        }
//        NSLog(@">>>>>> Auto Moved Right....");
    }
    else if (offset.x > MAP_COLS * MAP_WIDTH * 1.67 && xDirectionRight == YES)
    {
        self.dontRecalOffset = YES;
        newOffset.x = offset.x - MAP_COLS * MAP_WIDTH;
//        if (_selectedIndexPath != nil)
//        {
//            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section + 1)];
//            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//        }
//        NSLog(@"<<<<<< Auto Moved Left....");
    }
    
    if (offset.y < MAP_ROWS * MAP_HEIGHT / 3 && yDirectionDown == NO)
    {
        self.dontRecalOffset = YES;
        newOffset.y = offset.y + MAP_ROWS * MAP_HEIGHT;
//        if (_selectedIndexPath != nil)
//        {
//            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section - 2)];
//            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//        }
//        NSLog(@"vvvvvv Auto Moved Down....");
    }
    else if (offset.y > MAP_ROWS * MAP_HEIGHT * 1.67 && yDirectionDown == YES)
    {
        self.dontRecalOffset = YES;
        newOffset.y = offset.y - MAP_ROWS * MAP_HEIGHT;
//        if (_selectedIndexPath != nil)
//        {
//            NSLog(@"ORG r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//            _selectedIndexPath = [NSIndexPath indexPathForRow:_selectedIndexPath.row inSection:(_selectedIndexPath.section + 2)];
//            NSLog(@"NEW r = %ld, section = %ld", (long)_selectedIndexPath.row, (long)_selectedIndexPath.section);
//        }
//        NSLog(@"^^^^^^ Auto Moved Up....");
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

- (void)infoPanelToShow:(BOOL)show inSize:(CGSize)size completion:(void (^ __nullable)(BOOL finished))completion
{
    // 根据屏幕横竖状态来定义将要改变的constraint，动画距离以及显隐位置
    CGRect targetRect;
    if (size.width < size.height)
        targetRect = show ?
            CGRectMake(0, size.height - self.infoPanelHeight.constant, size.width, self.infoPanelHeight.constant)
            : CGRectMake(0, size.height, size.width, self.infoPanelHeight.constant);
    else
        targetRect = show ?
            CGRectMake(0, 0, self.infoPanelWidth.constant, size.height)
            : CGRectMake(-self.infoPanelWidth.constant, 0, self.infoPanelWidth.constant, size.height);
    
    // 根据显隐要求初始化状态
    if (show) [self setupInfoPanelData];
    
    self.infoPanel.hidden = NO;
    // 动画移动
    [UIView animateWithDuration:0.2f animations:^{
        [self.infoPanel setFrame:targetRect];
        if (size.width < size.height)
            self.infoPanelBottom.constant = show ? 0 : -self.infoPanelHeight.constant;
        else
            self.infoPanelLeading.constant = show ? 0 : -self.infoPanelWidth.constant;
    } completion:completion];
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

    [self infoPanelToShow:showPanel inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
        self.infoPanel.hidden = !showPanel;
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
            [self infoPanelToShow:NO inSize:CGSizeMake(kScreenWidth, kScreenHeight) completion:^(BOOL finished) {
                _selectedIndexPath = selectedIndexPath;
                [self infoPanelToShow:YES inSize:CGSizeMake(kScreenWidth, kScreenHeight)  completion:nil];
            }];
        }
        self.datasource.selectedRowIndex = selectedIndexPath.row;
    }
    [self.mapCollection reloadData];
}

#pragma mark - UICollectionView Datasource (For operator only)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    switch (indexPath.row)
    {
        case 0:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"action1" forIndexPath:indexPath];
            //cell.backgroundColor = [UIColor lightGrayColor];
            break;
        case 1:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"action2" forIndexPath:indexPath];
            //cell.backgroundColor = [UIColor lightGrayColor];
            break;
        case 2:
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"action3" forIndexPath:indexPath];
            //cell.backgroundColor = [UIColor lightGrayColor];
            break;
    }
    return cell;
}

#pragma mark - UICollectionView / UIScrollView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.mapCollection)
        self.selectedIndexPath = indexPath;
    else if (collectionView == self.operationCollection)
    {
        if ([self.delegate respondsToSelector:@selector(showOperator:withType:)])
            [self.delegate showOperator:self withType:0];
        if ([self.delegate respondsToSelector:@selector(showZoneInformation:withX:withY:)])
            [self.delegate showZoneInformation:self withX:0 withY:0];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.mapCollection)
    {
        self.dontRecalOffset = NO;
        [self recalculateSections:scrollView.contentOffset];
        [self calCenterIndexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.mapCollection)
    {
        if (self.dontRecalOffset == NO)
        {
            [self recalculateSections:scrollView.contentOffset];
            [self calCenterIndexPath];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.mapCollection)
    {
        if ([self.delegate respondsToSelector:@selector(endDrag:)])
            [self.delegate endDrag:self];
        
        if (self.selectedIndexPath != nil)
            self.showPanel = YES;
        // self.showPanelLight = NO;
        
        if (decelerate)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // NSLog(@"STOP ANIMATION...");
                [scrollView setContentOffset:scrollView.contentOffset animated:NO];
            });
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.mapCollection)
    {
        if ([self.delegate respondsToSelector:@selector(startDrag:)])
            [self.delegate startDrag:self];
        
        self.showPanel = NO;
        // self.showPanelLight = YES;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
