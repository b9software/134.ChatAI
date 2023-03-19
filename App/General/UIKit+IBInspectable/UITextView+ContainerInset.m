
#import <UIKit/UIKit.h>

@interface UITextView (ContainerInset)
@property IBInspectable CGRect RFTextContainerInset;
@end

@implementation UITextView (ContainerInset)
@dynamic RFTextContainerInset;

- (void)setRFTextContainerInset:(CGRect)inset {
    self.textContainerInset = (UIEdgeInsets){ inset.origin.x, inset.origin.y, inset.size.width, inset.size.height };
}

@end
