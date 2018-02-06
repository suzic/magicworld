//
//  DataManager+Game.m
//  magicworld
//
//  Created by 苏智 on 2018/2/6.
//  Copyright © 2018年 Suzic. All rights reserved.
//

#import "DataManager+Game.h"

@implementation DataManager (Game)

- (void)initUnitTypes:(NSUInteger)ver
{
    
}

- (void)initOverlays:(NSUInteger)ver
{
    
}

- (void)initTerrains:(NSUInteger)ver
{
    
}

- (void)initZoneTypes:(NSUInteger)ver
{
    
}

- (void)initMapTypes:(NSUInteger)ver
{
    
}

#pragma mark - Prepare for game

- (MWZone *)createZoneInstanceByZoneTypeId:(NSNumber *)zoneTypeId
{
    return nil;
}

- (MWMap *)createMapInstanceByTypeId:(NSNumber *)mapTypeId
{
    return nil;
}

- (MWGame *)createNewGameByGiveMap:(MWMap *)map
{
    return nil;
}

- (MWUnit *)createUnitByTypeId:(NSNumber *)unitTypeId
{
    return nil;
}

#pragma mark - Operations

- (void)addUnit:(MWUnitType *)unitType toForce:(MWForce *)force
{
    MWUnit *unit = [self createUnitByTypeId:unitType.unit_type_id];
    unit.belongForce = force;
}

- (MWGameSnapView *)createMyGameSnapViewFromGame:(MWGame *)game withForce:(MWForce *)force
{
    MWGameSnapView *snapView = (MWGameSnapView *)[self insertIntoCoreData:@"MWGameSnapView"];
    snapView.belongGame = game;
    snapView.myForce = force;
    for (MWUnit *unit in force.hasUnits)
    {
        MWUnitInstance *unitInstance = (MWUnitInstance *)[self insertIntoCoreData:@"MWUnitInstance"];
        unitInstance.belongUnit = unit;
        unitInstance.belongGameSnap = snapView;
    }
    return snapView;
}

- (BOOL)placeUnitInstance:(MWUnitInstance *)unitInstance onZone:(MWZone *)zone
{
    return YES;
}

@end
