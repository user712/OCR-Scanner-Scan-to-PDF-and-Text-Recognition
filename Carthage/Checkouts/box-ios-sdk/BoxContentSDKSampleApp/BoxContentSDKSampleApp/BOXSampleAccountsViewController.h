//
//  ViewController.h
//  BoxContentSDKSampleApp
//
//  Created on 1/5/15.
//  Copyright (c) 2015 Box. 
//

#import <UIKit/UIKit.h>

@interface BOXSampleAccountsViewController : UITableViewController <BOXAPIAccessTokenDelegate>

- (instancetype)initWithAppUsers:(BOOL)appUsers;

@end

