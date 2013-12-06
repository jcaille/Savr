//
//  SAVR_URLFluxLoaderTest.m
//  Savr
//
//  Created by Jean Caillé on 23/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAVR_URLFluxLoader.h"

@interface SAVR_URLFluxLoaderTest : XCTestCase
{
    SAVR_URLFluxLoader* fluxLoader;
}
@end

@implementation SAVR_URLFluxLoaderTest

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

-(void) test_fluxHasName
{
    XCTAssertFalse([fluxLoader.fluxName isEqualToString:@""], "Flux has no name");
}

#pragma mark - FETCHING

-(void) test_fetchingReturns
{
    XCTAssertTrue([fluxLoader fetch]);
}

-(void) test_fetchingReturnsAtLeastOneFile
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

-(void) test_cleanedDirectoryIsEmpty
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

-(void) test_defaultStateIsInactive
{
    XCTAssertFalse([fluxLoader isActive]);
}

-(void) test_settingActiveReturns
{
    XCTAssertTrue([fluxLoader setFluxAsActive]);
}

-(void) test_settingActiveChangesState
{
    [fluxLoader setFluxAsActive];
    XCTAssertTrue([fluxLoader isActive]);
}

-(void) test_settingInactiveReturns
{
    [fluxLoader setFluxAsActive];
    XCTAssertTrue([fluxLoader setFluxAsInactive]);
}

-(void) test_settingInactiveChangesState
{
    [fluxLoader setFluxAsActive];
    [fluxLoader setFluxAsInactive];
    XCTAssertFalse([fluxLoader isActive]);
}

@end
