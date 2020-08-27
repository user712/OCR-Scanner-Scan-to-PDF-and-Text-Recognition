//
//  PDFCreatorManager.m
//  Scanner
//
//   on 2/22/17.
//   
//

#import "PDFCreatorManager.h"

@implementation PDFCreatorManager

- (void) createPDFWithName:(NSString *)documentName withText:(NSArray *)stringsArray withWritePath:(NSString *) documentPath {
    int pageNr = 1;
    
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(documentPath, CGRectZero, nil);
    
    for (int i = 0; i < stringsArray.count; i++)
    {
        NSAttributedString *theString = stringsArray[i];
        // Prepare the text using a Core Text Framesetter.
        CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (__bridge CFStringRef)theString.string, NULL);
        
        if (currentText) {
            
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(theString));
            if (framesetter) {
                
                CFRange currentRange = CFRangeMake(0, 0);
                NSInteger currentPage = 0;
                BOOL done = NO;
                
                do {
                    // Mark the beginning of a new page.
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                    
                    // Draw a page number at the bottom of each page.
                    //                    currentPage++;
                    [self drawPageNbr:pageNr];
                    pageNr ++;
                    //                    [self drawPageNbr:i font: [theString attri]];
                    // Render the current page and update the current range to
                    // point to the beginning of the next page.
                    currentRange = *[self updatePDFPage:(int)currentPage setTextRange:&currentRange setFramesetter:&framesetter];
                    
                    // If we're at the end of the text, exit the loop.
                    if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                        done = YES;
                } while (!done);
                
                
                // Release the framewetter.
                CFRelease(framesetter);
                
            } else {
                NSLog(@"Could not create the framesetter..");
            }
            // Release the attributed string.
            CFRelease(currentText);
        } else {
            NSLog(@"currentText could not be created");
        }
        
    }
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

- (NSString *)createPDF:(NSString *)documentName withText:(NSArray *)stringsArray {
    
    //Get Document Directory path
//    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Define path for PDF file
//    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:documentName];
    NSString *documentPath = [NSTemporaryDirectory() stringByAppendingPathComponent:documentName];

    int pageNr = 1;
    
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(documentPath, CGRectZero, nil);
    
    for (int i = 0; i < stringsArray.count; i++)
    {
        NSAttributedString *theString = stringsArray[i];
        // Prepare the text using a Core Text Framesetter.
        CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (__bridge CFStringRef)theString.string, NULL);
        
        if (currentText) {
            
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(theString));
            if (framesetter) {
                
                CFRange currentRange = CFRangeMake(0, 0);
                NSInteger currentPage = 0;
                BOOL done = NO;
                
                do {
                    // Mark the beginning of a new page.
                    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                    
                    // Draw a page number at the bottom of each page.
                    //                    currentPage++;
                    [self drawPageNbr:pageNr];
                    pageNr ++;
                    //                    [self drawPageNbr:i font: [theString attri]];
                    // Render the current page and update the current range to
                    // point to the beginning of the next page.
                    currentRange = *[self updatePDFPage:(int)currentPage setTextRange:&currentRange setFramesetter:&framesetter];
                    
                    // If we're at the end of the text, exit the loop.
                    if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                        done = YES;
                } while (!done);
                
                
                // Release the framewetter.
                CFRelease(framesetter);
                
            } else {
                NSLog(@"Could not create the framesetter..");
            }
            // Release the attributed string.
            CFRelease(currentText);
        } else {
            NSLog(@"currentText could not be created");
        }
        
    }
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    
    return documentPath;
    
}


-(CFRange*)updatePDFPage:(int)pageNumber setTextRange:(CFRange*)pageRange setFramesetter:(CTFramesetterRef*)framesetter{
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    CGRect frameRect = CGRectMake(72, 72, 468, 648);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(*framesetter, *pageRange,
                                                   framePath, NULL);
    CGPathRelease(framePath);
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    // Update the current range based on what was drawn.
    *pageRange = CTFrameGetVisibleStringRange(frameRef);
    pageRange->location += pageRange->length;
    pageRange->length = 0;
    CFRelease(frameRef);
    
    return pageRange;
}

-(void)drawPageNbr:(int)pageNumber {
    NSString *setPageNum = [NSString stringWithFormat:@"Page %d", pageNumber];
    CGSize maxSize = CGSizeMake(612, 72);
    
    CGRect pageStringSize = [setPageNum boundingRectWithSize: maxSize options: NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes: nil context:nil];
    
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.size.width) / 2.0),
                                   720.0 + ((72.0 - pageStringSize.size.height) / 2.0),
                                   pageStringSize.size.width,
                                   pageStringSize.size.height);
    [setPageNum drawInRect:stringRect withAttributes:nil];
}

@end
