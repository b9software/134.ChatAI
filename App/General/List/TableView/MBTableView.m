
#import "MBTableView.h"
#import "Common.h"
#import "MBRefreshFooterView.h"
#import <RFKit/UIResponder+RFKit.h>

@interface MBTableView ()
@property (nonatomic) MBTableViewDataSource *trueDataSource;
@end

@implementation MBTableView
@dynamic delegate;
RFInitializingRootForUIView

- (void)onInit {
    self.trueDataSource = [MBTableViewDataSource new];
    self.trueDataSource.tableView = self;
    [super setDataSource:self.trueDataSource];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)afterInit {
    [self pullToFetchController];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *ev = self.outerEmptyView;
    if (ev) {
        self.outerEmptyView = nil;
        self.pullToFetchController.footerContainer.outerEmptyView = ev;
        self.pullToFetchController.footerContainer.emptyLabel.text = nil;
    }
}

- (void)dealloc {
    [super setDataSource:nil];
    [super setDelegate:nil];
}

- (MBTableViewPullToFetchControl *)pullToFetchController {
    if (!_pullToFetchController) {
        _pullToFetchController = ({
            MBTableViewPullToFetchControl *control = [[MBTableViewPullToFetchControl alloc] init];
            control.shouldScrollToTopWhenHeaderEventTrigged = YES;
            control.tableView = self;

            @weakify(self);
            [control setHeaderProcessBlock:^{
                @strongify(self);
                [self fetchItemsWithPageFlag:NO];
            }];

            [control setFooterProcessBlock:^{
                @strongify(self);
                NSInteger startPage = MBListDataSource.defualtPageStartZero ? -1 : 0;
                [self fetchItemsWithPageFlag:(self.dataSource.page != startPage)];
            }];
            
            control;
        });
    }
    return _pullToFetchController;
}

- (void)fetchItemsWithPageFlag:(BOOL)nextPage {
    __block BOOL success = NO;
    @weakify(self);
    [self.dataSource fetchItemsFromViewController:self.viewController nextPage:nextPage success:^(MBListDataSource *dateSource, NSArray *fetchedItems) {
        @strongify(self);
        if (!nextPage) {
            MBRefreshFooterView *fv = (id)self.pullToFetchController.footerContainer;
            fv.empty = dateSource.empty;
            MBRefreshHeaderView *hv = (id)self.pullToFetchController.headerContainer;
            hv.empty = dateSource.empty;
        }
        self.pullToFetchController.footerReachEnd = dateSource.pageEnd;
        success = YES;
    } completion:^(MBTableViewDataSource *dateSource) {
        @strongify(self);
        self.pullToFetchController.autoFetchWhenScroll = success;
        [self.pullToFetchController markProcessFinshed];
        if (self.fetchPageEnd) {
            self.fetchPageEnd(nextPage, dateSource);
        }
    }];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        if (self.autoFetchWhenMoveToWindow
            && !self.dataSource.hasSuccessFetched
            && !self.dataSource.fetching) {
            [self.pullToFetchController triggerHeaderProcess];
        }
        else {
            [self.pullToFetchController setNeedsDisplayHeader];
        }
    }
}

- (void)removeItem:(id)item withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *ip = [self.dataSource indexPathForItem:item];
    if (ip) {
        [self.dataSource.items removeObjectAtIndex:ip.row];
        [self deleteRowsAtIndexPaths:@[ ip ] withRowAnimation:animation];
    }
}

- (void)prepareForReuse {
    [self.dataSource prepareForReuse];
    if (self.pullToFetchController.fetching) {
        [self.pullToFetchController markProcessFinshed];
    }
    self.pullToFetchController.footerReachEnd = NO;
    [self reloadData];
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    if (self.dataSource.empty && !self.pullToFetchController.footerContainer.empty) {
        self.pullToFetchController.footerContainer.empty = YES;
        self.pullToFetchController.headerContainer.empty = YES;
    }
}

- (void)insertRowsWithRowRange:(NSRange)range inSection:(NSInteger)section rowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *indexPathes = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = 0; i < range.length; i++) {
        [indexPathes addObject:[NSIndexPath indexPathForRow:range.location + i inSection:section]];
    }
    [self insertRowsAtIndexPaths:indexPathes withRowAnimation:animation];
}

- (void)deleteRowsWithRowRange:(NSRange)range inSection:(NSInteger)section rowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *indexPathes = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = 0; i < range.length; i++) {
        [indexPathes addObject:[NSIndexPath indexPathForRow:range.location + i inSection:section]];
    }
    [self deleteRowsAtIndexPaths:indexPathes withRowAnimation:animation];
}

#pragma mark - DataSource Forward

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    self.trueDataSource.delegate = dataSource;

    // 视图释放时可能会调置空方法，此时不调 super
    if (!dataSource) return;
    // iOS 9 之后会缓存 delegate 响应方法的结果，需要重置刷新
    [super setDataSource:nil];
    [super setDataSource:self.trueDataSource];
}

- (id<UITableViewDataSource>)dataSource {
    return self.trueDataSource;
}

@end
