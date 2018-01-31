//
//  ActionCell.m
//  magicworld
//
//  Created by 苏智 on 2018/1/31.
//  Copyright © 2018年 Suzic. All rights reserved.
//

#import "ActionCell.h"

@interface ActionCell ()

@property (strong, nonatomic) IBOutlet UIImageView *actionImage;
@property (strong, nonatomic) IBOutlet UIButton *actionTitle;

@end

@implementation ActionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.actionType = NSNotFound;
}

- (void)setActionType:(NSInteger)actionType
{
    if (_actionType == actionType)
        return;
    _actionType = actionType;
    
    switch (actionType)
    {
        case 0:
            [self.actionImage setImage:[UIImage imageNamed:@"CMD_Explore"]];
            [self.actionTitle setTitle:@"Explore" forState:UIControlStateNormal];
            break;
        case 1:
            [self.actionImage setImage:[UIImage imageNamed:@"CMD_Attack"]];
            [self.actionTitle setTitle:@"Attack" forState:UIControlStateNormal];
            break;
        case 2:
            [self.actionImage setImage:[UIImage imageNamed:@"CMD_Force"]];
            [self.actionTitle setTitle:@"Force" forState:UIControlStateNormal];
            break;
        case 3:
            [self.actionImage setImage:[UIImage imageNamed:@"CMD_Construct"]];
            [self.actionTitle setTitle:@"Construct" forState:UIControlStateNormal];
            break;
        case NSNotFound:
        default:
            [self.actionImage setImage:[UIImage imageNamed:@"CMD_Undefined"]];
            [self.actionTitle setTitle:@"Undefined" forState:UIControlStateNormal];
            break;
    }
}

@end
