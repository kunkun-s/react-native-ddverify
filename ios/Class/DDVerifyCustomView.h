//
//  DDVerifyCustomView.h
//  RNDdverify
//
//  Created by 坤坤 on 2020/5/22.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDVerifyCustomView : UIView

@property (weak, nonatomic) IBOutlet UIButton *wxLoginBtn;
@property (nonatomic,copy) void(^clickBlock)(NSDictionary * _Nullable dic);
+ (UIView * )createView:(void (^_Nullable)(NSDictionary * _Nullable dic))clickBlock;
@end

NS_ASSUME_NONNULL_END
