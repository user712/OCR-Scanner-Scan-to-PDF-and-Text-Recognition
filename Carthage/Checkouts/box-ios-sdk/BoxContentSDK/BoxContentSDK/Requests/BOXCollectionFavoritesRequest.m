//
//  BOXCollectionFavoritesRequest.m
//  BoxContentSDK
//

#import "BOXRequest_Private.h"
#import "BOXCollectionFavoritesRequest.h"

#import "BOXCollection.h"
#import "BOXDispatchHelper.h"

@implementation BOXCollectionFavoritesRequest 

- (void)performRequestWithCompletion:(BOXCollectionBlock)completionBlock
{
    if (completionBlock) {
        BOOL isMainThread = [NSThread isMainThread];
        BOXAPIJSONOperation *collectionListOperation = (BOXAPIJSONOperation *)self.operation;

        collectionListOperation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary) {
            NSArray *collectionsJSON = JSONDictionary[BOXAPICollectionKeyEntries];

            BOXCollection *favoritesCollection = nil;

            for (NSDictionary *dict in collectionsJSON) @autoreleasepool {
                if ([dict[BOXAPIObjectKeyCollectionType] isEqual:[NSNull null]] == NO &&
                    [dict[BOXAPIObjectKeyCollectionType] isEqualToString:BOXAPIFavoritesCollectionType]) {
                    favoritesCollection = [[BOXCollection alloc] initWithJSON:dict];
                }
            }

            if ([self.cacheClient respondsToSelector:@selector(cacheFavoriteCollectionRequest:withCollection:error:)]) {
                [self.cacheClient cacheFavoriteCollectionRequest:self
                                                  withCollection:favoritesCollection
                                                           error:nil];
            }

            [BOXDispatchHelper callCompletionBlock:^{
                completionBlock(favoritesCollection, nil);
            } onMainThread:isMainThread];
        };
        collectionListOperation.failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {

            if ([self.cacheClient respondsToSelector:@selector(cacheFavoriteCollectionRequest:withCollection:error:)]) {
                [self.cacheClient cacheFavoriteCollectionRequest:self
                                                  withCollection:nil
                                                           error:error];
            }

            [BOXDispatchHelper callCompletionBlock:^{
                completionBlock(nil, error);
            } onMainThread:isMainThread];
        };
        [self performRequest];
    }
}

- (void)performRequestWithCached:(BOXCollectionBlock)cacheBlock
                       refreshed:(BOXCollectionBlock)refreshBlock
{
    if (cacheBlock) {
        if ([self.cacheClient respondsToSelector:@selector(retrieveCacheForFavoriteCollectionRequest:completionBlock:)]) {
            [self.cacheClient retrieveCacheForFavoriteCollectionRequest:self completionBlock:cacheBlock];
        } else {
            cacheBlock(nil, nil);
        }
    }

    [self performRequestWithCompletion:refreshBlock];
}

@end
