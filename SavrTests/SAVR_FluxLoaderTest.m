//
//  SAVR_FluxLoaderTest.m
//  Savr
//
//  Created by Jean Caillé on 22/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "SAVR_FluxLoader.h"
#import "SAVR_URLFluxLoader.h"

@interface SAVR_FluxLoaderTest : XCTestCase
{
    SAVR_FluxLoader* fluxLoader;
}
@end

@implementation SAVR_FluxLoaderTest

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    fluxLoader = [[SAVR_URLFluxLoader alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [fluxLoader setFluxAsInactive];
    [fluxLoader cleanDirectory];
    [super tearDown];
}

-(void) fluxHasName
{
    XCTAssertTrue(![fluxLoader->fluxName isEqualToString:@""]);
}

#pragma mark - FETCHING

-(void) fetchingReturns
{
    XCTAssertTrue([fluxLoader fetch]);
}

-(void) fetchingReturnsAtLeastOneFile
{
    [fluxLoader fetch];
    NSString* dir = [fluxLoader getOrCreateFluxDirectory];
    NSError* error;
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&error];
    if(error){
        XCTFail(@"Error : %@", [error localizedDescription]);
    }
    XCTAssertTrue([content count] > 0, @"No file in folder");
}

#pragma mark - FILE MANAGEMENT

-(void) cleanedDirectoryIsEmpty
{
    [fluxLoader fetch];
    NSString* dir = [fluxLoader getOrCreateFluxDirectory];
    [fluxLoader cleanDirectory];
    NSError* error;
    NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&error];
    if(error){
        XCTFail(@"Error : %@", [error localizedDescription]);
    }
    XCTAssertFalse([content count] > 0, @"Still some files in folder");

}

#pragma mark - STATE

-(void) defaultStateIsInactive
{
    XCTAssertFalse([fluxLoader isActive]);
}

-(void) settingActiveReturns
{
    XCTAssertTrue([fluxLoader setFluxAsActive]);
}

-(void) settingActiveChangesState
{
    [fluxLoader setFluxAsActive];
    XCTAssertTrue([fluxLoader isActive]);
}

-(void) settingInactiveReturns
{
    [fluxLoader setFluxAsActive];
    XCTAssertTrue([fluxLoader setFluxAsInactive]);
}

-(void) settingInactiveChangesState
{
    [fluxLoader setFluxAsActive];
    [fluxLoader setFluxAsInactive];
    XCTAssertFalse([fluxLoader isActive]);
}

@end
