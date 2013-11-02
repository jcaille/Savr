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
    // Construct URL https://api.imgur.com/3/r/subreddit_name/top/week/.json
    NSString* completeUrl = [[[[@"https://api.imgur.com/3/gallery"
                            stringByAppendingPathComponent:@"r"]
                            stringByAppendingPathComponent:mySubreddit]
                            stringByAppendingPathComponent:@"top/week/"]
                            stringByAppendingPathExtension:@"json"];
    
    //Set appropriate headers
    NSDictionary* headers = @{@"accept": @"application/json",
                              @"Authorization": imgurAuthHeader};
    
    UNIHTTPJsonResponse* response;
    @try {
        response = [[UNIRest get:^(UNISimpleRequest * request) {
            [request setUrl:completeUrl];
            [request setHeaders:headers];
        }] asJson];
    }
    @catch (NSException *exception) {
        NSLog(@"%@ : Exception during request : %@", fluxName,  [exception description]);
        return @[];
    }

    if(response.code == 200){
        NSDictionary* object = response.body.object;
        NSArray* data = [object objectForKey:@"data"];
        return data;
    } else {
        NSLog(@"%@ : Error code : %d", fluxName, (int)response.code);
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

-(BOOL) isImageAlreadyDownloaded:(NSDictionary*) image
{
    NSString* imageURL = [image objectForKey:@"link"];
    NSString* imageName = [imageURL lastPathComponent];
    NSString* imagePath = [[self getOrCreateFluxDirectory] stringByAppendingPathComponent:imageName];
    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - FETCH SINGLE IMAGE
-(BOOL) fetchSingleImage:(NSDictionary*) image
{
    NSString* imageURL = [image objectForKey:@"link"];
    NSString* imageName = [imageURL lastPathComponent];
    NSLog(@"%@ : Fetching %@", fluxName, imageName);
    NSError *error;
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL] options:NSDataReadingMappedIfSafe error:&error];
    if(error){
        NSLog(@"%@ : Error fetching %@", fluxName, imageName);
        NSLog(@"%@ : Error : %@", fluxName, [error localizedDescription]);
        return NO;
    }
    NSString* imagePath = [[self getOrCreateFluxDirectory] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:imagePath atomically:YES];
    return YES;
}

-(BOOL) fetch
{
    NSArray* images = [self fetchSubredditImageList];
    if((int)[images count] == 0){
        return NO;
    }
    for(NSDictionary* image in images){
        if([self isImageAcceptable:image] && ![self isImageAlreadyDownloaded:image]){
            if(![self fetchSingleImage:image]){
                return NO;
            }
        }
    }
    return YES;
}


@end
