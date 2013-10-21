//
//  SAVR_Utils.m
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_Utils.h"

@implementation SAVR_Utils

+(NSString*) getOrCreateDocumentDirectory
{
    // Returns path to ~/Documents/Savr
    // Create the directory if necessary
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* folder = [path stringByAppendingPathComponent:@"/Savr"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
    }

    return folder;
}

+(NSString*) getOrCreateApplicationSupportDirectory
{
    // Returns URL to ~/Application Support/Savr
    // Create the directory if necessary
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* folder = [path stringByAppendingPathComponent:@"/Savr"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return folder;
}
@end
