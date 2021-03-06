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
        self.fluxName = [[@"Imgur" stringByAppendingString:@"_"] stringByAppendingString:@"earth"];
    }
    return self;
}

-(id)initWithDictionnary:(NSDictionary*)fluxDictionnary;
{
    self = [super init];
    if (self) {
        mySubreddit = [fluxDictionnary objectForKey:@"subreddit"];
        self.fluxName = [[@"Imgur" stringByAppendingString:@"_"] stringByAppendingString:[fluxDictionnary objectForKey:@"userFacingName"]];
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
        NSLog(@"%@ : Exception during request : %@", self.fluxName,  [exception description]);
        return @[];
    }

    if(response.code == 200){
        NSDictionary* object = response.body.object;
        NSArray* data = [object objectForKey:@"data"];
        return data;
    } else {
        NSLog(@"%@ : Error code : %d", self.fluxName, (int)response.code);
        return @[];
    }
}

#pragma mark - FILTER IMAGES


-(BOOL)isImageHighRes:(NSDictionary*) image
{
    int width = [[image objectForKey:@"width"] intValue];
    int height = [[image objectForKey:@"height"] intValue];
    NSScreen *mainScreen = [[NSScreen screens] firstObject];

    return (1.5 * MIN(width, height) > MAX(mainScreen.frame.size.width, mainScreen.frame.size.height));
}

-(BOOL)isImageNotPanorama:(NSDictionary*)image
{
    int width = [[image objectForKey:@"width"] intValue];
    int height = [[image objectForKey:@"height"] intValue];
    float aspectRatio = MAX(width/height, height/width);
    return aspectRatio < 2.5;
}

-(BOOL) isImageAcceptable:(NSDictionary*) image
{
    return  [self isImageHighRes:image] && [self isImageNotPanorama:image];
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
    NSLog(@"%@ : Fetching %@", self.fluxName, imageName);
    NSError *error;
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL] options:NSDataReadingMappedIfSafe error:&error];
    if(error){
        NSLog(@"%@ : Error fetching %@", self.fluxName, imageName);
        NSLog(@"%@ : Error : %@", self.fluxName, [error localizedDescription]);
        return NO;
    }
    NSString* imagePath = [[self getOrCreateFluxDirectory] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:imagePath atomically:YES];
        
    return YES;
}

-(int) fetch
{
    NSArray* images = [self fetchSubredditImageList];
    if((int)[images count] == 0){
        return 0;
    }
    int totalImagesFetched = 0;
    for(NSDictionary* image in images){
        if([self isImageAcceptable:image] && ![self isImageAlreadyDownloaded:image]){
            int i = [self fetchSingleImage:image];
            if(i < 0){
                return -1;
            }
            totalImagesFetched += i;
        }
    }
    return totalImagesFetched;
}


@end
