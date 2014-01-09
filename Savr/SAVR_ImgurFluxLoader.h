//
//  SAVR_ImgurFluxLoader.h
//  Savr
//
//  Created by Jean Caillé on 21/10/13.
//  Copyright (c) 2013 Jean Caillé. All rights reserved.
//

#import "SAVR_FluxLoader.h"

@interface SAVR_ImgurFluxLoader : SAVR_FluxLoader
{
    NSString* mySubreddit;
}

-(id)initWithDictionnary:(NSDictionary*)fluxDictionnary;
@end
