//
//  ZoomView.h
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

#import <UIKit/UIKit.h>

@interface ZoomView : UIView{
    
    CGPoint _currentCenter;
    CGPoint _cornerCenter;
}

-(void)setZoomScale:(CGFloat)scale;

-(void)setZoomCenter:(CGPoint)point;
-(void)zoomViewHide:(BOOL)hide;

-(void)setDragingEnabled:(BOOL)enabled;

@end

