//
//  RectangleWrapper.h
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "OverlayView.h"
#import "Rectangle.h"

@interface RectangleWrapper : NSObject

- (NSArray *)detectRectangles:(CIImage *)image;
- (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight;
- (void) initAllFeatures;
- (Rectangle*) detectRectanglesInCIImage: (CIImage *) ciImage withOverlay:(OverlayView *) overlayView;
@end
