//
//  DataManager+Game.m
//  magicworld
//
//  Created by 苏智 on 2018/2/6.
//  Copyright © 2018年 Suzic. All rights reserved.
//

#import "DataManager+Game.h"

#import "MWOverlay+CoreDataClass.h"
#import "MWTerrain+CoreDataClass.h"

@implementation DataManager (Game)

- (void)initUnitTypes:(NSUInteger)ver
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"init_unit_types" ofType:@"plist"];
    NSArray *dicArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSArray *dbArray = [self arrayFromCoreData:@"MWUnitType" predicate:nil limit:NSIntegerMax offset:0 orderBy:nil];
    
    for (NSDictionary *groupDic in dicArray)
    for (NSDictionary *unitTypeDic in groupDic[@"units"])
    {
        MWUnitType *targetUnitType = nil;
        for (MWUnitType *unitType in dbArray)
        {
            if ([unitType.unit_type_id isEqualToNumber:unitTypeDic[@"unit_type_id"]])
            {
                targetUnitType = unitType;
                break;
            }
        }
        if (targetUnitType == nil)
        {
            targetUnitType = (MWUnitType *)[self insertIntoCoreData:@"MWUnitType"];
            targetUnitType.unit_type_id = unitTypeDic[@"unit_type_id"];
        }
        targetUnitType.unit_type_name = unitTypeDic[@"unit_type_name"];
        targetUnitType.point_action = unitTypeDic[@"point_action"];
        targetUnitType.point_attack = unitTypeDic[@"point_attack"];
        targetUnitType.point_defense = unitTypeDic[@"point_defense"];
        targetUnitType.point_hp = unitTypeDic[@"point_hp"];
        targetUnitType.max_range = unitTypeDic[@"max_range"];
        targetUnitType.min_range = unitTypeDic[@"min_range"];
    }
}

- (void)initOverlays:(NSUInteger)ver
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"init_overlay" ofType:@"plist"];
    NSArray *dicArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSArray *dbArray = [self arrayFromCoreData:@"MWOverlay" predicate:nil limit:NSIntegerMax offset:0 orderBy:nil];
    
    for (NSDictionary *overlayDic in dicArray)
    {
        MWOverlay *targetOverlay = nil;
        for (MWOverlay *overlay in dbArray)
        {
            if ([overlay.overlay_id isEqualToNumber:overlayDic[@"overlay_id"]])
            {
                targetOverlay = overlay;
                break;
            }
        }
        if (targetOverlay == nil)
        {
            targetOverlay = (MWOverlay *)[self insertIntoCoreData:@"MWOverlay"];
            targetOverlay.overlay_id = overlayDic[@"overlay_id"];
        }
        targetOverlay.overlay_name = overlayDic[@"overlay_name"];
        targetOverlay.overlay_hp_max = overlayDic[@"overlay_hp_max"];
        targetOverlay.overlay_hp_rec = overlayDic[@"overlay_hp_rec"];
        targetOverlay.bonus_attack = overlayDic[@"bonus_attack"];
        targetOverlay.bonus_defense = overlayDic[@"bonus_defense"];
        targetOverlay.bonus_explore = overlayDic[@"bonus_explore"];
    }
}

- (void)initTerrains:(NSUInteger)ver
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"init_terrains" ofType:@"plist"];
    NSArray *dicArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    NSArray *dbArray = [self arrayFromCoreData:@"MWTerrain" predicate:nil limit:NSIntegerMax offset:0 orderBy:nil];
    
    for (NSDictionary *overlayDic in dicArray)
    {
        MWOverlay *targetOverlay = nil;
        for (MWOverlay *overlay in dbArray)
        {
            if ([overlay.overlay_id isEqualToNumber:overlayDic[@"overlay_id"]])
            {
                targetOverlay = overlay;
                break;
            }
        }
        if (targetOverlay == nil)
        {
            targetOverlay = (MWOverlay *)[self insertIntoCoreData:@"MWOverlay"];
            targetOverlay.overlay_id = overlayDic[@"overlay_id"];
        }
        targetOverlay.overlay_name = overlayDic[@"overlay_name"];
        targetOverlay.overlay_hp_max = overlayDic[@"overlay_hp_max"];
        targetOverlay.overlay_hp_rec = overlayDic[@"overlay_hp_rec"];
        targetOverlay.bonus_attack = overlayDic[@"bonus_attack"];
        targetOverlay.bonus_defense = overlayDic[@"bonus_defense"];
        targetOverlay.bonus_explore = overlayDic[@"bonus_explore"];
    }
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
