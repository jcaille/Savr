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

#pragma mark - FETCH GLOBAL INFORMATION

-(NSArray*) fetchSubredditImageList
{
    // Construct URL https://api.imgur.com/3/r/subreddit_name/top/week/.jsson
    NSString* completeUrl = [[[[@"https://api.imgur.com/3/gallery"
                            stringByAppendingPathComponent:@"r"]
                            stringByAppendingPathComponent:mySubreddit]
                            stringByAppendingPathComponent:@"top/week/"]
                            stringByAppendingPathExtension:@"json"];
    
    NSLog(@"%@", completeUrl);
    //Set appropriate headers
    NSDictionary* headers = @{@"accept": @"application/json",
                              @"Authorization": imgurAuthHeader};
    
    UNIHTTPJsonResponse* response = [[UNIRest get:^(UNISimpleRequest * request) {
        [request setUrl:completeUrl];
        [request setHeaders:headers];
    }] asJson];
    
    if(response.code == 200){
        NSDictionary* object = response.body.object;
        NSArray* data = [object objectForKey:@"data"];
        return data;
    } else {
        NSLog(@"Error code : %d", (int)response.code);
        return @[];
    }
}

#pragma mark - FILTER IMAGES


-(BOOL) isImageHighRes:(NSDictionary*) image
{
    NSNumber* width = [image objectForKey:@"width"];
    NSNumber* height = [image objectForKey:@"height"];
    return (MIN(width, height) > [NSNumber numberWithInt:1000]);
}

-(BOOL) isImageAcceptable:(NSDictionary*) image
{
    return  [self isImageHighRes:image];
}

#pragma mark - FETCH SINGLE IMAGE
-(BOOL) fetchSingleImage:(NSDictionary*) image
{
    NSString* imageURL = [image objectForKey:@"link"];
    NSString* imageName = [imageURL lastPathComponent];
    NSLog(@"Fetching %@", imageName);
    NSData* imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageURL]];
    NSString* imagePath = [[self getOrCreateFluxDirectory] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:imagePath atomically:YES];
    return YES;
}

-(BOOL) fetch
{
    NSLog(@"Getting image list");
    NSArray* images = [self fetchSubredditImageList];
    NSLog(@"got iamage lists");
    for(NSDictionary* image in images){
        if([self isImageAcceptable:image]){
            [self fetchSingleImage:image];
        }
    }
    return YES;
}


@end
