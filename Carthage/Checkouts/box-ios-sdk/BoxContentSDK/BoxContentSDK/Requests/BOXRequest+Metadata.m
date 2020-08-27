//
//  BOXRequest+Metadata.m
//  BoxContentSDK
//
//  Created on 6/14/15.
//  Copyright (c) 2015 Box. 
//
#import "BOXRequest+Metadata.h"
#import "BOXContentSDKConstants.h"

@implementation BOXRequest (Metadata)

- (NSURL *)URLWithResource:(NSString *)resource
                        ID:(NSString *)ID
               subresource:(NSString *)subresource
                     scope:(NSString *)scope
                  template:(NSString *)templateName
{
    return [self URLWithBaseURL:self.baseURL
                       resource:resource
                             ID:ID
                    subresource:subresource
                          scope:scope
                       template:templateName];
}

- (NSURL *)URLWithBaseURL:(NSString *)baseURL
                 resource:(NSString *)resource
                       ID:(NSString *)ID
              subresource:(NSString *)subresource
                    scope:(NSString *)scope
                 template:(NSString *)templateName
{
    NSString *URLString = baseURL;
    if (resource) {
        URLString = [URLString stringByAppendingFormat:@"/%@", resource];
        if (ID) {
            URLString = [URLString stringByAppendingFormat:@"/%@", ID];
        }
        if (subresource) {
            URLString = [URLString stringByAppendingFormat:@"/%@", subresource];
        }
        if (scope) {
            URLString = [URLString stringByAppendingFormat:@"/%@", scope];
            if (templateName) {
                URLString = [URLString stringByAppendingFormat:@"/%@", templateName];
                
                if ([resource isEqualToString:BOXAPIResourceMetadataTemplates]) {
                    URLString = [URLString stringByAppendingString:@"/schema"];
                }
            }
        }
    }
        
    return [[NSURL alloc]initWithString:URLString];
}



@end
