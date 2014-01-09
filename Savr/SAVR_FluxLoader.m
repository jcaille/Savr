//
//  SAVR_FluxLoader.m
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_FluxLoader.h"
#import "SAVR_Utils.h"
#import <ParseOSX/ParseOSX.h>

@implementation SAVR_FluxLoader

-(int) fetch
{
    return -1;
}

#pragma mark - FILE MANAGEMENT

-(NSString*) getOrCreateFluxDirectory
{
    NSString* path = [SAVR_Utils getOrCreateApplicationSupportDirectory];
    NSString* folder = [path stringByAppendingPathComponent:_fluxName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return folder;
}

-(BOOL) cleanDirectory
{
    NSString* fluxDirectory = [self getOrCreateFluxDirectory];
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fluxDirectory error:nil];
    for(NSString* item in content)
    {
        NSString* itemFullPath = [fluxDirectory stringByAppendingPathComponent:item];
        [[NSFileManager defaultManager] removeItemAtPath:itemFullPath error:nil];
    }
    return YES;
}

-(BOOL) cleanFilesOlderThan:(NSTimeInterval)timeInterval{
    NSString* fluxDirectory = [self getOrCreateFluxDirectory];
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fluxDirectory error:nil];
    for(NSString* item in content)
    {
        NSString* itemFullPath = [fluxDirectory stringByAppendingPathComponent:item];
        NSDate* itemType = [[[NSFileManager defaultManager]
                               attributesOfItemAtPath:itemFullPath error:nil]
                              fileCreationDate];
        if(-[itemType timeIntervalSinceNow] > timeInterval){
            NSLog(@"Deleting old file %@", item);
            
            NSString* event_name = [NSString stringWithFormat:@"Event:Flux:%@:delete_old_image", self.fluxName];
            [PFAnalytics trackEvent:event_name];

            [[NSFileManager defaultManager] removeItemAtPath:itemFullPath error:nil];
        }
    }
    return YES;
}

#pragma mark - STATE MANAEGEMENT

-(BOOL) isActive
{
    NSString* userDefaultKey = [_fluxName stringByAppendingString:@"fluxIsActive"];
    NSUserDefaults* savrDefaults = [NSUserDefaults standardUserDefaults];
    
    // If key does not exist, we set the flux as active by default and set the key
    if([savrDefaults objectForKey:userDefaultKey] == nil){
        [self setFluxAsActive];
        [savrDefaults setBool:YES forKey:userDefaultKey];
        [savrDefaults synchronize];
    }
    
    return [savrDefaults boolForKey:userDefaultKey];
}

-(BOOL)setFluxAsActive
{
    //Creates the file whatever happens
    NSString* fluxDirectory = [self getOrCreateFluxDirectory];
    NSString* userVisibleDirectory = [[SAVR_Utils getOrCreateUserVisibleDirectory] stringByAppendingPathComponent:_fluxName];
    NSError* error;
    if(![[NSFileManager defaultManager] createSymbolicLinkAtPath:userVisibleDirectory withDestinationPath:fluxDirectory error:&error])
    {
        NSLog(@"Error during directory creation : %@", [error localizedDescription]);
        return NO;
    }
    
    // Modify NSUSerDefault to save state
    NSString* userDefaultKey = [_fluxName stringByAppendingString:@"fluxIsActive"];
    NSUserDefaults* savrDefaults = [NSUserDefaults standardUserDefaults];
    [savrDefaults setBool:YES forKey:userDefaultKey];
    [savrDefaults synchronize];
    
    
    NSString* event_name = [NSString stringWithFormat:@"Event:Flux:%@:set_active", self.fluxName];
    [PFAnalytics trackEvent:event_name];

    return YES;
}

-(BOOL)setFluxAsInactive
{
    NSString* userVisibleDirectory = [SAVR_Utils getOrCreateUserVisibleDirectory];
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userVisibleDirectory error:nil];
    for(NSString* item in content){
        if([item isEqualToString:_fluxName]){
            //Check if folder is symlink
            NSString* itemFullPath = [userVisibleDirectory stringByAppendingPathComponent:item];
            NSString* itemType = [[[NSFileManager defaultManager]
                                  attributesOfItemAtPath:itemFullPath error:nil]
                                  fileType];
            if([itemType isEqualToString:NSFileTypeSymbolicLink])
            {
                //Remove item
                [[NSFileManager defaultManager] removeItemAtPath:itemFullPath error:nil];
            }
        }
    }
    // Modify NSUSerDefault to save state
    NSString* userDefaultKey = [_fluxName stringByAppendingString:@"fluxIsActive"];
    NSUserDefaults* savrDefaults = [NSUserDefaults standardUserDefaults];
    [savrDefaults setBool:NO forKey:userDefaultKey];
    [savrDefaults synchronize];
    
    NSString* event_name = [NSString stringWithFormat:@"Event:Flux:%@:set_inactive", self.fluxName];
    [PFAnalytics trackEvent:event_name];

    //Returns yes even if flux was not initially active
    return YES;
}

#pragma mark - RELOADING

-(int) reload:(BOOL)force error:(NSError**)error{
    //This is probably not called in the main thread
    NSString *lastReloadDateKey = [_fluxName stringByAppendingString:@"lastReloadDate"];
    NSDate *lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:lastReloadDateKey];
    if([self isActive] && (lastReloadDate == nil || [lastReloadDate timeIntervalSinceNow] < - TIME_BETWEEN_FETCHING || force)){
        //Reload should actually take place
        [self cleanFilesOlderThan:TIME_BEFORE_DELETING_FILES];
        int numbersOfImagesFetched = [self fetch];
        if(numbersOfImagesFetched < 0){
            // This flux fetched failed
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSString stringWithFormat:@"Fetching of flux %@ failed.", _fluxName] forKey:NSLocalizedDescriptionKey];
            if (error) {
                *error = [[NSError alloc] initWithDomain:@"FluxManager" code:1 userInfo:details];
            }

            return -1;
        } else {
            return numbersOfImagesFetched;
        }
    } else {
        return 0;
    }
}
@end
