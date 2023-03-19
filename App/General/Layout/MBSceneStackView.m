
#import "MBSceneStackView.h"
#import <RFKit/NSArray+RFKit.h>

@interface MBSceneStackView ()
@property NSInteger activeSceneIndex;
@end

@implementation MBSceneStackView

- (void)setScenes:(NSArray<NSArray<UIView *> *> *)scenes {
    _scenes = scenes;
    [scenes enumerateObjectsUsingBlock:^(NSArray<UIView *> *vs, NSUInteger idx, BOOL * _Nonnull stop) {
        for (UIView *v in vs) {
            v.hidden = (idx != self.activeSceneIndex);
        }
    }];
}

- (void)setActiveSceneWithIndex:(NSInteger)index animated:(BOOL)animated {
    NSArray<NSArray<UIView *> *> *scenes = self.scenes;
    NSInteger count = scenes.count;
    if (!count || index >= count) return;
    
    NSArray *scNeedHide = [scenes rf_objectAtIndex:self.activeSceneIndex];
    NSArray *scNeedShow = [scenes rf_objectAtIndex:index];
    CGFloat transform = (self.activeSceneIndex < index)? 100 : -100;
    self.activeSceneIndex = index;
    if (self.onSceneChanged) {
        self.onSceneChanged(self, index);
    }
    if (!animated) {
        for (UIView *v in scNeedHide) {
            v.hidden = YES;
        }
        for (UIView *v in scNeedShow) {
            v.hidden = NO;
        }
        return;
    }
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        for (UIView *v in scNeedHide) {
            v.alpha = 0;
            v.transform = CGAffineTransformMakeTranslation(-transform, 0);
        }
    } completion:^(BOOL finished) {
        for (UIView *v in scNeedHide) {
            v.hidden = YES;
            v.alpha = 1;
            v.transform = CGAffineTransformIdentity;
        }
        for (UIView *v in scNeedShow) {
            v.hidden = NO;
            v.alpha = 0;
            v.transform = CGAffineTransformMakeTranslation(transform, 0);
        }
        [self layoutIfNeeded];
        
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            for (UIView *v in scNeedShow) {
                v.alpha = 1;
                v.transform = CGAffineTransformIdentity;
            }
        } completion:nil];
    }];
}

- (void)nextSceneAnimated:(BOOL)animated {
    [self setActiveSceneWithIndex:self.activeSceneIndex + 1 animated:animated];
}

- (void)previousSceneAnimated:(BOOL)animated {
    [self setActiveSceneWithIndex:self.activeSceneIndex - 1 animated:animated];
}

@end
