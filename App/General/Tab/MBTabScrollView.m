
#import "MBTabScrollView.h"

@interface MBTabScrollView ()
@end

@implementation MBTabScrollView

- (void)onInit {
    [super onInit];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.scrollsToTop = NO;
}

@end
