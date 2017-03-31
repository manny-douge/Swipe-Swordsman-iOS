//
//  EDMainMenu.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 5/31/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDMainMenu.h"
#import "EDGameData.h"
#import "EDButton.h"
#import "EDGameScene.h"
#import "EDCharacterForDisplay.h"
#import "AVFoundation/AVFoundation.h"
@implementation EDMainMenu
{
    BOOL didPlayTutorial;
    int currentScoreSurvival;
    int currentScoreTimeTrial;
    int numOfPlayableCharacters;
    
    float screenWidth;
    float screenHeight;
    float farthestDisplay;
    
    SKNode *backgroundLayer;
    SKNode *menuLayer;
    SKNode *leftTipOfSpotlight;
    SKNode *rightTipOfSpotlight;
    
    SKSpriteNode *tutorialImage;
    SKSpriteNode *soundButton;
    
    NSArray *buttonsToHide;
    NSArray *allButtons;
    NSMutableArray *allCharacterDisplays;
    NSMutableArray *leftSideEnemies;
    NSMutableArray *rightSideEnemies;
    
    EDButton *playButton;
    EDButton *charactersButton;
    EDButton *settingsButton;
    
    CGPoint initialTouchPosition;
    CGPoint lastMovedPos;
    
    AVAudioPlayer *musicPlayer;
    
    SKEmitterNode *petalParticle;
    SKNode *headOfCharacterDisplayNodes;
}
#pragma mark - Moved to View
+(id)sceneWithSize:(CGSize)size andArrayOfAtli:(NSArray *)arrayOfAtli
{
    EDMainMenu * scene = [EDMainMenu sceneWithSize:size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [scene setArrayOfAtlases:arrayOfAtli];
    return scene;
}
-(void)didMoveToView:(SKView *)view
{
    //Load variables and setup scene
    [self setAnchorPoint:CGPointMake(0, 0)];
    [self loadVariables];
    [self setupScene];
}
-(void)loadVariables
{
    SKLabelNode *loadText = [SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
    [self addChild:loadText];
    [loadText setText:@"Test"];
    [loadText removeFromParent];
    screenWidth = self.frame.size.width;
    screenHeight = self.frame.size.height;
    menuLayer = [SKNode node];
    backgroundLayer = [SKNode node];
    backgroundLayer.zPosition = 1;
    menuLayer.zPosition = 11;
    numOfPlayableCharacters = 4;
    leftSideEnemies = [NSMutableArray array];
    rightSideEnemies = [NSMutableArray array];
    //SKCameraNode *cam = [SKCameraNode node];
    //[cam setPosition:CGPointMake(screenWidth/2, screenHeight/2)];
    //[self setCamera:cam];
    //[self addChild:cam];
    //[self.camera setScale:3];
    [self addChild:menuLayer];
    [self addChild:backgroundLayer];
    //Prepare gameData
    if([[EDGameData sharedInstance] didPlayTutorial] == NO)
    {
        NSLog(@"FIRST LAUNCH OF GAME ON THIS DEVICE OR NO DATA FOUND");
        self.currentState = InTutorial;
        [self beginTutorial];
    }
    else
        self.currentState = MainMenu;
    [[EDGameData sharedInstance]setTotalPlays:0];
    
}
-(void)setupScene
{
    //Prepares background
    SKSpriteNode *backgroundTexture = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"titleScreenBackground"] size:self.frame.size];
    [backgroundTexture setName:@"backgroundTexture"];
    [backgroundTexture setPosition:CGPointMake(screenWidth/2, screenHeight/2)];
    [backgroundTexture setZPosition:5];
    [backgroundLayer addChild:backgroundTexture];
    //GAME TITLE TEXT
    SKSpriteNode *gameTitleTexture = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"gameTitle"] size:CGSizeMake(screenWidth/1.698, screenHeight/2.3)];
    [gameTitleTexture setName:@"gameTitleTexture"];
    [gameTitleTexture setZPosition:backgroundTexture.zPosition + 2];
    [gameTitleTexture setPosition:CGPointMake(screenWidth/2, screenHeight/1.5)];
    [backgroundLayer addChild:gameTitleTexture];


    //Prepare all buttons
    UIColor *baseButtonColor = [UIColor colorWithRed:.2 green:.27 blue:.35 alpha:1];
    playButton = [EDButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"playButton"] size:CGSizeMake(screenWidth/4.874, screenHeight/2.741) name:@"playButton" color:[UIColor colorWithRed:0.286 green:0.376 blue:0.49 alpha:1]];
    [playButton setPosition:CGPointMake(screenWidth/2, screenHeight/4.5)];
    //[statsButton setName:@"statsButton"];
    [menuLayer addChild:playButton];
    charactersButton = [EDButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"charactersButton"] size:CGSizeMake(screenWidth/7.215, screenHeight/4.058) name:@"charactersButton" color:baseButtonColor];
    [charactersButton setPosition:CGPointMake(screenWidth/8, screenHeight/3)];
    [menuLayer addChild:charactersButton];
    settingsButton = [EDButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"settingsButton"] size:CGSizeMake(screenWidth/7.215, screenHeight/4.058) name:@"settingsButton" color:baseButtonColor];
    [settingsButton setPosition:CGPointMake(screenWidth - screenWidth/8, screenHeight/3)];
    [menuLayer addChild:settingsButton];
    [charactersButton beginFloatingAnimation];
    [settingsButton beginFloatingAnimation];
    [self runAction:[SKAction waitForDuration:2] completion:^{
        [playButton beginFloatingAnimation];
    }];
    allButtons = @[playButton,charactersButton,settingsButton];
    [self setupSound];
    [self setupParticles];
}
#pragma mark - Update
-(void)update:(NSTimeInterval)currentTime
{
    [allCharacterDisplays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        EDCharacterForDisplay *charDisplay = (EDCharacterForDisplay *)obj;
        [charDisplay updateCharDisplay];
    }];
    [self enumerateDisplaysAndFindString];
}
#pragma mark - Touches
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location;
    SKNode *node;
    for (UITouch *touch in touches)
    {
        location = [touch locationInNode:self];
        node = [self nodeAtPoint:location];
    }
    if([node.name isEqualToString:@"tutorialImage"] && self.currentState == InTutorial)
    {
        [node runAction:[SKAction fadeOutWithDuration:.4] completion:^{
            [node removeFromParent];
            [self setCurrentState:MainMenu];
            [[EDGameData sharedInstance] setDidPlayTutorial:YES];
            [[EDGameData sharedInstance] save];
        }];
    }
    else if([node.name isEqualToString:@"charactersButton"] && self.currentState == MainMenu)
    {
        NSLog(@"Characters button tapped");
        [self changeMenuStateTo:InCharacterSelect];
        [charactersButton expand];
        [self setupCharacterSelect];
        [self hideButtons:@[playButton,settingsButton]];
        
    }
    else if([node.name isEqualToString:@"playButton"] && self.currentState == MainMenu)
    {
        NSLog(@"Beginning game");
        EDButton *buttonNode = (EDButton *)node;
        [self hideButtons:@[settingsButton,charactersButton]];
        [buttonNode expand];
        [self runAction:[SKAction runBlock:^{
            EDGameScene *gameScene = [EDGameScene sceneWithSize:self.size andArrayOfAtli:self.arrayOfAtlases withPlayerSkin:self.currentSkin];
            [self runAction:[SKAction waitForDuration:.3] completion:^{
                [musicPlayer stop];
                [self.view presentScene:gameScene];
            }];
        }]];
    }
    else if([node.name containsString:@"ExitButton"])
    {
        EDButton *buttonNode = (EDButton *)node.parent;
        [buttonNode removeExpansion];
        [self changeMenuStateTo:MainMenu];
        [self unHideButtons];
    }
    else if(self.currentState == InCharacterSelect)
    {
        initialTouchPosition = location;
        NSLog(@"Initial touch position is %f,%f",initialTouchPosition.x,initialTouchPosition.y);
    }
    else if([node.name isEqualToString:@"settingsButton"] && self.currentState == MainMenu)
    {
        NSLog(@"Settings button tapped");
        [self changeMenuStateTo:InSettings];
        [settingsButton expand];
        [self hideButtons:@[playButton,charactersButton]];
        [self setupSettings];
    }
    //Settings touches
    else if([node.name containsString:@"sound"] && self.currentState == InSettings)
    {
        if([EDGameData sharedInstance].isSoundOn)
            [self turnSound:@"OFF"];
        else
            [self turnSound:@"ON"];
    }

}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint touchPos = [touch locationInNode:self];
        if(self.currentState == InCharacterSelect)
        {
            CGPoint newTouchPos = touchPos;
            CGPoint displayHeadPos = [self convertPoint:headOfCharacterDisplayNodes.position fromNode:headOfCharacterDisplayNodes.parent];
            float difference = fabs(newTouchPos.x - initialTouchPosition.x)/1.3;
            //NSLog(@"Head Pos %f mid screen pos %f",displayHeadPos.x,screenWidth/2.0);
            if(newTouchPos.x != lastMovedPos.x )
            {
                //left to move right
                if(newTouchPos.x  < initialTouchPosition.x && !((displayHeadPos.x - difference) < (screenWidth/2 - farthestDisplay)))
                {
                    //NSLog(@"Moving left new touch %f initial touch %f",newTouchPos.x,initialTouchPosition.x);
                    
                    [headOfCharacterDisplayNodes runAction:[SKAction moveToX:headOfCharacterDisplayNodes.position.x-difference duration:.06]];
                    
                }
                // left to move right
                if(newTouchPos.x  > initialTouchPosition.x && !((displayHeadPos.x + difference) > screenWidth/2))
                {
                    /*[headOfCharacterDisplayNodes setPosition:CGPointMake(headOfCharacterDisplayNodes.position.x+8,headOfCharacterDisplayNodes.position.y)];*/
                    //NSLog(@"Moving right new touch %f initial touch %f",newTouchPos.x,initialTouchPosition.x);
                    [headOfCharacterDisplayNodes runAction:[SKAction moveToX:headOfCharacterDisplayNodes.position.x+difference duration:.06]];

                }
                lastMovedPos = newTouchPos;
            }
        }
    }
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        //CGPoint endedPosition = [touch locationInNode:self];
        if(self.currentState == InCharacterSelect)
        {
            
        }
    }
}
#pragma mark - Settings functions
-(void)turnSound:(NSString *)choice
{
    if([choice isEqualToString:@"OFF"])
    {
        [soundButton setTexture:[SKTexture textureWithImageNamed:@"soundIsOffButton"]];
        [[EDGameData sharedInstance] setIsSoundOn:NO];
        [musicPlayer stop];
    }
    else if([choice isEqualToString:@"ON"])
    {
        [soundButton setTexture:[SKTexture textureWithImageNamed:@"soundIsOnButton"]];
        [[EDGameData sharedInstance] setIsSoundOn:YES];
        [musicPlayer play];
    }
    NSLog(@"Sound is now %@",choice);
    [[EDGameData sharedInstance]save];
}
//Adds basic settings/statistic to settings button
-(void)setupSettings
{
    id fadeIn = [SKAction fadeInWithDuration:.1];
    int fontSize = 60;
    SKLabelNode *bestKills = [SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
    [bestKills setName:@"buttonAccessory"];
    [bestKills setText:[NSString stringWithFormat:@"Best Kills: %i",[EDGameData sharedInstance].bestKillCount]];
    [bestKills setFontSize:fontSize];
    [bestKills setAlpha:0];
    [bestKills setZPosition:settingsButton.zPosition+1];
    [settingsButton addChild:bestKills];
    CGPoint bestKillsPos = [self.scene convertPoint:CGPointMake(screenWidth/2, screenHeight/1.3) toNode:bestKills.parent];
    [bestKills setPosition:bestKillsPos];
    
    SKLabelNode *totalKills = [SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
    [totalKills setName:@"buttonAccessory"];
    [totalKills setText:[NSString stringWithFormat:@"Total Kills: %i",[EDGameData sharedInstance].totalKills]];
    [totalKills setFontSize:fontSize];
    [totalKills setAlpha:0];
    [totalKills setZPosition:settingsButton.zPosition+1];
    [settingsButton addChild:totalKills];
    [totalKills setPosition:CGPointMake(bestKills.position.x, bestKills.position.y - screenHeight/5)];


    SKLabelNode *deathCount = [SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
    [deathCount setName:@"buttonAccessory"];
    [deathCount setFontSize:fontSize];
    [deathCount setAlpha:0];
    [deathCount setText:[NSString stringWithFormat:@"Total Deaths: %i",[EDGameData sharedInstance].totalDeaths]];
    [settingsButton addChild:deathCount];
    [deathCount setPosition:CGPointMake(totalKills.position.x, totalKills.position.y - screenHeight/5)];
    SKTexture *initialSoundTexture = [EDGameData sharedInstance].isSoundOn?[SKTexture textureWithImageNamed:@"soundIsOnButton"]:[SKTexture textureWithImageNamed:@"soundIsOffButton"];
    soundButton = [SKSpriteNode spriteNodeWithTexture:initialSoundTexture size:CGSizeMake(screenWidth/2.549, screenHeight/4.870)];
    [soundButton setAlpha:0];
    [soundButton setName:@"soundbuttonAccessory"];
    [settingsButton addChild:soundButton];
    [soundButton setPosition:CGPointMake(deathCount.position.x, deathCount.position.y - screenHeight/5)];
    for(SKNode *settingEntity in @[bestKills,totalKills,deathCount,soundButton])
        [settingEntity runAction:fadeIn];
    SKLabelNode *musicCredits = [ SKLabelNode labelNodeWithFontNamed:@"HookedUpOneOhOne-Regular"];
    [musicCredits setName:@"buttonAccessory"];
    [musicCredits setFontSize:15];
    [settingsButton addChild:musicCredits];
    [musicCredits setText:@"Game Music Jahzzar - Foreigner"];
    [musicCredits setPosition:CGPointMake(soundButton.position.x - screenWidth/3, soundButton.position.y)];
    SKLabelNode *musicCredits2 = [musicCredits copy];
    [musicCredits2 setText:@" Menu Music The Kyoto Connection - Voyage I Waterfall"];
    [settingsButton addChild:musicCredits2];
    [musicCredits2 setPosition:CGPointMake(musicCredits.position.x + screenHeight/8,musicCredits.position.y - screenHeight/7)];

}
#pragma mark - Sound functions
-(void)setupSound
{
    musicPlayer = [[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"The_Kyoto_Connection_-_03_-_Voyage_I_-_Waterfall" ofType:@"mp3"]] error:nil];
    [musicPlayer setNumberOfLoops:999];
    [musicPlayer setVolume:.4];
    if([EDGameData sharedInstance].isSoundOn)
        [musicPlayer play];
    
}
#pragma mark - Character Select Functions
//Finds the display in the spotlight and saves the string
-(void)enumerateDisplaysAndFindString
{
    [allCharacterDisplays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        EDCharacterForDisplay *display = (EDCharacterForDisplay *)obj;
        if([display isBetweenBoundaries])
        {
            self.currentSkin = display.skinName;
        }
    }];
}
//Loads in basic graphics
-(void)setupCharacterSelect
{
    //Setup spotlight
    SKSpriteNode *spotlightShadow = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"spotlightShadow"] size:CGSizeMake(screenWidth/2.666,screenHeight/12.42)];
    [spotlightShadow setName:@"buttonAccessory"];
    [charactersButton addChild:spotlightShadow];
    CGPoint spotLightPos = [charactersButton convertPoint:CGPointMake(screenWidth/2, screenHeight/2.5) fromNode:self];
    [spotlightShadow setPosition:spotLightPos];
    leftTipOfSpotlight = [SKNode node];
    [leftTipOfSpotlight setPosition:CGPointMake(spotLightPos.x - spotlightShadow.size.width/2.3, spotLightPos.y)];
    [charactersButton addChild:leftTipOfSpotlight];
    rightTipOfSpotlight = [SKNode node];
    [rightTipOfSpotlight setPosition:CGPointMake(spotLightPos.x + spotlightShadow.size.width/2.3, spotLightPos.y)];
    [charactersButton addChild:rightTipOfSpotlight];
    NSArray *tips = @[leftTipOfSpotlight,rightTipOfSpotlight,spotlightShadow];
    //setup head
    headOfCharacterDisplayNodes = [SKNode node];
    [headOfCharacterDisplayNodes setName:@"buttonAccessory"];
    [headOfCharacterDisplayNodes setPosition:CGPointMake(spotLightPos.x, spotLightPos.y + self.frame.size.height/6)];
    [charactersButton addChild:headOfCharacterDisplayNodes];
    allCharacterDisplays = [NSMutableArray array];
    NSArray *skins = @[@"Swordsman",@"comingSoon",@"comingSoon",@"comingSoon"];
    float startingDisplayPositon = -(screenWidth/3);
    for (int charCount = 0; charCount < numOfPlayableCharacters; charCount++)
    {
        EDCharacterForDisplay *charDisplay = [EDCharacterForDisplay characterForDisplayWithSkin:skins[charCount] withTips:tips withSize:self.scene.size];
        [headOfCharacterDisplayNodes addChild:charDisplay];
        [charDisplay setZPosition:spotlightShadow.zPosition + 1];
        startingDisplayPositon += screenWidth/3;
        [charDisplay setPosition:CGPointMake(charDisplay.position.x + startingDisplayPositon, charDisplay.position.y + screenHeight/10)];
        [allCharacterDisplays addObject:charDisplay];
    }
    //Setup heads
    farthestDisplay = startingDisplayPositon;
}
#pragma mark - Effects
-(void)setupParticles
{
    NSString *pathToParticle = [[NSBundle mainBundle]pathForResource:@"petalEmitterInGame" ofType:@"sks"];
    petalParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToParticle];
    [backgroundLayer addChild:petalParticle];
    [petalParticle setZPosition:6];
    [petalParticle setPosition:CGPointMake(+0, screenHeight+screenHeight/12)];
    float baseXPosition = -screenHeight/1.5;
    for(int currentEmitterIdx = 0; currentEmitterIdx < 8; currentEmitterIdx++)
    {
        SKEmitterNode *newEmitter = [petalParticle copy];
        [backgroundLayer addChild:newEmitter];
        baseXPosition += screenWidth/4;
        [newEmitter setPosition:CGPointMake(baseXPosition, screenHeight)];
    }
}
#pragma mark - Tutorial
-(void)beginTutorial
{
        [[EDGameData sharedInstance] reset];
        tutorialImage = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"tutorialTexture"] size:self.frame.size];
        [tutorialImage setName:@"tutorialImage"];
        [tutorialImage setZPosition:tutorialImage.zPosition + 5];
        [menuLayer addChild:tutorialImage];
        [tutorialImage setAlpha:0];
        [tutorialImage setPosition:CGPointMake(screenWidth/2, screenHeight/2)];
        [tutorialImage runAction:[SKAction fadeInWithDuration:1.5]];
}

