//
//  BoxContentSDKConstants.m
//  BoxContentSDK
//
//  Created on 2/22/13.
//  Copyright (c) 2013 Box. 
//

#import "BOXContentSDKConstants.h"

// API Resources
NSString *const BOXAPIResourceFolders = @"folders";
NSString *const BOXAPIResourceFiles = @"files";
NSString *const BOXAPIResourceBookmarks = @"web_links";
NSString *const BOXAPIResourceSharedItems = @"shared_items";
NSString *const BOXAPIResourceUsers = @"users";
NSString *const BOXAPIResourceComments = @"comments";
NSString *const BOXAPIResourceCollections = @"collections";
NSString *const BOXAPIResourceEvents = @"events";
NSString *const BOXAPIResourceCollaborations = @"collaborations";
NSString *const BOXAPIResourceSearch = @"search";
NSString *const BOXAPIResourceMetadataTemplates = @"metadata_templates";
NSString *const BOXAPIResourceRecentItems = @"recent_items";

// API Metadata Template Scope
BOXMetadataScope const BOXAPITemplateScopeGlobal = @"global";
BOXMetadataScope const BOXAPITemplateScopeEnterprise = @"enterprise";

// API Subresources
NSString *const BOXAPISubresourceItems = @"items";
NSString *const BOXAPISubresourceCopy = @"copy";
NSString *const BOXAPISubresourceTrash = @"trash";
NSString *const BOXAPISubresourceContent = @"content";
NSString *const BOXAPISubresourceComments = @"comments";
NSString *const BOXAPISubresourceVersions = @"versions";
NSString *const BOXAPISubresourceThumnailPNG = @"thumbnail.png";
NSString *const BOXAPISubresourceCurrent = @"current";
NSString *const BOXAPISubresourceMetadata = @"metadata";
NSString *const BOXAPISubresourceAvatar = @"avatar";

// HTTP Method Names
BOXAPIHTTPMethod *const BOXAPIHTTPMethodHEAD = @"HEAD";
BOXAPIHTTPMethod *const BOXAPIHTTPMethodDELETE = @"DELETE";
BOXAPIHTTPMethod *const BOXAPIHTTPMethodGET = @"GET";
BOXAPIHTTPMethod *const BOXAPIHTTPMethodOPTIONS = @"OPTIONS";
BOXAPIHTTPMethod *const BOXAPIHTTPMethodPOST = @"POST";
BOXAPIHTTPMethod *const BOXAPIHTTPMethodPUT = @"PUT";

// HTTP Header Names
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderAuthorization = @"Authorization";
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderContentType = @"Content-Type";
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderContentLength = @"Content-Length";
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderContentMD5 = @"Content-MD5";
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderIfMatch = @"If-Match";
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderIfNoneMatch = @"If-None-Match";
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderBoxAPI = @"BoxApi";
BOXAPIHTTPHeader *const BOXAPIHTTPHeaderXRepHints = @"X-Rep-Hints";

// OAuth2 constants
// Authorization code response
NSString *const BOXAuthURLParameterAuthorizationStateKey = @"state";
NSString *const BOXAuthURLParameterAuthorizationCodeKey = @"code";
NSString *const BOXAuthURLParameterErrorCodeKey = @"error";
// token response
NSString *const BOXAuthTokenJSONAccessTokenKey = @"access_token";
NSString *const BOXAuthTokenJSONRefreshTokenKey = @"refresh_token";
NSString *const BOXAuthTokenJSONExpiresInKey = @"expires_in";
// token request
NSString *const BOXAuthTokenRequestGrantTypeKey = @"grant_type";
NSString *const BOXAuthTokenRequestAuthorizationCodeKey = @"code";
NSString *const BOXAuthTokenRequestRefreshTokenKey = @"refresh_token";
NSString *const BOXAuthTokenRequestClientIDKey = @"client_id";
NSString *const BOXAuthTokenRequestClientSecretKey = @"client_secret";
NSString *const BOXAuthTokenRequestRedirectURIKey = @"redirect_uri";
NSString *const BOXAuthTokenRequestDeviceIDKey = @"box_device_id";
NSString *const BOXAuthTokenRequestDeviceNameKey = @"box_device_name";
NSString *const BOXAuthTokenRequestAccessTokenExpiresAtKey = @"box_access_token_expires_at";
NSString *const BOXAuthTokenRequestRefreshTokenExpiresAtKey = @"box_refresh_token_expires_at";

