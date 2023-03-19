
#import "MBNavigationTitleView.h"

@interface MBNavigationTitleView ()
@property BOOL hasLayoutOnce;
@end

@implementation MBNavigationTitleView

// 这个类只是用于标识，布局操作是在 MBNavigationBar 中完成的
// 下面这段是辅助布局的，iOS 10 SDK 修改后，导航上布局代码触发的事件太晚了，导致进入界面后会闪一下
- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!self.hasLayoutOnce) {
        self.hasLayoutOnce = YES;
        [self.superview setNeedsLayout];
    }
}

@end
