
#import "UIAnyGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation UIAnyGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateRecognized;
}

@end
