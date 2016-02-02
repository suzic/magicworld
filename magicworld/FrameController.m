//
//  FrameController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "FrameController.h"
#import "MapController.h"

@interface FrameController () <MapControllerDelegate>

@property (retain, nonatomic) MapController *mapController;

@end

@implementation FrameController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:(kScreenWidth > kScreenHeight)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.navigationController setNavigationBarHidden:(size.width > size.height)];
    [self.mapController rotateMapToSize:size];
}

#pragma makr - MapController Delegate

- (void)startDrag:(MapController *)controller
{
    controller.stopAutoMoveCenter = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)endDrag:(MapController *)controller
{
    controller.stopAutoMoveCenter = YES;
    [self.navigationController setNavigationBarHidden:(kScreenWidth > kScreenHeight) animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapSegue"])
    {
        self.mapController = (MapController *)[segue destinationViewController];
        self.mapController.delegate = self;
    }
}

@end
