//
//  MapController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "MapController.h"
#import "MapDatasource.h"

@interface MapController () <UICollectionViewDelegate>

@property (assign, nonatomic) CGPoint lastOffset;
@property (assign, nonatomic) BOOL autoChangedNeeded;

@end

@implementation MapController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark - UICollectionView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.autoChangedNeeded == NO)
        [self recalculateSections:scrollView.contentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSLog(@"STOP ANIMATION...");
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        });
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

@end
