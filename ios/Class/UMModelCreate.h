//
//  UMModel.h
//
//

#import <Foundation/Foundation.h>
#import <UMVerify/UMVerify.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMModelCreate : NSObject


/// 创建全屏的model
+ (UMCustomModel *)createFullScreen:(NSDictionary *)params clickBlock:(void (^_Nullable)(NSDictionary * _Nonnull dic))clickBlock;

@end

NS_ASSUME_NONNULL_END
