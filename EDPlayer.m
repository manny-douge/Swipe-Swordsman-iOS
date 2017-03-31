//
//  EDPlayer.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/4/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDPlayer.h"
@implementation EDPlayer
+(id)playerWithSkin:(NSString *)skinName withScreenSize:(CGSize)size
{
    //Create character node to control charater
    EDPlayer *player = [EDPlayer spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-idle0",skinName]] size:CGSizeMake(size.width/3.247, size.height/3.105)];
    [player setName:@"player"];
    [player setAnchorPoint:CGPointMake(.5, .5)];
    [player setSkin:skinName];
    [player setHits:3];
    [player setScreenSize:size];
    //[player setPositionTracker:[SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(20, 20)]];
    //[player.positionTracker setZPosition:player.zPosition + 1];
    //[player addChild:player.positionTracker];
    [player setCanBeInterrupted:YES];
    [player setArrayOfIdle:[NSMutableArray array]];
    [player setArrayOfDash:[NSMutableArray array]];
    [player setArrayOfDodge:[NSMutableArray array]];
    [player setArrayOfDamageTaken:[NSMutableArray array]];
    [player setArrayOfAttackOne:[NSMutableArray array]];
    [player setArrayOfAttackTwo:[NSMutableArray array]];
    [player setArrayOfAttackThree:[NSMutableArray array]];
    [player setArrayOfExplosionTexture:[NSMutableArray array]];
    //Load animations into array
    [player loadFramesIntoArray];
    if(!player.soundPlayer)
    {
        [player setSoundPlayer:[[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"runningSound" ofType:@"wav"]] error:nil]];
        [player.soundPlayer setVolume:.15];
    }
    //Play idle animation
    [player playIdle];
    return player;
}

-(void)loadFramesIntoArray
{
    //Load idle frame data
    for(int num=0;num<31;num++){[self.arrayOfIdle addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-idle%i",self.skin,num]]];}
    for(int num=0;num<12;num++){[self.arrayOfDash addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-dash%i",self.skin,num]]];}
    for(int num=0;num<18;num++){[self.arrayOfDamageTaken addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-damageTaken%i",self.skin,num]]];}
    for(int num=0;num<31;num++){[self.arrayOfAttackOne addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-attackOne%i",self.skin,num]]];}
    for(int num=0;num<24;num++){[self.arrayOfAttackTwo addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-attackTwo%i",self.skin,num]]];}
    for(int num=0;num<5;num++){[self.arrayOfDodge addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-dodge%i",self.skin,num]]];}

    NSArray *limbType = @[@"head",@"left-forearm",@"left-shoulder",@"left-thigh",@"torso",@"right-forearm",
                          @"right-knee",@"right-shoulder",@"right-thigh",@"sword"];
    //LOAD EXPLSION TEXTURES
    for(int currentLimbIdx = 0; currentLimbIdx < limbType.count; currentLimbIdx++)
        [self.arrayOfExplosionTexture addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@",limbType[currentLimbIdx]]]];

    //****USING ARRAY RESULTS IN ERROR LOADING IMAGE****
    /*Load frame data into array
    NSArray *animationNames = @[@"attackOne", @"attackTwo", @"attackThree", @"idle",@"dash", @"damagetaken", @"dodge"];
    NSArray *animationFrames = @[@25,@25,@25,@25,@1,@1,@1];
    for (int animTypeIdx=0; animTypeIdx<7; animTypeIdx++)
    {
        for (int animNum=0; animNum<((int)animationFrames[animTypeIdx]); animNum++)
        {
           [self.arrayOfAnimations[animTypeIdx] addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-%@%i.png",self.skin,animationNames[animTypeIdx],animNum]]];
        }
    }*/
}
//Must be called IN SCENES UPDATES
-(void)update
{
    [self playIdle];
    //NSLog(@"tracker pos is %f,%f",self.position.x,self.position.y);
}
//Waits for no animation to be played then plays idle
-(void)playIdle
{
    if(!self.isAnimationPlaying)
    {
        [self runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:self.arrayOfIdle timePerFrame:.04]]];
    }
}
//Essentially handles the logic to play an animation with interruption time
-(void)attackWithDirection:(NSString *)direction
{
    //Handle direction
    [self setXScale:([direction isEqualToString:@"left"])?-1:1];
    //Lets you interrupt animaton with another swipe

        //Handle random attack
        int randNum = (arc4random() % 2) + 1;
        float interruptionTime = .05;
        //NSLog(@"Playing attack%i",randNum);
        if(self.isAnimationPlaying == NO)
        {
            [self setIsAnimationPlaying:YES];
            [self setCanBeInterrupted:NO];
            [self playAttackAnimationWithNum:randNum];
            [self runAction:[SKAction waitForDuration:interruptionTime] completion:^{
                [self setIsAnimationPlaying:NO]; //Allows to be interrupted with another attack after .2
                
            }];
        }

    
}
//Plays attack animation for num
-(void)playAttackAnimationWithNum:(int)attackNum
{
    if(attackNum == 1){[self runAction:[SKAction animateWithTextures:self.arrayOfAttackOne timePerFrame:.02]];}
    else if(attackNum == 2){[self runAction:[SKAction animateWithTextures:self.arrayOfAttackTwo timePerFrame:.02]];}
}
-(void)playDamageTaken
{
    [self runAction:[SKAction animateWithTextures:self.arrayOfDamageTaken timePerFrame:.03]];
}
-(void)playDashWithDirection:(NSString *)direction
{
    [self setIsAnimationPlaying:YES];
    [self setXScale:([direction isEqualToString:@"left"])?-1:1];
    SKAction *dash = [SKAction animateWithTextures:self.arrayOfDash timePerFrame:.03];
    [self runAction:[SKAction repeatAction:dash count:2]];
}
-(void)playDodge
{
    if(!self.isDodging)
    {
        [self setIsDodging:YES];
        [self setIsAnimationPlaying:YES];
        [self runAction:[SKAction animateWithTextures:self.arrayOfDodge timePerFrame:.04] completion:^{
            [self setIsAnimationPlaying:NO];
            [self setIsDodging:NO];
        }];
    }
}
-(void)takeDamageWithAmountOfHits:(int) amountOfHits
{
    self.hits-=amountOfHits;
    [self playDamageTaken];
    //NSLog(@"Player took damage");
    [self runAction:[SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:.6 duration:.1] completion:^{
        [self runAction:[SKAction colorizeWithColorBlendFactor:0 duration:.1]];
    }];
}
-(void)playRunningSound
{
    
    if([EDGameData sharedInstance].isSoundOn)
        [self.soundPlayer play];
}
@end
