//
//  EDCharacterForDisplay.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 7/5/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDCharacterForDisplay.h"

@implementation EDCharacterForDisplay
+(id)characterForDisplayWithSkin:(NSString *)skin withTips:(NSArray *)arrayOfTips withSize:(CGSize)size
{
    CGSize displaySize = ([skin isEqualToString:@"Swordsman"])?CGSizeMake(size.width/3.247, size.height/3.105):CGSizeMake(size.width/4.874, size.height/2.741);
    EDCharacterForDisplay *charDisplay = [EDCharacterForDisplay spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-idle0",skin]] size:displaySize];
    [charDisplay setSkinName:skin];
    [charDisplay setArrayOfIdle:[NSMutableArray array]];
    NSDictionary *frameData = @{@"Swordsman" : @31,
                                @"bigEnemy" : @41,
                                @"normalEnemy" : @32
                                };
    
    [charDisplay setLeftTip:arrayOfTips[0]];
    [charDisplay setRightTip:arrayOfTips[1]];
    [charDisplay setSpotlight:arrayOfTips[2]];
    if([skin isEqualToString:@"Swordsman"])
    {
        for(int frameCount = 0; frameCount < ((NSNumber *)[frameData objectForKey:skin]).intValue; frameCount++)
        {
            [charDisplay.arrayOfIdle addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@-idle%i",skin,frameCount]]];
        }
        [charDisplay runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:charDisplay.arrayOfIdle timePerFrame:.04]]];
    }
    return charDisplay;
}
-(void)updateCharDisplay
{
    
    if([self isBetweenBoundaries])
    {
        [self runAction:[SKAction scaleTo:1.3 duration:.2]];
        [self setSkinName:@"Swordsman"];
    }
    else
    {
        [self runAction:[SKAction scaleTo:.8 duration:.2]];
        //[self runAction:[SKAction moveToX:-middleOfSpotlight duration:.2]];

    }
}
-(BOOL)isBetweenBoundaries
{
    CGPoint leftBoundary = [self.scene convertPoint:self.leftTip.position fromNode:self.leftTip.parent];
    CGPoint rightBoundary = [self.scene convertPoint:self.rightTip.position fromNode:self.rightTip.parent];
    CGPoint displayPosition = [self.scene convertPoint:self.position fromNode:self.parent];
    return (displayPosition.x > leftBoundary.x && displayPosition.x < rightBoundary.x);
}
@end
