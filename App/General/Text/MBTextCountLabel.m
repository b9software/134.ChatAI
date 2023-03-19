
#import "MBTextCountLabel.h"

@implementation MBTextCountLabel
RFInitializingRootForUIView

- (void)onInit {
    
}

- (void)afterInit {
    // Nothing
}

- (void)dealloc {
    self.textView = nil;
}

- (void)setTextView:(UITextView *)textView {
    if (_textView == textView) return;
    if (_textView) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UITextViewTextDidChangeNotification object:_textView];
    }
    _textView = textView;
    if (textView) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateUIForTextChanged) name:UITextViewTextDidChangeNotification object:textView];
    }
    if (self.window) {
        [self _updateForTextChange:textView];
    }
}

- (void)setMaxLength:(NSUInteger)maxLength {
    _maxLength = maxLength;
    if (self.textView) {
        [self _updateForTextChange:self.textView];
    }
}

- (void)updateUIForTextChanged {
    [self _updateForTextChange:self.textView];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self _updateForTextChange:self.textView];
}

- (void)_updateForTextChange:(UITextView *)textView {
    if (self.textChangeUpdateBlock) {
        self.textChangeUpdateBlock(self);
        return;
    }
    if (!textView) {
        self.text = nil;
        return;
    }
    NSUInteger lenText = textView.text.length;
    NSUInteger lenMax = self.maxLength;
    if (lenMax == 0) {
        self.text = @(lenText).stringValue;
        self.highlighted = NO;
        return;
    }
    
    if (textView.markedTextRange) return;

    if (self.maxLengthColor) {
        NSMutableAttributedString *as = [NSMutableAttributedString.alloc initWithString:@(lenText).stringValue];
        [as appendAttributedString:[NSAttributedString.alloc initWithString:[NSString.alloc initWithFormat:@"/%ld", lenMax] attributes:@{ NSForegroundColorAttributeName: self.maxLengthColor }]];
        self.attributedText = as;
    }
    else {
        self.text = [NSString.alloc initWithFormat:@"%ld/%ld", lenText, lenMax];
    }
    self.highlighted = lenText >= lenMax;
}

@end
