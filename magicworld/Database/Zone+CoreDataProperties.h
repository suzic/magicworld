//
//  Zone+CoreDataProperties.h
//  magicworld
//
//  Created by 苏智 on 16/2/3.
//  Copyright © 2016年 Suzic. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Zone.h"

NS_ASSUME_NONNULL_BEGIN

@interface Zone (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *zid;
@property (nullable, nonatomic, retain) NSNumber *z_row;
@property (nullable, nonatomic, retain) NSNumber *z_col;
@property (nullable, nonatomic, retain) NSNumber *terrain;
@property (nullable, nonatomic, retain) NSNumber *overlay;

@end

NS_ASSUME_NONNULL_END