NSString *const BOXAuthTokenRequestGrantTypeAuthorizationCode = @"authorization_code";
NSString *const BOXAuthTokenRequestGrantTypeRefreshToken = @"refresh_token";

// Auth Delegation
NSString *const BOXOAuth2AuthDelegationNewClientKey = @"BOXOAuth2AuthDelegationNewClient";

// Notifications
NSString *const BOXUserWasLoggedOutDueToErrorNotification = @"BOXUserWasLoggedOutDueToErrorNotification";
NSString *const BOXAuthOperationDidCompleteNotification = @"BOXOAuth2OperationDidComplete";
NSString *const BOXAccessTokenRefreshDiagnosisNotification = @"BOXAccessTokenRefreshDiagnosisNotification";
NSString *const BOXFileDownloadCorruptedNotification = @"BOXFileDownloadCorruptedNotification";
NSString *const BOXRefreshTokenSaveToKeychainNotification = @"BOXRefreshTokenSaveToKeychainNotification";

// Item Types
BOXAPIItemType *const BOXAPIItemTypeFile = @"file";
BOXAPIItemType *const BOXAPIItemTypeFolder = @"folder";
BOXAPIItemType *const BOXAPIItemTypeWebLink = @"web_link";
BOXAPIItemType *const BOXAPIItemTypeUser = @"user";
BOXAPIItemType *const BOXAPIItemTypeComment = @"comment";
BOXAPIItemType *const BOXAPIItemTypeCollection = @"collection";
BOXAPIItemType *const BOXAPIItemTypeEvent = @"event";
BOXAPIItemType *const BOXAPIItemTypeCollaboration = @"collaboration";
BOXAPIItemType *const BOXAPIItemTypeGroup = @"group";
BOXAPIItemType *const BOXAPIItemTypeFileVersion = @"file_version";
BOXAPIItemType *const BOXAPIItemTypeRecentItem = @"recent_item";

// Shared Link Access Levels
BOXSharedLinkAccessLevel *const BOXSharedLinkAccessLevelOpen = @"open";
BOXSharedLinkAccessLevel *const BOXSharedLinkAccessLevelCompany = @"company";
BOXSharedLinkAccessLevel *const BOXSharedLinkAccessLevelCollaborators = @"collaborators";

// Collaboration collaborator types
BOXCollaborationCollaboratorType *const BOXCollaborationCollaboratorTypeUser = @"user";
BOXCollaborationCollaboratorType *const BOXCollaborationCollaboratorTypeGroup = @"group";

// Metadata Types
NSString *const BOXMetadataTypeProperties = @"properties";

BOXMetadataUpdateOperationType *const BOXMetadataUpdateOperationTypeAdd = @"add";
BOXMetadataUpdateOperationType *const BOXMetadataUpdateOperationTypeReplace = @"replace";
BOXMetadataUpdateOperationType *const BOXMetadataUpdateOperationTypeRemove = @"remove";
BOXMetadataUpdateOperationType *const BOXMetadataUpdateOperationTypeTest = @"test";

NSString *const BOXAPIMetadataParameterKeyOp = @"op";
NSString *const BOXAPIMetadataParameterKeyPath = @"path";
NSString *const BOXAPIMetadataParameterKeyValue = @"value";

// Collaboration Status
BOXCollaborationStatus *const BOXCollaborationStatusAccepted = @"accepted";
BOXCollaborationStatus *const BOXCollaborationStatusRejected = @"rejected";
BOXCollaborationStatus *const BOXCollaborationStatusPending = @"pending";

// Collaboration Role
BOXCollaborationRole *const BOXCollaborationRoleOwner = @"owner";
BOXCollaborationRole *const BOXCollaborationRoleCoOwner = @"co-owner";
BOXCollaborationRole *const BOXCollaborationRoleEditor = @"editor";
BOXCollaborationRole *const BOXCollaborationRoleViewerUploader = @"viewer uploader";
BOXCollaborationRole *const BOXCollaborationRolePreviewerUploader = @"previewer uploader";
BOXCollaborationRole *const BOXCollaborationRoleViewer = @"viewer";
BOXCollaborationRole *const BOXCollaborationRolePreviewer = @"previewer";
BOXCollaborationRole *const BOXCollaborationRoleUploader = @"uploader";

