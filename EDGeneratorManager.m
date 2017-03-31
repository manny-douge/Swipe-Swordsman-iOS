//
//  EDGeneratorManager.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/14/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDGeneratorManager.h"
#import "EDGenerator.h"
#import "EDEnemy.h"

@implementation EDGeneratorManager
+(id)generatorManagerWithLayer:(SKNode *)layer withPlayer:(EDPlayer *)player
{
    EDGeneratorManager *manager = [EDGeneratorManager node];
    [manager setName:@"GeneratorManager"];
    [manager setAllEnemies:[NSMutableArray array]];
    [manager setLeftGenerators:[NSMutableArray array]];
    [manager setRightGenerators:[NSMutableArray array]];
    [manager setGameLayer:layer];
    [manager setPlayer:player];
    [manager setPosition:CGPointMake(layer.scene.size.width/2, layer.scene.size.width/2)];
    [manager addBasicGenerators];
    return manager;
}
//Allows Updates for generators and enemies
-(void)updateManager
{
    //update enemies
    [self.allEnemies enumerateObjectsUsingBlock:^(id object,NSUInteger idx,BOOL *stop){
        EDEnemy *enemy = (EDEnemy *)object;
        [enemy updateEnemy];
    }];
    //update generators
     int leftCount = (int)[self.leftGenerators count];
     int rightCount = (int)[self.rightGenerators count];
     for (int leftGenIdx = 0;leftGenIdx < leftCount; leftGenIdx++)
     {
         EDGenerator *currentGen = (EDGenerator *)self.leftGenerators[leftGenIdx];
         [currentGen update];
     }
     for (int rightGenIdx = 0;rightGenIdx < rightCount; rightGenIdx++)
     {
         EDGenerator *currentGen = (EDGenerator *)self.rightGenerators[rightGenIdx];
         [currentGen update];
     }
    
     
}
-(void)addBasicGenerators
{
    [self.leftGenerators addObject:[EDGenerator generatorWithDirection:@"left" withPoint:CGPointMake(-self.player.scene.size.width/1.45,-self.player.scene.size.height/3.3) withPlayer:self.player withManager:self]];
    [self.rightGenerators addObject:[EDGenerator generatorWithDirection:@"right" withPoint:CGPointMake(+self.player.scene.size.width/1.45,-self.player.scene.size.height/3.3) withPlayer:self.player withManager:self]];
}
-(void)addNearCenterGenerators
{
    [self.leftGenerators addObject:[EDGenerator generatorWithDirection:@"left" withPoint:CGPointMake(-self.player.scene.size.width/4, -self.player.scene.size.height/4) withPlayer:self.player withManager:self]];
    [self.rightGenerators addObject:[EDGenerator generatorWithDirection:@"right" withPoint:CGPointMake(+self.player.scene.size.width/4, -self.player.scene.size.height/4)withPlayer:self.player withManager:self]];

}
-(void)addToQuota:(int)numOfEnemies
{
    NSLog(@"Adding %i to generators",numOfEnemies);
    int enemiesForAll = numOfEnemies/2;
    int leftCount = (int)[self.leftGenerators count];
    int rightCount = (int)[self.rightGenerators count];
    for (int leftGenIdx = 0;leftGenIdx < leftCount; leftGenIdx++)
    {
        [self.leftGenerators[leftGenIdx] increaseEnemyQuota:enemiesForAll];
    }
    for (int rightGenIdx = 0;rightGenIdx < rightCount; rightGenIdx++)
    {
        [self.rightGenerators[rightGenIdx] increaseEnemyQuota:enemiesForAll];
    }
}
@end

