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
    NSString* folder = [path stringByAppendingPathComponent:fluxName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return folder;
}

-(void) cleanDirectory
{
    NSString* fluxDirectory = [self getOrCreateFluxDirectory];
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fluxDirectory error:nil];
    for(NSString* item in content)
    {
        NSString* itemFullPath = [fluxDirectory stringByAppendingPathComponent:item];
        [[NSFileManager defaultManager] removeItemAtPath:itemFullPath error:nil];
    }
}

#pragma mark - STATE MANAEGEMENT

-(BOOL) isActive
{
    NSString* applicationSupportDirectory = [SAVR_Utils getOrCreateDocumentDirectory];
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportDirectory error:nil];
    for(NSString* item in content){
        if([item isEqualToString:fluxName]){
            //Check if folder is symlink
            NSString* itemFullPath = [applicationSupportDirectory stringByAppendingPathComponent:item];
            NSString* itemType = [[[NSFileManager defaultManager]
                                   attributesOfItemAtPath:itemFullPath error:nil]
                                  fileType];
            if([itemType isEqualToString:NSFileTypeSymbolicLink])
            {
                return YES;
            }
        }
    }
    return NO;

}

-(BOOL)setFluxAsActive
{
    if ([self isActive]) {
        return YES;
    }
    NSString* fluxDirectory = [self getOrCreateFluxDirectory];
    NSString* applicationSupportDirectory = [[SAVR_Utils getOrCreateDocumentDirectory] stringByAppendingPathComponent:fluxName];
    NSError* error;
    if(![[NSFileManager defaultManager] createSymbolicLinkAtPath:applicationSupportDirectory withDestinationPath:fluxDirectory error:&error])
    {
        return NO;
    }
    return YES;
}

-(BOOL)setFluxasInactive
{
    NSString* applicationSupportDirectory = [SAVR_Utils getOrCreateDocumentDirectory];
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportDirectory error:nil];
    for(NSString* item in content){
        if([item isEqualToString:fluxName]){
            //Check if folder is symlink
            NSString* itemFullPath = [applicationSupportDirectory stringByAppendingPathComponent:item];
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
    //Returns yes even if flux was not initially active
    return YES;
}
@end
