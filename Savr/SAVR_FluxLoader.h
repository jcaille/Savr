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
    @public NSString* fluxName;
}
// Setup the object (keys, permissions, directory, ...)
-(void) setup;

// Fetch the data from the source, save it to flux directory
// Returns success status
-(BOOL) fetch;

// Remove everything elements from directory
-(BOOL) cleanDirectory;

// Check if flux is active by looking for a symlink in document directory
-(BOOL) isActive;

//Creates a symlink between flux directory and appSupport directory.
-(BOOL) setFluxAsActive;

//Removes symlink between flux directory and appSupport directory
-(BOOL) setFluxAsInactive;

// Access the directory
-(NSString*) getOrCreateFluxDirectory;

@end