// File Representation documentation: https://developer.box.com/v2.0/reference#representations

// Representation Type
BOXRepresentationType *const BOXRepresentationTypeOriginal = @"original";
BOXRepresentationType *const BOXRepresentationTypePDF = @"pdf";
BOXRepresentationType *const BOXRepresentationTypeMP4 = @"mp4";
BOXRepresentationType *const BOXRepresentationTypeMP3 = @"mp3";
BOXRepresentationType *const BOXRepresentationTypePNG = @"png";
BOXRepresentationType *const BOXRepresentationTypeJPG = @"jpg";
BOXRepresentationType *const BOXRepresentationType3D = @"3d";
BOXRepresentationType *const BOXRepresentationTypeFilmstrip = @"filmstrip";
BOXRepresentationType *const BOXRepresentationTypeDASH = @"dash";
BOXRepresentationType *const BOXRepresentationTypeHLS = @"hls";
BOXRepresentationType *const BOXRepresentationTypeCrocodoc = @"crocodoc";
BOXRepresentationType *const BOXRepresentationTypeDICOM = @"box_dicom";
BOXRepresentationType *const BOXRepresentationTypeExtractedText = @"extracted_text";

// Representations URL Template
NSString *const BOXRepresentationTemplateKeyAccessPath = @"{+asset_path}";

// Representation Template Value
NSString *const BOXRepresentationTemplateValueHLSManifest = @"master.m3u8";

// Representation Status
BOXRepresentationStatus *const BOXRepresentationStatusSuccess = @"success";
BOXRepresentationStatus *const BOXRepresentationStatusViewable = @"viewable";
BOXRepresentationStatus *const BOXRepresentationStatusPending = @"pending";
BOXRepresentationStatus *const BOXRepresentationStatusNone = @"none";
BOXRepresentationStatus *const BOXRepresentationStatusError = @"error";

// Representation Supported Image Formats
BOXRepresentationImageDimensions *const BOXRepresentationImageDimensionsJPG32 = @"32x32";
BOXRepresentationImageDimensions *const BOXRepresentationImageDimensionsJPG94 = @"94x94";
BOXRepresentationImageDimensions *const BOXRepresentationImageDimensionsJPG160 = @"160x160";
BOXRepresentationImageDimensions *const BOXRepresentationImageDimensionsJPG320 = @"320x320";
BOXRepresentationImageDimensions *const BOXRepresentationImageDimensions1024 = @"1024x1024";
BOXRepresentationImageDimensions *const BOXRepresentationImageDimensions2048 = @"2048x2048";

// Folder Upload Email Access Levels
BOXFolderUploadEmailAccessLevel *const BOXFolderUploadEmailAccessLevelOpen = @"open";
BOXFolderUploadEmailAccessLevel *const BOXFolderUploadEmailAccessLevelCollaborators = @"collaborators";

// Item Status
BOXItemStatus *const BOXItemStatusActive = @"active";
BOXItemStatus *const BOXItemStatusTrashed = @"trashed";
BOXItemStatus *const BOXItemStatusDeleted =@"deleted";

// Collection keys
NSString *const BOXAPICollectionKeyEntries = @"entries";
NSString *const BOXAPICollectionKeyTotalCount = @"total_count";
NSString *const BOXAPICollectionKeyNextStreamPosition = @"next_stream_position";

// Parameter keys
NSString *const BOXAPIParameterKeyFields = @"fields";
NSString *const BOXAPIParameterKeyRecursive = @"recursive";
NSString *const BOXAPIParameterKeyLimit = @"limit";
NSString *const BOXAPIParameterKeyOffset = @"offset";
NSString *const BOXAPIParameterKeyFileVersion = @"version";
NSString *const BOXAPIParameterKeyStreamPosition = @"stream_position";
NSString *const BOXAPIParameterKeyStreamType = @"stream_type";
NSString *const BOXAPIParameterKeyCreatedAfter = @"created_after";
NSString *const BOXAPIParameterKeyCreatedBefore = @"created_before";
NSString *const BOXAPIParameterKeyEventType = @"event_type";
NSString *const BOXAPIParameterKeyNotify = @"notify";
NSString *const BOXAPIParameterKeyFileExtensions = @"file_extensions";
NSString *const BOXAPIParameterKeyCreatedAtRange = @"created_at_range";
NSString *const BOXAPIParameterKeyUpdatedAtRange = @"updated_at_range";
NSString *const BOXAPIParameterKeySizeRange = @"size_range";
NSString *const BOXAPIParameterKeyOwnerUserIDs = @"owner_user_ids";
NSString *const BOXAPIParameterKeyAncestorFolderIDs = @"ancestor_folder_ids";
NSString *const BOXAPIParameterKeyContentTypes = @"content_types";
NSString *const BOXAPIParameterKeyType = @"type";
NSString *const BOXAPIParameterKeyQuery = @"query";
NSString *const BOXAPIParameterKeyMDFilter = @"mdfilters";
NSString *const BOXAPIParameterKeyMinWidth = @"min_width";
NSString *const BOXAPIParameterKeyMinHeight = @"min_height";
NSString *const BOXAPIParameterKeyMaxWidth = @"max_width";
NSString *const BOXAPIParameterKeyMaxHeight = @"max_height";
NSString *const BOXAPIParameterKeyAvatarType = @"pic_type";

