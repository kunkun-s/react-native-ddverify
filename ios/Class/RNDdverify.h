#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTBridge.h>

@class UMCustomModel;
@interface RNDdverify : RCTEventEmitter <RCTBridgeModule>
+ (void)ddVerifySetVerifySDKInfo:(void (^_Nullable)( NSDictionary * _Nonnull Dic))complete;
+ (UMCustomModel * _Nonnull)buildCustomModel:(BOOL)isAlert params:(NSDictionary *_Nonnull)params clickBlock:(void (^_Nullable)(NSDictionary * _Nonnull dic))clickBlock;
@end
  
