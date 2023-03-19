
#import "MBKeyboardAdjustScrollView.h"
#import <RFKeyboard/RFKeyboard.h>
#import <RFKit/UIView+RFKit.h>
#import <RFKit/UIResponder+RFKit.h>

@interface MBKeyboardAdjustScrollView ()
@property (nonatomic) BOOL keyboardEventObserving;
@property (nonatomic) CGFloat keyboardAdjustInset;
@end

@implementation MBKeyboardAdjustScrollView

- (void)didMoveToWindow {
    [super didMoveToWindow];
    self.keyboardEventObserving = !!self.window;
}

- (void)dealloc {
    self.keyboardEventObserving = NO;
}

- (void)setKeyboardEventObserving:(BOOL)keyboardEventObserving {
    if (_keyboardEventObserving == keyboardEventObserving) return;
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    _keyboardEventObserving = keyboardEventObserving;
    if (keyboardEventObserving) {
        [nc addObserver:self selector:@selector(MBKeyboardAdjustScrollView_keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(MBKeyboardAdjustScrollView_keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    else {
        [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    }
}

- (void)MBKeyboardAdjustScrollView_keyboardShow:(NSNotification*)aNotification {
    CGFloat heightInView = [RFKeyboard keyboardLayoutHeightForNotification:aNotification inView:self];
    if (heightInView <= 0) return;

    self.keyboardAdjustInset = heightInView;
    self.scrollIndicatorInsets = self.contentInset;

    // Find input view in scrollview
    UIView<UITextInput> *activeView = UIResponder.firstResponder;
    if (![activeView isKindOfClass:UIView.class]) return;
    UIView *commonSuper = [UIView commonSuperviewWith:self anotherView:activeView];
    if (commonSuper != self) return;

    CGRect viewVisableBounds = self.bounds;
    if (CGRectGetHeight(viewVisableBounds) < heightInView) return;
    viewVisableBounds.size.height -= heightInView;

    // Try get cursor position
    CGRect activeBounds = activeView.bounds;
    if ([activeView respondsToSelector:@selector(selectedTextRange)]) {
        UITextRange *range = activeView.selectedTextRange;
        if ([activeView respondsToSelector:@selector(firstRectForRange:)]) {
            CGRect rect = [activeView firstRectForRange:range];
            if (!CGRectIsNull(rect)) {
                activeBounds = rect;
            }
        }
    }
    CGRect activeFrame = CGRectIntegral([activeView convertRect:activeBounds toView:self]);
    if (activeFrame.size.height > viewVisableBounds.size.height) {
        activeFrame.size.height = viewVisableBounds.size.height;
    }

    CGFloat activeOffsetYMin = CGRectGetMinY(activeFrame) - 10;
    CGFloat activeOffsetYMax = CGRectGetMaxY(activeFrame) + 10;
    CGPoint offset = self.contentOffset;
    CGFloat offsetVisableYMin = offset.y;
    CGFloat offsetVisableYMax = offsetVisableYMin + viewVisableBounds.size.height;
    if (offsetVisableYMax > activeOffsetYMax) return;
    CGFloat offsetChange = activeOffsetYMax - offsetVisableYMax;
    CGFloat offsetChangeMax = activeOffsetYMin - offsetVisableYMin;
    if (offsetChange > offsetChangeMax) {
        offsetChange = offsetChangeMax;
    }
    offset.y += offsetChange;
    self.contentOffset = offset;
}

- (void)MBKeyboardAdjustScrollView_keyboardHide:(NSNotification*)aNotification {
    self.keyboardAdjustInset = 0;
    self.scrollIndicatorInsets = self.contentInset;
}

- (void)setKeyboardAdjustInset:(CGFloat)keyboardAdjustInset {
    if (_keyboardAdjustInset == keyboardAdjustInset) return;
    UIEdgeInsets inset = self.contentInset;
    inset.bottom -= _keyboardAdjustInset;
    _keyboardAdjustInset = keyboardAdjustInset;
    inset.bottom += keyboardAdjustInset;
    self.contentInset = inset;
}

@end
