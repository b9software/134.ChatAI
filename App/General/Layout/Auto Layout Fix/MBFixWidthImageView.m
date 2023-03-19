
#import "MBFixWidthImageView.h"

@implementation MBFixWidthImageView

- (void)setBounds:(CGRect)bounds {
    if (CGRectGetWidth(self.bounds) != CGRectGetWidth(bounds)) {
        [self invalidateIntrinsicContentSize];
    }
    [super setBounds:bounds];
}

- (CGSize)intrinsicContentSize {
    CGSize imageSize = self.image.size;
    CGFloat width = self.bounds.size.width;

    if (imageSize.width <= 0 || imageSize.height <= 0) {
        if (self.defaultSizeRatio) {
            return CGSizeMake(width, width * self.defaultSizeRatio);
        }
        if (self.perfersNoIntrinsicMetric) {
            return super.intrinsicContentSize;
        }
        else {
            return CGSizeMake(width, 0);
        }
    }

    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit: {
            if (width > imageSize.width) {
                return CGSizeMake(width, imageSize.height);
            }
            // Else continue as fill
        }
        case UIViewContentModeScaleToFill:
        case UIViewContentModeScaleAspectFill: {
            return CGSizeMake(width, imageSize.height/imageSize.width*width);
        }

        default:
            return CGSizeMake(width, imageSize.height);
    }
}

@end
