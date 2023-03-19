
#import "MBPageScrollView.h"
#import <RFKit/UIView+RFAnimate.h>

@implementation MBPageScrollView {
    NSInteger _page;
}
@dynamic page;
@dynamic totalPage;
RFInitializingRootForUIView

- (void)onInit {
    self.pagingEnabled = YES;
}

- (void)afterInit {

}

- (void)dealloc {
    self.delegate = nil;
}

- (void)setBounds:(CGRect)bounds {
    CGFloat oldWidth = self.width;
    CGFloat newWidth = CGRectGetWidth(bounds);
    NSUInteger page = self.page;

    _dout_debug(@"Update bounds: %@", NSStringFromCGRect(bounds))
    [super setBounds:bounds];

    if (oldWidth == newWidth) return;
    if (self.isDragging) return;

    self.contentOffset = CGPointMake(page * newWidth, self.contentOffset.y);
}

#pragma mark - Page

+ (NSSet *)keyPathsForValuesAffectingPage {
    return [NSSet setWithObject:@keypathClassInstance(MBPageScrollView, contentOffset)];
}

- (NSInteger)page {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width > 0) {
        return self.contentOffset.x / width + 0.5;
    }
    return -1;
}

- (void)setPage:(NSInteger)page {
    [self setPage:page animated:NO];
}

- (void)setPage:(NSInteger)page animated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = page * self.width;
    [self setContentOffset:offset animated:animated];
    _dout_size(self.contentSize)
    _dout_point(self.contentOffset)
    if (self.contentSize.width == 0) {
        _page = page;
    }
}

- (NSInteger)totalPage {
    return self.contentSize.width / self.width;
}

- (void)setContentSize:(CGSize)contentSize {
    BOOL shouldRestorePageSetting = (_page && self.contentSize.width == 0 && contentSize.width > 0);
    [super setContentSize:contentSize];
    if (shouldRestorePageSetting) {
//        dispatch_after_seconds(0, ^{
            [self setPage:_page];
            _page = 0;
//        });
    }
}

@end

@implementation UIScrollView (MBPageScrolling)

- (NSInteger)MBPage {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width > 0) {
        return self.contentOffset.x / width + 0.5;
    }
    return 0;
}

- (void)MBSetPage:(NSInteger)page animated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = page * self.width;
    [self setContentOffset:offset animated:animated];
}

@end
