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
    NSArray *_fluxArray;
}

-(id) initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:array.count];
        for(NSString* fluxName in array){
            [tmp addObject:[[SAVR_ImgurFluxLoader alloc] initWithSubreddit:fluxName]];
        }
        _fluxArray = tmp;
    }
    return self;
}

#pragma mark - FLUX MANAGEMENT

-(void) reloadActiveFlux:(BOOL)force
{
    [self.delegate fluxManagerDidStartReloading:self];
    // Loading is done outside of main thread to prevent UI block
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int minimumTimeBetweenReload = 3600;
        int nextReload; // tommorow
        NSDate *lastReloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReloadDate"];

        if(lastReloadDate == nil || [lastReloadDate timeIntervalSinceNow] < - minimumTimeBetweenReload || force){
            // TODO : CHECK FOR CONNECTIVITY
            for (SAVR_FluxLoader* fluxLoader in _fluxArray) {
                if([fluxLoader isActive]){
                    if(![fluxLoader fetch]){
                        // This flux fetched failed
                        NSMutableDictionary* details = [NSMutableDictionary dictionary];
                        [details setValue:[NSString stringWithFormat:@"Fetching of flux %@ failed.", fluxLoader.fluxName] forKey:NSLocalizedDescriptionKey];
                        NSError* error = [[NSError alloc] initWithDomain:@"FluxManager" code:1 userInfo:details];
                        [self.delegate fluxManager:self didFailReloadingWithError:error];
                        return;
                    }
                }
            }
        } else {
            nextReload = minimumTimeBetweenReload + [lastReloadDate timeIntervalSinceNow];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSString stringWithFormat:@"Data still fresh. Next reload needed in %d.", nextReload] forKey:NSLocalizedDescriptionKey];
            NSError* error = [[NSError alloc] initWithDomain:@"FluxManager" code:2 userInfo:details];
            [self.delegate fluxManager:self didFailReloadingWithError:error];
            return;
        }
        NSDate* now = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"lastReloadDate"];
        [self.delegate fluxManagerDidFinishReloading:self];
    });

    
}


#pragma mark - TABLE VIEW DATA SOURCE

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_fluxArray count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    SAVR_FluxLoader* currentFlux = [_fluxArray objectAtIndex:row];
    NSButtonCell* cell = [[NSButtonCell alloc] init];
    
    [cell setButtonType:NSSwitchButton];
    [tableColumn setDataCell:cell];
    [[tableColumn dataCell] setTitle:currentFlux.fluxName];
    
    NSNumber *fState = [NSNumber numberWithBool:[currentFlux isActive]];

    return fState;
}

-(void) tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    SAVR_FluxLoader* fluxClicked = [_fluxArray objectAtIndex:row];
    if([fluxClicked isActive]){
        NSLog(@"Switching flux %@ OFF", fluxClicked.fluxName);
        [fluxClicked setFluxAsInactive];
    } else {
        NSLog(@"Switching flux %@ ON", fluxClicked.fluxName);
        [fluxClicked setFluxAsActive];
    }
}

@end
