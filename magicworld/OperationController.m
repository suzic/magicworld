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

@property (strong, nonatomic) IBOutlet UITableView *operationTable;
@property (assign, nonatomic) BOOL autoSelectMode;

@end

@implementation OperationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.autoSelectMode = YES;

    _selectedIndex = NSNotFound;
    self.selectedIndex = 0;
    [self.operationTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].selected = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)operationArray
{
    if (_operationArray == nil)
        _operationArray = [NSMutableArray arrayWithCapacity:20];
    return _operationArray;
}

- (void)setupTestData
{
    for (int i = 0; i < 20; i++)
        [self.operationArray addObject:[self getRamdomImageName]];
}

- (NSString *)getRamdomImageName
{
    NSArray *imageNameArray = @[@"C_001_0001", @"C_001_0002", @"C_001_0003", @"C_001_0004",
                                @"C_001_0005", @"C_001_0006", @"C_001_0007", @"C_001_0008",
                                @"C_001_0009", @"C_001_0010", @"C_001_0011", @"C_001_0012",
                                @"C_001_0013", @"C_001_0014", @"C_001_0015", @"C_001_0016",
                                @"C_001_0017"];
    int index = arc4random() % 17;
    return imageNameArray[index];
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
        [self.operationTable cellForRowAtIndexPath:indexUnsel].selected = NO;
    }
    
    _selectedIndex = selectedIndex;
    
    // 处理新索引
    if (_selectedIndex != NSNotFound)
    {
        NSIndexPath *indexTosel = [NSIndexPath indexPathForRow:_selectedIndex inSection:1];
        [updateIndexes addObject:indexTosel];

        // 执行动画切换
        [self.operationTable reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.operationTable cellForRowAtIndexPath:indexTosel].selected = YES;
    }
    else
    {
        // 执行动画切换
        [self.operationTable reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)scrollToIndex:(NSInteger)index
{
    if (index >= 0 && index < self.operationArray.count)
    {
        self.selectedIndex = index;
        [self scrollTableAtRow:index];
    }
}

- (void)scrollTableAtRow:(NSInteger)selectedRow
{
    NSInteger section = selectedRow < 2 ? 0 : 1;
    NSInteger row = selectedRow < 2 ? selectedRow : selectedRow - 2;
    [self.operationTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                               atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    return cell;
}

// 行高计算
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 2)
        return self.operationTable.frame.size.height / 8;
    
    return (self.selectedIndex == indexPath.row) ?
        self.operationTable.frame.size.height / 2 : self.operationTable.frame.size.height / 8;
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

// 点选操作会计算选择索引
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        // 点选操作会暂时取消自动选择功能
        self.autoSelectMode = NO;
        self.selectedIndex = indexPath.row;
        [self scrollTableAtRow:indexPath.row];
    }
}

// 当滚动将要进入减速效果的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"in Will Begin Decelerating");
    if (self.autoSelectMode == YES && self.selectedIndex != NSNotFound)
        [self scrollTableAtRow:self.selectedIndex];
}

// 当滚动减速结束的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"in Did End Decelerating");
    if (self.autoSelectMode == YES && self.selectedIndex != NSNotFound)
        [self scrollTableAtRow:self.selectedIndex];
}

// 当拖动结束的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"in Did End Dragging");
    if (self.selectedIndex != NSNotFound && !decelerate)
        [self scrollTableAtRow:self.selectedIndex];
}

// 滚动动画结束后重置自动滚动标记（无论是什么原因结束了滚动）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"in Did End Animation");
    if (self.autoSelectMode == NO)
        self.autoSelectMode = YES;
}

// 滚动的过程中不断的计算当前自动选择的索引数值
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.autoSelectMode == YES)
    {
        CGFloat rowHeight = self.operationTable.frame.size.height / 8;
        NSInteger autoSelectRow = (scrollView.contentOffset.y + rowHeight / 2) / rowHeight;
        
        if (autoSelectRow < 0) autoSelectRow = 0;
        if (self.operationArray.count > 0 && autoSelectRow >= self.operationArray.count)
            autoSelectRow = self.operationArray.count - 1;
        
        NSLog(@"Y偏移 %f, 选中行 %ld", scrollView.contentOffset.y, (long)autoSelectRow);
        self.selectedIndex = autoSelectRow;
    }
}


@end
