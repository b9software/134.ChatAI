
#import "MBRefreshFooterView.h"
#import <RFKit/UIView+RFAnimate.h>

@implementation MBRefreshFooterView
RFInitializingRootForUIView

- (void)onInit {
    _status = -1;
}

- (void)afterInit {
    // Nothing
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.empty = NO;
}

- (void)setEmpty:(BOOL)empty {
    _empty = empty;
    self.emptyLabel.hidden = !empty;
    self.outerEmptyView.hidden = !empty;
    self.textLabel.hidden = empty || (self.status == RFPullToFetchIndicatorStatusFrozen);
    self.endLabel.hidden = empty;
    self.endView.hidden = empty;
}

- (void)setOuterEmptyView:(UIView *)outerEmptyView {
    _outerEmptyView = outerEmptyView;
    outerEmptyView.hidden = !self.empty || self.status != RFPullToFetchIndicatorStatusFrozen;
}

- (void)updateStatus:(RFPullToFetchIndicatorStatus)status distance:(CGFloat)distance control:(RFTableViewPullToFetchPlugin *)control {

    if (self.outerEmptyView && status != RFPullToFetchIndicatorStatusFrozen) {
        if (!self.outerEmptyView.hidden) {
            self.outerEmptyView.hidden = YES;
        }
    }
    if (self.empty) return;
    self.status = status;

    if (status == RFPullToFetchIndicatorStatusDragging) {
        BOOL isCompleteVisible = !!(distance >= self.height);
        self.textLabel.text = isCompleteVisible? @"释放加载更多" : @"继续上拉以加载更多";
    }
}

- (void)setStatus:(RFPullToFetchIndicatorStatus)status {
    if (_status == status) return;
    _status = status;
    _dout_int(status)
    UILabel *label = self.textLabel;

    // 到底部了
    if (status == RFPullToFetchIndicatorStatusFrozen) {
        self.endLabel.hidden = NO;
        self.endView.hidden = NO;
        label.hidden = YES;
        return;
    }

    self.endLabel.hidden = YES;
    self.endView.hidden = YES;
    label.hidden = NO;
    switch (status) {
        case RFPullToFetchIndicatorStatusProcessing:
            label.text = @"正在加载...";
            return;

        case RFPullToFetchIndicatorStatusDecelerating:
            label.text = @"上拉加载更多";
            return;

        default:
            break;
    }
}

@end