// Recent Items Parameter Keys
NSString *const BOXAPIParameterKeyMarker = @"marker";
NSString *const BOXAPIParameterKeyNextMarker = @"next_marker";
NSString *const BOXAPIParameterKeyListType = @"list_type";

// Metadata Parameter Keys
NSString *const BOXAPIParameterKeyTemplate = @"templateKey";
NSString *const BOXAPIParameterKeyScope = @"scope";
NSString *const BOXAPIParameterKeyFilter = @"filters";

// Multipart parameter keys
NSString *const BOXAPIMultipartParameterFieldKeyFile = @"file";
NSString *const BOXAPIMultipartParameterFieldKeyParentID = @"parent_id";
NSString *const BOXAPIMultipartFormBoundary = @"0xBoXSdKMulTiPaRtFoRmBoUnDaRy";

// API object keys
NSString *const BOXAPIObjectKeyAccess = @"access";
NSString *const BOXAPIObjectKeyEffectiveAccess = @"effective_access";
NSString *const BOXAPIObjectKeyUnsharedAt = @"unshared_at";
NSString *const BOXAPIObjectKeyEmail = @"email";
NSString *const BOXAPIObjectKeyDownloadCount = @"download_count";
NSString *const BOXAPIObjectKeyPreviewCount = @"preview_count";
NSString *const BOXAPIObjectKeyPermissions = @"permissions";
NSString *const BOXAPIObjectKeyCanDownload = @"can_download";
NSString *const BOXAPIObjectKeyCanPreview = @"can_preview";
NSString *const BOXAPIObjectKeyCanUpload = @"can_upload";
NSString *const BOXAPIObjectKeyCanComment = @"can_comment";
NSString *const BOXAPIObjectKeyCanRename = @"can_rename";
NSString *const BOXAPIObjectKeyCanDelete = @"can_delete";
NSString *const BOXAPIObjectKeyCanShare = @"can_share";
NSString *const BOXAPIObjectKeyCanSetShareAccess = @"can_set_share_access";
NSString *const BOXAPIObjectKeyCanInviteCollaborator = @"can_invite_collaborator";

