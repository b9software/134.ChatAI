
#import "MBStateMachineView.h"
#import <RFKit/UIView+RFKit.h>

@interface MBStateMachineView ()
@property (nonatomic, strong) NSHashTable<id<MBStateMachineViewDelegate>> *delegates;
@property (nonatomic, weak) UIView *contentView;
@end

@implementation MBStateMachineView
RFInitializingRootForUIView

- (void)onInit {
    // Initialization code
}

- (void)afterInit {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.viewSource) {
        for (UIView<MBStateMachineViewIdentifying> *subView in self.subviews) {
            if (![subView respondsToSelector:@selector(stateIdentifier)]) continue;

            if ([self.state isEqualToString:subView.stateIdentifier]) {
                subView.hidden = NO;
            }
            else {
                subView.hidden = YES;
            }
        }
    }
}

- (NSHashTable *)delegates {
    if (_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)addDelegate:(nullable id<MBStateMachineViewDelegate>)aDelegate {
    [self.delegates addObject:aDelegate];
}

- (void)removeDelegate:(id<MBStateMachineViewDelegate>)aDelegate {
    [self.delegates removeObject:aDelegate];
}

- (void)setState:(NSString *)state {
    [self stateChangedFromState:_state toState:state];
    _state = state;
}

- (UIView<MBStateMachineViewIdentifying> *)viewForState:(NSString *)state {
    id viewSource = self.viewSource;
    if (viewSource) {
        NSString *newViewSelector = [NSString stringWithFormat:@"viewFor%@", state];
        id view = [viewSource valueForKey:newViewSelector];
        NSAssert(!view || [view isKindOfClass:[UIView class]], @"%@ not a UIView", newViewSelector);
        return view;
    }

    for (UIView<MBStateMachineViewIdentifying> *subView in self.subviews) {
        if ([subView respondsToSelector:@selector(stateIdentifier)]
            && [state isEqualToString:subView.stateIdentifier]) {
            return subView;
        }
    }
    return nil;
}

- (void)stateChangedFromState:(nullable NSString *)oldStats toState:(nullable NSString *)newState {
    id viewSource = self.viewSource;

    if (![oldStats isEqualToString:newState]
        && newState) {
        UIView *oldView = self.contentView;
        UIView<MBStateMachineViewIdentifying> *newView = [self viewForState:newState];

        if (oldView != newView) {
            if (viewSource) {
                [oldView removeFromSuperview];
                [self addSubview:newView resizeOption:RFViewResizeOptionFill];
                newView.autoresizingMask = UIViewAutoresizingFlexibleSize;
            }
            else {
                oldView.hidden = YES;
                if ([newView respondsToSelector:@selector(dontResizeWhenStateChanged)]
                    && newView.dontResizeWhenStateChanged) {

                }
                else {
                    newView.frame = self.bounds;
                }
                newView.hidden = NO;
            }
            self.contentView = newView;
        }
    }
    self.hidden = !newState;

    for (id<MBStateMachineViewDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(stateMachineView:didChangedStateFromState:toState:)]) {
            [delegate stateMachineView:self didChangedStateFromState:oldStats toState:newState];
        }
    }
}

@end


@implementation MBStateMachineSubview

@end

