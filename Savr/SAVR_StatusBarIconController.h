//
//  SAVR_StatusBarIconController.h
//  Savr
//
//  Created by Jean Caillé on 03/03/2014.
//  Copyright (c) 2014 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAVR_StatusBarIconController : NSObject

@property NSStatusItem *statusItem;
@property IBOutlet NSMenu *statusMenu;
@property (unsafe_unretained) IBOutlet NSWindow *preferenceWindow;

-(void)updateStatusBarIcon;

- (IBAction)reloadButtonWasClicked:(id)sender;
- (IBAction)openSavrPreferencesWasClicked:(id)sender;
- (IBAction)quitButtonWasClicked:(id)sender;

@end
