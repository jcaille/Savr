//
//  SAVR_FluxManager.h
//  Savr
//
//  Created by Jean Caillé on 01/11/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAVR_FluxManager : NSObject <NSTableViewDataSource>

-(id) initWithArray:(NSArray*)possibleFlux;

@end
