//
//  UMModel.m
//
//

#import "UMModelCreate.h"
#import <React/RCTRootView.h>
#import "DDVerifyCustomView.h"
#define UM_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define UM_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define IS_HORIZONTAL (UM_SCREEN_WIDTH > UM_SCREEN_WIDTH)


#define UM_Alert_NAV_BAR_HEIGHT      55.0
#define UM_Alert_HORIZONTAL_NAV_BAR_HEIGHT      41.0

//竖屏弹窗
#define UM_Alert_Default_LR_Padding           18.0
#define UM_Alert_LogoImg_Height_Width         60.0
#define UM_Alert_LogoImg_OffetY               12.0
#define UM_Alert_SloganTxt_OffetY             88.0
#define UM_Alert_SloganTxt_Height             24.0
#define UM_Alert_NumberTxt_OffetY             121.0
#define UM_Alert_LoginBtn_OffetY              163.0
#define UM_Alert_LogonBtn_Height              40.0
#define UM_Alert_ChangeWayBtn_OffetY          219.0
#define UM_Alert_Default_Left_Padding         42
#define UM_Alert_Default_Top_Padding          115

/**横屏弹窗*/
#define UM_Alert_Horizontal_Default_Left_Padding      80.0
#define UM_Alert_Horizontal_Default_LR_Padding        18.0
#define UM_Alert_Horizontal_NumberTxt_OffetY          22.5
#define UM_Alert_Horizontal_LoginBtn_OffetY           78.5
#define UM_Alert_Horizontal_LoginBtn_Height           51.0

/**竖屏全屏*/
#define UM_LogoImg_OffetY               32.0
#define UM_SloganTxt_OffetY             150.0
#define UM_SloganTxt_Height             24.0
#define UM_NumberTxt_OffetY             220.0
#define UM_LoginBtn_OffetY              270.0
#define UM_ChangeWayBtn_OffetY          344.0
#define UM_LoginBtn_Height              50.0
#define UM_LogoImg_Height_Width         90.0
#define UM_Default_LR_Padding           18.0
#define UM_Privacy_Bottom_OffetY        13.5

/**横屏全屏*/
#define UM_Horizontal_LogoImg_OffetY               11.0
#define UM_Horizontal_NumberTxt_OffetY             76.0
#define UM_Horizontal_LogoImg_Height_Width         55.0
#define UM_Horizontal_Default_LR_Padding           UM_SCREEN_WIDTH * 0.5 * 0.5
#define UM_Horizontal_LoginBtn_OffetY              122.0
#define UM_Horizontal_Privacy_Bottom_OffetY        13.5

static CGFloat ratio ;

@implementation UMModelCreate
+ (void)load {
    ratio = MAX(UM_SCREEN_WIDTH, UM_SCREEN_HEIGHT) / 667.0;
}
/// 创建横屏全屏的model
+ (UMCustomModel *)createFullScreen:(NSDictionary *)params clickBlock:(void (^_Nullable)(NSDictionary * _Nonnull dic))clickBlock{
    
    UMCustomModel *model = [[UMCustomModel alloc] init];
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    //导航栏相关设置
    model.navColor = UIColor.whiteColor;
    model.navTitle = [[NSAttributedString alloc] initWithString:params && params[@"navTitle"] ? params[@"navTitle"] : @"" attributes:@{NSForegroundColorAttributeName : UIColor.blackColor,NSFontAttributeName : [UIFont systemFontOfSize:20.0]}];
    //model.navIsHidden = NO;
    
    model.navBackImage = [UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"icon_close_gray.png" ofType:nil inDirectory:@"ATAuthSDK.bundle"]];
        //model.hideNavBackItem = NO;
//        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        [rightBtn setTitle:@"更多" forState:UIControlStateNormal];
//        model.navMoreView = rightBtn;
        
