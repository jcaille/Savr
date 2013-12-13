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

/**
 *  Fetch images from the flux. This method should be overloaded by respective classes
 *
 *  @return The number of images actually fetched. If this value is negative, it means an error has happened
 */
-(int) fetch;

/**
 *  Reload the flux
 *
 *  @param force If force is YES, the flux will be reloaded no matter what.
 *  @param error If there is a problem fetching, this parameter will contain a description of the error
 *
 *  @return The number of images actually fetched. If this value is negative, it means an error has happened
 */
-(int) reload:(BOOL)force error:(NSError**)error;

// Remove everything elements from directory
-(BOOL) cleanDirectory;

// Remove old elements from directory
-(BOOL) cleanFilesOlderThan:(NSTimeInterval)timeInterval;

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
