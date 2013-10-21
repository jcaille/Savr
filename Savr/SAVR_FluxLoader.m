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

-(void) setup
{
}

-(BOOL) fetch
{
    return NO;
}

-(void) cleanDirectory
{
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

@end
