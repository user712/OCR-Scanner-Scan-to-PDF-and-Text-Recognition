//
//  NSDate+BOXAdditions.h
//  BoxContentSDK
//
//  Created by Rico Yao on 12/12/14.
//  Copyright (c) 2014 Box. 
//

#import <Foundation/Foundation.h>

@interface NSDate (BOXContentSDKAdditions)

+ (NSDate *)box_dateWithISO8601String:(NSString *)timestamp;

- (NSString *)box_ISO8601String;

@end
