
#import "RNDdverify.h"
#import <UMVerify/UMVerify.h>
#import "UMModelCreate.h"
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
+ (void)ddVerifySetVerifySDKInfo:(NSString *)info complete:(void (^_Nullable)( NSDictionary * _Nonnull Dic))complete{
   
    [UMCommonHandler setVerifySDKInfo:info complete:^(NSDictionary * _Nonnull resultDic) {
        //是否调注册用成功
        complete(resultDic);
    }];
}

+ (UMCustomModel *)buildCustomModel:(BOOL)isAlert params:(NSDictionary *)params clickBlock:(void (^_Nullable)(NSDictionary * _Nonnull dic))clickBlock {
    
    return [UMModelCreate createFullScreen:params clickBlock:clickBlock];
    
}
//- (dispatch_queue_t)methodQueue{
//  return dispatch_get_main_queue();
//}
- (NSArray<NSString *> *)supportedEvents
{
  return @[@"RN_DDVERIFY_EVENT"];
}
RCT_EXPORT_MODULE(RNDdverify);
//设置SDK秘钥 RCTPromiseResolveBlock 必须和RCTPromiseRejectBlock配对使用
RCT_REMAP_METHOD(setVerifySDKInfo, setVerifySDKInfo:(NSString *)info resolve:(RCTPromiseResolveBlock)Resolve rejecter:(RCTPromiseRejectBlock)reject){
    __block RCTPromiseResolveBlock blockResolve = Resolve;
    [RNDdverify ddVerifySetVerifySDKInfo:info complete:^(NSDictionary * _Nonnull Dic) {
        
        if (blockResolve != nil) {
            blockResolve(Dic);
            blockResolve = nil;
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
    __block RCTPromiseResolveBlock blockResolve = Resolve;
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
//获取UMVerify版本号
RCT_REMAP_METHOD(getVersion, getVersion:(RCTResponseSenderBlock)complete){
    
    if (complete != nil) {
        complete(@[[UMCommonHandler getVersion]]);
        complete = nil;
    }
}
//一键登录预取号
RCT_REMAP_METHOD(accelerateLoginPageWithTimeout, accelerateLoginPageWithTimeout:(RCTResponseSenderBlock)complete){
    __block RCTResponseSenderBlock blockComplete = complete;
    [UMCommonHandler accelerateLoginPageWithTimeout:8 complete:^(NSDictionary * _Nonnull resultDic) {
        
        //这里返回给js端是否预约成功
        if (blockComplete != nil) {
            blockComplete(@[resultDic]);
            blockComplete = nil;
        }
        
    }];
}
//一键登录获取
RCT_REMAP_METHOD(getLoginTokenWithTimeout, getLoginTokenWithTimeout:(NSString *)timeout params:(NSDictionary *)params){
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UMCustomModel * newModel = [RNDdverify buildCustomModel:NO params:params clickBlock:^(NSDictionary * _Nonnull dic) {
            //这里是自定义按钮的回调
            [self sendEventWithName:@"RN_DDVERIFY_EVENT" body:dic];
        }];
        
        newModel.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        newModel.presentDirection = UMPNSPresentationDirectionBottom;
        [UMCommonHandler getLoginTokenWithTimeout: 3 controller:[UIApplication sharedApplication].keyWindow.rootViewController model:newModel complete:^(NSDictionary * _Nonnull resultDic) {
            if ( [@"700002" isEqual:[resultDic objectForKey:@"resultCode"]]  && ![[resultDic objectForKey:@"isChecked"] intValue]) {
                //没有勾选用户协议
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"请勾选协议" message:@"阅读并勾选底部用户协议。" delegate:NULL cancelButtonTitle:@"确定" otherButtonTitles: nil];
               
                // 显示
                [alert show];
            }
            //此处会多次调用
            [self sendEventWithName:@"RN_DDVERIFY_EVENT" body:resultDic];
        }];
    });

}

//隐藏授权时关闭
RCT_REMAP_METHOD(hideLoginLoading, hideLoginLoading){
    [self sendEventWithName:@"" body:nil];
}
//关闭一键登录登录界面
RCT_REMAP_METHOD(cancelLoginVCAnimated, cancelLoginVCAnimated){
    dispatch_async(dispatch_get_main_queue(), ^{
        [UMCommonHandler cancelLoginVCAnimated:YES complete:nil];
    });
}
//判断设备蜂窝网络是否开启
RCT_REMAP_METHOD(checkDeviceCellularDataEnable, checkDeviceCellularDataEnable:(RCTResponseSenderBlock)complete){
    if (complete != nil) {
        NSString * type = [UMCommonUtils checkDeviceCellularDataEnable] ? @"1" : @"0";
        complete(@[type]);
        complete = nil;
    }
}

//获取当前上网卡运营商名称中国移动，中国联通，中国电信等
RCT_REMAP_METHOD(getCurrentCarrierName, getCurrentCarrierName:(RCTResponseSenderBlock)complete){
    if (complete != nil) {
           NSString * type = [UMCommonUtils getCurrentCarrierName];
           complete(@[type]);
           complete = nil;
       }
}

@end
  
