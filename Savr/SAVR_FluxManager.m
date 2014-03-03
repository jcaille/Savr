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

    NSTimer *_reloadTimer;
    BOOL _isReloading;
}

#pragma mark - Object life

+(id)sharedInstance
{
    static SAVR_FluxManager* sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithImgurFlux:SAVR_DEFAULT_FLUX()];
    });
    return sharedInstance;
}

-(id)initWithImgurFlux:(NSArray*)imgurFlux
{
    self = [super init];
    if (self) {
        NSMutableArray* tmpFlux = [[NSMutableArray alloc] initWithCapacity:imgurFlux.count];
        NSMutableArray* tmpHumanReadableDescription = [[NSMutableArray alloc] initWithCapacity:imgurFlux.count];

        for(NSDictionary* flux in imgurFlux){
            [tmpFlux addObject:[[SAVR_ImgurFluxLoader alloc] initWithDictionnary:flux]];
            
            NSString* fluxHumanReadableDescription = [[[flux objectForKey:@"userFacingName"] stringByAppendingString:@" — "] stringByAppendingString:[flux objectForKey:@"description"]];
            [tmpHumanReadableDescription addObject:fluxHumanReadableDescription];
        }
        _fluxArray = tmpFlux;
        _humanReadableDescription = tmpHumanReadableDescription;

        [self checkIntegrity];
        [self fileNotifications];
        [self reloadActiveFlux:NO];
    }
    return self;
}

#pragma mark - Wake Up / Sleep Notifications

- (void) fileNotifications
{
    NSLog(@"Filing for notification");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

- (void) receiveWakeNote: (NSNotification*) note
{
    NSLog(@"Waking up - Reloading flux, no force");
    [self reloadActiveFlux:NO];
}

- (void) receiveSleepNote: (NSNotification*) note
{
    NSLog(@"Going to sleep - Invalidate timer");
    [_reloadTimer invalidate];
}

#pragma mark - Utilities

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

#pragma mark - Flux reloading cycle

-(void)resetReloadTimer
{
    _reloadTimer = [NSTimer timerWithTimeInterval:TIME_BETWEEN_RELOAD_TRY target:self selector:@selector(reloadActiveFluxOnTimer) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_reloadTimer forMode:NSRunLoopCommonModes];
}

-(void)reloadActiveFluxOnTimer
{
    [self reloadActiveFlux:NO];
}

-(void) reloadActiveFlux:(BOOL)force{
    // TODO : CHECK FOR CONNECTIVITY
    [self didStartReloading];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int totalImagesFetched = 0;
        for (SAVR_FluxLoader* fluxLoader in _fluxArray) {
            NSError *error;
            totalImagesFetched += [fluxLoader reload:force error:&error];
            if(error){
                [self didFailReloadingWithError:error];
                return;
            }
        }
        [self didFinishReloadingNewImages:totalImagesFetched];
    });
}

-(void)didStartReloading
{
    NSLog(@"Start reloading");
    _isReloading = YES;
    [_reloadTimer invalidate];

    if (self.delegate && [self.delegate respondsToSelector:@selector(fluxManagerDidStartReloading:)]) {
        [self.delegate fluxManagerDidStartReloading:self];
    }
}

-(void)didFailReloadingWithError:(NSError*)error
{
    NSLog(@"Reloading failed : %@", error.localizedDescription);
    _isReloading = NO;
    [self resetReloadTimer];

    if (self.delegate && [self.delegate respondsToSelector:@selector(fluxManager:didFailReloadingWithError:)]) {
        [self.delegate fluxManager:self didFailReloadingWithError:error];
    }
}

-(void)didFinishReloadingNewImages:(int)numberOfImagesFetched
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSAVRLastReloadDateKey];
    NSLog(@"Finished reloading, got %d images", numberOfImagesFetched);
    [self resetReloadTimer];
    _isReloading = NO;

    if (self.delegate && [self.delegate respondsToSelector:@selector(fluxManagerDidFinishReloading:newImages:)]) {
        [self.delegate fluxManagerDidFinishReloading:self newImages:numberOfImagesFetched];
    }
}

#pragma mark - TableView DataSource

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
        [self reloadActiveFlux:NO];
    }
}

@end
