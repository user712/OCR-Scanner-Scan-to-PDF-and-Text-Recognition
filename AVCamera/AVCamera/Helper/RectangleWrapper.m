//
//  RectangleWrapper.m
//  AVCamera
//
//  Created by Developer on 3/9/17.
//  Copyright © 2017 A. 
//

#import "RectangleWrapper.h"

@interface RectangleWrapper () {
    UIView *overlayView;
    UIView *topLeft;
    UIView *topRight;
    UIView *bottomLeft;
    UIView *bottomRight;
    NSMutableArray *vs;
    NSMutableArray *lastTopLeft;
    NSMutableArray *lastTopRight;
    NSMutableArray *lastBottomLeft;
    NSMutableArray *lastBottomRight;
    NSArray *last;
}
@end

@implementation RectangleWrapper


- (NSArray *)detectRectangles:(CIImage *)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
    CIDetector *rectDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:options];
    
    NSArray *rectangles = [rectDetector featuresInImage:image];
    return rectangles;
}

- (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    
    CIImage* overlay = [CIImage imageWithColor:[CIColor colorWithRed:74.0/255.0 green:144.0/255.0 blue:226.0/255.0 alpha:0.6]];
    overlay = [overlay imageByCroppingToRect:image.extent];
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],
                                                                                                       @"inputTopLeft":[CIVector vectorWithCGPoint:topLeft],
                                                                                                       @"inputTopRight":[CIVector vectorWithCGPoint:topRight],
                                                                                                       @"inputBottomLeft":[CIVector vectorWithCGPoint:bottomLeft],
                                                                                                       @"inputBottomRight":[CIVector vectorWithCGPoint:bottomRight]}];
    
    return [overlay imageByCompositingOverImage:image];
}

-(void) initAllFeatures
{
    vs = [NSMutableArray new];
    topLeft = [UIView new];
    topRight = [UIView new];
    bottomLeft = [UIView new];
    bottomRight = [UIView new];
    
    topLeft.backgroundColor = [UIColor redColor];
    topRight.backgroundColor = [UIColor blueColor];
    bottomLeft.backgroundColor = [UIColor greenColor];
    bottomRight.backgroundColor = [UIColor yellowColor];
    
    [vs addObject:topLeft];
    [vs addObject:topRight];
    [vs addObject:bottomLeft];
    [vs addObject:bottomRight];
    lastTopLeft = [NSMutableArray new];
    lastTopRight = [NSMutableArray new];
    lastBottomLeft = [NSMutableArray new];
    lastBottomRight = [NSMutableArray new];
    
    for (UIView *v in vs) {
        [overlayView addSubview:v];
        v.frame = CGRectMake(0, 0, 10, 10);
        //        v.backgroundColor = [UIColor redColor];
    }
}

- (Rectangle*) detectRectanglesInCIImage: (CIImage *) ciImage withOverlay:(OverlayView *) overlayView
{
    NSArray *rectangles = [self detectRectangles: ciImage];
    
    CGSize s = overlayView.frame.size;
    CGFloat sy = s.height/1920;
    CGFloat sx = s.width/1080;
    CGFloat bs = 0; CIRectangleFeature *bestr = nil;
    CGFloat rate = 0.4;
    
    for (CIRectangleFeature *rect in rectangles) {
        CGFloat ts = (rect.topRight.x - rect.topLeft.x) * (rect.topRight.y - rect.bottomRight.y);
        if (ts > bs) {
            bs = ts;
            bestr = rect;
        }
    }
    
    if (bs > 0) {
        [lastTopLeft addObject:[NSValue valueWithCGPoint:CGPointMake(bestr.topLeft.y * sy , bestr.topLeft.x * sx)]];
        [lastTopRight addObject:[NSValue valueWithCGPoint:CGPointMake(bestr.topRight.y * sy,  bestr.topRight.x * sx)]];
        [lastBottomRight addObject:[NSValue valueWithCGPoint:CGPointMake(bestr.bottomRight.y * sy, bestr.bottomRight.x * sx)]];
        [lastBottomLeft addObject:[NSValue valueWithCGPoint:CGPointMake(bestr.bottomLeft.y * sy, bestr.bottomLeft.x * sx)]];
        
        if ([lastTopLeft count] > 100) {
            [lastTopLeft removeObjectAtIndex:0];
            [lastTopRight removeObjectAtIndex:0];
            [lastBottomRight removeObjectAtIndex:0];
            [lastBottomLeft removeObjectAtIndex:0];
        }
        CGFloat tlx, tly, trx, try, blx, bly, brx, bry;
        tlx = tly = trx = try = blx = bly = brx = bry = 0;
        unsigned long c = [lastTopLeft count];
        
        for (int i=0; i<c; i++) {
            tlx += [lastTopLeft[i] CGPointValue].x / c;
            tly += [lastTopLeft[i] CGPointValue].y / c;
            
            trx += [lastTopRight[i] CGPointValue].x / c;
            try += [lastTopRight[i] CGPointValue].y / c;
            
            brx += [lastBottomRight[i] CGPointValue].x / c;
            bry += [lastBottomRight[i] CGPointValue].y / c;
            
            blx += [lastBottomLeft[i] CGPointValue].x / c;
            bly += [lastBottomLeft[i] CGPointValue].y / c;
        }
        
//        topLeft.center = CGPointMake(tlx, tly);
//        topRight.center = CGPointMake(trx, try);
//        bottomRight.center = CGPointMake(brx, bry);
//        bottomLeft.center = CGPointMake(blx, bly);
        
        [CATransaction flush];
        
        last = [NSArray arrayWithObjects:
                [NSValue valueWithCGPoint:CGPointMake(topLeft.center.x, topLeft.center.y)],
                [NSValue valueWithCGPoint:CGPointMake(topRight.center.x, topRight.center.y)],
                [NSValue valueWithCGPoint:CGPointMake(bottomRight.center.x, bottomRight.center.y)],
                [NSValue valueWithCGPoint:CGPointMake(bottomLeft.center.x, bottomLeft.center.y)],
                nil];
        
        Rectangle *newRectangle = [[Rectangle alloc] init];
        newRectangle.topleft = CGPointMake(tlx, tly);
        newRectangle.topRight = CGPointMake(trx, try);
        newRectangle.bottomRight = CGPointMake(brx, bry);
        newRectangle.bottomLeft = CGPointMake(blx, bly);
        
        return newRectangle;
    }
    
    return nil;
}

@end
