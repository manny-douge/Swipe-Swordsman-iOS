//
//  EDLoadingScreen.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 7/8/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDLoadingScreen.h"
#import "EDMainMenu.h"

@implementation EDLoadingScreen
+(id)sceneWithSize:(CGSize)size withView:(SKView *)view
{
    EDLoadingScreen *scene = [EDLoadingScreen sceneWithSize:size];
    [scene setScaleMode:SKSceneScaleModeAspectFill];
    return scene;
}
-(void)didMoveToView:(SKView *)view
{
    [self loadMainMenuWithView:view];
}
-(void)loadMainMenuWithView:(SKView *)view
{
    //All atlases are created and loaded here they must be kept with a strong pointer to stay in memory
    //when the scene changes
    SKSpriteNode *backgroundTexture = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"titleScreenBackground"] size:view.frame.size];
    [backgroundTexture setPosition:CGPointMake(view.frame.size.width/2, view.frame.size.height/2)];
    [self addChild:backgroundTexture];
    SKTextureAtlas *swordsmanLimbs = [SKTextureAtlas atlasNamed:@"Swordsman"];
    SKTextureAtlas *bigEnemyLimbs = [SKTextureAtlas atlasNamed:@"bigEnemy"];
    SKTextureAtlas *girlEnemyLimbs= [SKTextureAtlas atlasNamed:@"girlEnemy"];
    SKTextureAtlas *bigEnemyAttack = [SKTextureAtlas atlasNamed:@"bigEnemyAttackTextures"];
    SKTextureAtlas *bigEnemyWalk = [SKTextureAtlas atlasNamed:@"bigEnemyWalkTextures"];
    SKTextureAtlas *bigEnemyIdle = [SKTextureAtlas atlasNamed:@"bigEnemyIdleTextures"];
    SKTextureAtlas *girlEnemyAttack = [SKTextureAtlas atlasNamed:@"girlEnemyAttackTextures"];
    SKTextureAtlas *girlEnemyWalk = [SKTextureAtlas atlasNamed:@"girlEnemyWalkTextures"];
    SKTextureAtlas *girlEnemyIdle = [SKTextureAtlas atlasNamed:@"girlEnemyIdleTextures"];
    SKTextureAtlas *damageTaken = [SKTextureAtlas atlasNamed:@"damageTakenTextures"];
    SKTextureAtlas *dash = [SKTextureAtlas atlasNamed:@"dashTextures"];
    SKTextureAtlas *attackOne = [SKTextureAtlas atlasNamed:@"attackOneTextures"];
    SKTextureAtlas *attackTwo = [SKTextureAtlas atlasNamed:@"attackTwoTextures"];
    SKTextureAtlas *idle = [SKTextureAtlas atlasNamed:@"idleTextures"];
    [SKTextureAtlas preloadTextureAtlases:@[swordsmanLimbs,girlEnemyLimbs,bigEnemyLimbs,bigEnemyAttack,bigEnemyWalk,bigEnemyIdle,girlEnemyAttack,girlEnemyWalk,girlEnemyIdle,damageTaken,dash,attackOne,attackTwo,idle] withCompletionHandler:^{
        NSArray *atli = @[@[swordsmanLimbs,girlEnemyLimbs,bigEnemyLimbs,bigEnemyAttack,bigEnemyWalk,bigEnemyIdle,girlEnemyAttack,girlEnemyWalk,girlEnemyIdle,damageTaken,dash,attackOne,attackTwo,idle]];
        EDMainMenu *scene = [EDMainMenu sceneWithSize:view.frame.size andArrayOfAtli:atli];
        // Present the scene.
        [view presentScene:scene];
    }];
}
@end