NSString *const BOXAPIObjectKeyID = @"id";
NSString *const BOXAPIObjectKeyRank = @"rank";
NSString *const BOXAPIObjectKeyKey = @"key";
NSString *const BOXAPIObjectKeyDisplayName = @"displayName";
NSString *const BOXAPIObjectKeyOptions = @"options";
NSString *const BOXAPIObjectKeyType = @"type";
NSString *const BOXAPIObjectKeySequenceID = @"sequence_id";
NSString *const BOXAPIObjectKeyETag = @"etag";
NSString *const BOXAPIObjectKeySHA1 = @"sha1";
NSString *const BOXAPIObjectKeyName = @"name";
NSString *const BOXAPIObjectKeyCreatedAt = @"created_at";
NSString *const BOXAPIObjectKeyModifiedAt = @"modified_at";
NSString *const BOXAPIObjectKeyExpiresAt = @"expires_at";
NSString *const BOXAPIObjectKeyInteractedAt = @"interacted_at";
NSString *const BOXAPIObjectKeyContentCreatedAt = @"content_created_at";
NSString *const BOXAPIObjectKeyContentModifiedAt = @"content_modified_at";
NSString *const BOXAPIObjectKeyTrashedAt = @"trashed_at";
NSString *const BOXAPIObjectKeyPurgedAt = @"purged_at";
NSString *const BOXAPIObjectKeyDescription = @"description";
NSString *const BOXAPIObjectKeySize = @"size";
NSString *const BOXAPIObjectKeyCommentCount = @"comment_count";
NSString *const BOXAPIObjectKeyPathCollection = @"path_collection";
NSString *const BOXAPIObjectKeyCreatedBy = @"created_by";
NSString *const BOXAPIObjectKeyModifiedBy = @"modified_by";
NSString *const BOXAPIObjectKeyOwnedBy = @"owned_by";
NSString *const BOXAPIObjectKeySharedLink = @"shared_link";
NSString *const BOXAPIObjectKeyFolderUploadEmail = @"folder_upload_email";
NSString *const BOXAPIObjectKeyParent = @"parent";
NSString *const BOXAPIObjectKeyItem = @"item";
NSString *const BOXAPIObjectKeyItemStatus = @"item_status";
NSString *const BOXAPIObjectKeyItemCollection = @"item_collection";
NSString *const BOXAPIObjectKeySyncState = @"sync_state";
NSString *const BOXAPIObjectKeyURL = @"url";
NSString *const BOXAPIObjectKeyURLTemplate = @"url_template";
NSString *const BOXAPIObjectKeyDownloadURL = @"download_url";
NSString *const BOXAPIObjectKeyAuthenticatedDownloadURL = @"authenticated_download_url";
NSString *const BOXAPIObjectKeyVanityURL = @"vanity_url";
NSString *const BOXAPIObjectKeyIsPasswordEnabled = @"is_password_enabled";
NSString *const BOXAPIObjectKeyLogin = @"login";
NSString *const BOXAPIObjectKeyRole = @"role";
NSString *const BOXAPIObjectKeyLanguage = @"language";
NSString *const BOXAPIObjectKeySpaceAmount = @"space_amount";
NSString *const BOXAPIObjectKeySpaceUsed = @"space_used";
NSString *const BOXAPIObjectKeyMaxUploadSize = @"max_upload_size";
NSString *const BOXAPIObjectKeyTrackingCodes = @"tracking_codes";
NSString *const BOXAPIObjectKeyCanSeeManagedUsers = @"can_see_managed_users";
NSString *const BOXAPIObjectKeyIsSyncEnabled = @"is_sync_enabled";
NSString *const BOXAPIObjectKeyStatus = @"status";
NSString *const BOXAPIObjectKeyState = @"state";
NSString *const BOXAPIObjectKeyCode = @"code";
NSString *const BOXAPIObjectKeyJobTitle = @"job_title";
NSString *const BOXAPIObjectKeyPhone = @"phone";
NSString *const BOXAPIObjectKeyAddress = @"address";
NSString *const BOXAPIObjectKeyAvatarURL = @"avatar_url";
NSString *const BOXAPIObjectKeyIsExemptFromDeviceLimits = @"is_exempt_from_device_limits";
NSString *const BOXAPIObjectKeyIsExemptFromLoginVerification = @"is_exempt_from_login_verification";
NSString *const BOXAPIObjectKeyIsDeactivated = @"is_deactivated";
NSString *const BOXAPIObjectKeyHasCustomAvatar = @"has_custom_avatar";
NSString *const BOXAPIObjectKeyIsPasswordResetRequired = @"is_password_reset_required";
NSString *const BOXAPIObjectKeyMessage = @"message";
NSString *const BOXAPIObjectKeyTaggedMessage = @"tagged_message";
NSString *const BOXAPIObjectKeyIsReplyComment = @"is_reply_comment";
NSString *const BOXAPIObjectKeyLock = @"lock";
NSString *const BOXAPIObjectKeyExtension = @"extension";
NSString *const BOXAPIObjectKeyIsPackage = @"is_package";
NSString *const BOXAPIObjectKeyAllowedSharedLinkAccessLevels = @"allowed_shared_link_access_levels";
NSString *const BOXAPIObjectKeyCollections = @"collections";
NSString *const BOXAPIObjectKeyCollection = @"collection";
NSString *const BOXAPIObjectKeyCollectionMemberships = @"collection_memberships";
NSString *const BOXAPIObjectKeyHasCollaborations = @"has_collaborations";
NSString *const BOXAPIObjectKeyIsExternallyOwned = @"is_externally_owned";
NSString *const BOXAPIObjectKeyCanNonOwnersInvite = @"can_non_owners_invite";
NSString *const BOXAPIObjectKeyAllowedInviteeRoles = @"allowed_invitee_roles";
NSString *const BOXAPIObjectKeyVersionNumber = @"version_number";
NSString *const BOXAPIObjectKeyTimezone = @"timezone";
NSString *const BOXAPIObjectKeyIsExternalCollabRestricted = @"is_external_collab_restricted";
NSString *const BOXAPIObjectKeyEnterprise = @"enterprise";
NSString *const BOXAPIObjectKeyIsDownloadPrevented = @"is_download_prevented";
NSString *const BOXAPIObjectKeySharedLinkPassword = @"shared_link_password";
NSString *const BOXAPIObjectKeyCollectionType = @"collection_type";
NSString *const BOXAPIObjectKeyCollectionRank = @"rank";
NSString *const BOXAPIObjectKeyEventID = @"event_id";
NSString *const BOXAPIObjectKeyEventType = @"event_type";
NSString *const BOXAPIObjectKeyInteractionSharedLink = @"interaction_shared_link";
NSString *const BOXAPIObjectKeyInteractionType = @"interaction_type";
NSString *const BOXAPIObjectKeySessionID = @"session_id";
NSString *const BOXAPIObjectKeySource = @"source";
NSString *const BOXAPIObjectKeyAcknowledgedAt = @"acknowledged_at";
NSString *const BOXAPIObjectKeyAccessibleBy = @"accessible_by";
NSString *const BOXAPIObjectKeyEntries = @"entries";
NSString *const BOXAPIObjectKeyIsBoxNotesCreationEnabled = @"is_boxnotes_creation_enabled";
NSString *const BOXAPIObjectKeyRepresentations = @"representations";
NSString *const BOXAPIObjectKeyRepresentation = @"representation";
NSString *const BOXAPIObjectKeyProperties = @"properties";
NSString *const BOXAPIObjectKeyDetails = @"details";
NSString *const BOXAPIObjectKeyLinks = @"links";
NSString *const BOXAPIObjectKeyContent = @"content";
NSString *const BOXAPIObjectKeyInfo = @"info";
NSString *const BOXAPIObjectKeyDimensions = @"dimensions";

