
#import "OSSConfigEntity.h"
#import <RFKit/NSArray+RFKit.h>

@implementation OSSConfigEntity

- (NSString *)endpoint {
    if (_endpoint) return _endpoint;
    NSArray<NSString *> *part = [self.host componentsSeparatedByString:@"."];
    // 取后三
    _endpoint = [NSString.alloc initWithFormat:@"https://%@", [[part rf_subarrayWithRangeLocation:-1 length:-3] componentsJoinedByString:@"."]];
    return _endpoint;
}

- (NSURL *)destinationURLWithObjectKey:(NSString *)objectKey {
    NSString *url = [NSString stringWithFormat:@"%@/%@", self.host, objectKey];
    return [NSURL URLWithString:url];
}

@end
