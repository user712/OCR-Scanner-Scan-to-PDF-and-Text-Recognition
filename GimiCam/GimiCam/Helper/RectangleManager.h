//
//  RectangleManager.h
//  GimiCam
//
//  Created by Developer on 3/6/17.
//  Copyright © 2017 A. 
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RectangleManager : NSObject

-(void) initializeRects;
    
- (void)captureOutputdidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
    
@end
