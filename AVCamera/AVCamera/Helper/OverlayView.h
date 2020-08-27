//
//  OverlayView.h
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

#import <UIKit/UIKit.h>
#import "SelectableRoundView.h"
#import "ZoomView.h"

@interface OverlayView : UIView<SelectabeRoundDelegate>{
    
    ZoomView* _zoomView;
    
    SelectableRoundView* _topLeftCornerView;
    SelectableRoundView* _topRightCornerView;
    SelectableRoundView* _bottomLeftCornerView;
    SelectableRoundView* _bottomRightCornerView;
    
}

@property(nonatomic) CGPoint topLeftPath;
@property(nonatomic) CGPoint topRightPath;
@property(nonatomic) CGPoint bottomLeftPath;
@property(nonatomic) CGPoint bottomRightPath;

@property(nonatomic) CGFloat absoluteWidth;
@property(nonatomic) CGFloat absoluteHeight;

-(void)initializeSubView;

-(UIImage *)cropImage:(UIImage *)image;


@end
