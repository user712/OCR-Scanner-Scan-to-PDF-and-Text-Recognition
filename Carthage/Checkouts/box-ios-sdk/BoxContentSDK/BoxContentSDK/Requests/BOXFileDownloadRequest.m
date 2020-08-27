//
//  BOXFileDownloadRequest.m
//  BoxContentSDK
//

#import "BOXRequest_Private.h"
#import "BOXFileDownloadRequest.h"
#import "BOXLog.h"
#import "BOXAPIDataOperation.h"
#import "BOXDispatchHelper.h"

@interface BOXFileDownloadRequest ()

@property (nonatomic, readonly, strong) NSString *destinationPath;
@property (nonatomic, readonly, strong) NSOutputStream *outputStream;
@property (nonatomic, readonly, strong) NSString *fileID;
@property (nonatomic, readwrite, copy) NSString *associateId;
@end

@implementation BOXFileDownloadRequest

- (instancetype)initWithLocalDestination:(NSString *)destinationPath
                                  fileID:(NSString *)fileID;
{
    if (self = [super init]) {
        _destinationPath = destinationPath;
        _fileID = fileID;
        _ignoreLocalURLRequestCache = NO;
    }
    return self;
}


- (instancetype)initWithLocalDestination:(NSString *)destinationPath
                                  fileID:(NSString *)fileID
                             associateId:(NSString *)associateId
{
    self = [self initWithLocalDestination:destinationPath fileID:fileID];
    self.associateId = associateId;
    return self;
}

- (instancetype)initWithOutputStream:(NSOutputStream *)outputStream
                              fileID:(NSString *)fileID
{
    if (self = [super init]) {
        _outputStream = outputStream;
        _fileID = fileID;
        _ignoreLocalURLRequestCache = NO;
    }
    return self;
}

- (void) setIgnoreLocalURLRequestCache:(BOOL)ignoreLocalURLRequestCache {
    if(ignoreLocalURLRequestCache) {
        [self.operation.APIRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    } else {
        [self.operation.APIRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
        
    }
}

- (BOXAPIOperation *)createOperation
{
    NSURL *URL = [self URLWithResource:BOXAPIResourceFiles
                                    ID:self.fileID
                           subresource:BOXAPISubresourceContent
                                 subID:nil];

    NSDictionary *queryParameters = nil;

    if (self.versionID.length > 0) {
        queryParameters = @{BOXAPIParameterKeyFileVersion : self.versionID};
    }

    BOXAPIDataOperation *dataOperation = [self dataOperationWithURL:URL
                                                         HTTPMethod:BOXAPIHTTPMethodGET
                                              queryStringParameters:queryParameters
                                                     bodyDictionary:nil
                                                       successBlock:nil
                                                       failureBlock:nil
                                                        associateId:self.associateId];

    dataOperation.modelID = self.fileID;
    
    BOXAssert(self.outputStream != nil || self.destinationPath != nil, @"An output stream or destination file path must be specified.");
    BOXAssert(!(self.outputStream != nil && self.destinationPath != nil), @"You cannot specify both an outputStream and a destination file path.");

    if (self.destinationPath != nil && self.associateId != nil) {
        dataOperation.destinationPath = self.destinationPath;
    } else if (self.outputStream != nil) {
        dataOperation.outputStream = self.outputStream;
    } else {
        dataOperation.outputStream = [[NSOutputStream alloc] initToFileAtPath:self.destinationPath append:NO];
    }
    [self addSharedLinkHeaderToRequest:dataOperation.APIRequest];

    return dataOperation;
}

- (void)performRequestWithProgress:(BOXProgressBlock)progressBlock completion:(BOXErrorBlock)completionBlock
{
    if (completionBlock) {
        BOOL isMainThread = [NSThread isMainThread];

        BOXAPIDataOperation *fileOperation = (BOXAPIDataOperation *)self.operation;
        if (progressBlock) {
            fileOperation.progressBlock = ^(long long expectedTotalBytes, unsigned long long bytesReceived) {
                [BOXDispatchHelper callCompletionBlock:^{
                    progressBlock(bytesReceived, expectedTotalBytes);
                } onMainThread:isMainThread];
            };
        }

        fileOperation.successBlock = ^(NSString *modelID, long long expectedTotalBytes) {
            [BOXDispatchHelper callCompletionBlock:^{
                completionBlock(nil);
            } onMainThread:isMainThread];
        };
        fileOperation.failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [BOXDispatchHelper callCompletionBlock:^{
                completionBlock(error);
            } onMainThread:isMainThread];
        };
        [self performRequest];
    }
}

#pragma mark - Superclass overidden methods

- (NSString *)itemIDForSharedLink
{
    return self.fileID;
}

- (BOXAPIItemType *)itemTypeForSharedLink
{
    return BOXAPIItemTypeFile;
}

- (void)cancelWithIntentionToResume
{
    BOXAPIDataOperation *dataOperation = (BOXAPIDataOperation *)self.operation;
    dataOperation.allowResume = YES;
    [self cancel];
}

@end
