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

#if 1
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
#endif

@end
