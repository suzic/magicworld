//
//  OperationCell.h
//  magicworld
//
//  Created by 苏智 on 16/4/21.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OperationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *cardType;
@property (strong, nonatomic) IBOutlet UILabel *cardTypeString;
@property (strong, nonatomic) IBOutlet UIView *cardBorder;
@property (strong, nonatomic) IBOutlet UIImageView *cardImage;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *blur;

@property (assign, nonatomic) BOOL inLandMode;

@end
