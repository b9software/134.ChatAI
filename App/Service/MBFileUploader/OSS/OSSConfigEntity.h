/*
 OSSConfigEntity
 MBOSSUploader
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBModel.h"

/**
 图片上传到 OSS 时需要的上传凭证
 
 STS 鉴权 https://help.aliyun.com/document_detail/32059.html

 根据具体项目按需修改键值
 */
@interface OSSConfigEntity : MBModel

@property NSString *bucket;

/// 形如 https://example.oss-cn-beijing.aliyuncs.com
@property NSString *host;

/// 形如 https://oss-cn-beijing.aliyuncs.com
@property (nonatomic) NSString *endpoint;

@property NSString *accessKeyId;
@property NSString *accessKeySecret;
@property NSString *securityToken;
// 未使用
@property NSString *expiration;

- (NSURL *)destinationURLWithObjectKey:(NSString *)objectKey;

@end
