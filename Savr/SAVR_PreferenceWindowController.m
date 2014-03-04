//
//  SAVR_PreferenceWindowController.m
//  Savr
//
//  Created by Jean Caillé on 03/03/2014.
//  Copyright (c) 2014 Jean Caillé. All rights reserved.
//

#import "SAVR_PreferenceWindowController.h"
#import "SAVR_Utils.h"
#import "LaunchAtLoginController.h"
#import <ParseOSX/ParseOSX.h>

@implementation SAVR_PreferenceWindowController

#pragma mark - Object life

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setCheckboxes];
    [self setStatusLabelToLastReloadDate];
    [self prepareFluxList];
    
}

#pragma mark - Interface

-(void)prepareFluxList
{
    SAVR_FluxManager *fluxManager = [SAVR_FluxManager sharedInstance];
    fluxManager.delegate = self;
    [_fluxList setDataSource:fluxManager];
    [_fluxList setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];

}

-(void)setStatusLabelToLastReloadDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"]];
    formatter.doesRelativeDateFormatting = YES;
    
    NSString* formattedLastReloadDate;
    NSDate* lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSAVRLastReloadDateKey];
    if (!lastReloadDate) {
        formattedLastReloadDate = @"Never";
    } else {
        formattedLastReloadDate = [formatter stringFromDate:lastReloadDate];
    }
    NSString* statusString = [@"Last reloaded : " stringByAppendingString:formattedLastReloadDate];
    [_statusLabel setStringValue:statusString];
}

-(void)setCheckboxes
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults boolForKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey]){
        [_notifyWhenFetchingImageCheckbox setState:NSOnState];
    } else {
        [_notifyWhenFetchingImageCheckbox setState:NSOffState];
    }
    
    if([defaults boolForKey:kSAVRHideStatusBarIconKey]){
        [_hideStatusBarIconCheckbox setState:NSOnState];
    } else {
        [_hideStatusBarIconCheckbox setState:NSOffState];
    }
    
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    if ([lc launchAtLogin]) {
        [_startApplicationAtLoginCheckbox setState:NSOnState];
    } else {
        [_startApplicationAtLoginCheckbox setState:NSOffState];
    }

}

#pragma mark - Option switch

- (IBAction)didToggleStartApplicationAtLogin:(id)sender {
    LaunchAtLoginController *lc = [[LaunchAtLoginController alloc] init];
    if(_startApplicationAtLoginCheckbox.state == NSOnState){
        NSLog(@"Adding application to login list");
        [PFAnalytics trackEvent:@"Event:Start_at_login:YES"];
        [lc setLaunchAtLogin:YES];
    } else {
        NSLog(@"Removing application from login list");
        [PFAnalytics trackEvent:@"Event:Start_at_login:NO"];
        [lc setLaunchAtLogin:NO];
    }
}

- (IBAction)didToggleNotifyWhenFetchingImage:(id)sender {
    if(_notifyWhenFetchingImageCheckbox.state == NSOnState){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey];
        [PFAnalytics trackEvent:@"Event:Send_notifications:YES"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSAVRShouldSendNotificationsWhenDoneFetchingKey];
        [PFAnalytics trackEvent:@"Event:Send_notifications:NO"];
    }
}

- (IBAction)didToggleHideStatusBarIcon:(id)sender {
    if(_hideStatusBarIconCheckbox.state == NSOnState)
    {
        NSLog(@"Hide status bar icon");
        [PFAnalytics trackEvent:@"Event:Hide_status_bar_icon:YES"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSAVRHideStatusBarIconKey];
    } else {
        NSLog(@"Show status bar icon");
        [PFAnalytics trackEvent:@"Event:Hide_status_bar_icon:NO"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSAVRHideStatusBarIconKey];
    }
}

- (IBAction)didClickReloadButton:(id)sender {
    [[SAVR_FluxManager sharedInstance] reloadActiveFlux:YES];
}

- (IBAction)didClickOpenScreensaverPreferencePane:(id)sender {
    [self openHelpWindow];
}

- (IBAction)didClickCloseHelpPanel:(id)sender {
    [self closeHelpWindow];
}

#pragma mark - Flux Manager Delegate

-(void)fluxManagerDidStartReloading:(SAVR_FluxManager *)fluxManager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_statusLabel setStringValue:@"Fetching new images"];
    });
}

-(void)fluxManagerDidFinishReloading:(SAVR_FluxManager *)fluxManager newImages:(int)newImagesCount
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setStatusLabelToLastReloadDate];
    });
}

-(void)fluxManager:(SAVR_FluxManager *)fluxManager didFailReloadingWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setStatusLabelToLastReloadDate];
    });
}


#pragma mark - Help and preference panel

-(void)openHelpWindow
{
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"]];
    [PFAnalytics trackEvent:@"Page:Help"];
    NSPoint ref = {.x = 25, .y = (_helpWindow.screen.frame.size.height - _helpWindow.frame.size.height) / 2};
    [_helpWindow setFrameOrigin:ref];
    [_helpWindow makeKeyAndOrderFront:nil];
}

-(void)closeHelpWindow
{
    [_helpWindow orderOut:self];
}
@end
