
#import "MBParallaxView.h"
#import <RFAlpha/RFKVOWrapper.h>
#import <RFKit/UIView+RFAnimate.h>

@interface MBParallaxView ()
@property (strong, nonatomic) id scrollObserver;
@property (nonatomic) BOOL ignoralNextKVONotification;
@end

@implementation MBParallaxView
RFInitializingRootForUIView

- (void)onInit {
    self.acceleration = 1;
    self.scrollEnabled = NO;
    self.minParallaxOffset = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
    self.maxParallaxOffset = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
}

- (void)afterInit {

}

- (CGSize)intrinsicContentSize {
    return self.size;
}

- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        if (_scrollView) {
            [_scrollView RFRemoveObserverWithIdentifier:self.scrollObserver];
        }

        _scrollView = scrollView;
        _douts(@"MBParallaxView scrollView changing")

        if (scrollView) {
            self.scrollObserver = [scrollView RFAddObserver:self forKeyPath:@keypath(scrollView, contentOffset) options:NSKeyValueObservingOptionNew queue:nil block:^(MBParallaxView *observer, NSDictionary *change) {
                if (observer.ignoralNextKVONotification) {
                    observer.ignoralNextKVONotification = NO;
                    return;
                }
                [observer _updateLayoutAttributes];
            }];
        }
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [self _updateLayoutAttributes];
}

- (void)_updateLayoutAttributes {
    if (!self.scrollView) return;

    CGPoint lockedOffset = self.lockedContentOffset;
    if (!CGPointEqualToPoint(CGPointZero, lockedOffset)
        && !CGPointEqualToPoint(self.scrollView.contentOffset, lockedOffset)) {
        self.ignoralNextKVONotification = YES;
        self.scrollView.contentOffset = lockedOffset;
    }
    CGPoint offset = [self parallaxOffsetFromScrollViewContentOffset:self.scrollView.contentOffset];
    [self updateLayoutForParallaxOffset:offset];
}

- (void)updateLayoutForParallaxOffset:(CGPoint)offset {
    _dout_point(offset)
    CGPoint origin = offset;

    CGPoint minParallaxOffset = self.minParallaxOffset;
    CGPoint maxParallaxOffset = self.maxParallaxOffset;
    if (origin.x < minParallaxOffset.x) {
        origin.x = minParallaxOffset.x;
    }
    if (origin.x > maxParallaxOffset.x) {
        origin.x = maxParallaxOffset.x;
    }
    if (origin.y < minParallaxOffset.y) {
        origin.y = minParallaxOffset.y;
    }
    if (origin.y > maxParallaxOffset.y) {
        origin.y = maxParallaxOffset.y;
    }
    self.contentOffset = origin;
}

- (CGPoint)parallaxOffsetFromScrollViewContentOffset:(CGPoint)contentOffset {
    CGPoint origin = contentOffset;

    CGPoint adjust = self.contentOffsetAdjust;
    origin.x += adjust.x;
    origin.y += adjust.y;

    CGFloat acceleration = self.acceleration;
    origin.x *= acceleration;
    origin.y *= acceleration;

    return origin;
}

- (CGPoint)scrollViewContentOffsetFromParallaxOffset:(CGPoint)parallaxOffset {
    CGPoint origin = parallaxOffset;

    CGFloat acceleration = self.acceleration;
    origin.x /= acceleration;
    origin.y /= acceleration;

    CGPoint adjust = self.contentOffsetAdjust;
    origin.x -= adjust.x;
    origin.y -= adjust.y;

    return origin;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect fixedRect = (CGRect){ CGPointZero, self.bounds.size };
    BOOL c = CGRectContainsPoint(fixedRect, point);
    return c;
}

@end
