//
//  SAVR_StatusBarIconController.m
//  Savr
//
//  Created by Jean Caillé on 03/03/2014.
//  Copyright (c) 2014 Jean Caillé. All rights reserved.
//

#import "SAVR_StatusBarIconController.h"
#import "SAVR_Utils.h"
#import "SAVR_FluxManager.h"


@implementation SAVR_StatusBarIconController

#pragma mark - Object Life

-(id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStatusBarIcon)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self updateStatusBarIcon];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Status Bar Icon

-(void)updateStatusBarIcon
{
    // Read from the defaults and update the Status bar Icon
    if([[NSUserDefaults standardUserDefaults] boolForKey:kSAVRHideStatusBarIconKey]){
        [self hideStatusBarIcon];
    } else {
        [self showStatusBarIcon];
    }
}

-(void)showStatusBarIcon
{
    if(!_statusItem){
        _statusItem  = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        [_statusItem setMenu:_statusMenu];
        
        NSImage* image = [NSImage imageNamed:@"Savr_Logo_16"];
        NSImage* alternateImage = [NSImage imageNamed:@"Savr_LogoW_16"];
        
        [_statusItem setImage:image];
        [_statusItem setAlternateImage:alternateImage];
        [_statusItem setHighlightMode:YES];
    }
}

-(void)hideStatusBarIcon
{
    if(_statusItem){
        [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
        _statusItem = nil;
    }
}

#pragma mark - Menu

- (IBAction)openSavrPreferencesWasClicked:(id)sender
{
    [_preferenceWindow makeKeyAndOrderFront:nil];
}

- (IBAction)reloadButtonWasClicked:(id)sender;
{
    [[SAVR_FluxManager sharedInstance] reloadActiveFlux:YES];
}

- (IBAction)quitButtonWasClicked:(id)sender
{
    [NSApp terminate: nil];
}

@end
