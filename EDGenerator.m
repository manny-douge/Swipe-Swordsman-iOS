//
//  EDGenerator.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/13/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDGenerator.h"
@implementation EDGenerator
+(id)generatorWithDirection:(NSString *)direction withPoint:(CGPoint)point withPlayer:(EDPlayer *)player withManager:(EDGeneratorManager *)genManager
{
    //Spawns a generator on "direction" side
    EDGenerator *generator = [EDGenerator node];
    [generator setName:[NSString stringWithFormat:@"%@generator",direction]];
    
    [generator setDirection:direction];
    [generator setCanSpawnEnemies:YES];
    [generator setManager:genManager];
    [generator setPosition:point];
    [generator setEnemyQuota:0];
    [generator setPlayer:player];
    [genManager addChild:generator];
    NSLog(@"%@ generator created",generator.direction);
    return generator;
}
//UPDATE FUNCTION MUST BE IMPLEMENTED
-(void)update
{
    
    //Spawns a single enemy per secon
    if(self.canSpawnEnemies && self.enemyQuota > 0)
    {
        //NSLog(@"Spawning an enemy");
        [self setCanSpawnEnemies:NO];
        SKAction *wait = [SKAction waitForDuration:.9];
        SKAction *spawnEnemyBlock= [SKAction runBlock:^{
            [self spawnEnemy];
        }];
        SKAction *canSpawnAgainBlock = [SKAction runBlock:^{
            [self setCanSpawnEnemies:YES];
        }];
        [self runAction:[SKAction sequence:@[spawnEnemyBlock,wait,canSpawnAgainBlock]]];
    }
}

-(void)increaseEnemyQuota:(int)amount
{
    self.enemyQuota += amount;
}
-(void)spawnEnemy
{
    [self spawnEnemies:1];
    //NSLog(@"%i enemies left on %@ generator",self.enemyQuota,self.direction);
}
-(void)spawnEnemies:(int)amountOfEnemies{
    for (int enemies = amountOfEnemies; enemies > 0; enemies--)
    {
        self.enemyQuota--;
        EDEnemy *enemy = [self spawnLogic];
        [self addChild:enemy];
        [self.manager.allEnemies addObject:enemy];
    }
    
}
//Handles randomness of spawn current set is 60% norm 30%girlEnemy 10%big
-(EDEnemy *)spawnLogic
{
    int randNum = (arc4random() % 10) + 1;
    EDEnemy *enemy;
    if (randNum > 7)
    {
        enemy = [EDEnemy enemySizeForType:@"bigEnemy" withDirection:self.direction withSpawnPoint:self.position withSize:self.scene.size withPlayer:self.player];
        NSLog(@"SPAEWNED BIG");
    }
    else
    {
        enemy = [EDEnemy enemySizeForType:@"girlEnemy" withDirection:self.direction withSpawnPoint:self.position withSize:self.scene.size withPlayer:self.player];
        NSLog(@"SPAEWNED GIRL");
    }
    return enemy;
    
}
@end
