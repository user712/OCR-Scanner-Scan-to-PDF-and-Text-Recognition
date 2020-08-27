//
//  BOXCannedURLProtocol.h
//  BoxContentSDK
//
//  Created by Rico Yao on 11/24/14.
//  Copyright (c) 2014 Box. 
//

#import "BOXCannedResponse.h"

@interface BOXCannedURLProtocol : NSURLProtocol

+ (void)setCannedResponse:(BOXCannedResponse *)cannedResponse
               forRequest:(NSURLRequest *)request;

+ (void)reset;

@end
