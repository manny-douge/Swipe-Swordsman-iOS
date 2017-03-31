//
//  EDGameScene.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/2/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDGameScene.h"
#import "EDDefaultStage.h"
#import "EDGeneratorManager.h"
#import "EDGameData.h"
#import "AVFoundation/AVFoundation.h"
#import "EDMainMenu.h"
#import "AppDelegate.h"
@import GoogleMobileAds;
@implementation EDGameScene
{
    int timeInSeconds;
    int currentKillCount;
    float screenWidth;
    float screenHeight;
    
    BOOL isTrackingPlayer;
    BOOL stopAllEnemyAttacking;
    BOOL isPlayerAlive;
    BOOL isHighScoreBeaten;
    
    SKNode *backgroundLayer;
    SKNode *gameLayer;
    SKNode *menuLayer;
    
    SKSpriteNode *menuButton;
    SKSpriteNode *replayButton;
    
    SKCameraNode *camNode;
    
    SKLabelNode *highScoreLabel;
    SKLabelNode *currentScoreLabel;
    
    SKEmitterNode *petalParticle;
    
    EDPlayer *player;
    EDGeneratorManager *genManager;
    EDEnemy *testEnemy;
    
    enum GameState currentGameState;
    enum PlayerState currentPlayerState;
    
    AVAudioPlayer *musicPlayer;
    SKAction *popIn;
    SKAction *popOut;
    SKAction *pop;
    
    UIView *subView_;
    
    GADInterstitial *interstitial;
    
    UISwipeGestureRecognizer *leftRecognizer;
    UISwipeGestureRecognizer *rightRecognizer;
}
#pragma mark - Moved to View/Setup
+(id)sceneWithSize:(CGSize)size andArrayOfAtli:(NSArray *)arrayOfAtli withPlayerSkin:(NSString *)skin
{
    EDGameScene *scene = [EDGameScene sceneWithSize:size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [scene setArrayOfAtlases:arrayOfAtli];
    [scene setSkin:skin];
    return scene;
}
-(void)didMoveToView:(SKView *)view
{
    [self setupVariables];
    [self transitionIn];
    [self setupSound];
    [self addSwipeEvent:self.view];
    [self setupScene];
}
-(void)addSwipeEvent:(UIView *)subView
{
    //Add gesture recognizers to view
    rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeRecognizer:)];
    [rightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [rightRecognizer setNumberOfTouchesRequired:1];
    [subView addGestureRecognizer:rightRecognizer];
    
    leftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeRecognizer:)];
    [leftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [leftRecognizer setNumberOfTouchesRequired:1];
    [subView addGestureRecognizer:leftRecognizer];
    subView_ = subView;
}
-(void)setupVariables
{
    //Sets up basic variables
    screenWidth = self.frame.size.width;
    screenHeight = self.frame.size.height;
    backgroundLayer = [SKNode node];
    currentGameState = InGame;
    currentPlayerState = Idle;
    currentKillCount = 0;
    SKAction *intro = [SKAction group:@[[SKAction fadeInWithDuration:.5],[SKAction scaleTo:1 duration:.1]]];
    popIn = [SKAction sequence:@[intro,[SKAction scaleTo:1.5 duration:.1],[SKAction scaleTo:1 duration:.1]]];
    popOut = [SKAction group:@[[SKAction fadeOutWithDuration:.5],[SKAction scaleTo:0 duration:.1]]];
    pop = [SKAction sequence:@[popIn,popOut]];
    [backgroundLayer setZPosition:1];
    gameLayer = [SKNode node];
    [gameLayer setZPosition:11];
    menuLayer = [SKNode node];
    [menuLayer setZPosition:21];
    [self addChild:backgroundLayer];
    [self addChild:gameLayer];
    [self addChild:menuLayer];
    //Setup camera
    camNode = [SKCameraNode node];
    [camNode setPosition:CGPointMake(screenWidth/2, screenHeight/2)];
    //[camNode setScale:2.5];
    [self addChild:camNode];
    [self setCamera:camNode];
}
-(void)setupScene
{
    //Create stage
    NSLog(@"screen WIDTH %f AND HEIGHT %f",self.view.frame.size.width,self.view.frame.size.height);
    EDDefaultStage *gameStage = [EDDefaultStage stageWithName:@"default" size:self.size];
    [backgroundLayer addChild:gameStage];
    [gameStage setPosition:CGPointMake(screenWidth/2, screenHeight/2)];
    //Create character
    player = [EDPlayer playerWithSkin:@"Swordsman" withScreenSize:self.scene.size];\
    [player setPosition:CGPointMake(screenWidth*1.5, screenHeight/4.55)];
    [gameLayer addChild:player];
    isPlayerAlive = YES;
    isTrackingPlayer = YES;
    //Add currentScoreLabel
    currentScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
    [currentScoreLabel setFontSize:30];
    [menuLayer addChild:currentScoreLabel];
    [currentScoreLabel setZPosition:currentScoreLabel.zPosition+5];
    [currentScoreLabel setPosition:CGPointMake(-screenWidth/3,+screenHeight/12)];
    [currentScoreLabel setText:[NSString stringWithFormat:@"%i kills",currentKillCount]];
    //GeneratorManager on creation immediately begins spawning
    genManager = [EDGeneratorManager generatorManagerWithLayer:gameLayer withPlayer:player];
    [genManager setPosition:CGPointMake(screenWidth*1.5,+screenHeight)];
    [gameLayer addChild:genManager];
    [genManager addToQuota:2000];
    //begin raining petal particles
    [self setupParticles];
    //Countdown
    [self beginCountdown];
    [self beginPeriodicallySaving];
    //Begin loading ad
    [self createAndLoadInterstitial];
}
#pragma mark - Update
-(void)update:(NSTimeInterval)currentTime
{
    //Waits for enemies to stop attacking before making them idle
    [self makeAllEnemiesStopAttacking];
    //track cam on player
    [self trackPlayerWithCamera];
    //Run update func for player class
    [self enumerateChildNodesWithName:@"player" usingBlock:^(SKNode *node, BOOL *stop){
        EDPlayer *tempPlayer = (EDPlayer *)node;
        [tempPlayer update];
    }];
    //Run update for generators and enemies
    if(currentGameState == InGame)
    {
        [genManager updateManager];
    }

    
    //Neccesary for spine animations to run

}
#pragma mark - Swipes
-(void)SwipeRecognizer:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction == UISwipeGestureRecognizerDirectionRight && currentGameState == InGame)
    {
        NSLog(@"Right swiped");
        if(currentPlayerState == Idle)
        [self attackWithSwipeDirection:@"right"];
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionLeft && currentGameState == InGame)
    {
        NSLog(@"Left swiped");
        if(currentPlayerState == Idle)
        [self attackWithSwipeDirection:@"left"];
    }
}

