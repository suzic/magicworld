//
//  LoginActionCell.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginActionCell;

@protocol LoginActionCellDelegate <NSObject>

@optional

- (void)actionExeicute:(LoginActionCell *)cell;

@end

@interface LoginActionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *actionButton;
@property(nonatomic, assign) id<LoginActionCellDelegate> delegate;

@end
