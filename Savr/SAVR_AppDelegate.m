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
#import "SAVR_URLFluxLoader.h"

@implementation SAVR_AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Hello !");
}

- (IBAction)buttonWasClicked:(id)sender {
    SAVR_URLFluxLoader* fluxLoader = [[SAVR_URLFluxLoader alloc] init];
    [fluxLoader setup];
    [fluxLoader fetch];
}

- (IBAction)setFluxAsActive:(id)sender {
    SAVR_FluxLoader* fluxLoader = [[SAVR_URLFluxLoader alloc] init];
    [fluxLoader setup];
    [fluxLoader setFluxAsActive];
}

- (IBAction)setFluxAsInactive:(id)sender {
    SAVR_FluxLoader* fluxLoader = [[SAVR_URLFluxLoader alloc] init];
    [fluxLoader setup];
    [fluxLoader setFluxAsInactive];
}

- (IBAction)openPreferencePane:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"]];
}

@end
