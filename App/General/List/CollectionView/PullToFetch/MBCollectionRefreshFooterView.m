
#import "MBCollectionRefreshFooterView.h"
#import <RFKit/UIView+RFKit.h>

@interface MBCollectionRefreshFooterView ()
@property (readwrite, nonatomic) BOOL end;
@property (readwrite, nonatomic) BOOL empty;

@end

@implementation MBCollectionRefreshFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.status = RFRefreshControlStatusWaiting;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    self.frame = layoutAttributes.frame;
}

- (void)setCustomEmptyView:(UIView *)customEmptyView {
    if (_customEmptyView != customEmptyView) {
        if (_customEmptyView) {
            [_customEmptyView removeFromSuperview];
            if (self.status == RFRefreshControlStatusEmpty) {
                self.endLabel.hidden = NO;
                self.endView.hidden = NO;
            }
        }

        _customEmptyView = customEmptyView;

        if (customEmptyView.superview != self) {
            [customEmptyView removeFromSuperview];
            customEmptyView.autoresizingMask = UIViewAutoresizingFlexibleSize;
            customEmptyView.translatesAutoresizingMaskIntoConstraints = YES;
            [self addSubview:customEmptyView resizeOption:RFViewResizeOptionFill];

            self.emptyLabel.hidden = YES;
        }
    }
}

- (void)setEmpty:(BOOL)empty {
    _empty = empty;
    if (empty) {
        self.outerEmptyView.hidden = NO;
        if (self.customEmptyView) {
            self.customEmptyView.hidden = NO;
        }
        else {
            self.emptyLabel.hidden = NO;
        }
    }
    else {
        self.outerEmptyView.hidden = YES;
        self.customEmptyView.hidden = YES;
        self.emptyLabel.hidden = YES;
    }
}

- (void)setOuterEmptyView:(UIView *)outerEmptyView {
    _outerEmptyView = outerEmptyView;
    outerEmptyView.hidden = !self.empty;
}

- (void)setCustomEndView:(UIView *)customEndView {
    if (_customEndView != customEndView) {
        if (_customEndView) {
            [_customEndView removeFromSuperview];
            if (self.status == RFRefreshControlStatusEnd) {
                self.endLabel.hidden = NO;
                self.endView.hidden = NO;
            }
        }

        _customEndView = customEndView;

        if (customEndView.superview != self) {
            [customEndView removeFromSuperview];
            customEndView.autoresizingMask = UIViewAutoresizingFlexibleSize;
            customEndView.translatesAutoresizingMaskIntoConstraints = YES;
            [self addSubview:customEndView resizeOption:RFViewResizeOptionFill];

            self.endLabel.hidden = YES;
            self.endView.hidden = YES;
        }
    }
}

- (void)setEnd:(BOOL)end {
    _end = end;
    if (end) {
        if (self.customEndView) {
            self.customEndView.hidden = NO;
        }
        else {
            self.endLabel.hidden = NO;
            self.endView.hidden = NO;
        }
    }
    else {
        self.endLabel.hidden = YES;
        self.endView.hidden = YES;
        self.customEndView.hidden = YES;
    }
}

- (void)setStatus:(RFRefreshControlStatus)status {
    self.end = (status == RFRefreshControlStatusEnd);
    self.empty = (status == RFRefreshControlStatusEmpty);

    switch (status) {
        case RFRefreshControlStatusPossible:
        case RFRefreshControlStatusReady:
        case RFRefreshControlStatusFetching: {
            self.loadButton.enabled = NO;
            self.loadButton.hidden = NO;
            break;
        }

        case RFRefreshControlStatusWaiting: {
            self.loadButton.enabled = YES;
            self.loadButton.hidden = NO;
            break;
        }
        default:
            self.loadButton.hidden = YES;
            break;
    }
    _status = status;
}

@end
