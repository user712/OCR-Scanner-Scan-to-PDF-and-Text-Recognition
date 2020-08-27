//
//  BOXFolder.m
//  BoxContentSDK
//
//  Created on 12/3/14.
//  Copyright (c) 2014 Box. 
//

#import "BOXFolder.h"
#import "BOXFile.h"
#import "BOXBookmark.h"

@implementation BOXFolderMini

- (instancetype)initWithJSON:(NSDictionary *)JSONResponse
{
    BOXAssert([JSONResponse[BOXAPIObjectKeyType] isEqualToString:BOXAPIItemTypeFolder], @"Invalid type for object.");
    self = [super initWithJSON:JSONResponse];
    return self;
}

- (BOOL)isFolder
{
    return YES;
}

- (BOOL)isRoot
{
    return [self.modelID isEqualToString:BOXAPIFolderIDRoot];
}

@end

@implementation BOXFolder

- (instancetype)initWithJSON:(NSDictionary *)JSONResponse
{
    BOXAssert([JSONResponse[BOXAPIObjectKeyType] isEqualToString:BOXAPIItemTypeFolder], @"Invalid type for object.");
    
    self = [super initWithJSON:JSONResponse];

    if (self != nil) {

        // Parse FolderUploadEmail
        NSDictionary *folderUploadEmailDictionary = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyFolderUploadEmail
                                                                                   inDictionary:JSONResponse
                                                                                hasExpectedType:[NSDictionary class]
                                                                                    nullAllowed:YES];
        
        if ([folderUploadEmailDictionary isEqual:[NSNull null]] == NO) {
            self.folderUploadEmailAccess = folderUploadEmailDictionary[BOXAPIObjectKeyAccess];
            self.folderUploadEmailAddress = folderUploadEmailDictionary[BOXAPIObjectKeyEmail];
        }

        // Parse SyncState.
        self.syncState = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeySyncState
                                                        inDictionary:JSONResponse
                                                     hasExpectedType:[NSString class]
                                                         nullAllowed:NO];

        // Parse Permissions.
        NSDictionary *permissions = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyPermissions
                                                                   inDictionary:JSONResponse
                                                                hasExpectedType:[NSDictionary class]
                                                                    nullAllowed:NO];
        [self parsePermssionsFromJSON:permissions];
        
        // Parse CanNonOwnersInvite
        NSNumber *canNonOwnersInvite = [NSJSONSerialization box_ensureObjectForKey:BOXAPIObjectKeyCanNonOwnersInvite
                                                                      inDictionary:JSONResponse
                                                                   hasExpectedType:[NSNumber class]
                                                                       nullAllowed:NO];
        if (canNonOwnersInvite) {
            self.canNonOwnersInvite = canNonOwnersInvite.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }
    }

    return self;
}

- (void)parsePermssionsFromJSON:(NSDictionary *)permissions
{
    if ([permissions count] > 0) {
        NSNumber *canDownload = permissions[BOXAPIObjectKeyCanDownload];
        if (canDownload != nil) {
            self.canDownload = canDownload.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canUpload = permissions[BOXAPIObjectKeyCanUpload];
        if (canUpload != nil) {
            self.canUpload = canUpload.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canRename = permissions[BOXAPIObjectKeyCanRename];
        if (canRename != nil) {
            self.canRename = canRename.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canDelete = permissions[BOXAPIObjectKeyCanDelete];
        if (canDelete != nil) {
            self.canDelete = canDelete.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canShare = permissions[BOXAPIObjectKeyCanShare];
        if (canShare != nil) {
            self.canShare = canShare.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canInviteCollaborator = permissions[BOXAPIObjectKeyCanInviteCollaborator];
        if (canInviteCollaborator != nil) {
            self.canInviteCollaborator = canInviteCollaborator.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }

        NSNumber *canSetShareAccess = permissions[BOXAPIObjectKeyCanSetShareAccess];
        if (canSetShareAccess != nil) {
            self.canSetShareAccess = canSetShareAccess.boolValue ? BOXAPIBooleanYES : BOXAPIBooleanNO;
        }
    }
}

- (BOOL)isFolder
{
    return YES;
}

- (BOOL)isRoot
{
    return [self.modelID isEqualToString:BOXAPIFolderIDRoot];
}

@end
