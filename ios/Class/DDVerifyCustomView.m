//
//  DDVerifyCustomView.m
//  RNDdverify
//
//  Created by 坤坤 on 2020/5/22.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "DDVerifyCustomView.h"

@implementation DDVerifyCustomView
{
    

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)clickButton:(UIButton *)sender {
    
    if (sender.tag == 1 &&  self.clickBlock) {
        //微信
        self.clickBlock(@{
            @"resultCode": @"DD1",
                        });
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    NSBundle * currentBundle =  [NSBundle bundleForClass:[self class]];
    [self.wxLoginBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"wechar_icon.png" ofType:nil inDirectory:@"RNDDverify.bundle"]] forState:UIControlStateNormal];
   [self.wxLoginBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"wechar_icon.png" ofType:nil inDirectory:@"RNDDverify.bundle"]] forState:UIControlStateHighlighted];
   [self.wxLoginBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"wechar_icon.png" ofType:nil inDirectory:@"RNDDverify.bundle"]] forState:UIControlStateSelected];
}
+(UIView *)createView:(void (^_Nullable)(NSDictionary * _Nonnull dic))clickBlock{
    
    NSBundle * bundlePath = [NSBundle bundleForClass:[self class]];
    NSBundle * currentBundle = [NSBundle bundleWithPath:[bundlePath pathForResource:@"RNDDverify" ofType:@"bundle"]];//一般Assert文件夹下的资源所在的位置就是frameworkbundle底下

    
    DDVerifyCustomView * customView = [[currentBundle loadNibNamed:@"DDVerifyCustomView" owner:self options:nil] firstObject];
   
 
    customView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 10, 80);
    customView.clickBlock = clickBlock;
    return customView;
}
@end
