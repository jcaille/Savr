//
//  SAVR_AppDelegate.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SAVR_AppDelegate : NSObject <NSApplicationDelegate>
{
    // STATUS MENU
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
    
    // PREFERENCE PANE
    __unsafe_unretained NSWindow *_preferenceWindow;
    __weak NSButton *_earthpornCheckbox;
    __weak NSButton *_applicationShouldStartAtLoginCheckbox;
    
    // RELOAD
    BOOL isLoading;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSTimer *reloadTimer;

// STATUS MENU INTERACTION
- (IBAction)reloadFlux:(id)sender;
- (IBAction)openSavrPreference:(id)sender;

// PREFERENCE PANE INTERACTION
- (IBAction)earthpornCheckboxWasToggled:(id)sender;
- (IBAction)openPreferencePane:(id)sender;

// RELOAD
-(void) reloadActiveFlux:(BOOL)force;
-(void) reloadActiveFluxNoForce;

@property (unsafe_unretained) IBOutlet NSWindow *preferenceWindow;
@property (weak) IBOutlet NSButton *earthpornCheckbox;
@property (weak) IBOutlet NSButton *applicationShouldStartAtLoginCheckbox;
@end
