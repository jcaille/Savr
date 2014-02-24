//
//  SAVR_Utils.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TIME_BETWEEN_FETCHING 3600
#define TIME_BETWEEN_RELOAD_TRY 1800
#define TIME_BEFORE_DELETING_FILES 1209600 // 2 weeks

// NSDefaults Keys

#define kSAVRShouldSendNotificationsWhenDoneFetchingKey @"notification"
#define kSAVRLastReloadDateKey @"lastReloadDate"
#define kSAVRFluxIsActiveKeySuffix @"fluxIsActive"
#define kSAVRFluxLastReloadDateKeySuffix @"lastReloadDate"


@interface SAVR_Utils : NSObject

+(NSString*) getOrCreateUserVisibleDirectory;
+(NSString*) getOrCreateApplicationSupportDirectory;
NSArray* SAVR_DEFAULT_FLUX();

@end