// API metadata object keys
NSString *const BOXAPIMetadataObjectKeyID = @"$id";
NSString *const BOXAPIMetadataObjectKeyType = @"$type";
NSString *const BOXAPIMetadataObjectKeyScope = @"$scope";
NSString *const BOXAPIMetadataObjectKeyTemplate = @"$template";
NSString *const BOXAPIMetadataObjectKeyParent = @"$parent";
NSString *const BOXAPIMetadataObjectKeyOperation = @"op";
NSString *const BOXAPIMetadataObjectKeyPath = @"path";
NSString *const BOXAPIMetadataObjectKeyValue = @"value";
NSString *const BOXAPIMetadataObjectKeyVersion = @"$version";
NSString *const BOXAPIMetadataObjectKeyTypeVersion = @"$typeVersion";

// API Folder IDs
NSString *const BOXAPIFolderIDRoot = @"0";
NSString *const BOXAPIFolderIDTrash = @"trash";

// API Collection constants
NSString *const BOXAPIFavoritesCollectionType = @"favorites";

// API Events Constants
NSString *const BOXAPIEventStreamPositionDefault = @"0";

NSString *const BOXAPIEventStreamTypeAll = @"all";
NSString *const BOXAPIEventStreamTypeChanges = @"changes";
NSString *const BOXAPIEventStreamTypeSync = @"sync";
NSString *const BOXAPIEventStreamTypeAdminLogs = @"admin_logs";

// API Recent Items Constants
NSString *const BOXAPIRecentItemsListTypeShared = @"shared";
NSString *const BOXAPIRecentItemsInteractionTypeOpen = @"item_open";
NSString *const BOXAPIRecentItemsInteractionTypePreview = @"item_preview";
NSString *const BOXAPIRecentItemsInteractionTypeComment = @"item_comment";
NSString *const BOXAPIRecentItemsInteractionTypeModification = @"item_modify";
NSString *const BOXAPIRecentItemsInteractionTypeUpload = @"item_upload";

