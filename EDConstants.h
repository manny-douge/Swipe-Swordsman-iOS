//
//  EDConstants.h
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 6/30/16.
//  Copyright © 2016 Emmanuel Douge. All rights reserved.
//

#ifndef EDConstants_h
#define EDConstants_h
enum MenuState
{
    InTutorial = 0,
    MainMenu,
    InCharacterSelect,
    InSettings,
};
enum GameState
{
    Countdown = 0,
    InGame,
    InAd,
    GameOver,
};
enum PlayerState
{
    Idle = 0,
    Attacking,
    Dodging,
};

#endif /* EDConstants_h */
