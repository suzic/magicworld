//
//  OperationCell.m
//  magicworld
//
//  Created by 苏智 on 16/4/21.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "OperationCell.h"

@implementation OperationCell
{
    BOOL lastSelectedState;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

//    self.cardBorder.layer.cornerRadius = 4.0f;
//    self.cardBorder.layer.borderColor = [UIColor darkGrayColor].CGColor;
//    self.cardBorder.layer.borderWidth = 0.5f;
    
//    self.cardWidth.constant = lastSelectedState ? self.frame.size.width : self.frame.size.width * 7 / 8;
//    [UIView animateWithDuration:1.0f animations:^{
//    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    lastSelectedState = selected;
    self.cardWidth.constant = selected ? self.frame.size.width : self.frame.size.width * 7 / 8;
}

@end
