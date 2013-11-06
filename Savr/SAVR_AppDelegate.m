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
#import "LaunchAtLoginController.h"

#define SAVR_FLUX @[@"earthporn", @"fractalporn", @"animalporn", @"spaceporn", @"winterporn", @"cityporn"]

@implementation SAVR_AppDelegate
{
    SAVR_FluxManager* fluxManager;
}

- (void)awakeFromNib
{
    // Initialize status bar
    statusItem = statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Savr"];
    [statusItem setHighlightMode:YES];
}

#pragma mark - APP LIFE CYCLE

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // File for notification
    [self fileNotifications];
    
    // Make sure that folders exist and state is correct for each flux
    [SAVR_Utils getOrCreateApplicationSupportDirectory];
    [SAVR_Utils getOrCreateUserVisibleDirectory];
    for(NSString* flux in SAVR_FLUX){
        SAVR_FluxLoader *f = [[SAVR_ImgurFluxLoader alloc] initWithSubreddit:flux];
        if([f isActive]){
            [f setFluxAsActive];
        } else {
            [f setFluxAsInactive];
        }
    }
    
    // Init preference pane state
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    if ([lc launchAtLogin]) {
        [_applicationShouldStartAtLoginCheckbox setState:NSOnState];
    } else {
        [_applicationShouldStartAtLoginCheckbox setState:NSOffState];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([defaults valueForKey:@"notification"] == nil){
        [defaults setBool:YES forKey:@"notification"];
    }
    if([defaults boolForKey:@"notification"]){
        [_notificationCheckbox setState:NSOnState];
    } else {
        [_notificationCheckbox setState:NSOffState];
    }
    
    //Create flux manager
    fluxManager = [[SAVR_FluxManager alloc] initWithArray:SAVR_FLUX];
    fluxManager.delegate = self;
    [_fluxList setDataSource:fluxManager];
    
    //Reload active flux
    isLoading = NO;
    [self tryReloadingActiveFlux:NO];
}

- (void) fileNotifications
{
    NSLog(@"Filing for notification");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

- (void) receiveWakeNote: (NSNotification*) note
{
    NSLog(@"Waking up - Reloading flux, no force");
    [self tryReloadingActiveFlux:NO];
}

- (void) receiveSleepNote: (NSNotification*) note
{
    NSLog(@"Going to sleep - Invalidate timer");
    [_reloadTimer invalidate];
}

#pragma mark - FLUX MANAGER DELEGATE

-(void)resetReloadTimer{
    _reloadTimer = [NSTimer timerWithTimeInterval:300 target:self selector:@selector(tryReloadingActiveFlux) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_reloadTimer forMode:NSRunLoopCommonModes];
}

-(void)tryReloadingActiveFlux{
    [fluxManager reloadActiveFlux:NO];
}

-(void)tryReloadingActiveFlux:(BOOL) force{
    if(!isLoading){
        [fluxManager reloadActiveFlux:force];
    }
}

-(void)fluxManagerDidStartReloading:(SAVR_FluxManager *)fluxManager{
    //Invalidate timer
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Starting to reload");
        isLoading = YES;
        [_reloadTimer invalidate];
    });
}

-(void)fluxManagerDidFinishReloading:(SAVR_FluxManager *)fluxManager{
    //Set new timer
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Finished reloading");
        [self resetReloadTimer];
        isLoading = NO;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"notification"]){
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Savr just got new images!";
            notification.informativeText = @"Savr just downloaded a bunch of fresh images for your screensaver.";
            notification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

        }
    });
}

-(void)fluxManager:(SAVR_FluxManager *)fluxManager didFailReloadingWithError:(NSError *)error{
    //Set new timer
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Reloading failed : %@", error.localizedDescription);
        [self resetReloadTimer];
        isLoading = NO;
    });}

#pragma mark - PREFERENCE MANAGEMENT

- (IBAction)openSavrPreference:(id)sender {
    [_preferenceWindow makeKeyAndOrderFront:nil];
}

- (IBAction)applicationShouldStartAtLoginWasToggled:(id)sender {
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    if(_applicationShouldStartAtLoginCheckbox.state == NSOnState){
        NSLog(@"Adding application to login list");
        [lc setLaunchAtLogin:YES];
    } else {
        NSLog(@"Removing application from login list");
        [lc setLaunchAtLogin:NO];
    }
}

- (IBAction)notificationCheckboxWasToggled:(id)sender {
    if(_notificationCheckbox.state == NSOnState){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notification"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"notification"];
    }
}

- (IBAction)openPreferencePane:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"]];
}

- (IBAction)reloadFlux:(id)sender
{
    // CLICK ON ITEM IN MENU
    [self tryReloadingActiveFlux:YES];
}

@end
