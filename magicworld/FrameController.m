//
//  FrameController.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "FrameController.h"
#import "MapController.h"
#import "OperationController.h"

@interface FrameController () <MapControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *mapLayer;
//@property (strong, nonatomic) IBOutlet UIView *playerLayer;
//@property (strong, nonatomic) IBOutlet UIView *operationLayer;

@property (retain, nonatomic) MapController *mapController;

@end

@implementation FrameController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.operationLayer.hidden = YES;
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

- (IBAction)logOut:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Log Out"
                                                    message:@"Do you really want to Log Out ?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}

- (IBAction)rightPress:(id)sender
{
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - MapController Delegate

- (void)startDrag:(MapController *)controller
{
    controller.stopAutoMoveCenter = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)endDrag:(MapController *)controller
{
    controller.stopAutoMoveCenter = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:(kScreenWidth > kScreenHeight) animated:YES];
}

//- (void)showOperator:(MapController *)controller withType:(NSInteger)opType
//{
//    self.operationLayer.alpha = 0.0f;
//    self.operationLayer.hidden = NO;
//    [UIView animateWithDuration:0.5f animations:^{
//        self.operationLayer.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//        [self.opearationController scrollToIndex:19];
//    }];
//}

- (void)showZoneInformation:(MapController *)controller withX:(NSInteger)x withY:(NSInteger)y
{
    [self performSegueWithIdentifier:@"showZone" sender:controller];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapSegue"])
    {
        self.mapController = (MapController *)[segue destinationViewController];
        self.mapController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"showZone"])
    {
        UINavigationController *nc = [segue destinationViewController];
        OperationController *opearationController = (OperationController *)[nc topViewController];
        opearationController.frameController = self;
    }
}

@end
