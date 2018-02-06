//
//  MapCell.h
//  magicworld
//
//  Created by 苏智 on 16/1/31.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIView *cellBackground;
@property (strong, nonatomic) IBOutlet UILabel *indexLabel;
@property (strong, nonatomic) IBOutlet UIImageView *unitAvator;

@property (assign, nonatomic) BOOL highlight;

- (void)setIndexNumberIn:(NSInteger)row andCol:(NSInteger)col;

@end
