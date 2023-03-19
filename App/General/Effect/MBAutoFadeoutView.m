
#import "MBAutoFadeoutView.h"
#import <RFAlpha/RFTimer.h>
#import <RFKit/UIView+RFKit.h>

@interface MBAutoFadeoutView ()
@property (nonatomic, strong) RFTimer *autoFadeoutTimer;
@end

@implementation MBAutoFadeoutView
RFInitializingRootForUIView

- (void)onInit {
    _fadeoutDelay = 3;
    _showAlpha = 1;
    _hideAlpha = 0;
    _fadeAnimationDuration = 0.3;
}

- (void)afterInit {

}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))completion {
    CGFloat alphaShouldBe = hidden? self.hideAlpha : self.showAlpha;
    if (self.alpha == alphaShouldBe) {
        // Alpha is same means hidden not changed, do nothing except reset fade out timer.
        if (!hidden) {
            [self resetFadeoutTimer];
        }
        return;
    }

    if (hidden) {
        self.autoFadeoutTimer.suspended = YES;
    }

    [UIView animateWithDuration:self.fadeAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationCurveEaseInOut animated:animated beforeAnimations:nil animations:^{
        self.alpha = alphaShouldBe;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        if (!hidden) {
            // If animation not finished, it means another call received during the animation.
            if (finished || !animated) {
                [self resetFadeoutTimer];
            }
        }
    }];
}

#pragma mark - Timer

- (RFTimer *)autoFadeoutTimer {
    if (!_autoFadeoutTimer) {
        @weakify(self);
        _autoFadeoutTimer = [RFTimer scheduledTimerWithTimeInterval:self.fadeoutDelay repeats:NO fireBlock:^(RFTimer *timer, NSUInteger repeatCount) {
            @strongify(self);
            [self setHidden:YES animated:YES completion:nil];
        }];
    }
    return _autoFadeoutTimer;
}

- (void)setFadeoutDelay:(NSTimeInterval)fadeoutDelay {
    _fadeoutDelay = fadeoutDelay;
    self.autoFadeoutTimer.timeInterval = fadeoutDelay;
}

- (void)resetFadeoutTimer {
    self.autoFadeoutTimer.suspended = YES;
    self.autoFadeoutTimer.suspended = NO;
}

@end
