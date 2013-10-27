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

@implementation SAVR_AppDelegate

- (void)awakeFromNib
{
    // Initialize status bar
    statusItem = statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Savr"];
    [statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Create NSUserDefaults object
//    savrDefaults = [[NSUserDefaults alloc] init];
    
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
    
    //Reload active flux
    isLoading = NO;
    [self reloadActiveFlux:NO];
}

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
            int nextReload = 3600; // tommorow
            NSDate *lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReloadDate"];
            
            if(lastReloadDate == nil || [lastReloadDate timeIntervalSinceNow] < - minimumTimeBetweenReload || force){
                // TODO : CHECK FOR CONNECTIVITY
                [reloadTimer invalidate];
                NSLog(@"Data is too old");
                
                SAVR_FluxLoader *fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
                if([fluxLoader isActive]){
                    NSLog(@"Flux is active - Fetching data");
                    BOOL success = [fluxLoader fetch];
                    if (success) {
                        NSLog(@"Success");
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastReloadDate"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        // NOTIFY USER VIA NOTIFICATION
                        NSUserNotification *notification = [[NSUserNotification alloc] init];
                        notification.title = @"Savr just got new images !!";
                        notification.informativeText = @"Savr just downloaded a bunch of image from the internet for your Screensaver !";
                        notification.soundName = NSUserNotificationDefaultSoundName;
                        
                        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                        
                    } else {
                        NSLog(@"Failure");
                        nextReload = 3600 ; // in one hour
                    }
                } else {
                    NSLog(@"Flux is not active");
                }
            } else {
                NSLog(@"Data is still fresh - not fetching anything");
                nextReload = minimumTimeBetweenReload - [lastReloadDate timeIntervalSinceNow] + 1 ;
            }
            
            reloadTimer = [NSTimer timerWithTimeInterval:nextReload target:self selector:@selector(reloadActiveFluxNoForce) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:reloadTimer forMode:NSRunLoopCommonModes];
            isLoading = NO;
        });
    } else {
        NSLog(@"Can't load, loading is already taking place ");
    }
}

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

- (IBAction)openPreferencePane:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"]];
}

@end
