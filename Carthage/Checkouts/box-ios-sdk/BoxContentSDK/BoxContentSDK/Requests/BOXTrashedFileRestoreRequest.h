//
//  BOXTrashedFileRestoreRequest.h
//  BoxContentSDK
//

#import "BOXRequest.h"

@interface BOXTrashedFileRestoreRequest : BOXRequest

// NOTE: Both the associateID and requestDirectoryPath values are required for performing the request in the background.
/**
 Caller provided unique ID to execute the request as a NSURLSession background task.
 This is a required value for performing the request in the background.
 */
@property (nonatomic, readwrite, copy) NSString *associateId;

/**
 Caller provided directory path for the result payload of the background operation to be written to.
 This is a required value for performing the request in the background.
 */
@property (nonatomic, readwrite, copy) NSString *requestDirectoryPath;

@property (nonatomic, readonly, strong) NSString *fileID;

@property (nonatomic, readwrite, strong) NSString *fileName;

@property (nonatomic, readwrite, strong) NSString *parentFolderID;

- (instancetype)initWithFileID:(NSString *)fileID;
- (void)performRequestWithCompletion:(BOXFileBlock)completionBlock;

@end
