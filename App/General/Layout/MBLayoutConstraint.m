
#import "MBLayoutConstraint.h"
#import <RFKit/NSLayoutConstraint+RFKit.h>

@interface MBLayoutConstraint ()
@end

@implementation MBLayoutConstraint

- (void)awakeFromNib {
    [super awakeFromNib];

    if (self.constant && !self.expandedConstant) {
        self.expandedConstant = self.constant;
        self.expand = YES;
    }
}

- (void)setExpand:(BOOL)expand {
    _expand = expand;
    self.constant = expand? self.expandedConstant : self.contractedConstant;
}

- (void)setContractedConstant:(CGFloat)contractedConstant {
    _contractedConstant = contractedConstant;
    if (!self.expand) {
        self.constant = contractedConstant;
    }
}

- (void)setExpandedConstant:(CGFloat)expandedConstant {
    _expandedConstant = expandedConstant;
    if (self.expand) {
        self.constant = expandedConstant;
    }
}

- (void)setExpand:(BOOL)expand animated:(BOOL)animated {
    self.expand = expand;

    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            [self updateLayoutIfNeeded];
        }];
    }
}

@end