#pragma mark - Touches
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //Handles dodge

    if(currentGameState == InGame && currentPlayerState == Idle && !player.isDodging)
    {
        currentPlayerState = Dodging;
        if(player.xScale == -1)
        {
            if(player.position.x + player.size.width/2 < screenWidth*3)
            [player runAction:[SKAction moveToX:player.position.x + player.size.width/2 duration:.15]];
        }
        else
        {
            if(player.position.x - player.size.width/2 > 0)
            [player runAction:[SKAction moveToX:player.position.x - player.size.width/2 duration:.15]];

        }
        currentPlayerState = Idle;
        [player playDodge];
    }
    //Handles replay and menu
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        if(currentGameState == GameOver && [node.name isEqualToString:@"menuButton"])
        {
            EDMainMenu *menuScene = [EDMainMenu sceneWithSize:self.view.bounds.size andArrayOfAtli:self.arrayOfAtlases];
            [musicPlayer stop];
            [self removeGestureRecognizers];
            [self.view presentScene:menuScene];
            
        }
        else if(currentGameState == GameOver && [node.name isEqualToString:@"replayButton"])
        {
            EDGameScene *gameScene = [EDGameScene sceneWithSize:self.view.bounds.size andArrayOfAtli:self.arrayOfAtlases withPlayerSkin:@"Swordsman"];
            [musicPlayer stop];
            [self removeGestureRecognizers];
            [EDGameData sharedInstance].totalPlays++;
            [self.view presentScene:gameScene];

        }
    }

}
-(void)removeGestureRecognizers
{
    [subView_ removeGestureRecognizer:leftRecognizer];
    [subView_ removeGestureRecognizer:rightRecognizer];
}
#pragma mark - Player functions
-(void)playerTookDamageWithEnemy:(EDEnemy *)enemy
{
    int hits = ([enemy.name isEqualToString:@"bigEnemy"])?2:1;
    [player takeDamageWithAmountOfHits:hits];
    if(player.hits <= 0 && currentGameState == InGame)
    {
        [self beginGameOver];
    }

}
-(void)explodePlayer
{
    if(isPlayerAlive == YES)
    {
        CGPoint copiedPlayerPos = player.position;
        [player removeFromParent];
        isPlayerAlive = NO;
        isTrackingPlayer = NO;
        //[player setAlpha:0];
        NSLog(@"exploding");
        for (SKTexture *texture in player.arrayOfExplosionTexture)
        {
            SKSpriteNode *limb = [SKSpriteNode spriteNodeWithTexture:texture size:CGSizeMake(self.scene.frame.size.height/  24.84, self.scene.frame.size.height/24.84)];
            [limb setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.scene.frame.size.height/62.1, self.scene.frame.size.height/62.1)]];
            [limb.physicsBody setMass:1];
            [limb setScale:1.3];
            [limb setZPosition:25];
            [self addChild:limb];
            [limb setPosition:CGPointMake(copiedPlayerPos.x, copiedPlayerPos.y + 15)];
            [limb setAlpha:1];
            [limb runAction:[SKAction runBlock:^{
                float xValue = (player.xScale == 1)?-400:600;
                [limb.physicsBody applyImpulse:CGVectorMake(xValue, self.scene.frame.size.height/6.42)];
            }]];
        }
    }
}

