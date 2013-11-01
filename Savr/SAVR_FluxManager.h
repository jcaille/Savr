//
//  SAVR_FluxManager.h
//  Savr
//
//  Created by Jean Caillé on 01/11/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SAVR_FluxManagerDelegate;

@interface SAVR_FluxManager : NSObject <NSTableViewDataSource>
@property (nonatomic, weak) id<SAVR_FluxManagerDelegate> delegate;
-(id) initWithArray:(NSArray*)possibleFlux;
-(void) reloadActiveFlux:(BOOL)force;

@end

@protocol SAVR_FluxManagerDelegate <NSObject>

-(void)fluxManagerDidStartReloading:(SAVR_FluxManager*)fluxManager;
-(void)fluxManagerDidFinishReloading:(SAVR_FluxManager*)fluxManager;
-(void)fluxManager:(SAVR_FluxManager*)fluxManager didFailReloadingWithError:(NSError*)error;

@end
