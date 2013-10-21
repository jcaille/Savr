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
    NSLog(@"Fetching");
    [fluxLoader fetch];
    NSLog(@"Done fectching");
}

@end
