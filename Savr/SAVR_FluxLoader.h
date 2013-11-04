//
//  SAVR_FluxLoader.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAVR_FluxLoader : NSObject
@property (strong, nonatomic) NSString *fluxName;

// Fetch the data from the source, save it to flux directory
// Returns success status
-(BOOL) fetch;

// Remove everything elements from directory
-(BOOL) cleanDirectory;

// Check if flux is active by first looking at user defaults, and then is symlink exists between Application Support and Documents
-(BOOL) isActive;

//Creates a symlink between flux directory and appSupport directory.
// Then modifies NSUSerDefaults to save state
-(BOOL) setFluxAsActive;

//Removes symlink between flux directory and appSupport directory
// Then modifies NSUserDefault to save state
-(BOOL) setFluxAsInactive;

// Access the directory
-(NSString*) getOrCreateFluxDirectory;

@end
