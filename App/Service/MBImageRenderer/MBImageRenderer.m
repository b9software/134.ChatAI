
#import "MBImageRenderer.h"

@interface MBImageRenderer ()
@property UIViewController *viewController;
@property NSArray<NSLayoutConstraint *> *_installedConstraints;
@end

@implementation MBImageRenderer

- (instancetype)init {
    return nil;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    NSParameterAssert(viewController);
    self = [super init];
    if (self) {
        _renderScale = 2;
        _viewController = viewController;
    }
    return self;
}

- (void)prepareForRendering {
    UIView *r = self.viewController.view;
    r.hidden = YES;
    UIView *rc =  UIApplication.sharedApplication.keyWindow;
    if (!r.superview) {
        // 只有 view 显示出来，Auto Layout 才会起作用，所以需要加入到 window 中
        [rc insertSubview:r atIndex:0];
    }
    CGSize cSize = self.viewController.preferredContentSize;
    if (CGSizeEqualToSize(cSize, CGSizeZero)) {
        // 自动布局
        r.translatesAutoresizingMaskIntoConstraints = NO;
        if (self._installedConstraints) return;
        
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:rc attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:r attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:rc attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:r attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        self._installedConstraints = @[ c1, c2 ];
        [rc addConstraints:self._installedConstraints];
    }
    else {
        // 固定大小
        r.frame = (CGRect){ CGPointZero, cSize };
        r.translatesAutoresizingMaskIntoConstraints = YES;
    }
    [r setNeedsLayout];
    [r layoutIfNeeded];
}

- (UIImage *)renderAndClean {
    [self prepareForRendering];
    UIView *r = self.viewController.view;
    r.hidden = NO;
    UIGraphicsBeginImageContextWithOptions(r.bounds.size, r.opaque, self.renderScale);
    [r.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [r removeFromSuperview];
    RFAssert(img, @"生成图片失败");
    return img;
}

@end
