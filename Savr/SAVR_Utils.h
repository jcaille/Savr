//
//  SAVR_Utils.h
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAVR_Utils : NSObject

+(NSString*) getOrCreateDocumentDirectory;
+(NSString*) getOrCreateApplicationSupportDirectory;

@end
