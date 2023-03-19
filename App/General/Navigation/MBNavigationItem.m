
#import "MBNavigationItem.h"

@interface MBNavigationItem ()
@property (nonatomic) UINavigationItem *orginalNavigationItem;
@end

@implementation MBNavigationItem

+ (void)applyNavigationItem:(UINavigationItem *)sorceItem toNavigationItem:(UINavigationItem *)destinationItem animated:(BOOL)animated {
    destinationItem.title = sorceItem.title;
    destinationItem.prompt = sorceItem.prompt;
    destinationItem.backBarButtonItem = sorceItem.backBarButtonItem;
    destinationItem.hidesBackButton = sorceItem.hidesBackButton;
    destinationItem.leftItemsSupplementBackButton = sorceItem.leftItemsSupplementBackButton;
    destinationItem.titleView = sorceItem.titleView;
    [destinationItem setLeftBarButtonItems:sorceItem.leftBarButtonItems animated:animated];
    [destinationItem setRightBarButtonItems:sorceItem.rightBarButtonItems animated:animated];
}

- (void)applyNavigationItem:(UINavigationItem *)navigationItem animated:(BOOL)animated {
    if (!navigationItem) return;
    if (!self.orginalNavigationItem) {
        UINavigationItem *item = [UINavigationItem new];
        [self.class applyNavigationItem:self toNavigationItem:item animated:NO];
        self.orginalNavigationItem = item;
    }

    [self.class applyNavigationItem:navigationItem toNavigationItem:self animated:animated];
}

- (void)restoreNavigationItemAnimated:(BOOL)animated {
    if (self.orginalNavigationItem) {
        [self.class applyNavigationItem:self.orginalNavigationItem toNavigationItem:self animated:animated];
    }
}

@end
