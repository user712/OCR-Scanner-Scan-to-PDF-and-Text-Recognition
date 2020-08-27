//
//  NSJSONSerialization+BOXAdditions.m
//  BoxContentSDK
//
//  Created on 8/19/13.
//  Copyright (c) 2013 Box. 
//

#import "NSJSONSerialization+BOXContentSDKAdditions.h"

#import "BOXLog.h"

@implementation NSJSONSerialization (BOXContentSDKAdditions)

+ (id)box_ensureObjectForKey:(NSString *)key inDictionary:(NSDictionary *)dictionary hasExpectedType:(Class)cls nullAllowed:(BOOL)nullAllowed
{
    id object = [dictionary objectForKey:key];
    id extractedObject = object;
    if ([object isEqual:[NSNull null]])
    {
        if (nullAllowed)
        {
            extractedObject = [NSNull null];
        }
        else
        {
            BOXAssertFail(@"Unexpected JSON null when extracting key %@ from dictionary %@", key, dictionary);
            extractedObject = nil;
        }
    }
    else if (object == nil)
    {
        extractedObject = nil;
    }
    else if (![object isKindOfClass:cls])
    {
        BOXAssertFail(@"Unexpected type when extracting key %@ from dictionary %@\nExpected type %@ but instead got %@", key, dictionary, NSStringFromClass(cls), NSStringFromClass([object class]));
        extractedObject = nil;
    }
    return extractedObject;
}

+ (id)box_ensureObjectForKey:(NSString *)key inDictionary:(NSDictionary *)dictionary hasExpectedType:(Class)cls nullAllowed:(BOOL)nullAllowed suppressNullAsNil:(BOOL)suppressNullAsNil
{
    id extractedObject = [self box_ensureObjectForKey:key
                                     inDictionary:dictionary
                                  hasExpectedType:cls
                                      nullAllowed:nullAllowed];

    if (suppressNullAsNil)
    {
        if ([extractedObject isEqual:[NSNull null]])
        {
            extractedObject = nil;
        }
    }

    return extractedObject;
}

@end
