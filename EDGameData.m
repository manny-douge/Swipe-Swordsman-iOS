//
//  EDGameData.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 5/31/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#import "EDGameData.h"

@implementation EDGameData
static NSString *const SSTutorialKey= @"tutorial";
static NSString *const SSDeathCountKey = @"deathcount";
static NSString *const SSTotalKillsKey = @"totalkills";
static NSString *const SSBestKillCountKey = @"bestkillcount";
static NSString *const SSBoxerKey = @"boxer";
static NSString *const SSSoundKey = @"sound";
+(instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    return sharedInstance;
}
+(NSString *)filePath
{
    static NSString *filePath = nil;
    if(!filePath)
    {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"gameData"];
    }
    return filePath;
}
+(instancetype)loadInstance
{
    NSData *decodedData = [NSData dataWithContentsOfFile:[EDGameData filePath]];
    if(decodedData)
    {
        EDGameData *data = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return data;
    }
    return [[EDGameData alloc] init];
}
-(void)save
{
    NSLog(@"SAVED GAME");
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [encodedData writeToFile:[EDGameData filePath] atomically:YES];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:[self totalKills] forKey:SSTotalKillsKey];
    [aCoder encodeInt:[self bestKillCount] forKey:SSBestKillCountKey];
    [aCoder encodeInt:[self totalDeaths] forKey:SSDeathCountKey];
    [aCoder encodeBool:[self didPlayTutorial] forKey:SSTutorialKey];
    [aCoder encodeBool:[self isBoxerUnlocked] forKey:SSBoxerKey];
    [aCoder encodeBool:[self isSoundOn] forKey:SSSoundKey];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        [self setTotalDeaths:[aDecoder decodeIntForKey:SSDeathCountKey]];
        [self setTotalKills:[aDecoder decodeIntForKey:SSTotalKillsKey]];
        [self setBestKillCount:[aDecoder decodeIntForKey:SSBestKillCountKey]];
        [self setDidPlayTutorial:[aDecoder decodeBoolForKey:SSTutorialKey]];
        [self setIsBoxerUnlocked:[aDecoder decodeBoolForKey:SSBoxerKey]];
        [self setIsSoundOn:[aDecoder decodeBoolForKey:SSSoundKey]];

    }
    return self;
}
-(void)incrementTotalKills
{
    self.totalKills++;
}
-(void)incrementTotalDeaths
{
    self.totalDeaths++;
}
-(void)reset
{
    [self setDidPlayTutorial:NO];
    [self setIsBoxerUnlocked:NO];
    [self setTotalDeaths:0];
    [self setTotalKills:0];
    [self setBestKillCount:0];
    [self setIsSoundOn:YES];
    [self save];
    
}
@end
