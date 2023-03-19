
#import "MBNotificationIndicatorViews.h"
#import "MBNotificationBadgeManager.h"
#import "Common.h"
#import "ShortCuts.h"

@implementation MBNotificationIndicator
RFInitializingRootForUIView

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:nil afterDelay:0];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:nil afterDelay:0];
    }
    return self;
}

- (void)onInit {
}

- (void)afterInit {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateStatus) name:MBNotificatioBadgeChangedNotification object:nil];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self updateStatus];
    }
}

- (void)updateStatus {
    if (!self.observerProperty || self.disabled) return;
    self.hidden = !self.shouldShow;
}

- (BOOL)shouldShow {
    if (!self.observerProperty) return NO;
    id value = [AppBadge() valueForKeyPath:self.observerProperty];
    return [value boolValue];
}

- (void)setHidden:(BOOL)hidden {
    if (!hidden && !self.shouldShow) {
        // 当应当隐藏时，忽略外部设置的显示
        return;
    }
    [super setHidden:hidden];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:MBNotificatioBadgeChangedNotification object:nil];
}

@end


@implementation MBNotificationNumberIndicator
RFInitializingRootForUIView

- (void)onInit {
    CALayer *layer = self.layer;
    layer.cornerRadius = CGRectGetHeight(self.bounds) / 2.;
    self.clipsToBounds = YES;
    self.textAlignment = NSTextAlignmentCenter;
    self.contentInset = UIEdgeInsetsMake(2, 4, 2, 4);
}

- (void)afterInit {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateStatus) name:MBNotificatioBadgeChangedNotification object:nil];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    UIEdgeInsets inset = self.contentInset;
    size.width += inset.left + inset.right;
    size.height += inset.top + inset.bottom;
    if (size.width < size.height) {
        size.width = size.height;
    }
    return size;
}

- (void)sizeToFit {
    CGSize size = self.intrinsicContentSize;
    CGRect frame = CGRectMakeWithCenterAndSize(self.center, size);
    self.frame = frame;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.layer.cornerRadius = CGRectGetHeight(bounds) / 2.;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self updateStatus];
    }
}

- (void)updateStatus {
    if (!self.observerProperty || self.disabled) return;
    long count = self.count;
    long max = self.maxCount;
    if (max && count > max) {
        self.text = [NSString stringWithFormat:@"%ld+", max];
    }
    else {
        self.text = [NSString stringWithFormat:@"%ld", count];
    }
    if (self.autoFitSize) {
        [self sizeToFit];
    }
    self.hidden = count == 0;
}

- (long)count {
    if (!self.observerProperty) return 0;
    NSNumber *value = [AppBadge() valueForKeyPath:self.observerProperty];
    return value.longValue;
}

- (void)setHidden:(BOOL)hidden {
    if (!hidden && self.count == 0) {
        // 当应当隐藏时，忽略外部设置的显示
        return;
    }
    [super setHidden:hidden];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:MBNotificatioBadgeChangedNotification object:nil];
}

- (void)setLayoutBindButton:(UIButton *)layoutBindButton {
    _layoutBindButton = layoutBindButton;
    if (!layoutBindButton) return;
    [self removeFromSuperview];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [layoutBindButton addSubview:self];
    UILabel *label = layoutBindButton.titleLabel;
    UIImageView *imageView = layoutBindButton.imageView;
    if (label.text.length) {
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [layoutBindButton addConstraints:@[ c1, c2 ]];
    }
    else if (imageView.image) {
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [layoutBindButton addConstraints:@[ c1, c2 ]];
    }
    @weakify(self);
    dispatch_after_seconds(0, ^{
        @strongify(self);
        if (self.superview == layoutBindButton) {
            [self bringToFront];
        }
    });
}

@end
