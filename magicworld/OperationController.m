//
//  OperationController.m
//  magicworld
//
//  Created by 苏智 on 16/4/21.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "OperationController.h"
#import "PaddingCell.h"
#import "OperationCell.h"

@interface OperationController () <UITableViewDelegate, UITableViewDataSource>

// 操作用控件
@property (strong, nonatomic) IBOutlet UIButton *backFloatButton;
@property (strong, nonatomic) IBOutlet UIButton *bagFloatButton;
@property (strong, nonatomic) IBOutlet UITableView *operationTable;

// 记录选择
@property (assign, nonatomic) NSInteger lastSelectedIndexBeforeDrag;
@property (assign, nonatomic) BOOL autoSelectMode;
@property (retain, nonatomic) OperationCell *selectedCell;

// 布局相关属性
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableHeight;
@property (assign, nonatomic) BOOL inLandMode;

@end

@implementation OperationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化布局
    self.tableWidth.constant = kScreenWidth;
    self.tableHeight.constant = kScreenHeight;
    self.operationTable.transform = CGAffineTransformIdentity;

    self.backFloatButton.hidden = YES;
    self.backFloatButton.layer.cornerRadius = 25.0f;
    self.backFloatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.backFloatButton.layer.borderWidth = 1.0f;
    
    self.bagFloatButton.hidden = YES;
    self.bagFloatButton.layer.cornerRadius = 25.0f;
    self.bagFloatButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.bagFloatButton.layer.borderWidth = 1.0f;

    // 创建测试用数据
    [self setupTestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.inLandMode = kScreenWidth > kScreenHeight;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 初始化选择索引
    _selectedIndex = NSNotFound;
    self.selectedIndex = 0;
    
    // 自动选择模式初始化时选择第一条
    self.autoSelectMode = YES;
    self.selectedCell = [self.operationTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    self.selectedCell.selected = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (size.width < size.height)
    {
        self.inLandMode = NO;
        self.tableWidth.constant = size.width;
        self.tableHeight.constant = size.height;
    }
    else
    {
        self.inLandMode = YES;
        self.tableWidth.constant = size.height;
        self.tableHeight.constant = size.width;
    }
}

#pragma mark - Test Data Setup

- (void)setupTestData
{
    for (int i = 0; i < 20; i++)
        [self.operationArray addObject:[self getRamdomImageName]];
}

- (NSString *)getRamdomImageName
{
    NSArray *imageNameArray = @[@"C_001_0001", @"C_001_0002", @"C_001_0003", @"C_001_0003",
                                @"C_001_0005", @"C_001_0006", @"C_001_0007", @"C_001_0017",
                                @"C_001_0018", @"C_001_0019", @"C_001_0020", @"C_001_0016",
                                @"C_001_0013", @"C_001_0014", @"C_001_0015", @"C_001_0016",
                                @"C_001_0017", @"C_001_0018", @"C_001_0019", @"C_001_0020"];
    int index = arc4random() % 20;
    return imageNameArray[index];
}

#pragma mark - Properties process

// 显示或隐藏功能层
- (void)showFunctions:(BOOL)show animated:(BOOL)animated inLandMode:(BOOL)inLandMode
{
    // 系统状态栏和导航在横屏时不显示，竖屏时根据show来决定显隐，并套用是否动画演示效果
    [[UIApplication sharedApplication] setStatusBarHidden:(inLandMode || !show)];
    [self.navigationController setNavigationBarHidden:(inLandMode || !show) animated:animated];
    
    // 浮动工具栏在竖屏时不显示，横屏总是显示（但会以动画方式进入／离开屏幕区域）
    self.backFloatButton.hidden = !inLandMode;
    self.bagFloatButton.hidden = !inLandMode;
    [UIView animateWithDuration:(animated ? 0.5f : 0.0f) animations:^{
        self.backFloatButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, -60, 0);
        self.bagFloatButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 60, 0);
    }];
}

- (void)setInLandMode:(BOOL)inLandMode
{
    if (_inLandMode == inLandMode)
        return;
    _inLandMode = inLandMode;

    [self showFunctions:YES animated:NO inLandMode:inLandMode];
    
    if (inLandMode)
    {
        self.tableWidth.constant = kScreenHeight;
        self.tableHeight.constant = kScreenWidth;
        self.operationTable.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    }
    else
    {
        self.tableWidth.constant = kScreenWidth;
        self.tableHeight.constant = kScreenHeight;
        self.operationTable.transform = CGAffineTransformIdentity;
    }
    self.selectedCell.inLandMode = inLandMode;
}

