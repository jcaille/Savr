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
    statusItem = statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Savr"];
    [statusItem setHighlightMode:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (IBAction)reloadFlux:(id)sender
{
    SAVR_FluxLoader *fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
    [fluxLoader fetch];
}

- (IBAction)setFluxAsActive:(id)sender {
    SAVR_FluxLoader* fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
    [fluxLoader setFluxAsActive];
}

- (IBAction)setFluxAsInactive:(id)sender {
    SAVR_FluxLoader* fluxLoader = [[SAVR_ImgurFluxLoader alloc] init];
    [fluxLoader setFluxAsInactive];
}

- (IBAction)openPreferencePane:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"]];
}

@end