//resumes floating aimation for buttons
#pragma mark - Miscellaneous title functions

//pauses floating animations for buttons
-(void)pauseMovingButtons
{
    for(SKNode *node in allButtons)
    {
        [node removeAllActions];
    }
}
-(void)resumeMovingButtons
{
    for(SKNode *node in allButtons)
    {
        EDButton *button = (EDButton *)node;
        [button beginFloatingAnimation];
    }
}
//Hides an array of buttons with a fade animation
-(void)hideButtons:(NSArray *)arrayOfButtons
{
    [self pauseMovingButtons];
    buttonsToHide = arrayOfButtons;
    for(id obj in buttonsToHide)
    {
        EDButton *button = (EDButton *)obj;
        [button runAction:[SKAction fadeOutWithDuration:.1] completion:^{
        }];
    }
}
//Unhides an array of buttons
-(void)unHideButtons
{
    [self resumeMovingButtons];
    for(id obj in buttonsToHide)
    {
        EDButton *button = (EDButton *)obj;
        [button runAction:[SKAction fadeInWithDuration:.1] completion:^{
        }];
    }
    buttonsToHide = nil;
}
//Changes state after exit button has been tapped
-(void)changeMenuStateTo:(enum MenuState) state
{
    [self runAction:[SKAction waitForDuration:.3] completion:^{
        [self setCurrentState:state];
        NSLog(@"Game state chnaged to %u",state);
    }];
}
@end
