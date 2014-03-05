//
//  SAVR_AppDelegate.m
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <ParseOSX/ParseOSX.h>

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
    if(self = [super init])
    {
        [Parse setApplicationId:@"jeq89GwwfBhAAA5tUtFfSWwNCvKNqyGkBazzXRnU"
                      clientKey:@"EXe8h3KhUbBlzqDieDki32a4f9ZPyX7ZI5YybRSK"];
    }
    return self;
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
        [PFAnalytics trackEvent:@"Page:Preference_Window"];
    }
    isAlreadyLaunched = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Did finish Launching");
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:aNotification.userInfo];
    [PFAnalytics trackEvent:@"Event:Launch"];
}

@end
