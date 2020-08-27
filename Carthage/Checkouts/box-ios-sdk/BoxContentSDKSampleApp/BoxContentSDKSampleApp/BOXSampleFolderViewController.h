//
//  FolderListingViewController.h
//  BoxContentSDKSampleApp
//
//  Created on 1/6/15.
//  Copyright (c) 2015 Box. 
//

#import <UIKit/UIKit.h>

@interface BOXSampleFolderViewController : UITableViewController

- (instancetype)initWithClient:(BOXContentClient *)client folderID:(NSString *)folderID;

@end
