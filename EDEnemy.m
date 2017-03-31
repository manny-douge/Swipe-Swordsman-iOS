//
//  EDEnemy.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/13/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDEnemy.h"
#import "EDGenerator.h"
#import "EDGameScene.h"


@implementation EDEnemy
+(id)enemySizeForType:(NSString *)type withDirection:(NSString *)direction withSpawnPoint:(CGPoint)point withSize:(CGSize)sceneSize withPlayer:(EDPlayer *)player
{
    //Initializes enemy with size calculated from class method calcuateTex..
    CGSize textureSize = [EDEnemy calculateTextureSizeForEnemyType:type withSize:sceneSize];
    EDEnemy *enemy = [EDEnemy spriteNodeWithTexture:[SKTexture textureWithImageNamed:@""] size:CGSizeMake(textureSize.width, textureSize.height)];
    [enemy setName:type];
    [enemy setDirection:direction];
    [enemy setXScale:([direction isEqualToString:@"left"])?1:-1];
    [enemy setAnchorPoint:CGPointMake(.5, .5)];
    //[enemy addChild:[SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(20, 20)]];
    /*[enemy setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(enemy.size.width/4, enemy.size.height/1.15 )]];
    [enemy.physicsBody setMass:5];*/
    [enemy setZPosition:([type isEqualToString:@"bigEnemy"])?enemy.zPosition:enemy.zPosition + 1];
    [enemy setPosition:([type isEqualToString:@"bigEnemy"])?CGPointMake(point.x,point.y):CGPointMake(point.x, point.y - enemy.size.height/6)];
    [enemy setPlayer:player];
    [enemy setArrayOfIdle:[NSMutableArray array]];
    [enemy setArrayOfWalk:[NSMutableArray array]];
    [enemy setArrayOfAttack:[NSMutableArray array]];
    [enemy setArrayOfExplosion:[NSMutableArray array]];
    [enemy loadEnemySpecificTexturesWithType:type];
    [enemy setIsAttacking:NO];
    [enemy setIsAlive:YES];
    [enemy handleWalk];
    [enemy setAlpha:0];
    [enemy runAction:[SKAction fadeInWithDuration:.2]];
    return enemy;
}
//Calculates the texture of the enemy when passed in the type
+(CGSize)calculateTextureSizeForEnemyType:(NSString *)type withSize:(CGSize)sceneSize
{
    CGSize textureSize;
    if([type isEqualToString:@"girlEnemy"]){textureSize = CGSizeMake(sceneSize.width/2.715, sceneSize.height/2.123);}
    else if([type isEqualToString:@"bigEnemy"]){textureSize = CGSizeMake(sceneSize.width/1.526, sceneSize.height/1.401);}
    else if([type isEqualToString:@"normalEnemy"]){textureSize = CGSizeMake(sceneSize.width/2.715, sceneSize.height/2.123);}
    return textureSize;
}
//Loads enemy specific tedxtures with passed in type also sets dead zone
-(void)loadEnemySpecificTexturesWithType:(NSString *)type
{
    //Deadzone set half of player texture
    [self setDeadzone:self.size.width/4];
    [self setMoveSpeed:4];
    if([type isEqualToString:@"girlEnemy"]){[self setMoveSpeed:5];[self setHits:1];}
    else if ([type isEqualToString:@"bigEnemy"]){[self setMoveSpeed:1];[self setHits:2];}
    //Pattern is idle,walk,atack
    NSDictionary *frameData = @{@"girlEnemy" : @[@24,@25,@49],
                                @"bigEnemy" : @[@41,@34,@70],
                                @"normalEnemy" : @[@21,@32,@16]
                                };
    NSArray *arrayOfFrameCounts = [NSArray arrayWithArray:[frameData objectForKey:type]];
    for(int frameCount = 0; frameCount < ((NSNumber *)arrayOfFrameCounts[0]).intValue; frameCount++)
        [self.arrayOfIdle addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-idle%i", self.name, frameCount]]];
    for(int frameCount = 0; frameCount < ((NSNumber *)arrayOfFrameCounts[1]).intValue; frameCount++)
        [self.arrayOfWalk addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-walk%i",self.name,frameCount]]];
    for(int frameCount = 0; frameCount < ((NSNumber *)arrayOfFrameCounts[2]).intValue; frameCount++)
        [self.arrayOfAttack addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-attackOne%i", self.name, frameCount]]];
    NSArray *limbType = @[@"head",@"left-forearm",@"left-shoulder",@"left-thigh",@"torso",@"right-forearm",
                               @"right-knee",@"right-shoulder",@"right-thigh"];
    //LOAD EXPLSION TEXTURES
    for(int currentLimbIdx = 0; currentLimbIdx < limbType.count; currentLimbIdx++)
        [self.arrayOfExplosion addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-%@", self.name, limbType[currentLimbIdx]]]];
}
-(void)handleWalk
{
    if(!self.isAttacking)
        [self runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:self.arrayOfWalk
                                                                       timePerFrame:.03]]];
}
-(void)handleAttack
{
    if(!self.isAttacking)
    {
        [self setIsAttacking:YES];
        [self runAction:[SKAction waitForDuration:([self.name isEqualToString:@"bigEnemy"])?1.5:1] completion:^{
            //NSLog(@"%@ Attacked",self.name);
            //left
            [self playAttackSound];
            CGPoint playerPos = [self.scene convertPoint:self.player.position fromNode:self.player.parent];
            CGPoint enemyPos = [self.scene convertPoint:self.position fromNode:self.parent];
            SKSpriteNode *largeNode = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(5, 5)];
            SKSpriteNode *smallNode = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(5, 5)];
            int smallDistanceOffset = ([self.name isEqualToString:@"bigEnemy"])?self.frame.size.width/9.64:self.frame.size.width/9.03;
            int largeDistanceOffset = ([self.name isEqualToString:@"bigEnemy"])?self.frame.size.width/3.21:self.frame.size.width/3.38;
            //[self addChild:largeNode];
            //[self addChild:smallNode];
            if([self.direction isEqualToString:@"left"])
            {
                [largeNode setPosition:CGPointMake(+largeDistanceOffset, +0)];
                [smallNode setPosition:CGPointMake(+smallDistanceOffset, +0)];
                //NSLog(@"LEFT SIDE player pos is %f, small %i larg %i",playerPos.x,smallDistanceOffset, largeDistanceOffset);
                if(playerPos.x > enemyPos.x - smallDistanceOffset && playerPos.x < enemyPos.x + largeDistanceOffset)
                {
                    EDGameScene *scene = (EDGameScene *)self.scene;
                    [scene playerTookDamageWithEnemy:self];
                }
            }
            //right
            else if([self.direction isEqualToString:@"right"])
            {
                [largeNode setPosition:CGPointMake(+largeDistanceOffset, +0)];
                [smallNode setPosition:CGPointMake(+smallDistanceOffset, +0)];
                //NSLog(@"RIGHT SIDEplayer pos is %f, small %f larg %f",playerPos.x, enemyPos.x + smallDistanceOffset, enemyPos.x - largeDistanceOffset);

                if(playerPos.x < enemyPos.x + smallDistanceOffset  && playerPos.x > enemyPos.x - largeDistanceOffset)
                {
                    EDGameScene *scene = (EDGameScene *)self.scene;
                    [scene playerTookDamageWithEnemy:self];
                }
            }
        }];
        [self runAction:[SKAction animateWithTextures:self.arrayOfAttack timePerFrame:.03] completion:^{
            [self setIsAttacking:NO];
        }];
    }
}
-(void)updateEnemy
{
    if(self.isAlive)
    {
    //Converts a point to the callers coordinate system, you must pass the nodes parent
    //Allows player and enemy proximity to be calculated and compared
    //Player deadzone when an added to player pos x gives extra space between them when tracking
    //float playerDeadzone = self.scene.size.width/7;
    CGPoint playerPos = [self.scene convertPoint:self.player.position fromNode:self.player.parent];
    CGPoint enemyPos = [self.scene convertPoint:self.position fromNode:self.parent];
    //NSLog(@"enemy on %@ pos is %f player pos is %f",self.direction,ePos.x,pPos.x);
    if([self.direction isEqualToString:@"left"])
    {
        if(enemyPos.x < playerPos.x - self.deadzone && !self.isAttacking)
        {
            [self runAction:[SKAction runBlock:^{
                [self setPosition:CGPointMake(self.position.x + self.moveSpeed, self.position.y)];
            }]];
        }
        else if(playerPos.x > enemyPos.x && playerPos.x < enemyPos.x + self.deadzone)
        {
            [self handleAttack];
        }
        else if(playerPos.x < enemyPos.x && !self.isAttacking)
        {
            [self setXScale:-1];
            [self setDirection:@"right"];
        }
    }
    else if([self.direction isEqualToString:@"right"])
    {
        if(enemyPos.x > playerPos.x + self.deadzone && !self.isAttacking)
        {
            [self runAction:[SKAction runBlock:^{
                [self setPosition:CGPointMake(self.position.x - self.moveSpeed, self.position.y)];
            }]];
        }
        else if(playerPos.x < enemyPos.x && playerPos.x > enemyPos.x - self.deadzone)
        {
            [self handleAttack];
        }
        else if(playerPos.x > enemyPos.x && !self.isAttacking)
        {
            [self setXScale:1];
            [self setDirection:@"left"];
        }

    }
    }

}
-(void)playIdle
{
    [self runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:self.arrayOfIdle timePerFrame:.03]]];
}
-(void)takeDamage
{
    self.hits--;
    SKAction *colorize = [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:.8 duration:.1];
    SKAction *uncolorize = [SKAction colorizeWithColorBlendFactor:0 duration:.1];
    [self runAction:[SKAction sequence:@[colorize,uncolorize]]];
    if(self.hits == 0)
    {
        EDGenerator *gen = (EDGenerator *)self.parent;
        [[gen.manager allEnemies] removeObject:self];
        EDGameScene *gameScene = (EDGameScene *)self.scene;
        [gameScene incrementCurrentKillCount];
        [self explode];
    }
 

}
-(void)explode
{
    [self setIsAlive:NO];
    [self setAlpha:0];
    //NSLog(@"exploding");
    for (SKTexture *texture in self.arrayOfExplosion)
    {
        SKSpriteNode *limb = [SKSpriteNode spriteNodeWithTexture:texture size:CGSizeMake(self.scene.frame.size.height/24.84, self.scene.frame.size.height/24.84)];
        [limb setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.scene.frame.size.height/62.1, self.scene.frame.size.height/62.1)]];
        [limb.physicsBody setMass:1];
        [limb setScale:([self.name isEqualToString:@"bigEnemy"])?2.3:1.3];
        [self.parent addChild:limb];
        [limb setPosition:self.position];
        [limb setAlpha:1];
        [limb runAction:[SKAction runBlock:^{
            float xValue = (self.xScale == 1)?-400:600;
            [limb.physicsBody applyImpulse:CGVectorMake(xValue, self.scene.frame.size.height/6.42)];
            [limb runAction:[SKAction waitForDuration:4] completion:^{
                [limb runAction:[SKAction fadeOutWithDuration:.3] completion:^{
                    [limb removeFromParent];
                }];
            }];
        }]];
    }
    [self removeFromParent];
}
-(void)playAttackSound
{
    if([EDGameData sharedInstance].isSoundOn)
    [self runAction:[SKAction playSoundFileNamed:[NSString stringWithFormat:@"%@AttackSound",self.name] waitForCompletion:NO]];
}
@end
