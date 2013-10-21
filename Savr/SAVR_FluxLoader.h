//
//  SAVR_FluxLoader.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAVR_FluxLoader : NSObject
{
    NSString* fluxName;
}
// Setup the object (keys, permissions, directory, ...)
-(void) setup;

// Fetch the data from the source, save it to flux directory
// Returns success status
-(BOOL) fetch;

// Remove old elements from directory
-(void) cleanDirectory;

// Access the directory
-(NSString*) getOrCreateFluxDirectory;

@end
