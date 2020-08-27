//
//  BOXFile.m
//  BoxContentSDK
//
//
 
#import "BOXFile.h"
#import "BOXFileLock.h"
#import "BOXRepresentation.h"

@implementation BOXFileMini

- (instancetype)initWithJSON:(NSDictionary *)JSONResponse
{
    BOXAssert([JSONResponse[BOXAPIObjectKeyType] isEqualToString:BOXAPIItemTypeFile], @"Invalid type for object.");
    self = [super initWithJSON:JSONResponse];
    return self;
}

- (BOOL)isFile
{
    return YES;
}

@end

@implementation BOXFile

- (instancetype)initWithJSON:(NSDictionary *)JSONResponse
{
    BOXAssert([JSONResponse[BOXAPIObjectKeyType] isEqualToString:BOXAPIItemTypeFile], @"Invalid type for object.");

    if (self = [super initWithJSON:JSONResponse]) {
        
        // Parse SHA1 Value of File.
        self.SHA1 = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeySHA1
                                                   inDictionary:JSONResponse
                                                hasExpectedType:[NSString class]
                                                    nullAllowed:NO];

        // Parse Version Number.
        self.versionNumber = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyVersionNumber
                                                            inDictionary:JSONResponse
                                                         hasExpectedType:[NSString class]
                                                             nullAllowed:NO];

        // Parse Comment Count.
        self.commentCount = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyCommentCount
                                                           inDictionary:JSONResponse
                                                        hasExpectedType:[NSNumber class]
                                                            nullAllowed:NO];

        // Parse Extension.
        self.extension = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyExtension
                                                        inDictionary:JSONResponse
                                                     hasExpectedType:[NSString class]
                                                         nullAllowed:NO];

        // Parse Permissions.
        NSDictionary *permissions = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyPermissions
                                                                   inDictionary:JSONResponse
                                                                hasExpectedType:[NSDictionary class]
                                                                    nullAllowed:NO];
        [self parsePermssionsFromJSON:permissions];

        // Parse IsPackage.
        NSNumber *isPackage = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyIsPackage
                                                              inDictionary:JSONResponse
                                                           hasExpectedType:[NSNumber class]
                                                               nullAllowed:NO];
        if (isPackage) {
            self.isPackage = isPackage.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        // Parse Lock.
        NSDictionary *lock = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyLock
                                                            inDictionary:JSONResponse
                                                         hasExpectedType:[NSDictionary class]
                                                             nullAllowed:YES];
        if (lock && ![lock isKindOfClass:[NSNull class]]) {
            self.lock = [[BOXFileLock alloc] initWithJSON:lock];
        }

        NSString *authenticatedDownloadURLString = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyAuthenticatedDownloadURL
                                                                     inDictionary:JSONResponse
                                                                  hasExpectedType:[NSString class]
                                                                      nullAllowed:NO];
        if (authenticatedDownloadURLString.length > 0) {
            self.authenticatedDownloadUrl = [NSURL URLWithString:authenticatedDownloadURLString];
        }
        
        // Parse Representations.
        NSDictionary *representationsJSON = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyRepresentations
                                                                          inDictionary:JSONResponse
                                                                       hasExpectedType:[NSDictionary class]
                                                                           nullAllowed:NO];
        NSArray *representations = representationsJSON[BOXAPIObjectKeyEntries];
        if (representations) {
            NSMutableArray *tempRepresentations = [NSMutableArray array];
            
            for (NSDictionary *representationJSON in representations) {
                BOXRepresentation *representation = [[BOXRepresentation alloc] initWithJSON:representationJSON];
                [tempRepresentations addObject:representation];
            }
            
            // Add the original content url to self.representations as BOXRepresentationRequestOriginal for convenience
            if (self.authenticatedDownloadUrl.absoluteString.length > 0) {
                BOXRepresentation *representation = [[BOXRepresentation alloc] init];
                representation.type = BOXRepresentationTypeOriginal;
                representation.contentURL = self.authenticatedDownloadUrl;
                representation.status = BOXRepresentationStatusSuccess;
                [tempRepresentations addObject:representation];
            }
            
            self.representations = [NSArray arrayWithArray:tempRepresentations];
        }
    }
    
    return self;
}

- (void)parsePermssionsFromJSON:(NSDictionary *)permissions
{
    if (permissions) {
        NSNumber *canDownload = permissions[BOXAPIObjectKeyCanDownload];
        if (canDownload) {
            self.canDownload = canDownload.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canPreview = permissions[BOXAPIObjectKeyCanPreview];
        if (canDownload) {
            self.canPreview = canPreview.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canUpload = permissions[BOXAPIObjectKeyCanUpload];
        if (canUpload) {
            self.canUpload = canUpload.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canComment = permissions[BOXAPIObjectKeyCanComment];
        if (canComment) {
            self.canComment = canComment.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canRename = permissions[BOXAPIObjectKeyCanRename];
        if (canRename) {
            self.canRename = canRename.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canDelete = permissions[BOXAPIObjectKeyCanDelete];
        if (canDelete) {
            self.canDelete = canDelete.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canShare = permissions[BOXAPIObjectKeyCanShare];
        if (canShare) {
            self.canShare = canShare.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canSetShareAccess = permissions[BOXAPIObjectKeyCanSetShareAccess];
        if (canSetShareAccess) {
            self.canSetShareAccess = canSetShareAccess.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }
        
        NSNumber *canInviteCollaborator = permissions[BOXAPIObjectKeyCanInviteCollaborator];
        if (canInviteCollaborator != nil) {
            self.canInviteCollaborator = canInviteCollaborator.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }
    }
}

- (BOOL)isFile
{
    return YES;
}

@end
