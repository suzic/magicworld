//
//  MapCell.m
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "MapCell.h"

@implementation MapCell

- (void)awakeFromNib
{
    self.cellBackground.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.cellBackground.layer.borderWidth = 0.5f;
}

- (void)setIndexNumberIn:(NSInteger)row andCol:(NSInteger)col
{
    self.indexLabel.text = [NSString stringWithFormat:@"%02ld - %02ld", (long)row, (long)col];
}

@end
