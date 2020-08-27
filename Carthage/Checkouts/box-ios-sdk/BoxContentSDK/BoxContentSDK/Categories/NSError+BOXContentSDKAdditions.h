//
//  NSError+BOXAdditions.h
//  BoxSDK
//
//  Copyright (c) 2015 Box. 
//

#import <Foundation/Foundation.h>

@interface NSError (BOXContentSDKAdditions)

- (NSString *)box_localizedFailureReasonString;
- (NSString *)box_localizedShortFailureReasonString;

@end
