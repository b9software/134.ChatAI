
#import "MBTableViewPullToFetchControl.h"
#import <RFKit/UIView+RFKit.h>

@implementation MBTableViewPullToFetchControl
@dynamic headerContainer;
@dynamic footerContainer;

- (void)onInit {
    [super onInit];

    self.headerContainer = [MBRefreshHeaderView loadWithNibName:nil];

    MBRefreshFooterView *fv = [MBRefreshFooterView loadWithNibName:nil];
    self.footerContainer = fv;
    self.autoFetchWhenScroll = YES;
    self.autoFetchTolerateDistance = 100;
}

- (void)afterInit {
    [super afterInit];

    [self setHeaderStatusChangeBlock:^(RFTableViewPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView) {
        [indicatorView updateStatus:status distance:visibleHeight control:control];
    }];

    [self setFooterStatusChangeBlock:^(RFTableViewPullToFetchPlugin *control, id indicatorView, RFPullToFetchIndicatorStatus status, CGFloat visibleHeight, UITableView *tableView) {
        [indicatorView updateStatus:status distance:visibleHeight control:control];
    }];

    [self setNeedsDisplayHeader];
    [self setNeedsDisplayFooter];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
