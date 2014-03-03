//
//  SAVR_AppDelegate.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SAVR_FluxManager.h"

@interface SAVR_AppDelegate : NSObject <NSApplicationDelegate, SAVR_FluxManagerDelegate>
{
    // STATUS MENU
    NSStatusItem * statusItem;
    
    // PREFERENCE PANE
    __unsafe_unretained NSWindow *_preferenceWindow;
    __weak NSTableView *_fluxList;
    
    // RELOAD
    BOOL isLoading;
    BOOL isAlreadyLaunched;
    // FLUX MANAGER
    
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSTimer *reloadTimer;
@property (unsafe_unretained) IBOutlet NSWindow *helpWindow;

// PREFERENCE PANE INTERACTION
- (IBAction)openPreferencePane:(id)sender;
- (IBAction)notificationCheckboxWasToggled:(id)sender;
- (IBAction)applicationShouldStartAtLoginWasToggled:(id)sender;
- (IBAction)hideStatusBarIconWasToggled:(id)sender;


@property (unsafe_unretained) IBOutlet NSWindow *preferenceWindow;
@property (weak) IBOutlet NSButton *notificationCheckbox;
@property (weak) IBOutlet NSButton *applicationShouldStartAtLoginCheckbox;
@property (weak) IBOutlet NSButton *hideStatusBarIconCheckbox;

@property (weak) IBOutlet NSTableView *fluxList;
@property (weak) IBOutlet NSTextField *statusLabel;

@end
