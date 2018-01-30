//
//  LoginActionCell.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "LoginActionCell.h"

@implementation LoginActionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)actionButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(actionExeicute:)])
        [self.delegate actionExeicute:self];
}

@end
