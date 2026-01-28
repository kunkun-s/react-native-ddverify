//
//  DDVerifyImpl.m
//  RNDdverify
//
//  Created by ddmobile on 2025/12/8.
//

#import "DDVerifyImpl.h"
#import <UMVerify/UMVerify.h>
#import "UMModelCreate.h"
#import <React/RCTBridgeModule.h>

@implementation DDVerifyImpl
+ (instancetype)sharedInstanceDelegate:(id<DDEventEmitterDelegate>)delegate {
    static DDVerifyImpl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        // 可以在这里进行初始化配置
    });
    sharedInstance.delegate = delegate;
    return sharedInstance;
}
//设置SDK秘钥 RCTPromiseResolveBlock 必须和RCTPromiseRejectBlock配对使用
- (void)setVerifySDKInfo:(NSString *)info
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject{
    __block RCTPromiseResolveBlock blockResolve = resolve;
    [UMCommonHandler setVerifySDKInfo:info complete:^(NSDictionary * _Nonnull resultDic) {
        //是否调注册用成功
        if (blockResolve != nil) {
            blockResolve(resultDic);
            blockResolve = nil;
        }
    }];
    
}
//检查认证环境
- (void)checkEnvAvailableWithAuthType:(NSString *)authType
                              resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject{
    
    UMPNSAuthType newAuthType = UMPNSAuthTypeLoginToken;
    
    if ([@"UMPNSAuthTypeLoginToken" isEqualToString:authType]) {
        newAuthType = UMPNSAuthTypeLoginToken;
        
    }else if([@"UMPNSAuthTypeVerifyToken" isEqual:authType]){
        newAuthType = UMPNSAuthTypeVerifyToken;
        
    }
    __block RCTPromiseResolveBlock blockResolve = resolve;
    //检查当前环境是否可以认证或者可以一键登录
    if (newAuthType == UMPNSAuthTypeLoginToken || newAuthType == UMPNSAuthTypeVerifyToken) {
      [UMCommonHandler checkEnvAvailableWithAuthType:UMPNSAuthTypeLoginToken complete:^(NSDictionary * _Nullable resultDic) {
            //错误码
          if (blockResolve != nil) {
              blockResolve(resultDic);
              blockResolve = nil;
          }
          
        }];
    }else {
        //类型不对，直接按照不能使用处理
        if (blockResolve != nil) {
            blockResolve(@{@"resultCode": @"0", @"msg": @"请设置正确的AuthType"});
            blockResolve = nil;
        }
        
    }

}
//一键登录预取号
- (void)accelerateLoginPageWithTimeout:(RCTResponseSenderBlock)callback{
    __block RCTResponseSenderBlock blockComplete = callback;
    [UMCommonHandler accelerateLoginPageWithTimeout:8 complete:^(NSDictionary * _Nonnull resultDic) {
        
        //这里返回给js端是否预约成功
        if (blockComplete != nil) {
            blockComplete(@[resultDic]);
            blockComplete = nil;
        }
        
    }];
}
//一键登录获取
- (void)getLoginTokenWithTimeout:(NSString *)timeout
                          params:(NSDictionary *)params{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UMCustomModel * newModel = [UMModelCreate createFullScreen:params clickBlock:^(NSDictionary * _Nonnull dic) {
            //这里是自定义按钮的回调
            [self.delegate sendJSEventWithName:@"RN_DDVERIFY_EVENT" body:dic];
        }];
        int n_timeout = 3;
        if (timeout) {
            n_timeout = [timeout intValue];
        }
        newModel.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        newModel.presentDirection = UMPNSPresentationDirectionBottom;
        [UMCommonHandler getLoginTokenWithTimeout: n_timeout controller:[UIApplication sharedApplication].keyWindow.rootViewController model:newModel complete:^(NSDictionary * _Nonnull resultDic) {
            if ( [@"700002" isEqual:[resultDic objectForKey:@"resultCode"]]  && ![[resultDic objectForKey:@"isChecked"] intValue]) {
                //没有勾选用户协议
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请勾选协议" message:@"阅读并勾选底部用户协议。" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                UIViewController *vc = [[UIApplication sharedApplication].delegate.window rootViewController];
                [vc presentViewController:alert animated:YES completion:nil];
            
            }
            //此处会多次调用
            [self.delegate sendJSEventWithName:@"RN_DDVERIFY_EVENT" body:resultDic];
        }];
    });

}
//本机号码校验
- (void)getVerifyToken:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject{
    [UMCommonHandler getVerifyTokenWithTimeout:3 complete:^(NSDictionary * _Nonnull resultDic) {
        if ([PNSCodeSuccess isEqualToString:[resultDic objectForKey:@"resultCode"]] == NO) {
            //获取VerifyToken 失败
            reject(@"-1",@"获取VerifyToken失败", nil);
        } else {
            //2. 去服务器验证 VerifyToken
            NSString *token = [resultDic objectForKey:@"token"];
            resolve(token);
        }
    }];
}
//关闭一键登录登录界面
- (void)cancelLoginVCAnimated{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UMCommonHandler cancelLoginVCAnimated:YES complete:nil];
    });
}
@end
