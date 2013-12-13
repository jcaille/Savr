//
//  SAVR_URLFluxLoader.m
//  Savr
//
//  Created by Jean Caillé on 19/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_URLFluxLoader.h"

@implementation SAVR_URLFluxLoader

- (id)init {
    self = [super init];
    if (self) {
        self.fluxName = @"URL";
        myUrl = @"http://placekitten.com/1024/768";
    }
    return self;
}

-(int) fetch
{
    NSData* imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: myUrl]];
    NSString* imagePath = [[[self getOrCreateFluxDirectory] stringByAppendingPathComponent:@"image"] stringByAppendingPathExtension:@"jpg"];
    [imageData writeToFile:imagePath atomically:YES];
    return 1;
}
@end
