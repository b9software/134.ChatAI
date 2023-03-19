
#import "MBBottomLayoutView.h"

@interface MBBottomLayoutView ()
@property (nullable) NSLayoutConstraint *_bottomConstraint;
@property (nullable) NSLayoutConstraint *_leftConstraint;
@property (nullable) NSLayoutConstraint *_rightConstraint;
@property NSNumber *_MBBottomLayoutView_isClippingSetValue;
@property (nonatomic) BOOL _MBBottomLayoutView_isClipping;
@end

@implementation MBBottomLayoutView
RFInitializingRootForUIView

- (void)onInit {
    self.clipsToBounds = YES;
    _clippingCornerRadius = CGFLOAT_MAX;
    _clippingMargin = 15;
}

- (void)afterInit {
    // Nothing
}

- (BOOL)clipping {
    if (self._MBBottomLayoutView_isClippingSetValue) {
        return self._MBBottomLayoutView_isClippingSetValue.boolValue;
    }
    return self._MBBottomLayoutView_isClipping;
}
- (void)setClipping:(BOOL)clipping {
    [self willChangeValueForKey:@"clipping"];
    self._MBBottomLayoutView_isClippingSetValue = @(clipping);
    self._MBBottomLayoutView_isClipping = clipping;
    [self didChangeValueForKey:@"clipping"];
}
+ (BOOL)automaticallyNotifiesObserversOfClipping {
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _updateClipping];
    [self _updateCornerRadius];
}

- (void)_updateClipping {
    NSLayoutConstraint *c = self._bottomConstraint;
    UIView *superView = self.superview;
    if (c && superView) {
        self._MBBottomLayoutView_isClipping = CGRectGetMaxY(superView.bounds) - CGRectGetMaxY(self.frame) > c.constant;
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    if (@available(iOS 11.0, *)) {} else return;

    for (NSLayoutConstraint *c in self.superview.constraints) {
        if (c.firstItem != self && c.secondItem != self) continue;
        UILayoutGuide *lg = c.firstItem == self ? c.secondItem : c.firstItem;
        if (![lg isKindOfClass:UILayoutGuide.class]) continue;
        NSLayoutAttribute viewAttribute = c.firstItem == self ? c.firstAttribute : c.secondAttribute;

        switch (viewAttribute) {
            case NSLayoutAttributeLeading:
                self._leftConstraint = c;
                break;
            case NSLayoutAttributeTrailing:
                self._rightConstraint = c;
                break;
            case NSLayoutAttributeBottom:
                self._bottomConstraint = c;
                break;
            default:
                break;
        }
    }
}

- (void)set_MBBottomLayoutView_isClipping:(BOOL)isClipping {
    if (__MBBottomLayoutView_isClipping == isClipping) return;
    [self willChangeValueForKey:@"clipping"];
    __MBBottomLayoutView_isClipping = isClipping;
    [self didChangeValueForKey:@"clipping"];
    [self _updateCornerRadius];

    CGFloat margin = isClipping ? self.clippingMargin : 0;
    self._leftConstraint.constant = self._leftConstraint.firstItem == self ? margin : -margin;
    self._rightConstraint.constant = self._rightConstraint.firstItem == self ? -margin : margin;
}

- (void)_updateCornerRadius {
    BOOL isClipping = self._MBBottomLayoutView_isClipping;
    CGFloat cr = 0;
    if (isClipping) {
        cr = self.bounds.size.height / 2;
        if (self.clippingCornerRadius < cr && self.clippingCornerRadius >= 0) {
            cr = self.clippingCornerRadius;
        }
    }
    self.layer.cornerRadius = cr;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    self.heightConstraint.active = !hidden;
    [self invalidateIntrinsicContentSize];
    if (!self._MBBottomLayoutView_isClipping) return;
    if (@available(iOS 11.0, *)) {
        if (self.hiddenMoveTopAnchor) {
            CGFloat guideY = CGRectGetMaxY(self.superview.safeAreaLayoutGuide.layoutFrame);
            CGFloat viewY = CGRectGetHeight(self.superview.bounds);
            CGFloat constant = hidden ? guideY - viewY : 0;
            self._bottomConstraint.constant = self._bottomConstraint.firstItem == self ? -constant : constant;
        }
    }
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    if (self.isHidden) {
        size.height = 0;
    }
    return size;
}

@end
