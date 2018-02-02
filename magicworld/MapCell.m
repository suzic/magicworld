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
    [super awakeFromNib];
    self.cellBackground.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.cellBackground.layer.borderWidth = 0.5f;
}

//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//    self.cellBackground.layer.borderColor = [UIColor darkGrayColor].CGColor;
//    self.cellBackground.layer.borderWidth = 0.5f;
//    self.cellBackground.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
//    self.cellBackground.layer.cornerRadius = 0.0f;
//    _isSelected = NO;
//}

- (void)setIndexNumberIn:(NSInteger)row andCol:(NSInteger)col
{
    self.indexLabel.text = [NSString stringWithFormat:@"%02ld - %02ld", (long)row, (long)col];
}

- (void)setHighlight:(BOOL)highlight
{
    _highlight = highlight;
    self.cellBackground.backgroundColor = highlight ? [UIColor colorWithWhite:0.5f alpha:1.0f] : [UIColor colorWithWhite:145.0f / 256.0f alpha:1.0f];
}

@end
