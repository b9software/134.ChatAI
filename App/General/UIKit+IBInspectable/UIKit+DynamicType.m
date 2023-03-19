
#import <UIKit/UIKit.h>

@interface UILabel (IBDynamicType)
@property IBInspectable BOOL dynamicTypeEnabled;
@end

@implementation UILabel (DynamicType)

- (BOOL)dynamicTypeEnabled {
    return self.adjustsFontForContentSizeCategory;
}
- (void)setDynamicTypeEnabled:(BOOL)dynamicTypeEnabled {
    self.font = [UIFontMetrics.defaultMetrics scaledFontForFont:self.font];
    self.adjustsFontForContentSizeCategory = YES;
}

@end


@interface UIButton (IBDynamicType)
@property IBInspectable BOOL dynamicTypeEnabled;
@end

@implementation UIButton (DynamicType)

- (BOOL)dynamicTypeEnabled {
    return self.titleLabel.dynamicTypeEnabled;
}
- (void)setDynamicTypeEnabled:(BOOL)dynamicTypeEnabled {
    self.titleLabel.dynamicTypeEnabled = dynamicTypeEnabled;
}

@end
