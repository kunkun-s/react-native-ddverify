//
//  DDVerifyImpl.h
//  RNDdverify
//
//  Created by ddmobile on 2025/12/8.
//

#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN
// TaskManager.h - 定义协议
@protocol DDEventEmitterDelegate <NSObject>

@required  // 必需实现的方法
- (void)sendJSEventWithName:(NSString *)name body:(NSDictionary*)body;

@end

@interface DDVerifyImpl : NSObject

// 弱引用委托对象，避免循环引用
@property (nonatomic, weak) id<DDEventEmitterDelegate> delegate;

+ (instancetype)sharedInstanceDelegate:(id<DDEventEmitterDelegate>)delegate;

- (void)setVerifySDKInfo:(NSString *)info
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject;
- (void)checkEnvAvailableWithAuthType:(NSString *)authType
                              resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject;
- (void)accelerateLoginPageWithTimeout:(RCTResponseSenderBlock)callback;
- (void)getLoginTokenWithTimeout:(NSString *)timeout
                          params:(NSDictionary *)params;
- (void)getVerifyToken:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject;
- (void)cancelLoginVCAnimated;
@end

NS_ASSUME_NONNULL_END
