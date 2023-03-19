
#import "MBFormSelectButton.h"
#import "UIKit+App.h"


@implementation MBFormSelectButton

- (void)setHighlighted:(BOOL)highlighted {
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.height = MAX(size.height, 36);
    return size;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    if (!self.placeHolder) {
        self.placeHolder = [self titleForState:UIControlStateNormal];
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    if (!self.selected) {
        [self setTitle:placeHolder forState:UIControlStateNormal];
    }
}

- (void)setSelectedVaule:(id)selectedVaule {
    if (_selectedVaule != selectedVaule) {
        NSString *title = [self displayStringWithValue:selectedVaule];
        [self setTitle:title forState:UIControlStateNormal];
        self.selected = !!(selectedVaule);
        _selectedVaule = selectedVaule;
    }
}

- (NSString *)displayStringWithValue:(id)value {
    if (!value) return self.placeHolder;
    if (self.valueDisplayString) {
        return self.valueDisplayString(value);
    }
    if (self.valueDisplayMap) {
        return self.valueDisplayMap[value];
    }
    return [NSString.alloc initWithFormat:@"%@", value];
}

@end