//Dashes to enemy and attacks
-(void)attackWithSwipeDirection:(NSString *)direction
{

    if([[genManager allEnemies] count] > 0)
    {
        float dashTime = .5;
        EDEnemy *closestEnemy = [self closestEnemyWithDirection:direction];
        CGPoint closestEnemyPos = [self convertPoint:closestEnemy.position fromNode:closestEnemy.parent];
        CGPoint playerPos = [self playerPositionInScene];
        //NSLog(@"%i",(int)[[genManager allEnemies] count]);
        if([direction isEqualToString:@"left"])
        {
            if(closestEnemyPos.x > playerPos.x){NSLog(@"No enemies on left side");}
            else if(playerPos.x - closestEnemyPos.x > 100)
            {
                currentPlayerState = Attacking;
                //NSLog(@"Far difference :%f",playerPos.x - closestEnemyPos.x);
                [player playDashWithDirection:direction];
                [player playRunningSound];
                [player runAction:[SKAction moveToX:(int)closestEnemyPos.x + screenHeight/19 duration:[self calculateDashTimeWith:playerPos.x WithEnemyPos:closestEnemyPos.x]] completion:^{
                    CGPoint playerPosAfterDash = [self playerPositionInScene];
                    //NSLog(@"player %f, enemy %f",playerPosAfterDash.x,closestEnemyPos.x);
                    int paddedEnemyPosition = (int)closestEnemyPos.x + (int)screenHeight/19;
                    //NSLog(@"player %f, enemy %i",playerPosAfterDash.x,paddedEnemyPosition );
                    if((int)playerPosAfterDash.x == paddedEnemyPosition)
                    {
                        //plays slash animation
                        currentPlayerState = Idle;
                        [self playSlash];
                        [closestEnemy takeDamage];
                        [player setIsAnimationPlaying:NO];
                        [player attackWithDirection:direction];
                    }
                }];
            }
            else if(playerPos.x - closestEnemyPos.x < 100)
            {
                currentPlayerState = Attacking;
                //NSLog(@"Close difference:%f",playerPos.x-closestEnemyPos.x);
                [player attackWithDirection:direction];
                [self playSlash];
                [self runAction:[SKAction waitForDuration:.04] completion:^{
                    currentPlayerState = Idle;
                    [closestEnemy takeDamage];
                }];
            }
        }
        else if([direction isEqualToString:@"right"])
        {
            if(closestEnemyPos.x < playerPos.x){NSLog(@"No enemies on right side");}
            else if(closestEnemyPos.x - playerPos.x > screenHeight/12.42)
            {
                currentPlayerState = Attacking;
                //NSLog(@"Far difference :%f",closestEnemyPos.x-playerPos.x);
                [player playDashWithDirection:direction];
                [player playRunningSound];
                [player runAction:[SKAction moveToX:(int)closestEnemyPos.x - (int)screenHeight/19 duration:[self calculateDashTimeWith:playerPos.x WithEnemyPos:closestEnemyPos.x]] completion:^{
                    CGPoint playerPosAfterDash = [self playerPositionInScene];
                    int paddedEnemyPosition = (int)closestEnemyPos.x - (int)screenHeight/19;
                    //NSLog(@"player %f, enemy %i",playerPosAfterDash.x,paddedEnemyPosition );
                    if((int)playerPosAfterDash.x == (int)paddedEnemyPosition)
                    {
                        currentPlayerState = Idle;
                        [self playSlash];
                        [closestEnemy takeDamage];
                        [player setIsAnimationPlaying:NO];
                        [player attackWithDirection:direction];
                    }
                }];
            }
            else if(closestEnemyPos.x - playerPos.x < screenHeight/12.42)
            {
                currentPlayerState = Attacking;
                //NSLog(@"Close difference:%f",closestEnemyPos.x-playerPos.x);
                [player attackWithDirection:direction];
                [self playSlash];
                [self runAction:[SKAction waitForDuration:.04] completion:^{
                    currentPlayerState = Idle;
                    [closestEnemy takeDamage];
                }];
            }
        }
    }
}
//Enumerates throuw array of all enemies and returns closest one
-(EDEnemy *)closestEnemyWithDirection:(NSString *)direction
{
    EDEnemy *closestEnemy = [[genManager allEnemies] objectAtIndex:0];
    CGPoint closestEnemyPos;
    CGPoint playerPos = [self playerPositionInScene];
    for(int i = 1; i < [[genManager allEnemies] count]; i++)
    {
        EDEnemy *currentEnemy = [[genManager allEnemies] objectAtIndex:i];
        CGPoint currentEnemyPos = [self convertPoint:currentEnemy.position fromNode:currentEnemy.parent];
        closestEnemyPos = [self convertPoint:closestEnemy.position fromNode:closestEnemy.parent];
        if([direction isEqualToString:@"right"])
        {
            if(closestEnemyPos.x > playerPos.x)
            {
                if(currentEnemyPos.x > playerPos.x)
                {
                    closestEnemy = (closestEnemyPos.x < currentEnemyPos.x)?closestEnemy:currentEnemy;
                }
            }
            else
            {
                closestEnemy = currentEnemy;
            }
        }
        else
        {
            if(closestEnemyPos.x < playerPos.x)
            {
                if(currentEnemyPos.x < playerPos.x)
                {
                    closestEnemy = (closestEnemyPos.x > currentEnemyPos.x)?closestEnemy:currentEnemy;
                }
            }
            else
            {
                closestEnemy = currentEnemy;
            }
        }
    }
    closestEnemyPos = [self convertPoint:closestEnemy.position fromNode:closestEnemy.parent];
    //NSLog(@"Pos was %f and closest enemy pos was %f on %@ side",playerPos.x,closestEnemyPos.x,closestEnemy.direction);
    //[closestEnemy runAction:[SKAction colorizeWithColor:[UIColor blueColor] colorBlendFactor:.5 duration:0]];
    return closestEnemy;
}-(float)calculateDashTimeWith:(float)playerXPos WithEnemyPos:(float)enemyXPos
{
    float dashTime = 0;
    float slowestSpeed = .5;
    float quickestSpeed = .2;
    float greatestDistance = screenHeight/1.38;
    float leastDistance = greatestDistance/4.5;
    //Dashing left
    if(playerXPos > enemyXPos)
    {
        NSLog(@"Dashing left");
        if(playerXPos - enemyXPos > greatestDistance)
            dashTime = slowestSpeed;
        else if(playerXPos - enemyXPos < leastDistance)
            dashTime = .1;
        else if(playerXPos - enemyXPos < greatestDistance)
            dashTime = quickestSpeed;
    }
    else if(playerXPos < enemyXPos)
    {
        NSLog(@"Dashing right");
        if(enemyXPos - playerXPos > greatestDistance)
            dashTime = slowestSpeed;
        else if(enemyXPos - playerXPos < leastDistance)
            dashTime = .1;
        else if(enemyXPos - playerXPos < greatestDistance)
            dashTime = quickestSpeed;

    }
    NSLog(@"Dash speed is %f",dashTime);
    return dashTime;
    
}
#pragma mark - effects
-(void)setupParticles
{
    NSString *pathToParticle = [[NSBundle mainBundle]pathForResource:@"petalEmitterInGame" ofType:@"sks"];
    petalParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToParticle];
    [backgroundLayer addChild:petalParticle];
    [petalParticle setZPosition:6];
    [petalParticle setPosition:CGPointMake(+0, screenHeight+screenHeight/12)];
    float baseXPosition = -screenHeight/1.5;
    for(int currentEmitterIdx = 0; currentEmitterIdx < 10; currentEmitterIdx++)
    {
        SKEmitterNode *newEmitter = [petalParticle copy];
        [backgroundLayer addChild:newEmitter];
        baseXPosition += screenWidth/3.5;
        [newEmitter setPosition:CGPointMake(baseXPosition, screenHeight)];
    }
}
#pragma mark - Sound
-(void)setupSound
{
    musicPlayer = [[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Jahzzar-Foreigner" ofType:@"wav"]] error:nil];
    [musicPlayer setNumberOfLoops:999];
    [musicPlayer setVolume:.4];
    if([EDGameData sharedInstance].isSoundOn)
        [musicPlayer play];

}
-(void)playSlash
{
    if([EDGameData sharedInstance].isSoundOn)
    [self runAction:[SKAction playSoundFileNamed:@"slashSound" waitForCompletion:NO]];
}
#pragma mark - Game over
-(void)beginGameOver
{
    NSLog(@"GAME OVER");
    [self explodePlayer];
    //MAKE ALL ENEMIES STOP MOVING
    stopAllEnemyAttacking = YES;
    [self showAdMobInterstitial];
    //BEGIN GAME OVER
    currentGameState = GameOver;


    //jandle highscore

    [self handleScores];
    [self loadInEndMenu];
    

}
-(void)loadInEndMenu
{
    menuButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"backButton"] size:CGSizeMake(screenWidth/7.215,screenHeight/4.058)];
    [menuButton setName:@"menuButton"];
    [menuLayer addChild:menuButton];
    [menuButton setAlpha:0];
    [menuButton setPosition:CGPointMake(-player.size.width/3,+screenHeight/2)];
    replayButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"replayButton"] size:CGSizeMake(screenWidth/7.215,screenHeight/4.058)];
    [replayButton setName:@"replayButton"];
    [menuLayer addChild:replayButton];
    [replayButton setAlpha:0];
    [replayButton setPosition:CGPointMake(+player.size.width/3,+screenHeight/2)];
    [replayButton runAction:popIn];
    [menuButton runAction:popIn];
}
-(void)makeAllEnemiesStopAttacking
{
    if(genManager.allEnemies && stopAllEnemyAttacking == YES)
    {
        [genManager.allEnemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop){
            if(genManager.allEnemies)
            {
                EDEnemy *enemy = (EDEnemy *)obj;
                if(!enemy.isAttacking)
                {
                    [enemy setIsAlive:NO];
                    [enemy playIdle];
                    [genManager.allEnemies removeObject:obj];
                }
            }
        }];
    }
}
#pragma mark - Ad stuff
-(void)createAndLoadInterstitial
{
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:@""];
    GADRequest *request = [GADRequest request];
    //Request test ads on devices you specify
    [interstitial loadRequest:request];
    //[self performSelector:@selector(showAdMobInterstitial) withObject:nil afterDelay:1.5];
}
-(void)showAdMobInterstitial
{
    [musicPlayer stop];
    currentGameState = InAd;
    AppDelegate *app = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    NSLog(@"%i plays so far",[EDGameData sharedInstance].totalPlays);
    if(interstitial.isReady && [EDGameData sharedInstance].totalPlays % 2 == 0)
    {
        [interstitial presentFromRootViewController: app.viewController];
    }
    else if(!interstitial.isReady)
        NSLog(@"Ad not ready");
    currentGameState = GameOver;
    interstitial = nil;
    [self runAction:[SKAction waitForDuration:5] completion:^{
        if([EDGameData sharedInstance].isSoundOn == YES)
            [musicPlayer play];
    }];
    //[self createAndLoadInterstitial];
}
#pragma mark - Points and score management
-(void)handleHighScoreAchievement
{
    if(currentKillCount > [EDGameData sharedInstance].bestKillCount && !isHighScoreBeaten)
    {
        isHighScoreBeaten = YES;
        NSLog(@"New high score is %i",currentKillCount);
        [[EDGameData sharedInstance] save];
        ///Load in highScore emblem on top of the screen
        highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
        [highScoreLabel setFontSize:60];
        [highScoreLabel setText:@"New highscore!"];
        [menuLayer addChild:highScoreLabel];
        [highScoreLabel setPosition:CGPointMake(+0,+screenHeight/2)];
        [highScoreLabel setAlpha:0];
        [highScoreLabel runAction:[SKAction sequence:@[popIn,[SKAction waitForDuration:1],popOut]]];
        //Turn current score label yellow and scale it slightly to show increasing highscore
        [currentScoreLabel runAction:[SKAction scaleTo:1.6 duration:.1]];
        [currentScoreLabel setFontColor:[UIColor yellowColor]];

    }
}
#pragma mark - Miscellaneous functions
-(void)incrementCurrentKillCount
{
    currentKillCount++;
    [[EDGameData sharedInstance] incrementTotalKills];
    [self handleHighScoreAchievement];
    [currentScoreLabel setText:[NSString stringWithFormat:@"%i kills",currentKillCount]];
    if(isHighScoreBeaten)
    {
        [currentScoreLabel setXScale:currentScoreLabel.xScale + .01];
        [currentScoreLabel setYScale:currentScoreLabel.yScale + .01];
    }
    
}
-(void)handleScores
{
    //HANDLES HIGH SCORE
    if(currentKillCount > [EDGameData sharedInstance].bestKillCount)
    {
        [[EDGameData sharedInstance] setBestKillCount:currentKillCount];
    }
    //HANDLES DEATHS
    [[EDGameData sharedInstance] incrementTotalDeaths];
    [[EDGameData sharedInstance] save];
}
-(void)transitionIn
{
    SKShapeNode *expandedCircle = [SKShapeNode shapeNodeWithCircleOfRadius:15];
    [expandedCircle setScale:50];
    [expandedCircle setFillColor:[UIColor colorWithRed:0.286 green:0.376 blue:0.49 alpha:1]];
    [expandedCircle setStrokeColor:[UIColor colorWithRed:0.286 green:0.376 blue:0.49 alpha:1]];
    [self addChild:expandedCircle];
    [expandedCircle setZPosition:30];
    [expandedCircle setPosition:CGPointMake(screenWidth*1.5, screenHeight/4.5)];
    [expandedCircle runAction:[SKAction scaleTo:0 duration:.3] completion:^(void){
        [expandedCircle runAction:[SKAction fadeOutWithDuration:.1] completion:^{
            [expandedCircle removeFromParent];
        }];
    }];

}
-(void)beginPeriodicallySaving
{
    id wait = [SKAction waitForDuration:10];
    id block = [SKAction runBlock:^{
        if(currentGameState == InGame)
        {
            [[EDGameData sharedInstance] save];
        }
    }];
    [self runAction:[SKAction sequence:@[wait,block]]];
}
-(void)beginCountdown
{
    NSLog(@"Beginning countdown");
    currentGameState = Countdown;
    SKLabelNode *countdownText = [SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
    [countdownText setFontSize:125];
    [countdownText setAlpha:.5];
    [countdownText setPosition:CGPointMake(screenWidth + screenWidth/2, +screenHeight)];
    [gameLayer addChild:countdownText];
    [countdownText runAction:[SKAction group:@[[SKAction moveToY:screenHeight/2 duration:.1 ],[SKAction fadeInWithDuration:.14]]]completion:^{
        timeInSeconds = 3;
        id wait = [SKAction waitForDuration:1];
        id run = [SKAction runBlock:^(void){
            if(timeInSeconds > 0)
            {
                timeInSeconds--;
                [countdownText setText:[NSString stringWithFormat:@"%i",timeInSeconds + 1]];
            }
            else if(timeInSeconds == 0)
            {
                [countdownText setText:@"Go!"];
                [countdownText runAction:[SKAction scaleTo:2 duration:.15] completion:^{
                    [countdownText runAction:[SKAction fadeOutWithDuration:.15] completion:^{
                        currentGameState = InGame;
                        [countdownText removeFromParent];
                    }];
                }];
            }
        }];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wait,run]]] withKey:@"time"];
    }];
    }
-(void)trackPlayerWithCamera
{
    //Camera tracks player
    //NSLog(@"player pos",[self playerPositionInScene].x, screenWidth);
    if(isTrackingPlayer == YES)
    {
        if([self playerPositionInScene].x < screenWidth/2){}
        else if([self playerPositionInScene].x > screenWidth*3 - screenWidth/2){}
        else
        {
            [camNode setPosition:CGPointMake(player.position.x, camNode.position.y)];
            [menuLayer setPosition:CGPointMake(player.position.x, menuLayer.position.y)];
        }
    }
}
-(CGPoint)playerPositionInScene
{
    return [self convertPoint:player.position fromNode:player.parent];
}
@end
