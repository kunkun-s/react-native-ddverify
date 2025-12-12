
#import "RNDdverify.h"

@implementation RNDdverify

//+ (BOOL)requiresMainQueueSetup {
//  return YES;
//}

//设置单利模式 解决错误：Bridge is not set. This is probably because you've explicitly synthesized the bridge in RNDdverify, even though it's inherited from RCTEventEmitter
+(id)allocWithZone:(NSZone *)zone {
    static RNDdverify *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}
#if RCT_NEW_ARCH_ENABLED

#else
//旧的桥接架构
//- (dispatch_queue_t)methodQueue{
//  return dispatch_get_main_queue();
//}
- (void)sendJSEventWithName:(NSString *)name body:(id)body{
    [self sendEventWithName:name body:body];
}
- (NSArray<NSString *> *)supportedEvents
{
  return @[@"RN_DDVERIFY_EVENT"];
}

RCT_EXPORT_MODULE(RNDdverify);
//设置SDK秘钥 RCTPromiseResolveBlock 必须和RCTPromiseRejectBlock配对使用
RCT_REMAP_METHOD(setVerifySDKInfo, setVerifySDKInfo:(NSString *)info resolve:(RCTPromiseResolveBlock)Resolve rejecter:(RCTPromiseRejectBlock)reject){
    [[DDVerifyImpl sharedInstanceDelegate:self] setVerifySDKInfo:info resolve:Resolve reject:reject];
    
}
//检查认证环境
RCT_REMAP_METHOD(checkEnvAvailableWithAuthType, checkEnvAvailableWithAuthType:(NSString *)authType Resolve:(RCTPromiseResolveBlock)Resolve rejecter:(RCTPromiseRejectBlock)reject){
    [[DDVerifyImpl sharedInstanceDelegate:self] checkEnvAvailableWithAuthType:authType resolve:Resolve reject:reject];
    
}

//一键登录预取号
RCT_REMAP_METHOD(accelerateLoginPageWithTimeout, accelerateLoginPageWithTimeout:(RCTResponseSenderBlock)complete){
    [[DDVerifyImpl sharedInstanceDelegate:self] accelerateLoginPageWithTimeout:complete];
   
}
//一键登录获取
RCT_REMAP_METHOD(getLoginTokenWithTimeout, getLoginTokenWithTimeout:(NSString *)timeout params:(NSDictionary *)params){
    [[DDVerifyImpl sharedInstanceDelegate:self] getLoginTokenWithTimeout:timeout params:params];
}
//本机号码校验
RCT_REMAP_METHOD(getVerifyToken, getVerifyTokenWithTimeout:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject){
    [[DDVerifyImpl sharedInstanceDelegate:self] getVerifyToken:resolve reject:reject];
}
//关闭一键登录登录界面
RCT_REMAP_METHOD(cancelLoginVCAnimated, cancelLoginVCAnimated){
    [[DDVerifyImpl sharedInstanceDelegate:self] cancelLoginVCAnimated];
    
}
#endif




@end
  
