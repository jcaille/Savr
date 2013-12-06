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
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
    
    // PREFERENCE PANE
    __unsafe_unretained NSWindow *_preferenceWindow;
    __weak NSButton *_applicationShouldStartAtLoginCheckbox;
    __weak NSButton *_notificationCheckbox;
    __weak NSTableView *_fluxList;
    
    // RELOAD
    BOOL isLoading;
    
    // FLUX MANAGER
    
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSTimer *reloadTimer;
@property (unsafe_unretained) IBOutlet NSWindow *helpWindow;

// STATUS MENU BUTTONS
- (IBAction)reloadButtonWasClicked:(id)sender;
- (IBAction)openSavrPreferencesWasClicked:(id)sender;
- (IBAction)quitButtonWasClicked:(id)sender;

// PREFERENCE PANE INTERACTION
- (IBAction)openPreferencePane:(id)sender;
- (IBAction)notificationCheckboxWasToggled:(id)sender;
- (IBAction)applicationShouldStartAtLoginWasToggled:(id)sender;

@property (unsafe_unretained) IBOutlet NSWindow *preferenceWindow;
@property (weak) IBOutlet NSButton *notificationCheckbox;
@property (weak) IBOutlet NSButton *applicationShouldStartAtLoginCheckbox;
@property (weak) IBOutlet NSTableView *fluxList;
@end
