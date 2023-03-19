
#import "MBTouchEffectButton.h"

@interface MBTouchEffectButton ()
@property (nonatomic) BOOL touchDownEffectApplied;
@end

@implementation MBTouchEffectButton

- (void)onInit {
    [super onInit];

    [self addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchCancel];
}

- (void)onTouchDown {
    if (self.touchEffectDisabled) return;
    if (self.touchDownEffectApplied) return;
    self.touchDownEffectApplied = YES;
    [self touchDownEffect];
}

- (void)onTouchUp {
    if (!self.touchDownEffectApplied) return;
    [self touchUpEffect];
    self.touchDownEffectApplied = NO;
}

- (void)touchDownEffect {
    // For overwrite
}

- (void)touchUpEffect {
    // For overwrite
}

@end
