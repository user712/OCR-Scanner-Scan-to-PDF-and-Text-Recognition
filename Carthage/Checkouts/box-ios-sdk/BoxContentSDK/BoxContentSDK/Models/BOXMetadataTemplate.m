//
//  BOXMetadataTemplate.m
//  BoxContentSDK
//
//  Created on 6/15/15.
//  Copyright (c) 2015 Box. 
//

#import "BOXMetadataTemplate.h"
#import "BOXISO8601DateFormatter.h"
#import "BOXMetadataTemplateField.h"

@implementation BOXMetadataTemplate

- (instancetype)initWithJSON:(NSDictionary *)JSONData
{
    if (self = [super initWithJSON:JSONData]) {
        self.modelID = [NSJSONSerialization box_ensureObjectForKey:BOXAPIParameterKeyTemplate
                                                      inDictionary:JSONData
                                                   hasExpectedType:[NSString class]
                                                       nullAllowed:NO];
        self.scope = [NSJSONSerialization box_ensureObjectForKey:BOXAPIParameterKeyScope
                                                    inDictionary:JSONData
                                                 hasExpectedType:[NSString class]
                                                     nullAllowed:NO];
        self.displayName = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyDisplayName
                                                          inDictionary:JSONData
                                                       hasExpectedType:[NSString class]
                                                           nullAllowed:NO];
        NSMutableArray *fields = [[NSMutableArray alloc]init];
        NSArray *serializedFieldsJSON = [NSJSONSerialization box_ensureObjectForKey:BOXAPIParameterKeyFields
                                                                       inDictionary:JSONData
                                                                    hasExpectedType:[NSArray class]
                                                                        nullAllowed:NO];
        for (NSDictionary *field in serializedFieldsJSON) {
            BOXMetadataTemplateField *templateField = [[BOXMetadataTemplateField alloc]initWithJSON:field];
            [fields addObject:templateField];
        }
        self.fields = fields;
        self.JSONData = JSONData;
    }
    
    return self;
}

@end
