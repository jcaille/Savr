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
#import "SAVR_FluxManager.h"

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
    
    // Make sure that folders exist
    [SAVR_Utils getOrCreateApplicationSupportDirectory];
    [SAVR_Utils getOrCreateDocumentDirectory];
    
    // Init state of window
    SAVR_FluxLoader *fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
    if([fluxLoader isActive]){
        [_earthpornCheckbox setState:NSOnState];
    } else {
        [_earthpornCheckbox setState:NSOffState];
    }
    
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    if ([lc launchAtLogin]) {
        [_applicationShouldStartAtLoginCheckbox setState:NSOnState];
    } else {
        [_applicationShouldStartAtLoginCheckbox setState:NSOffState];
    }
    
    //Reload active flux
    isLoading = NO;
    [self reloadActiveFlux:NO];
    
    //Create flux manager
    fluxManager = [[SAVR_FluxManager alloc] initWithArray:@[@"earthporn", @"fractalporn", @"animalporn"]];
    [_fluxList setDataSource:fluxManager];
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
    [self reloadActiveFlux:NO];
}

- (void) receiveSleepNote: (NSNotification*) note
{
    NSLog(@"Going to sleep - Invalidate timer");
    [_reloadTimer invalidate];
}

#pragma mark - FLUX MANAGEMENT

- (IBAction)reloadFlux:(id)sender
{
    [self reloadActiveFlux:YES];
}

-(void) reloadActiveFluxNoForce
{
    [self reloadActiveFlux:NO];
}


-(void) reloadActiveFlux:(BOOL)force
{
    if(!isLoading){
        isLoading = YES;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Relods the flux if it has been more than 24 hours since last successfull load
            NSLog(@"Trying to reload active flux");
            
            int minimumTimeBetweenReload = 3600;
            int nextReload = 3601; // tommorow
            NSDate *lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReloadDate"];
            
            if(lastReloadDate == nil || [lastReloadDate timeIntervalSinceNow] < - minimumTimeBetweenReload || force){
                // TODO : CHECK FOR CONNECTIVITY
                if(force){
                    [_reloadTimer invalidate];
                }
                NSLog(@"Data is too old");
                
                SAVR_FluxLoader *fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
                if([fluxLoader isActive]){
                    NSLog(@"Flux is active - Fetching data");
                    BOOL success = [fluxLoader fetch];
                    if (success) {
                        NSLog(@"Success");
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastReloadDate"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
#if 1
                        // NOTIFY USER VIA NOTIFICATION
                        NSUserNotification *notification = [[NSUserNotification alloc] init];
                        notification.title = @"Savr just got new images !!";
                        notification.informativeText = @"Savr just downloaded a bunch of image from the internet for your Screensaver !";
                        notification.soundName = NSUserNotificationDefaultSoundName;

                        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
#endif
                    } else {
                        NSLog(@"Failure");
                        nextReload = 600;
                    }
                } else {
                    NSLog(@"Flux is not active");
                }
            } else {
                NSLog(@"Data is still fresh - not fetching anything");
                nextReload = minimumTimeBetweenReload + [lastReloadDate timeIntervalSinceNow] + 1 ;
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"Next reload in %d", nextReload);
                _reloadTimer = [NSTimer timerWithTimeInterval:nextReload target:self selector:@selector(reloadActiveFluxNoForce) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:_reloadTimer forMode:NSRunLoopCommonModes];
                isLoading = NO;
            });

        });
    } else {
        NSLog(@"Can't load, loading is already taking place ");
    }
}

#pragma mark - PREFERENCE MANAGEMENT

- (IBAction)openSavrPreference:(id)sender {
    [_preferenceWindow makeKeyAndOrderFront:nil];
}

- (IBAction)earthpornCheckboxWasToggled:(id)sender {
    SAVR_FluxLoader *fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
    if(self.earthpornCheckbox.state == NSOnState)
    {
        NSLog(@"Activating flux");
        [fluxLoader setFluxAsActive];
    } else {
        NSLog(@"Deactivating Flux");
        [fluxLoader setFluxAsInactive];
    }
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

- (IBAction)openPreferencePane:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"]];
}

@end
