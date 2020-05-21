
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import "UMModelCreate.h"
@interface RNDdverify : RCTEventEmitter <RCTBridgeModule>
+ (void)ddVerifySetVerifySDKInfo:(void (^_Nullable)( NSDictionary * _Nonnull Dic))complete;
+ (UMCustomModel * _Nonnull)buildCustomModel:(BOOL)isAlert;
@end
  
