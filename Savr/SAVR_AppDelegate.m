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
    SAVR_FluxManager* _fluxManager;
}

#pragma mark - APP LIFE CYCLE

- (void)awakeFromNib
{
    NSLog(@"Awake form nib");
    
    // Initialize Parse
    [Parse setApplicationId:@"jeq89GwwfBhAAA5tUtFfSWwNCvKNqyGkBazzXRnU"
                  clientKey:@"EXe8h3KhUbBlzqDieDki32a4f9ZPyX7ZI5YybRSK"];
    
    // Make sure that folders exist
    [SAVR_Utils getOrCreateApplicationSupportDirectory];
    [SAVR_Utils getOrCreateUserVisibleDirectory];

    //Create flux manager
    _fluxManager = [SAVR_FluxManager sharedInstance];
    _fluxManager.delegate = self;
    [_fluxList setDataSource:_fluxManager];
    [_fluxList setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    isLoading = NO;
    
    /*** Initialize the state of the UI ***/
    // Lauch at login checkbox
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    if ([lc launchAtLogin]) {
        [_applicationShouldStartAtLoginCheckbox setState:NSOnState];
    } else {
        [_applicationShouldStartAtLoginCheckbox setState:NSOffState];
    }
    
    // Notification checkbox
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults valueForKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey] == nil){
        [defaults setBool:YES forKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey];
    }
    if([defaults boolForKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey]){
        [_notificationCheckbox setState:NSOnState];
    } else {
        [_notificationCheckbox setState:NSOffState];
    }
    
    // Hide status bar icon checkbox
    if([defaults valueForKey:kSAVRHideStatusBarIconKey] ==nil){
        [defaults setBool:NO forKey:kSAVRHideStatusBarIconKey];
    }
    if([defaults boolForKey:kSAVRHideStatusBarIconKey]){
        [_hideStatusBarIconCheckbox setState:NSOnState];
    } else {
        [_hideStatusBarIconCheckbox setState:NSOffState];
    }
    
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

-(void)updateStatusLabel
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
    formatter.doesRelativeDateFormatting = YES;
    
    NSString* formattedLastReloadDate;
    NSDate* lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSAVRLastReloadDateKey];
    if (!lastReloadDate) {
        formattedLastReloadDate = @"Never";
    } else {
        formattedLastReloadDate = [formatter stringFromDate:lastReloadDate];
    }
    NSString* statusString = [@"Last reloaded : " stringByAppendingString:formattedLastReloadDate];
    [_statusLabel setStringValue:statusString];
}

#pragma mark - FLUX MANAGER DELEGATE

-(void)fluxManagerDidStartReloading:(SAVR_FluxManager *)fluxManager{
    //Invalidate timer
    dispatch_async(dispatch_get_main_queue(), ^{
        [_statusLabel setStringValue:@"Reloading"];
        [PFAnalytics trackEvent:@"Event:Reload:Start"];
    });
}

-(void)fluxManagerDidFinishReloading:(SAVR_FluxManager *)fluxManager newImages:(int)newImagesCount{
    //Set new timer
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStatusLabel];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"notification"] && newImagesCount > 2){
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Savr just got new images!";
            notification.informativeText = [NSString stringWithFormat:@"Savr just downloaded %d new images for your screensaver.", newImagesCount];
            notification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            [PFAnalytics trackEvent:@"Event:Reload:Success"];
        }
    });
}

-(void)fluxManager:(SAVR_FluxManager *)fluxManager didFailReloadingWithError:(NSError *)error{
    //Set new timer
    dispatch_async(dispatch_get_main_queue(), ^{
        [PFAnalytics trackEvent:@"Event:Reload:Failure"];
    });}

#pragma mark - PREFERENCE MANAGEMENT

- (IBAction)applicationShouldStartAtLoginWasToggled:(id)sender {
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    if(_applicationShouldStartAtLoginCheckbox.state == NSOnState){
        NSLog(@"Adding application to login list");
        [PFAnalytics trackEvent:@"Event:Start_at_login:YES"];
        [lc setLaunchAtLogin:YES];
    } else {
        NSLog(@"Removing application from login list");
        [PFAnalytics trackEvent:@"Event:Start_at_login:NO"];
        [lc setLaunchAtLogin:NO];
    }
}

- (IBAction)hideStatusBarIconWasToggled:(id)sender {
    if(_hideStatusBarIconCheckbox.state == NSOnState)
    {
        NSLog(@"Hide status bar icon");
        [PFAnalytics trackEvent:@"Event:Hide_status_bar_icon:YES"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSAVRHideStatusBarIconKey];
    } else {
        NSLog(@"Show status bar icon");
        [PFAnalytics trackEvent:@"Event:Hide_status_bar_icon:NO"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSAVRHideStatusBarIconKey];
    }
}

- (IBAction)notificationCheckboxWasToggled:(id)sender {
    if(_notificationCheckbox.state == NSOnState){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey];
        [PFAnalytics trackEvent:@"Event:Send_notifications:YES"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey];
        [PFAnalytics trackEvent:@"Event:Send_notifications:NO"];
    }
}


#pragma mark - HELP AND PREFERENCE PANE

- (IBAction)openPreferencePane:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"]];
    [PFAnalytics trackEvent:@"Page:Help"];
    NSPoint ref = {.x = 25, .y = (_helpWindow.screen.frame.size.height - _helpWindow.frame.size.height) / 2};
    [_helpWindow setFrameOrigin:ref];
    [_helpWindow makeKeyAndOrderFront:nil];
}
- (IBAction)closeHelpPanel:(id)sender {
    [_helpWindow orderOut:self];
}

@end
