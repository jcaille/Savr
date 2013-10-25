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
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;

}
@property (assign) IBOutlet NSWindow *window;

- (IBAction)setFluxAsActive:(id)sender;
- (IBAction)setFluxAsInactive:(id)sender;
- (IBAction)openPreferencePane:(id)sender;
- (IBAction)reloadFlux:(id)sender;
@end
