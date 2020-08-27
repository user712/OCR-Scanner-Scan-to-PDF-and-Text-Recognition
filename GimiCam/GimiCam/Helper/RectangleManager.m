//
//  RectangleManager.m
//  GimiCam
//
//  Created by Developer on 3/6/17.
//  Copyright © 2017 A. 
//

#import "RectangleManager.h"


@interface RectangleManager () {
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


@implementation RectangleManager

- (NSArray *)detectRectangles:(CIImage *)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil];
    CIDetector *rectDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:options];
    
    NSArray *rectangles = [rectDetector featuresInImage:image];
    return rectangles;
}
    
    
- (UIBezierPath *)createPathFromRect:(CIRectangleFeature *)rect
{
    UIBezierPath *path = [UIBezierPath new];
    // Start at the first corner
    [path moveToPoint:rect.topLeft];
    [path addLineToPoint:rect.topRight];
    [path addLineToPoint:rect.bottomRight];
    [path addLineToPoint:rect.bottomLeft];
    [path addLineToPoint:rect.topLeft];
    
    return path;
}
    
-(void) initializeRects {
    
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
}
    
    
    

- (void)captureOutputdidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    if (attachments) {
        CFRelease(attachments);
    }
    
    
    NSArray *rectangles = [self detectRectangles:ciImage];
    
    
    CGSize s = overlayView.frame.size;
    CGFloat sy = s.height/3840;
    CGFloat sx = s.width/2160;
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
        unsigned long int c = [lastTopLeft count];
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
        
        topLeft.center = CGPointMake(tlx, tly);
        topRight.center = CGPointMake(trx, try);
        bottomRight.center = CGPointMake(brx, bry);
        bottomLeft.center = CGPointMake(blx, bly);
        
        [CATransaction flush];
        
        last = [NSArray arrayWithObjects:
                [NSValue valueWithCGPoint:CGPointMake(topLeft.center.x, topLeft.center.y)],
                [NSValue valueWithCGPoint:CGPointMake(topRight.center.x, topRight.center.y)],
                [NSValue valueWithCGPoint:CGPointMake(bottomRight.center.x, bottomRight.center.y)],
                [NSValue valueWithCGPoint:CGPointMake(bottomLeft.center.x, bottomLeft.center.y)],
                nil];
        
        
    }

}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
@end
