//
//  ScannerWrapper.h
//  Scanner
//
//   on 1/20/17.
//   
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface ScannerWrapper : NSObject

//- (NSString *)createPDF:(NSString *)documentName withText:(NSAttributedString *)theString;
- (NSString *)createPDF:(NSString *)documentName withText:(NSArray *)stringsArray;

@end
