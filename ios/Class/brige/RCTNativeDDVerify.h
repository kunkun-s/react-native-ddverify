//
//  RCTNativeDDVerify.h
//  RNDdverify
//
//  Created by ddmobile on 2025/12/8.
//

#import <Foundation/Foundation.h>
#import "DDVerifyImpl.h"
#import <React/RCTEventEmitter.h>

#if RCT_NEW_ARCH_ENABLED
#import <NativeDDVerifySpec/NativeDDVerifySpec.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if RCT_NEW_ARCH_ENABLED
//新架构
@interface RCTNativeDDVerify : RCTEventEmitter<NativeDDVerifySpec, DDEventEmitterDelegate>
#else
//旧架构
@interface RCTNativeDDVerify : NSObject
#endif

@end

NS_ASSUME_NONNULL_END
