
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "UMModelCreate.h"
@interface RNDdverify : RCTEventEmitter <RCTBridgeModule>
+ (void)setVerifySDKInfo;
+ (UMCustomModel *)buildCustomModel:(BOOL)isAlert;
@end
  
