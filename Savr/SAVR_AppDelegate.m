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
    
    //
    _reloadTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(mockReloadFlux) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_reloadTimer forMode:NSRunLoopCommonModes];
}

-(void) mockReloadFlux
{
    NSLog(@"Mocking reload flux");
}

- (IBAction)reloadFlux:(id)sender
{
    SAVR_FluxLoader *fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
    [fluxLoader fetch];
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
