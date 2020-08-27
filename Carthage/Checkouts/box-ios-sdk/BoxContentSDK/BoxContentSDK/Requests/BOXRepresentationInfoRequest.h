//
//  BOXRepresentationInfoRequest.h
//  BoxContentSDK
//
//  Created by Prithvi Jutur on 4/10/18.
//  Copyright © 2018 Box. 
//

#import <BoxContentSDK/BoxContentSDK.h>
@class BOXRepresentation;

@interface BOXRepresentationInfoRequest : BOXRequestWithSharedLinkHeader

- (instancetype)initWithFileID:(NSString *)fileID
                representation:(BOXRepresentation *)representation;
- (void)performRequestWithCompletion:(BOXRepresentationInfoBlock)completionBlock;
@end