// Standard Events
NSString *const BOXAPIEventTypeItemCreate = @"ITEM_CREATE";
NSString *const BOXAPIEventTypeItemUpload = @"ITEM_UPLOAD";
NSString *const BOXAPIEventTypeCommentCreate = @"COMMENT_CREATE";
NSString *const BOXAPIEventTypeItemDownload = @"ITEM_DOWNLOAD";
NSString *const BOXAPIEventTypeItemPreview = @"ITEM_PREVIEW";
NSString *const BOXAPIEventTypeItemMove = @"ITEM_MOVE";
NSString *const BOXAPIEventTypeItemCopy = @"ITEM_COPY";
NSString *const BOXAPIEventTypeTaskAssignment = @"TASK_ASSIGNMENT_CREATE";
NSString *const BOXAPIEventTypeLockCreate = @"LOCK_CREATE";
NSString *const BOXAPIEventTypeLockDestroy = @"LOCK_DESTROY";
NSString *const BOXAPIEventTypeItemTrash = @"ITEM_TRASH";
NSString *const BOXAPIEventTypeItemUndeleteViaTrash = @"ITEM_UNDELETE_VIA_TRASH";
NSString *const BOXAPIEventTypeCollaboratorAdded = @"COLLAB_ADD_COLLABORATOR";
NSString *const BOXAPIEventTypeCollaborationInvited = @"COLLAB_INVITE_COLLABORATOR";
NSString *const BOXAPIEventTypeItemSync = @"ITEM_SYNC";
NSString *const BOXAPIEventTypeItemUnsync = @"ITEM_UNSYNC";
NSString *const BOXAPIEventTypeItemRename = @"ITEM_RENAME";
NSString *const BOXAPIEventTypeItemSharedCreate = @"ITEM_SHARED_CREATE";
NSString *const BOXAPIEventTypeItemSharedUnshare = @"ITEM_SHARED_UNSHARE";
NSString *const BOXAPIEventTypeItemShared = @"ITEM_SHARED";
NSString *const BOXAPIEventTypeTagItemCreate = @"TAG_ITEM_CREATE";
NSString *const BOXAPIEventTypeAddLoginActivityDevice = @"ADD_LOGIN_ACTIVITY_DEVICE";
NSString *const BOXAPIEventTypeRemoveLoginActivityDevice = @"REMOVE_LOGIN_ACTIVITY_DEVICE";
NSString *const BOXAPIEventTypeChangeAdminRole = @"CHANGE_ADMIN_ROLE";

