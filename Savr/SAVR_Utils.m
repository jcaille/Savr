//
//  SAVR_Utils.m
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_Utils.h"

@implementation SAVR_Utils

+(NSString*) getOrCreateUserVisibleDirectory
{
    // Returns path to ~/Documents/Savr
    // Create the directory if necessary
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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


NSArray* SAVR_DEFAULT_FLUX()
{
    return @[
             @{@"subreddit" : @"earthporn",
               @"userFacingName" : @"Earth",
               @"description" : @"Mother nature"
               },
             @{@"subreddit" : @"animalporn",
               @"userFacingName" : @"Animals",
               @"description" : @"Wild or tame"
               },
             @{@"subreddit" : @"skyporn",
               @"userFacingName" : @"Sky",
               @"description" : @"Amazing clouds"
               },
             @{@"subreddit" : @"macroporn",
               @"userFacingName" : @"Macro",
               @"description" : @"Incredible close-ups"
               },
             @{@"subreddit" : @"cityporn",
               @"userFacingName" : @"City",
               @"description" : @"Breathtaking skylines"
               },
             @{@"subreddit" : @"winterporn",
               @"userFacingName" : @"Winter",
               @"description" : @"Chilling images"
               },
             @{@"subreddit" : @"foodporn",
               @"userFacingName" : @"Food",
               @"description" : @"Mouth-watering"
               },
             ];
}

@end
