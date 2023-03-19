
#import "CALayer+MBAnimationPersistence.h"
#import <UIKit/UIKit.h>
#import <RFAlpha/RFSynthesizeCategoryProperty.h>

/// TechNote QA1673 - How to pause the animation of a layer tree
/// @see https://developer.apple.com/library/ios/qa/qa1673/_index.html
static void MBPauseLayer(CALayer *layer) {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

static void MBResumeLayer(CALayer *layer) {
    CFTimeInterval pausedTime = layer.timeOffset;
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

@interface MBPersistentAnimationContainer : NSObject
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, copy) NSArray<NSString *> *persistentAnimationKeys;
@property (nonatomic, readonly, strong) NSMutableDictionary<NSString *, CAAnimation *> *persistedAnimations;
@property (nonatomic) BOOL notificationRegistering;
@end

@implementation MBPersistentAnimationContainer

#pragma mark - Lifecycle

- (id)initWithLayer:(CALayer *)layer {
	self = [super init];
	if (self) {
		_layer = layer;
        _persistedAnimations = [NSMutableDictionary dictionaryWithCapacity:10];
	}
	return self;
}

- (void)dealloc {
    self.notificationRegistering = NO;
}

#pragma mark - Keys

- (void)setPersistentAnimationKeys:(NSArray *)persistentAnimationKeys {
	if (persistentAnimationKeys != _persistentAnimationKeys) {
		if (_persistentAnimationKeys) {
            self.notificationRegistering = NO;
		}
        else if (persistentAnimationKeys) {
            self.notificationRegistering = YES;
            [self persistAnimationWithKeys:persistentAnimationKeys];
        }
        _persistentAnimationKeys = persistentAnimationKeys;
	}
}

#pragma mark - Persistence

- (void)persistAnimationWithKeys:(NSArray *)keys {
    [self.persistedAnimations removeAllObjects];
    CALayer *layer = self.layer;
    for (NSString *key in keys) {
        CAAnimation *animation = [layer animationForKey:key];
        if (animation) {
            self.persistedAnimations[key] = animation;
        }
    }
}

- (void)restoreLayerAnimations {
    CALayer *layer = self.layer;
    if (!layer) {
        return;
    }
    [self.persistedAnimations enumerateKeysAndObjectsUsingBlock:^(NSString *key, CAAnimation *animation, BOOL *stop) {
        if ([layer animationForKey:key]) return;
        [layer addAnimation:animation forKey:key];
    }];
}

#pragma mark - Notifications

- (void)setNotificationRegistering:(BOOL)notificationRegistering {
    if (_notificationRegistering != notificationRegistering) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        if (_notificationRegistering) {
            [nc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
            [nc removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        }
        _notificationRegistering = notificationRegistering;
        if (notificationRegistering) {
            [nc addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [nc addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
    }
}

- (void)applicationDidEnterBackground {
    MBPauseLayer(self.layer);
}

- (void)applicationWillEnterForeground {
    [self restoreLayerAnimations];
    MBResumeLayer(self.layer);
}

@end


@interface CALayer (MBAnimationPersistencePrivate)
@property (nonatomic, strong) MBPersistentAnimationContainer *MBPersistentAnimationContainer;
@end

@implementation CALayer (MBAnimationPersistence)
RFSynthesizeCategoryObjectProperty(MBPersistentAnimationContainer, setMBPersistentAnimationContainer, MBPersistentAnimationContainer *, OBJC_ASSOCIATION_RETAIN_NONATOMIC)

- (NSArray *)MBPersistentAnimationKeys {
    return self.MBPersistentAnimationContainer.persistentAnimationKeys;
}

- (void)setMBPersistentAnimationKeys:(NSArray<NSString *> *)persistentAnimationKeys {
    if (!persistentAnimationKeys) {
        // set nil to reset
        self.MBPersistentAnimationContainer = nil;
        return;
    }
    MBPersistentAnimationContainer *container = self.MBPersistentAnimationContainer;
    if (!container) {
        container = [[MBPersistentAnimationContainer alloc] initWithLayer:self];
        self.MBPersistentAnimationContainer = container;
    }
    container.persistentAnimationKeys = persistentAnimationKeys;
}

- (void)MBPersistCurrentAnimations {
    self.MBPersistentAnimationKeys = self.animationKeys;
}

- (void)MBResumePersistentAnimationsIfNeeded {
    if (!self.MBPersistentAnimationKeys.count) return;
    [self.MBPersistentAnimationContainer restoreLayerAnimations];
}

@end