// Enterprise Events
NSString *const BOXAPIEnterpriseEventTypeGroupAddUser = @"GROUP_ADD_USER";
NSString *const BOXAPIEnterpriseEventTypeNewUser = @"NEW_USER";
NSString *const BOXAPIEnterpriseEventTypeGroupCreation = @"GROUP_CREATION";
NSString *const BOXAPIEnterpriseEventTypeGroupDeletion = @"GROUP_DELETION";
NSString *const BOXAPIEnterpriseEventTypeDeleteUser = @"DELETE_USER";
NSString *const BOXAPIEnterpriseEventTypeGroupEdited = @"GROUPE_EDITED";
NSString *const BOXAPIEnterpriseEventTypeEditUser = @"EDIT_USER";
NSString *const BOXAPIEnterpriseEventTypeGroupAddFolder = @"GROUP_ADD_FOLDER";
NSString *const BOXAPIEnterpriseEventTypeGroupeRemoveFolder = @"GROUP_REMOVE_FOLDER";
NSString *const BOXAPIEnterpriseEventTypeItemGroupeRemoveUser = @"GROUP_REMOVE_USER";
NSString *const BOXAPIEnterpriseEventTypeAdminLogin = @"ADMIN_LOGIN";
NSString *const BOXAPIEnterpriseEventTypeAddDeviceAssociation = @"ADD_DEVICE_ASSOCIATION";
NSString *const BOXAPIEnterpriseEventTypeFailedLogin = @"FAILED_LOGIN";
NSString *const BOXAPIEnterpriseEventTypeLogin = @"LOGIN";
NSString *const BOXAPIEnterpriseEventTypeUserAuthTokenRefresh = @"USER_AUTHENTICATE_OAUTH2_TOKEN_REFRESH";
NSString *const BOXAPIEnterpriseEventTypeRemoveDeviceAssociation = @"REMOVE_DEVICE_ASSOCIATION";
NSString *const BOXAPIEnterpriseEventTypeTosAgree = @"TERMS_OF_SERVICE_AGREE";
NSString *const BOXAPIEnterpriseEventTypeTosReject = @"TERMS_OF_SERVICE_REJECT";
NSString *const BOXAPIEnterpriseEventTypeCopy = @"COPY";
NSString *const BOXAPIEnterpriseEventTypeDelete = @"DELETE";
NSString *const BOXAPIEnterpriseEventTypeDownload = @"DOWNLOAD";
NSString *const BOXAPIEnterpriseEventTypeLock = @"LOCK";
NSString *const BOXAPIEnterpriseEventTypeMove = @"MOVE";
NSString *const BOXAPIEnterpriseEventTypePreview = @"PREVIEW";
NSString *const BOXAPIEnterpriseEventTypeRename = @"RENAME";
NSString *const BOXAPIEnterpriseEventTypeStorageExpiration = @"STORAGE_EXPIRATION";
NSString *const BOXAPIEnterpriseEventTypeUndelete = @"UNDELETE";
NSString *const BOXAPIEnterpriseEventTypeUnlock = @"UNLOCK";
NSString *const BOXAPIEnterpriseEventTypeUpload = @"UPLOAD";
NSString *const BOXAPIEnterpriseEventTypeShare = @"SHARE";
NSString *const BOXAPIEnterpriseEventTypeUpdateShareExpiration = @"UPDATE_SHARE_EXPIRATION";
NSString *const BOXAPIEnterpriseEventTypeShareExpiration = @"SHARE_EXPIRATION";
NSString *const BOXAPIEnterpriseEventTypeUnshare = @"UNSHARE";
NSString *const BOXAPIEnterpriseEventTypeItemAcceptCollaboration = @"ITEM_ACCEPT_COLLABORATION";
NSString *const BOXAPIEnterpriseEventTypeCollaborationRoleChange = @"COLLABORATION_ROLE_CHANGE";
NSString *const BOXAPIEnterpriseEventTypeUpdateCollaborationExpiration = @"UPDATE_COLLABORATION_EXPIRATION";
NSString *const BOXAPIEnterpriseEventTypeCollaborationRemove = @"COLLABORATION_REMOVE";
NSString *const BOXAPIEnterpriseEventTypeCollaborationInvite = @"COLLABORATION_INVITE";
NSString *const BOXAPIEnterpriseEventTypeCollaborationExpiration = @"COLLABORATION_EXPIRATION";
NSString *const BOXAPIEnterpriseEventTypeItemSync = @"ITEM_SYNC";
NSString *const BOXAPIEnterpriseEventTypeItemUnsync = @"ITEM_UNSYNC";


//urlsessiontask cache dir, file prefix
NSString *const BOXURLSessionTaskCacheDirectoryName = @"BOXURLSessionCache";
NSString *const BOXURLSessionTaskCacheOnGoingSessionTasksDirectoryName = @"onGoingSessionTasks";
NSString *const BOXURLSessionTaskCacheUsersDirectoryName = @"users";
NSString *const BOXURLSessionTaskCacheExtensionSessionsDirectoryName = @"extensionSessions";
NSString *const BOXURLSessionTaskCacheDestinationFilePath = @"destinationFilePath";
NSString *const BOXURLSessionTaskCacheResumeData = @"resumeData";
NSString *const BOXURLSessionTaskCacheResponse = @"response";
NSString *const BOXURLSessionTaskCacheResponseData = @"responseData";
NSString *const BOXURLSessionTaskCacheError = @"error";
NSString *const BOXURLSessionTaskCacheUserIdAndAssociateId = @"userIdAndAssociateId";

const BOXRepresentationHints BOXRepresentationHintsDefaultThumbnails = @"[jpg?dimensions=320x320&paged=false][jpg?dimensions=1024x1024&paged=false]";
// We separate HLS here because HLS is only suitable for streaming, and there will be cases
// we want to fall back on MP4
const BOXRepresentationHints BOXRepresentationHintsDefaultPreview = @"[hls][pdf,mp4,mp3,jpg?dimensions=1024x1024&paged=false]";
const BOXRepresentationHints BOXRepresentationHintsDefaultThumbnailsandPreview = @"[jpg?dimensions=320x320&paged=false][jpg?dimensions=1024x1024&paged=false][hls][pdf,mp4,mp3]";
