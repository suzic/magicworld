//
//  DataManager+Game.h
//  magicworld
//
//  Created by 苏智 on 2018/2/6.
//  Copyright © 2018年 Suzic. All rights reserved.
//

#import "DataManager.h"

#import "MWZone+CoreDataClass.h"
#import "MWMap+CoreDataClass.h"
#import "MWGame+CoreDataClass.h"
#import "MWUnit+CoreDataClass.h"
#import "MWUnitType+CoreDataClass.h"
#import "MWUnitInstance+CoreDataClass.h"
#import "MWGameSnapView+CoreDataClass.h"

@interface DataManager (Game)

- (void)initUnitTypes:(NSUInteger)ver;
- (void)initOverlays:(NSUInteger)ver;
- (void)initTerrains:(NSUInteger)ver;
- (void)initZoneTypes:(NSUInteger)ver;
- (void)initMapTypes:(NSUInteger)ver;

- (MWZone *)createZoneInstanceByZoneTypeId:(NSString *)zoneTypeId;
- (MWMap *)createMapInstanceByTypeId:(NSString *)mapTypeId;
- (MWGame *)createNewGameByGiveMap:(MWMap *)map;

- (void)addUnit:(MWUnitType *)unitType toForce:(MWForce *)force;
- (MWGameSnapView *)createMyGameSnapViewFromGame:(MWGame *)game withForce:(MWForce *)force;
- (BOOL)placeUnitInstance:(MWUnitInstance *)unitInstance onZone:(MWZone *)zone;

@end
