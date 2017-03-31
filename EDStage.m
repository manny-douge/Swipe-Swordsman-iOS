//
//  EDStage.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/2/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDStage.h"

@implementation EDStage
+(id)stageWithName:(NSString *)name size:(CGSize)size
{
    //Create base scene  3 iPhone screens in length by default
    EDStage *stageNode = [EDStage node];
    [stageNode setName:name];
    SKSpriteNode *backgroundTextureLeft = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@BackgroundTextureLeft",name]] size:CGSizeMake(size.width, size.height)];
    [backgroundTextureLeft setZPosition:2];
    //[backgroundTextureLeft setPosition:CGPointMake(0+,+0)];
    [stageNode addChild:backgroundTextureLeft];
    SKSpriteNode *backgroundTextureMid = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@BackgroundTextureMid",name]] size:CGSizeMake(size.width, size.height)];
    [backgroundTextureMid setPosition:CGPointMake(backgroundTextureLeft.position.x + size.width, +0)];
    [backgroundTextureMid setZPosition:2];
    [stageNode addChild:backgroundTextureMid];
    SKSpriteNode *backgroundTextureRight = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@BackgroundTextureRight",name]] size:CGSizeMake(size.width, size.height)];
    [backgroundTextureRight setZPosition:2];
    [backgroundTextureRight setPosition:CGPointMake(backgroundTextureMid.position.x +size.width,+0)];
    [stageNode addChild:backgroundTextureRight];
    SKSpriteNode *ground = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@GroundTexture",name]] size:CGSizeMake(size.width*3, size.height/10)];
    [ground setAlpha:0];
    [ground setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:ground.size]];
    [ground.physicsBody setDynamic:NO];
    [ground setPosition:CGPointMake(+size.width,-size.height/2 + ground.size.height/2)];
    [ground setZPosition:3];
    [stageNode addChild:ground];
    SKSpriteNode *leftWall = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(size.width/20, size.height)];
    [leftWall setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:leftWall.size]];
    [leftWall.physicsBody setDynamic:NO];
    [leftWall setPosition:CGPointMake(-size.width/2 + leftWall.size.width/2, leftWall.size.height/2 + ground.position.y)];
    [leftWall setAlpha:0];
    [stageNode addChild:leftWall];
    
    SKSpriteNode *rightWall = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(size.width/20, size.height)];
    [rightWall setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:rightWall.size]];
    [rightWall.physicsBody setDynamic:NO];
    [rightWall setPosition:CGPointMake(-size.width/2 + ground.size.width - leftWall.size.width/2, leftWall.size.height/2 + ground.position.y)];
    [rightWall setAlpha:0];
    [stageNode addChild:rightWall];
    return stageNode;
}

@end
