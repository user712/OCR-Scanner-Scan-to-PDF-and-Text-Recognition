
#import <UIKit/UIKit.h>

@interface UIImage (Filters)

/**
 *  A convenience method for using CoreImage filters to preprocess an image by
 *  1) setting the saturation to 0 to achieve grayscale, 2) increasing the
 *  contrast by 10% to make black parts blacker, and 3) reducing the exposure
 *  by 30% to reduce the amount of "light" in the image.
 *
 *  @return The filtered image.
 */
- (UIImage *)image_blackAndWhite;

/**
 *  A convenience method for converting an image to grayscale by manually
 *  iterating over each of the pixels in the image and applying the following
 *  formula to each pixel: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
 *
 *  @return The grayscale image.
 */
- (UIImage *)image_grayScale;

@end
