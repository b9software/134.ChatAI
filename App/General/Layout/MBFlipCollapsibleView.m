
#import "MBFlipCollapsibleView.h"

@implementation MBFlipCollapsibleView
RFInitializingRootForUIView

- (void)onInit {
    _direction = RFResizeAnchorTop;
}

- (void)afterInit {
    // Nothing
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.layer.mask) {
        [self updateLayout];
    }
}

- (void)setExpand:(BOOL)expand {
    _expand = expand;
    [self updateLayout];
}

- (void)setDirection:(RFResizeAnchor)direction {
    _direction = direction;
    [self updateLayout];
}

- (void)updateLayout {
    BOOL expand = self.expand;
    CALayer *layer = self.layer;
    CALayer *mask = layer.mask;
    CGRect frame = (CGRect){ CGPointZero, layer.bounds.size };
    if (expand) {
        mask.frame = frame;
    }
    else {
        if (!mask) {
            mask = CALayer.new;
            mask.backgroundColor = UIColor.whiteColor.CGColor;
            mask.frame = self.layer.bounds;
            self.layer.mask = mask;
        }
        
        mask.frame = CGRectResize(frame, CGSizeMake(frame.size.width, 0), self.direction);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:point withEvent:event];
    return self.expand? v : nil;
}

@end
