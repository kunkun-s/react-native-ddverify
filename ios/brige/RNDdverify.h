#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTBridge.h>
#import "DDVerifyImpl.h"

#if !RCT_NEW_ARCH_ENABLED
//旧框架
@interface RNDdverify : RCTEventEmitter <RCTBridgeModule, DDEventEmitterDelegate>
#else
//不注册桥，改为默认的空文件
@interface RNDdverify : NSObject

#endif
@end
  
