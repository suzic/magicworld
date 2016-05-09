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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *boarderWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *boarderHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *typeHeight;

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
    
    // 默认按横屏初始化数据
    _inLandMode = NO;
    self.cardBorder.transform = CGAffineTransformIdentity;
    self.cardTypeString.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    self.boarderWidth.constant = self.frame.size.width;
    self.boarderHeight.constant = self.frame.size.height - 1;
    self.typeHeight.constant = self.frame.size.height - 1;
}

- (void)setInLandMode:(BOOL)inLandMode
{
    if (_inLandMode == inLandMode)
        return;
    _inLandMode = inLandMode;

    self.boarderWidth.constant = (_inLandMode && self.selected) ? self.frame.size.height : self.frame.size.width;
    self.boarderHeight.constant = (_inLandMode && self.selected) ? self.frame.size.width : self.frame.size.height - 1;
    self.cardBorder.transform = (_inLandMode && self.selected) ? CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2) : CGAffineTransformIdentity;
    self.cardTypeString.transform =  _inLandMode ? CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2) : CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // 横屏选择模式下进行旋转调整
    self.boarderWidth.constant = (_inLandMode && selected) ? self.frame.size.height : self.frame.size.width;
    self.boarderHeight.constant = (_inLandMode && selected) ? self.frame.size.width : self.frame.size.height - 1;
    self.cardBorder.transform = (_inLandMode && selected) ? CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2) : CGAffineTransformIdentity;

    [UIView animateWithDuration:selected ? 1.0f : 0.0f animations:^{
        self.gradientView.backgroundColor = !selected ? [UIColor clearColor] :[UIColor colorWithWhite:0.5f alpha:0.6f];
        self.cardType.transform = selected ? CGAffineTransformTranslate(CGAffineTransformIdentity, -36, 0) : CGAffineTransformIdentity;
        self.blur.alpha = selected ? 0 : 1;
    } completion:^(BOOL finished) {
        self.blur.hidden = selected ? YES : NO;
    }];
}

@end
