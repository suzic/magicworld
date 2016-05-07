//
//  OperationCell.m
//  magicworld
//
//  Created by 苏智 on 16/4/21.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "OperationCell.h"

@interface OperationCell ()

@property (strong, nonatomic) IBOutlet UIView *gradientView;
//@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end

@implementation OperationCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    // 对表格进行尾部渐变消隐处理
    //    self.gradientLayer = [CAGradientLayer layer];
    //    self.gradientLayer.frame = self.gradientView.frame;
    //    [self.gradientView.layer addSublayer:self.gradientLayer];
    //    self.gradientLayer.startPoint = CGPointMake(0, 0);
    //    self.gradientLayer.endPoint = CGPointMake(0, 0.9);
    //    self.gradientLayer.colors = @[(__bridge id)[UIColor whiteColor].CGColor,
    //                                  (__bridge id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
    //    self.gradientLayer.locations = @[@(0.0f) ,@(0.9f)];
    
    // 状态标签旋转90度
    self.cardTypeString.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI/2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.cardType.transform = selected ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, -36, 0);

    self.blur.alpha = selected ? 1 : 0;
    self.gradientView.backgroundColor = selected ? [UIColor clearColor] : [UIColor colorWithWhite:0.5f alpha:0.6f];
    [UIView animateWithDuration:1.0f animations:^{
        self.cardType.transform = selected ? CGAffineTransformTranslate(CGAffineTransformIdentity, -36, 0) : CGAffineTransformIdentity;
        self.blur.alpha = selected ? 0 : 1;
        self.gradientView.backgroundColor = !selected ? [UIColor clearColor] :[UIColor colorWithWhite:0.5f alpha:0.6f];
    } completion:^(BOOL finished) {
        self.blur.hidden = selected ? YES : NO;
    }];
}

@end
