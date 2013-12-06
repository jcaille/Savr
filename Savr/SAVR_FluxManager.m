//
//  SAVR_FluxManager.m
//  Savr
//
//  Created by Jean Caillé on 01/11/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_FluxManager.h"
#import "SAVR_ImgurFluxLoader.h"
#import "SAVR_Utils.h"
@implementation SAVR_FluxManager
{
    NSArray *_fluxArray;
    NSArray *_humanReadableDescription;
}

-(id) initWithImgurFlux:(NSArray*)imgurFlux
{
    self = [super init];
    if (self) {
        NSMutableArray* tmpFlux = [[NSMutableArray alloc] initWithCapacity:imgurFlux.count];
        NSMutableArray* tmpHumanReadableDescription = [[NSMutableArray alloc] initWithCapacity:imgurFlux.count];

        for(NSDictionary* flux in imgurFlux){
            NSString* fluxSubreddit = [flux objectForKey:@"subreddit"];
            [tmpFlux addObject:[[SAVR_ImgurFluxLoader alloc] initWithSubreddit:fluxSubreddit]];
            
            NSString* fluxHumanReadableDescription = [flux objectForKey:@"description"];
            [tmpHumanReadableDescription addObject:fluxHumanReadableDescription];
        }
        _fluxArray = tmpFlux;
        _humanReadableDescription = tmpHumanReadableDescription;
    }
    return self;
}

#pragma mark - FLUX MANAGEMENT

-(void) reloadActiveFlux:(BOOL)force{
    // TODO : CHECK FOR CONNECTIVITY
    [self.delegate fluxManagerDidStartReloading:self];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (SAVR_FluxLoader* fluxLoader in _fluxArray) {
            NSError *error;
            [fluxLoader reload:force error:&error];
            if(error){
                [self.delegate fluxManager:self didFailReloadingWithError:error];
                return;
            }
        }
        [self.delegate fluxManagerDidFinishReloading:self];
    });
}

-(void) checkIntegrity
{
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[SAVR_Utils getOrCreateUserVisibleDirectory] error:nil];
    for(NSString* directory in content){
        NSString* itemFullPath = [[SAVR_Utils getOrCreateUserVisibleDirectory] stringByAppendingPathComponent:directory];
        NSString* itemType = [[[NSFileManager defaultManager]
                               attributesOfItemAtPath:itemFullPath error:nil]
                              fileType];
        if([itemType isEqualToString:NSFileTypeSymbolicLink])
        {
            //Remove item
            [[NSFileManager defaultManager] removeItemAtPath:itemFullPath error:nil];
        }
    }
    for(SAVR_FluxLoader* flux in _fluxArray)
    {
        if([flux isActive]){
            [flux setFluxAsActive];
        } else {
            [flux setFluxAsInactive];
        }
    }
}
#pragma mark - TABLE VIEW DATA SOURCE

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_fluxArray count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    SAVR_FluxLoader* currentFlux = [_fluxArray objectAtIndex:row];
    [[tableColumn dataCell] setTitle:[_humanReadableDescription objectAtIndex:row]];
    
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
