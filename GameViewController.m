//
//  GameViewController.m
//  Swipe Swordsman
//
//  Created by Emmanuel Douge on 5/31/16.
//  Copyright (c) 2016 Emmanuel Douge. All rights reserved.
//

#import "GameViewController.h"
#import "EDLoadingScreen.h"
#import "EDMainMenu.h"
#import "AppDelegate.h"
@import  GoogleMobileAds;

@interface GameViewController () <UIAlertViewDelegate>
//@property (nonatomic, strong) GADInterstitial *interstitial;

@end
@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = NO;
    //skView.showsNodeCount = YES;
    //skView.showsDrawCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    EDLoadingScreen *scene = [EDLoadingScreen sceneWithSize:skView.bounds.size];
    NSLog(@"%f,%f",skView.bounds.size.width,skView.bounds.size.height);
    [skView presentScene:scene];
}
-(void)viewWillLayoutSubviews
{
    AppDelegate *app = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    app.viewController = self;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
