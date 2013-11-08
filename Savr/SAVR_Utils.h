//
//  SAVR_Utils.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TIME_BETWEEN_FETCHING 3600
#define TIME_BETWEEN_RELOAD_TRY 600
#define TIME_BEFORE_DELETING_FILES 1209600 // 2 week

@interface SAVR_Utils : NSObject

+(NSString*) getOrCreateUserVisibleDirectory;
+(NSString*) getOrCreateApplicationSupportDirectory;

@end
