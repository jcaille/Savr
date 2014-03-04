//
//  SAVR_AppDelegate.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SAVR_FluxManager.h"

@interface SAVR_AppDelegate : NSObject <NSApplicationDelegate>
{
    BOOL isAlreadyLaunched;
}
@property (unsafe_unretained) IBOutlet NSWindow *preferenceWindow;

@end
