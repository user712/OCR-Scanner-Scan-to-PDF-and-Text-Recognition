//
//  Rectangle.h
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Rectangle : NSObject

@property (nonatomic, assign) CGPoint topleft;
@property (nonatomic, assign) CGPoint topRight;
@property (nonatomic, assign) CGPoint bottomRight;
@property (nonatomic, assign) CGPoint bottomLeft;

@end
