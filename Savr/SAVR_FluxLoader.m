//
//  SAVR_FluxLoader.m
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_FluxLoader.h"
#import "SAVR_Utils.h"

@implementation SAVR_FluxLoader

-(BOOL) fetch
{
    return NO;
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

#pragma mark - STATE MANAEGEMENT

-(BOOL) isActive
{
    NSString* userDefaultKey = [_fluxName stringByAppendingString:@"fluxIsActive"];
    NSUserDefaults* savrDefaults = [NSUserDefaults standardUserDefaults];
    
    // If key does not exist, we check manually if the symlink exists, and set the appropriate key
    if([savrDefaults objectForKey:userDefaultKey] == nil){
        NSString* applicationSupportDirectory = [SAVR_Utils getOrCreateUserVisibleDirectory];
        NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportDirectory error:nil];
        for(NSString* item in content){
            if([item isEqualToString:_fluxName]){
                //Check if folder is symlink
                NSString* itemFullPath = [applicationSupportDirectory stringByAppendingPathComponent:item];
                NSString* itemType = [[[NSFileManager defaultManager]
                                       attributesOfItemAtPath:itemFullPath error:nil]
                                      fileType];
                if([itemType isEqualToString:NSFileTypeSymbolicLink])
                {
                    [savrDefaults setBool:YES forKey:userDefaultKey];
                    [savrDefaults synchronize];
                    return YES;
                }
            }
        }
        [savrDefaults setBool:NO forKey:userDefaultKey];
        [savrDefaults synchronize];
        return NO;
    }
    
    return [savrDefaults boolForKey:userDefaultKey];
}

-(BOOL)setFluxAsActive
{
    if ([self isActive]) {
        return YES;
    }
    NSString* fluxDirectory = [self getOrCreateFluxDirectory];
    NSString* userVisibleDirectory = [[SAVR_Utils getOrCreateUserVisibleDirectory] stringByAppendingPathComponent:_fluxName];
    NSError* error;
    if(![[NSFileManager defaultManager] createSymbolicLinkAtPath:userVisibleDirectory withDestinationPath:fluxDirectory error:&error])
    {
        return NO;
    }
    
    // Modify NSUSerDefault to save state
    NSString* userDefaultKey = [_fluxName stringByAppendingString:@"fluxIsActive"];
    NSUserDefaults* savrDefaults = [NSUserDefaults standardUserDefaults];
    [savrDefaults setBool:YES forKey:userDefaultKey];
    [savrDefaults synchronize];
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

    //Returns yes even if flux was not initially active
    return YES;
}
@end
