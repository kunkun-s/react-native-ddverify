//
//  RCTNativeDDVerify.m
//  RNDdverify
//
//  Created by ddmobile on 2025/12/8.
//

#import "RCTNativeDDVerify.h"

@implementation RCTNativeDDVerify

#ifdef RCT_NEW_ARCH_ENABLED
//新架构
RCT_EXPORT_MODULE(NativeDDVerify)
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    NSLog(@"[RNDdverify] 创建 TurboModule JSI 实例");
    return std::make_shared<facebook::react::NativeDDVerifySpecJSI>(params);
}
- (void)sendJSEventWithName:(NSString *)name body:(NSDictionary*)body{
//CodegenTypes.EventEmitter ->    "RN_DDVERIFY_EVENT"
    [self emitOnVerifyEvent:@{@"key":name,@"value":body}];
}
// 必须添加这个方法，否则新架构下模块不会被正确识别
+ (BOOL)requiresMainQueueSetup {
    return YES;
}
#endif


- (void)setVerifySDKInfo:(NSString *)info
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject{
    
    [[DDVerifyImpl sharedInstanceDelegate:self] setVerifySDKInfo:info resolve:resolve reject:reject];
}
- (void)checkEnvAvailableWithAuthType:(NSString *)authType
                              resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject{
    [[DDVerifyImpl sharedInstanceDelegate:self] checkEnvAvailableWithAuthType:authType resolve:resolve reject:reject];
}
- (void)accelerateLoginPageWithTimeout:(RCTResponseSenderBlock)callback{
    [[DDVerifyImpl sharedInstanceDelegate:self] accelerateLoginPageWithTimeout:callback];
}
- (void)getLoginTokenWithTimeout:(NSString *)timeout
                          params:(NSDictionary *)params{
    [[DDVerifyImpl sharedInstanceDelegate:self] getLoginTokenWithTimeout:timeout params:params];
}
- (void)getVerifyToken:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject{
    [[DDVerifyImpl sharedInstanceDelegate:self] getVerifyToken:resolve reject:reject];
}
- (void)cancelLoginVCAnimated{
    [[DDVerifyImpl sharedInstanceDelegate:self] cancelLoginVCAnimated];
}




@end
