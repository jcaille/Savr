//
//  SAVR_FluxManager.m
//  Savr
//
//  Created by Jean Caillé on 01/11/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_FluxManager.h"
#import "SAVR_ImgurFluxLoader.h"

@implementation SAVR_FluxManager
{
    NSArray *fluxArray;
}

-(id) initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        fluxArray = array;
    }
    return self;
}

#pragma mark - FLUX MANAGEMENT

-(void) reloadActiveFlux:(BOOL)force
{
    [self.delegate fluxManagerDidStartReloading:self];
    // Loading is done outside of main thread to prevent UI block
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Trying to reload active flux");
        
        int minimumTimeBetweenReload = 3600;
        int nextReload; // tommorow
        NSDate *lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReloadDate"];

        if(lastReloadDate == nil || [lastReloadDate timeIntervalSinceNow] < - minimumTimeBetweenReload || force){
            // TODO : CHECK FOR CONNECTIVITY
            NSLog(@"Data is too old");
            for (NSString* flux in fluxArray) {
                SAVR_FluxLoader *fluxLoader = [[SAVR_ImgurFluxLoader alloc] initWithSubreddit:flux];
                if([fluxLoader isActive]){
                    if(![fluxLoader fetch]){
                        // This flux fetched failed
                        NSMutableDictionary* details = [NSMutableDictionary dictionary];
                        [details setValue:[NSString stringWithFormat:@"Fetching of flux %@ failed.", flux] forKey:NSLocalizedDescriptionKey];
                        NSError* error = [[NSError alloc] initWithDomain:@"FluxManager" code:1 userInfo:details];
                        [self.delegate fluxManager:self didFailReloadingWithError:error];
                    }
                } else {
                    NSLog(@"Flux %@ is not active", flux);
                }
            }
        } else {
            NSLog(@"Data is still fresh - not fetching anything");
            nextReload = minimumTimeBetweenReload + [lastReloadDate timeIntervalSinceNow];
            NSLog(@"Next reload needed in %d", nextReload);
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSString stringWithFormat:@"Next reload will take place in %d.", nextReload] forKey:NSLocalizedDescriptionKey];
            NSError* error = [[NSError alloc] initWithDomain:@"FluxManager" code:2 userInfo:details];
            [self.delegate fluxManager:self didFailReloadingWithError:error];

        }
        NSLog(@"Finished fetching");
        NSDate* now = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"lastReloadDate"];
        [self.delegate fluxManagerDidFinishReloading:self];
    });

    
}


#pragma mark - TABLE VIEW DATA SOURCE

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [fluxArray count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString* currentFlux = [fluxArray objectAtIndex:row];
    NSButtonCell* cell = [[NSButtonCell alloc] init];
    
    [cell setButtonType:NSSwitchButton];
    [tableColumn setDataCell:cell];
    [[tableColumn dataCell] setTitle:currentFlux];
    
    SAVR_FluxLoader* f = [[SAVR_ImgurFluxLoader alloc] initWithSubreddit:currentFlux];
    NSNumber *fState = [NSNumber numberWithBool:[f isActive]];

    return fState;
}

-(void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* fluxClicked = [fluxArray objectAtIndex:row];
    SAVR_ImgurFluxLoader *f = [[SAVR_ImgurFluxLoader alloc] initWithSubreddit:fluxClicked];
    if([f isActive]){
        NSLog(@"Switching flux %@ OFF", fluxClicked);
        [f setFluxAsInactive];
    } else {
        NSLog(@"Switching flux %@ ON", fluxClicked);
        [f setFluxAsActive];
    }
}

@end
