//
//  PDFCreatorManager.h
//  Scanner
//
//   on 2/22/17.
//   
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface PDFCreatorManager : NSObject

- (NSString *)createPDF:(NSString *)documentName withText:(NSArray *)stringsArray;
- (void) createPDFWithName:(NSString *)documentName withText:(NSArray *)stringsArray withWritePath:(NSString *) documentPath;

@end