//        model.privacyNavColor = UIColor.orangeColor;
//        model.privacyNavBackImage = [UIImage imageNamed:@"icon_nav_back_light"];
//        model.privacyNavTitleFont = [UIFont systemFontOfSize:20.0];
//        model.privacyNavTitleColor = UIColor.whiteColor;
    //图标logo
    model.logoImage = [UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"diandao.png" ofType:nil inDirectory:@"RNDDverify.bundle"]];
    //model.logoIsHidden = NO;
    //model.sloganIsHidden = NO;
    //图标下面的显示文案
    NSString * sloganText = params && params[@"sloganText"] ? params[@"sloganText"] : @"";
    model.sloganText = [[NSAttributedString alloc] initWithString:sloganText attributes:@{NSForegroundColorAttributeName : UIColor.grayColor,NSFontAttributeName : [UIFont systemFontOfSize:16.0]}];
    //手机号码
    model.numberColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.87];
    model.numberFont = [UIFont systemFontOfSize:30.0];
    //登录按钮
    NSString * loginBtnText = params && params[@"loginBtnText"] ? params[@"loginBtnText"] : @"";
    model.loginBtnText = [[NSAttributedString alloc] initWithString:loginBtnText attributes:@{NSForegroundColorAttributeName : UIColor.whiteColor,NSFontAttributeName : [UIFont systemFontOfSize:20.0]}];
    model.loginBtnBgImgs = @[ [UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"loginBtnBgImgSelect.png" ofType:nil inDirectory:@"RNDDverify.bundle"]], [UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"loginBtnBgImgDefault.png" ofType:nil inDirectory:@"RNDDverify.bundle"]], [UIImage imageWithContentsOfFile:[currentBundle pathForResource:@"loginBtnBgImgSelect.png" ofType:nil inDirectory:@"RNDDverify.bundle"]]];
    //model.autoHideLoginLoading = NO;
    //用户协议
    if(params){
        if (params[@"privacyOne"]) {
            model.privacyOne = @[params[@"privacyOne"][@"title"],params[@"privacyOne"][@"url"]];

        }
        if (params[@"privacyTwo"]) {
            model.privacyTwo = @[params[@"privacyTwo"][@"title"],params[@"privacyTwo"][@"url"]];

        }
    }
    model.privacyColors = @[UIColor.lightGrayColor, UIColor.orangeColor];
    model.privacyAlignment = NSTextAlignmentCenter;
    model.privacyFont = [UIFont fontWithName:@"PingFangSC-Regular" size:13.0];
    model.privacyOperatorPreText = @"《";
    model.privacyOperatorSufText = @"》";
    model.checkBoxIsHidden = YES;
    model.checkBoxIsChecked = YES;
    model.checkBoxWH = 17.0;
    //切换到其他方式
    NSString * changeBtnTitle = params && params[@"changeBtnTitle"] ? params[@"changeBtnTitle"] : @"";
    model.changeBtnTitle = [[NSAttributedString alloc] initWithString:changeBtnTitle attributes:@{NSForegroundColorAttributeName : UIColor.grayColor,NSFontAttributeName : [UIFont systemFontOfSize:16.0]}];
    model.preferredStatusBarStyle = UIStatusBarStyleLightContent;
    //授权页面弹出方向
    model.presentDirection = UMPNSPresentationDirectionRight;
    
    //授权页默认控件布局调整
    //model.navBackButtonFrameBlock =
    //model.navTitleFrameBlock =
    model.navMoreViewFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        CGFloat width = superViewSize.height;
        CGFloat height = width;
        return CGRectMake(superViewSize.width - 15 - width, 0, width, height);
    };
    model.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([self isHorizontal:screenSize]) {
            frame.origin.y = 20;
            
            return frame;
        }

        return frame;
    };
    model.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([self isHorizontal:screenSize]) {
            return CGRectZero; //横屏时模拟隐藏该控件
        } else {
            return CGRectMake(0, 200, superViewSize.width, frame.size.height);
        }
    };
    model.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([self isHorizontal:screenSize]) {
            frame.origin.y = 0;
        }
        frame.origin.y = 160;
        return frame;
    };
    model.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([self isHorizontal:screenSize]) {
            frame.origin.y = 185;
        }
        return frame;
    };
    model.changeBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        if ([self isHorizontal:screenSize]) {
            return CGRectZero; //横屏时模拟隐藏该控件
        } else {
            return CGRectMake(10, frame.origin.y, superViewSize.width - 20, 30);
        }
    };
    //model.privacyFrameBlock =
    
    //添加自定义控件并对自定义控件进行布局
  
    UIView * customView = [DDVerifyCustomView createView:clickBlock];
    model.customViewBlock = ^(UIView * _Nonnull superCustomView) {
         [superCustomView addSubview:customView];
    };
    
    model.customViewLayoutBlock = ^(CGSize screenSize, CGRect contentViewFrame, CGRect navFrame, CGRect titleBarFrame, CGRect logoFrame, CGRect sloganFrame, CGRect numberFrame, CGRect loginFrame, CGRect changeBtnFrame, CGRect privacyFrame) {
        CGRect frame = customView.frame;
        frame.origin.x = (contentViewFrame.size.width - frame.size.width) * 0.5;
        frame.origin.y = CGRectGetMinY(privacyFrame) - frame.size.height - 20;
        frame.size.width = contentViewFrame.size.width - frame.origin.x * 2;
        customView.frame = frame;
    };
    return model;
}


//是否是横屏 YES:横屏 NO:竖屏
+ (BOOL)isHorizontal:(CGSize)size {
    return size.width > size.height;
}
@end
