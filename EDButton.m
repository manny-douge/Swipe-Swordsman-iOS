//
//  EDButton.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/1/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDButton.h"

//Used by checking if exitButton names contains exitButton
@implementation EDButton
{
    SKSpriteNode *exitButton;
    SKShapeNode *expandCircle;
}
+(id)spriteNodeWithTexture:(SKTexture *)texture size:(CGSize)size name:(NSString *)name color:(UIColor *)color
{
    EDButton *button = [EDButton spriteNodeWithTexture:texture size:size];
    [button setName:name];
    [button setExpandColor:color];
    [button setIsExpanded:NO];
    [button setFoundPosition:NO];
    return button;
}
//actiavtes floating

-(void)beginFloatingAnimation
{
    if(self.foundPosition == NO)
    {
        self.largestHeight = self.position.y + self.scene.size.height/40;
        self.lowestHeight = self.position.y - self.scene.size.height/40;
        [self setFoundPosition:YES];
    }
    float buttonMovementSpeed = 2;
    SKAction *moveUp = [SKAction moveToY:self.largestHeight  duration:buttonMovementSpeed];
    SKAction *moveDown = [SKAction moveToY:self.lowestHeight duration:buttonMovementSpeed];
    SKAction *sequence = [SKAction sequence:@[moveDown,moveUp]];
    [self runAction:[SKAction repeatActionForever:sequence]];
}
//Expands the button to create effect
-(void)expand
{
    if(!self.isExpanded)
    {
        [self setIsExpanded:YES];
        expandCircle = [SKShapeNode shapeNodeWithCircleOfRadius:15];
        [expandCircle setStrokeColor:self.expandColor];
        [expandCircle setName:[NSString stringWithFormat:@"%@ExpandedCircle",self.name]];
        [expandCircle setZPosition:self.zPosition - 1];
        [expandCircle setFillColor:self.expandColor];
        [self addChild:expandCircle];
        [expandCircle runAction:[SKAction scaleTo:50 duration:.3] completion:^(void){
            exitButton = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"exitButton"] size:CGSizeMake(self.scene.frame.size.width/12.266, self.scene.frame.size.height/6.9)];
            [exitButton setName:[NSString stringWithFormat:@"ExitButton"]];
            //Convert point to callers coordinate system
            CGPoint topRightCorner = [self convertPoint:CGPointMake(self.scene.frame.size.width - self.scene.frame.size.width/11 , self.scene.frame.size.height - self.scene.frame.size.height/11) fromNode:self.parent];
            [exitButton setPosition:topRightCorner];
            [exitButton setZPosition:self.zPosition + 1];
            [self addChild:exitButton];
        }];
    }
}
//Shrinks the button then removes child
-(void)removeExpansion
{
    [exitButton setName:@"exiting"];
    [self.children enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop){
        if([node.name isEqualToString:@"exiting"])
        {
            [node runAction:[SKAction group:@[[SKAction fadeOutWithDuration:.15],[SKAction rotateByAngle:.5 duration:.15]]]];
        }
        else if([node.name containsString:@"buttonAccessory"])
        {
            [node runAction:[SKAction group:@[[SKAction fadeOutWithDuration:.15]]] completion:^{
                //[node removeFromParent];
            }];
        }
    }];
    [expandCircle runAction:[SKAction scaleTo:1 duration:.3] completion:^(void){
        [expandCircle removeFromParent];
        [self setIsExpanded:NO];
    }];
}
@end
