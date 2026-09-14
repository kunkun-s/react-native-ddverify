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
#import <UIKit/UIKit.h>

@interface DDVerifyImpl ()

//getLoginTokenWithTimeout 传入的可选回调，与 RN_DDVERIFY_EVENT 事件内容一致
@property (nonatomic, copy, nullable) RCTResponseSenderBlock loginCallback;

@end

@implementation DDVerifyImpl

//授权页流程已结束的结果码。收到后释放本次调用的回调引用，避免长期持有 JS 侧闭包（页面卸载后无法回收）
+ (NSSet<NSString *> *)loginTerminalCodes {
    static NSSet<NSString *> *codes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        codes = [NSSet setWithObjects:@"600000", @"600002", @"600011", @"600013", @"600014", @"600015", @"700000", nil];
    });
    return codes;
}

+ (BOOL)isLoginTerminalCode:(id)code {
    if (code == nil) {
        return NO;
    }
    //resultCode 可能是字符串也可能是数字，统一转成字符串再比对
    return [[self loginTerminalCodes] containsObject:[NSString stringWithFormat:@"%@", code]];
}

/**
 取当前 keyWindow。
 iOS 13 起 keyWindow 已废弃，多 scene 场景下经常返回 nil，会让授权页拿不到宿主控制器；
 这里按 scene -> keyWindow -> delegate.window 逐级兜底，兼容各 iOS 版本。
 */
+ (UIWindow *)dd_keyWindow {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
            if (windowScene.windows.count > 0) {
                //该 scene 还没有 keyWindow（例如启动过程中），退回第一个窗口
                return windowScene.windows.firstObject;
            }
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //iOS 13 以下，以及上面都没取到时的兜底
    return [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
}

/**
 所有下发给 JS 的结果统一走这里：
 1. RN_DDVERIFY_EVENT 事件（保持原有行为，onVerifyEvent 监听）
 2. getLoginTokenWithTimeout 传入的可选回调（仅本次授权页流程有效）
 */
- (void)emitEvent:(NSDictionary *)body {
    NSDictionary *payload = body ?: @{};
    [self.delegate sendJSEventWithName:@"RN_DDVERIFY_EVENT" body:payload];

    RCTResponseSenderBlock callback = self.loginCallback;
    if (callback == nil) {
        return;
    }
    callback(@[payload]);
    if ([DDVerifyImpl isLoginTerminalCode:payload[@"resultCode"]]) {
        self.loginCallback = nil;
    }
}

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
    //检查当前环境是否可以认证或者可以一键登录。
    //这里必须传 newAuthType：原来写死传 UMPNSAuthTypeLoginToken，
    //导致请求"本机号码校验"环境时实际检测的是一键登录环境
    [UMCommonHandler checkEnvAvailableWithAuthType:newAuthType complete:^(NSDictionary * _Nullable resultDic) {
        //错误码
        if (blockResolve != nil) {
            blockResolve(resultDic);
            blockResolve = nil;
        }
    }];

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
                          params:(NSDictionary *)params
                        callback:(RCTResponseSenderBlock)callback{

    dispatch_async(dispatch_get_main_queue(), ^{
        //上一次授权页流程残留的回调先释放，避免回调到已经卸载的页面
        self.loginCallback = callback;
        UMCustomModel * newModel = [UMModelCreate createFullScreen:params clickBlock:^(NSDictionary * _Nonnull dic) {
            //这里是自定义按钮的回调
            [self emitEvent:dic];
        }];
        int n_timeout = 3;
        if (timeout) {
            n_timeout = [timeout intValue];
        }
        newModel.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        newModel.presentDirection = UMPNSPresentationDirectionBottom;
        [UMCommonHandler getLoginTokenWithTimeout: n_timeout controller:[DDVerifyImpl dd_keyWindow].rootViewController model:newModel complete:^(NSDictionary * _Nonnull resultDic) {
            if ( [@"700002" isEqual:[resultDic objectForKey:@"resultCode"]]  && ![[resultDic objectForKey:@"isChecked"] intValue]) {
                //没有勾选用户协议
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请勾选协议" message:@"阅读并勾选底部用户协议。" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                UIViewController *vc = [[UIApplication sharedApplication].delegate.window rootViewController];
                [vc presentViewController:alert animated:YES completion:nil];

            }
            //此处会多次调用
            [self emitEvent:resultDic];
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
            if (token.length == 0) {
                //token 为 nil 时 resolve(nil) 会让 RN 直接抛异常，这里按失败处理
                reject(@"-1",@"获取VerifyToken失败：token为空", nil);
            } else {
                resolve(token);
            }
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
