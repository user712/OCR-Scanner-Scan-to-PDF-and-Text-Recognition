//
//  BOXRequestTestCase.h
//  BoxContentSDK
//
//  Created by Rico Yao on 11/21/14.
//  Copyright (c) 2014 Box. 
//

#import "BOXContentSDKTestCase.h"
#import "BOXCannedResponse.h"

@class BOXRequest;

@interface BOXRequestTestCase : BOXContentSDKTestCase

- (void)setCannedResponse:(BOXCannedResponse *)cannedResponse
               forRequest:(BOXRequest *)request;

// Deprecated. Use setCannedResponse:forRequest instead.
- (void)setCannedURLResponse:(NSHTTPURLResponse *)URLResponse
          cannedResponseData:(NSData *)cannedResponseData
                  forRequest:(BOXRequest *)request;

- (NSData *)cannedResponseDataWithName:(NSString *)cannedName;

- (NSHTTPURLResponse *)cannedURLResponseWithStatusCode:(NSInteger)statusCode responseData:(NSData *)responseData;

- (NSString *)stringFromInputStream:(NSInputStream *)inputStream;

- (NSArray *)sortedMultiPartPiecesFromBodyData:(NSData *)bodyData;

- (NSArray *)sortedMultiPartPiecesFromBodyDataString:(NSString *)bodyDataString;

- (void)setFakeQueueManagerForRequest:(BOXRequest *)request;

- (NSArray *)itemsFromResponseData:(NSData *)data;

@end
