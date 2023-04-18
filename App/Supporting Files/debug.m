
#import <Foundation/Foundation.h>

void DebugLog(BOOL fatal, NSString *_Nullable recordID, NSString *_Nonnull format, ...) {
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

BOOL RFAssertKindOfClass(id obj, Class aClass) {
    return YES;
}
