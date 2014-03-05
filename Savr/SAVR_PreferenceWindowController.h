//
//  SAVR_PreferenceWindowController.h
//  Savr
//
//  Created by Jean Caillé on 03/03/2014.
//  Copyright (c) 2014 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAVR_FluxManager.h"

@interface SAVR_PreferenceWindowController : NSObject <SAVR_FluxManagerDelegate, NSWindowDelegate>

@property (unsafe_unretained) IBOutlet NSWindow *preferenceWindow;
@property (unsafe_unretained) IBOutlet NSWindow *helpWindow;

#pragma mark - NSTableView

@property (weak) IBOutlet NSTableView *fluxList;
@property (weak) IBOutlet NSTextField *statusLabel;

#pragma mark - Options

// Buttons
@property (weak) IBOutlet NSButton *startApplicationAtLoginCheckbox;
@property (weak) IBOutlet NSButton *notifyWhenFetchingImageCheckbox;
@property (weak) IBOutlet NSButton *hideStatusBarIconCheckbox;

// Actions
- (IBAction)didToggleStartApplicationAtLogin:(id)sender;
- (IBAction)didToggleNotifyWhenFetchingImage:(id)sender;
- (IBAction)didToggleHideStatusBarIcon:(id)sender;
- (IBAction)didClickOpenScreensaverPreferencePane:(id)sender;

@end
