
#import "RNDdverify.h"
#import <UMVerify/UMVerify.h>

@implementation RNDdverify

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

+ (void)ddVerifySetVerifySDKInfo:(void (^_Nullable)( NSDictionary * _Nonnull Dic))complete{
 NSString *info = @"2itUZoze3p8lAe1f2CxYWjFuButzB5NId7veWo3g0K2eQ7KP/lpp8ua//fdTMraYXv1ExrFBKh/xOnJpSk9Jv18mpRaaHyuUrefTWdLYTezqyGI2+eVKtd1VUlLX+X2oglQUQlx+hgS65J8aP2NeRV93ex4wIWzvY5XAxwcNrpnqrVpddU+vRmXOOhE0rEfNv8ka4Ht1fpuyd+j0zWLtQyc+1Edm7k3Tt1OwUqiFyBzcnWhBVe0eBg==";
    [UMCommonHandler setVerifySDKInfo:info complete:^(NSDictionary * _Nonnull resultDic) {
        //是否调注册用成功
        complete(resultDic);
    }];
}

+ (UMCustomModel *)buildCustomModel:(BOOL)isAlert {
    if (isAlert) {
        return [UMModelCreate createAlert];
    } else {
        return [UMModelCreate createFullScreen];
    }
}
- (NSArray<NSString *> *)supportedEvents
{
  return @[@"RN_DDVERIFY_EVENT"];
}
RCT_EXPORT_MODULE(RNDdverify);
//设置SDK秘钥 RCTPromiseResolveBlock 必须和RCTPromiseRejectBlock配对使用
RCT_REMAP_METHOD(setVerifySDKInfo, setVerifySDKInfoResolve:(RCTPromiseResolveBlock)Resolve rejecter:(RCTPromiseRejectBlock)reject){
    
    [RNDdverify ddVerifySetVerifySDKInfo:^(NSDictionary * _Nonnull Dic) {
        if([@"600000" isEqual:[Dic objectForKey:@"resultCode"]]){
            //密钥解析成功
            Resolve(@{@"resultCode": @"1", @"msg": [Dic objectForKey:@"msg"]});
        }else{
            Resolve(@{@"resultCode": @"0", @"msg": @"解密失败"});
        }
        
    }];
}
//检查认证环境
RCT_REMAP_METHOD(checkEnvAvailableWithAuthType, checkEnvAvailableWithAuthType:(NSString *)authType Resolve:(RCTPromiseResolveBlock)Resolve rejecter:(RCTPromiseRejectBlock)reject){
    
    UMPNSAuthType newAuthType = UMPNSAuthTypeLoginToken;
    
    if ([@"UMPNSAuthTypeLoginToken" isEqualToString:authType]) {
        newAuthType = UMPNSAuthTypeLoginToken;
        
    }else if([@"UMPNSAuthTypeVerifyToken" isEqual:authType]){
        newAuthType = UMPNSAuthTypeVerifyToken;
        
    }

    //检查当前环境是否可以认证或者可以一键登录
    if (newAuthType == UMPNSAuthTypeLoginToken || newAuthType == UMPNSAuthTypeVerifyToken) {
      [UMCommonHandler checkEnvAvailableWithAuthType:UMPNSAuthTypeLoginToken complete:^(NSDictionary * _Nullable resultDic) {
            //错误码
          if([@"600000" isEqual:[resultDic objectForKey:@"resultCode"]]){
              Resolve(@{@"resultCode": @"1", @"msg": @"环境验证通过"});
          }else{
              Resolve(@{@"resultCode": @"0", @"msg": @"环境不可用"});
          }
          
        }];
    }else {
        //类型不对，直接按照不能使用处理
        Resolve(@{@"resultCode": @"0", @"msg": @"请设置正确的AuthType"});
    }

}
//获取UMVerify版本号
RCT_REMAP_METHOD(getVersion, getVersion:(RCTResponseSenderBlock)complete){
    
    if (complete) {
        complete(@[[UMCommonHandler getVersion]]);
    }
}
//一键登录预取号
RCT_REMAP_METHOD(accelerateLoginPageWithTimeout, accelerateLoginPageWithTimeout:(NSTimeInterval)timeout complete:(RCTResponseSenderBlock)complete){
    [UMCommonHandler accelerateLoginPageWithTimeout:timeout complete:^(NSDictionary * _Nonnull resultDic) {
        NSLog(@"%@",[resultDic objectForKey:@"resultCode"]);
        //这里返回给js端是否预约成功
    }];
}
//一键登录获取
RCT_REMAP_METHOD(getLoginTokenWithTimeout, getLoginTokenWithTimeout:(NSString *)timeout Resolve:(RCTPromiseResolveBlock)Resolve rejecter:(RCTPromiseRejectBlock)reject){
    UMCustomModel * newModel = [RNDdverify buildCustomModel:NO];
       newModel.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
   

    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview: rootViewController.view];
    [UMCommonHandler getLoginTokenWithTimeout: 3 controller:rootViewController model:newModel complete:^(NSDictionary * _Nonnull resultDic) {
        Resolve(resultDic);
    }];
    
}
//隐藏授权时关闭
RCT_REMAP_METHOD(hideLoginLoading, hideLoginLoading){
  
}
//一键登录注销登录界面
RCT_REMAP_METHOD(cancelLoginVCAnimated, cancelLoginVCAnimated:(BOOL)flag complete:(void (^_Nullable)  (void))complete){
  
}
@end
  
