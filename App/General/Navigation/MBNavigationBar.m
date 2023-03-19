
#import "MBNavigationBar.h"
#import "MBNavigationTitleView.h"
#import <RFKit/UIView+RFAnimate.h>

@interface MBNavigationBar ()
@property (nonatomic) BOOL hasLayoutOnce;
@end

@implementation MBNavigationBar
RFInitializingRootForUIView

- (void)onInit {
    [self setupShadowImageView];
}

- (void)afterInit {
}

- (void)setupShadowImageView {
    UIView *backgroundView = self.subviews.firstObject;
    if (!backgroundView) return;

    CGRect frame = backgroundView.bounds;
    frame.origin.y += frame.size.height;
    frame.size.height = 7;
    UIImageView *iv = [UIImageView.alloc initWithFrame:frame];
    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.customShadowImageView = iv;

    [backgroundView addSubview:iv];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!self.hasLayoutOnce) {
        // 这里的判断不是为了解决新布局方式先有鸡还是先有蛋的问题
        // 发现在部分设备上会遇到在 layoutSubviews 里访问 titleView 直接挂掉的问题
        // 怀疑界面元素是懒加载的，在下面的布局代码在访问时触发了创建，创建就需要布局，内部状态冲突了导致的
        self.hasLayoutOnce = YES;
    }
    else {
        [self updateLayoutForMBNavigationTitleView];
    }
}

- (void)updateLayoutForMBNavigationTitleView {
    MBNavigationTitleView *tv = (id)self.topItem.titleView;
    if (![tv isKindOfClass:[MBNavigationTitleView class]]
        || ![self.subviews containsObject:tv]) return;

    CGFloat contentWidth = self.width;
    CGRect frame = tv.frame;
    CGFloat tvMinX = CGRectGetMinX(frame);
    CGFloat tvMaxX = CGRectGetMaxX(frame);
    CGFloat buttonLeftRang = 0;
    CGFloat buttonRightRang = contentWidth;
    CGFloat btMinX;
    CGFloat btMaxX;
    for (UIButton *bt in self.subviews) {
        if ((btMaxX = CGRectGetMaxX(bt.frame)) < tvMinX) {
            // 是左侧按钮
            if (buttonLeftRang < btMaxX) {
                buttonLeftRang = btMaxX;
            }
        }
        if ((btMinX = CGRectGetMinX(bt.frame)) > tvMaxX) {
            // 是右侧按钮
            if (buttonRightRang > btMinX) {
                buttonRightRang = btMinX;
            }
        }
    }

    if (tv.keepCenterLayout) {
        CGFloat padding = MAX(buttonLeftRang, contentWidth - buttonRightRang) + 4;
        frame.origin.x = padding;
        frame.size.width = contentWidth - 2 * padding;
    }
    else {
        frame.origin.x = buttonLeftRang + 10;
        frame.size.width = buttonRightRang - buttonLeftRang - 10;
    }
    tv.frame = frame;
}

@end
