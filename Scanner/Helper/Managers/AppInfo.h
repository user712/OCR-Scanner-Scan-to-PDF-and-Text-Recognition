
#import <Foundation/Foundation.h>

typedef void (^AppInfoResultBlock)(BOOL success);

@interface AppInfo : NSObject

#pragma mark - Initializations
+ (AppInfo *) sharedManager;

#pragma mark - Info
- (void) updateInfoWithCompletion:(AppInfoResultBlock) completion;
- (NSString *) bundleID;
- (NSString *) appID;
- (NSString *) storeAppLink;
- (NSString *) redirectStoreAppLink;
- (NSString *) shortAppURL;
- (BOOL) isFirstLaunch;
- (BOOL) appHasBeenUpdated;

@end
