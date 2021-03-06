//
//  SAVR_AppDelegate.m
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_AppDelegate.h"
#import "SAVR_Utils.h"
#import "SAVR_URLFluxLoader.h"
#import "SAVR_ImgurFluxLoader.h"
#import "SAVR_StatusBarIconController.h"
#import "LaunchAtLoginController.h"

@implementation SAVR_AppDelegate
{

}

#pragma mark - APP LIFE CYCLE

-(id)init
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSAVRFirstLaunchKey]) {
        [self handleFirstLaunch];
    }
    
    return self;
}

-(void)handleFirstLaunch
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSAVRFirstLaunchKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSAVRHideStatusBarIconKey];
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    [lc setLaunchAtLogin:YES];
    isAlreadyLaunched = true;
}

- (void)awakeFromNib
{
    NSLog(@"Awake form nib");
        
    // Make sure that folders exist
    [SAVR_Utils getOrCreateApplicationSupportDirectory];
    [SAVR_Utils getOrCreateUserVisibleDirectory];
}

-(void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSLog(@"Did become active");
    if(isAlreadyLaunched){
        // Application is not starting up
        [_preferenceWindow makeKeyAndOrderFront:nil];
    }
    isAlreadyLaunched = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Did finish Launching");
}

@end