- (NSMutableArray *)operationArray
{
    if (_operationArray == nil)
        _operationArray = [NSMutableArray arrayWithCapacity:20];
    return _operationArray;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    // 不处理同索引设置
    if (_selectedIndex == selectedIndex)
        return;
    
    NSMutableArray *updateIndexes = [NSMutableArray arrayWithCapacity:2];

    // 处理旧索引
    if (_selectedIndex != NSNotFound)
    {
        NSIndexPath *indexUnsel = [NSIndexPath indexPathForRow:_selectedIndex inSection:1];
        [updateIndexes addObject:indexUnsel];
        if (self.selectedCell != nil)
            self.selectedCell.selected = NO;
    }
    
    _selectedIndex = selectedIndex;
    
    // 处理新索引
    if (_selectedIndex != NSNotFound)
    {
        NSIndexPath *indexTosel = [NSIndexPath indexPathForRow:_selectedIndex inSection:1];
        [updateIndexes addObject:indexTosel];

        // 执行动画切换
        [self.operationTable reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
        self.selectedCell = [self.operationTable cellForRowAtIndexPath:indexTosel];
        self.selectedCell.selected = YES;
    }
    else
    {
        self.selectedCell = nil;
        // 执行动画切换
        [self.operationTable reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)scrollTableAtRow:(NSInteger)selectedRow
{
    NSInteger section = selectedRow < 2 ? 0 : 1;
    NSInteger row = selectedRow < 2 ? selectedRow : selectedRow - 2;
    [self.operationTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                               atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Operation

- (void)scrollToIndex:(NSInteger)index
{
    if (index >= 0 && index < self.operationArray.count)
    {
        self.selectedIndex = index;
        [self scrollTableAtRow:index];
    }
}

- (IBAction)closeOperation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView datasource & delegate

// 表格区数量为3个，一个前导区一个结尾区再加一个内容区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

// 表格每个区项目行数，前导和结尾区都是2行，内容区根据数量来定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 2)
        return 2;
    return self.operationArray.count;
}

// 单元格进行订制
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 2)
        return [tableView dequeueReusableCellWithIdentifier:@"paddingCell"];

    OperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"operationCell"];
    cell.cardImage.image = [UIImage imageNamed:self.operationArray[indexPath.row]];
    cell.inLandMode = self.inLandMode;
    return cell;
}

// 行高计算
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat referLength = (self.inLandMode ? kScreenWidth : kScreenHeight);
    
    if (indexPath.section == 0 || indexPath.section == 2)
        return referLength / 10;
    
    return (self.selectedIndex == indexPath.row) ? referLength * 6 / 10 : referLength / 10;
}

// 区间隔头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

// 区间隔尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

// 点选操作会计算选择索引
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showFunctions:NO animated:YES inLandMode:self.inLandMode];

    if (indexPath.section == 1)
    {
        // 点选操作会暂时取消自动选择功能
        self.autoSelectMode = NO;
        self.selectedIndex = indexPath.row;
        [self scrollTableAtRow:indexPath.row];
    }
}

// 准备开始拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // NSLog(@"in Will Begin Dragging");
    [self showFunctions:NO animated:YES inLandMode:self.inLandMode];
    self.lastSelectedIndexBeforeDrag = self.selectedIndex;
}

// 当滚动将要进入减速效果的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    // NSLog(@"in Will Begin Decelerating");
    if (self.autoSelectMode == YES && self.selectedIndex != NSNotFound)
        [self scrollTableAtRow:self.selectedIndex];
}

// 当滚动减速结束的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // NSLog(@"in Did End Decelerating");
    if (self.autoSelectMode == YES && self.selectedIndex != NSNotFound)
        [self scrollTableAtRow:self.selectedIndex];
}

// 当拖动结束的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // NSLog(@"in Did End Dragging");
    [self showFunctions:YES animated:YES inLandMode:self.inLandMode];
    if (self.selectedIndex != NSNotFound && !decelerate)
        [self scrollTableAtRow:self.selectedIndex];
}

// 滚动动画结束后重置自动滚动标记（无论是什么原因结束了滚动）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // NSLog(@"in Did End Animation");
    if (self.autoSelectMode == NO)
        self.autoSelectMode = YES;
}

// 滚动的过程中不断的计算当前自动选择的索引数值
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.autoSelectMode == YES)
    {
        CGFloat referLength = (self.inLandMode ? kScreenWidth : kScreenHeight);
        CGFloat rowHeight = referLength / 10;
        NSInteger autoSelectRow = (scrollView.contentOffset.y + rowHeight / 2) / rowHeight;
        
        if (autoSelectRow < 0) autoSelectRow = 0;
        if (self.operationArray.count > 0 && autoSelectRow >= self.operationArray.count)
            autoSelectRow = self.operationArray.count - 1;
        
        // NSLog(@"Y偏移 %f, 选中行 %ld", scrollView.contentOffset.y, (long)autoSelectRow);
        self.selectedIndex = autoSelectRow;
    }
}

@end
