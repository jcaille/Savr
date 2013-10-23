//
//  SAVR_ImgurFluxLoader.m
//  Savr
//
//  Created by Jean Caillé on 21/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_ImgurFluxLoader.h"
#import "SAVR_Secrets.h"
#import "UNIRest.h"

@implementation SAVR_ImgurFluxLoader

- (id)init {
    self = [super init];
    if (self) {
        mySubreddit = @"earthporn";
        fluxName = [[@"Imgur" stringByAppendingString:@"_"] stringByAppendingString:mySubreddit];
    }
    return self;
}

- (id)initWithSubreddit:(NSString*)subredditName
{
    self = [super init];
    if (self) {
        mySubreddit = subredditName;
        fluxName = [[@"Imgur" stringByAppendingString:@"_"] stringByAppendingString:mySubreddit];
    }
    return self;
}

-(void) fetchSubredditImageList
{
    // Construct URL https://api.imgur.com/3/r/subreddit_name/top/week/.jsson
    NSString* completeUrl = [[[[@"https://api.imgur.com/3/gallery"
                            stringByAppendingPathComponent:@"r"]
                            stringByAppendingPathComponent:mySubreddit]
                            stringByAppendingPathComponent:@"top/week/"]
                            stringByAppendingPathExtension:@"json"];
    
    //Set appropriate headers
    NSDictionary* headers = @{@"accept": @"application/json",
                              @"Authorization": imgurAuthHeader};
    
    UNIHTTPJsonResponse* response = [[UNIRest get:^(UNISimpleRequest * request) {
        [request setUrl:completeUrl];
        [request setHeaders:headers];
    }] asJson];
    
    NSLog(@"%@", response.body.object);
    
}

-(BOOL) fetchImageWithUrl:(NSString*)url andName:(NSString*)name andExtension:(NSString*) extension
{
    NSData* imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    NSString* imagePath = [[[self getOrCreateFluxDirectory] stringByAppendingPathComponent:name]
        stringByAppendingPathExtension:extension];
    [imageData writeToFile:imagePath atomically:YES];
    return YES;
}


-(BOOL) fetch
{
    [self fetchSubredditImageList];
    return YES;
}


@end
