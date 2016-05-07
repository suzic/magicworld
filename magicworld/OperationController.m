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
@property (assign, nonatomic) BOOL autoScroll;
@property (assign, nonatomic) NSInteger delaySelectedIndex;

@end

@implementation OperationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.autoScroll = NO;
    self.delaySelectedIndex = NSNotFound;
        
    [self setupTestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.operationTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].selected = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)operationArray
{
    if (_operationArray == nil)
        _operationArray = [NSMutableArray arrayWithCapacity:10];
    return _operationArray;
}

- (void)setupTestData
{
    for (int i = 0; i < 20; i++)
        [self.operationArray addObject:[self getRamdomImageName]];
    _selectedIndex = NSNotFound;
    self.selectedIndex = 0;
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
    // 超出索引范围，或者索引未曾改变的情况下不予处理
    if (selectedIndex < 0 || selectedIndex >= self.operationArray.count || _selectedIndex == selectedIndex)
        return;
    NSMutableArray *updateIndexes = [NSMutableArray arrayWithCapacity:2];

    // 处理旧索引
    if (_selectedIndex != NSNotFound)
    {
        NSIndexPath *indexUnsel = [NSIndexPath indexPathForRow:_selectedIndex + 2 inSection:0];
        [updateIndexes addObject:indexUnsel];
        [self.operationTable cellForRowAtIndexPath:indexUnsel].selected = NO;
    }
    
    _selectedIndex = selectedIndex;
    
    // 处理新索引
    NSIndexPath *indexTosel = [NSIndexPath indexPathForRow:_selectedIndex + 2 inSection:0];
    [updateIndexes addObject:indexTosel];
    
    // 执行动画切换
    [self.operationTable reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.operationTable cellForRowAtIndexPath:indexTosel].selected = YES;
}

- (void)scrollToIndex:(NSInteger)index
{
    if (index >= 0 && index < self.operationArray.count)
    {
        self.delaySelectedIndex = index;
        self.autoScroll = YES; // 提示下面将进入自动滚动模式，滚动后需更新delaySelectedIndex到真正的selectedIndex里面
        [self.operationTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                   atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2 + self.operationArray.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 2 || indexPath.row >= self.operationArray.count + 2)
        return [tableView dequeueReusableCellWithIdentifier:@"paddingCell"];

    OperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"operationCell"];
    cell.cardImage.image = [UIImage imageNamed:self.operationArray[indexPath.row - 2]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row >= 2 && self.selectedIndex == (indexPath.row - 2) && indexPath.row < self.operationArray.count + 2) ?
        self.operationTable.frame.size.height / 2 : self.operationTable.frame.size.height / 8;
}

// 点选操作会计算选择索引
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 2 || indexPath.row >= self.operationArray.count + 2)
        return;
    
    // OperationCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
    [self scrollToIndex:indexPath.row - 2];
}

// 当滚动将要进入减速效果的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.autoScroll == YES) return;
    [self.operationTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]
                               atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

// 当滚动减速结束的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.autoScroll == YES) return;
    [self.operationTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]
                               atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

// 当拖动结束的时候强制执行滚动到索引的功能以中断不可控减速
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll == YES) return;
    if (!decelerate)
        [self.operationTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]
                                   atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

// 滚动动画结束后重置自动滚动标记（无论是什么原因结束了滚动）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.autoScroll == YES)
    {
        self.autoScroll = NO;
        if (self.delaySelectedIndex != NSNotFound)
        {
            self.selectedIndex = self.delaySelectedIndex;
            self.delaySelectedIndex = NSNotFound;
        }
    }
}

// 滚动的过程中不断的计算当前自动选择的索引数值
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.autoScroll == YES) return;
    
    NSInteger firstRow = ((scrollView.contentOffset.y + 1) * 8 / self.operationTable.frame.size.height);
    if (firstRow < 0) firstRow = 0;
    if (self.operationArray.count > 0)
    {
        NSLog(@"First Row is - %ld", firstRow);

//        OperationCell * cell = [self.operationTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
//        cell.taskContent.hidden = YES;
//        cell.taskAddress.hidden = YES;
//        cell.taskTime.hidden = YES;
        if (firstRow >= self.operationArray.count)
            firstRow = self.operationArray.count - 1;
//        OperationCell * newCell = [self.operationTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:firstRow + 2 inSection:0]];
//        newCell.taskContent.hidden = NO;
//        newCell.taskAddress.hidden = NO;
//        newCell.taskTime.hidden = NO;
        self.selectedIndex = firstRow;
    }
}

@end
