
package com.quenice.cardview;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Surface;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import javax.annotation.Nullable;

import com.umeng.umverify.UMVerifyHelper;
import com.umeng.umverify.listener.UMAuthUIControlClickListener;
import com.umeng.umverify.listener.UMPreLoginResultListener;
import com.umeng.umverify.listener.UMTokenResultListener;
import com.umeng.umverify.model.UMTokenRet;
import com.umeng.umverify.view.UMAbstractPnsViewDelegate;
import com.umeng.umverify.view.UMAuthRegisterViewConfig;
import com.umeng.umverify.view.UMAuthRegisterXmlConfig;
import com.umeng.umverify.view.UMAuthUIConfig;
public class RNDdverifyModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  private UMTokenResultListener mTokenListener = null;
  private UMVerifyHelper umVerifyHelper = null;
  private Callback myCallBack = null;
  private Promise myPromise = null;
  private int mScreenWidthDp;
  private int mScreenHeightDp;
  private Boolean isLogin = false;

  private void sendEvent(ReactContext reactContext, String eventName, @Nullable WritableMap params){
    reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
  }

  public RNDdverifyModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }
  private void updateScreenSize(int authPageScreenOrientation) {
    int screenHeightDp = AppUtils.px2dp(this.reactContext.getApplicationContext(), AppUtils.getPhoneHeightPixels(this.reactContext));
    int screenWidthDp = AppUtils.px2dp(this.reactContext.getApplicationContext(), AppUtils.getPhoneWidthPixels(this.reactContext));
    int rotation = this.reactContext.getCurrentActivity().getWindowManager().getDefaultDisplay().getRotation();
    if (authPageScreenOrientation == ActivityInfo.SCREEN_ORIENTATION_BEHIND) {
      authPageScreenOrientation = this.reactContext.getCurrentActivity().getRequestedOrientation();
    }
    if (authPageScreenOrientation == ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
            || authPageScreenOrientation == ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT
            || authPageScreenOrientation == ActivityInfo.SCREEN_ORIENTATION_USER_PORTRAIT) {
      rotation = Surface.ROTATION_180;
    }else if (authPageScreenOrientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
            || authPageScreenOrientation == ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
            || authPageScreenOrientation == ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE){
      rotation = Surface.ROTATION_180;
    }
    switch (rotation) {
      case Surface.ROTATION_180:
        mScreenWidthDp = screenWidthDp;
        mScreenHeightDp = screenHeightDp;
        break;
    }
  }

  @Override
  public String getName() {
    return "RNDdverify";
  }

  @ReactMethod
  public void setVerifySDKInfo(String info, final Promise promise){
    final Boolean[] b = {false};
    if (mTokenListener == null){
      //回调监听
      mTokenListener = new UMTokenResultListener() {
        @Override
        public void onTokenSuccess(final String ret) {
          reactContext.runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
              umVerifyHelper.hideLoginLoading();
              WritableMap dic = Arguments.createMap();
              dic.putString("resultCode", "600010");
              dic.putString("msg", "解析错误");
              UMTokenRet tokenRet = null;
              try {
                tokenRet = UMTokenRet.fromJson(ret);
              } catch (Exception e) {
                tokenRet = null;
              }
              if (tokenRet != null ) {
                dic.putString("resultCode", tokenRet.getCode());
                dic.putString("token", tokenRet.getToken());
                dic.putString("msg", tokenRet.getMsg());
                if (("600024").equals(tokenRet.getCode())) {
                  //终端环境可以使用
                  isLogin = true;
                }
              }
              //通过监听通知React当前时间结果

              if (b[0] == false){
                b[0] = true;
                try {
                  //首次
                  promise.resolve(dic);
                } catch (Exception e) {
                  
                }
                
              } else  {
                sendEvent(getReactApplicationContext(), "RN_DDVERIFY_EVENT", dic);

              }


            }
          });
        }

        @Override
        public void onTokenFailed(final String ret) {
          reactContext.runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {

              umVerifyHelper.hideLoginLoading();
              WritableMap dic = Arguments.createMap();
              dic.putString("resultCode", "600010");
              dic.putString("msg", "解析错误");
              UMTokenRet tokenRet = null;
              try {
                tokenRet = UMTokenRet.fromJson(ret);

              } catch (Exception e) {
                tokenRet = null;
              }

              if (tokenRet != null) {
                dic.putString("resultCode", tokenRet.getCode());
                dic.putString("msg", tokenRet.getMsg());
                if( (("600013").equals(tokenRet.getCode()) || ("600017").equals(tokenRet.getCode())) ){
                  //注册时回调当前环境是否可用且当前，检测完成后再发起预取号操作
                  isLogin = false;
                }
              }

              if (b[0] == false){
                b[0] = true;
                try {
                  //首次
                  promise.resolve(dic);
                } catch (Exception e) {

                }
              } else {
                sendEvent(getReactApplicationContext(), "RN_DDVERIFY_EVENT", dic);
              }
            }
          });
        }
      };
    }
    umVerifyHelper = UMVerifyHelper.getInstance(reactContext, mTokenListener);

    umVerifyHelper.setAuthListener(mTokenListener);
    umVerifyHelper.setAuthSDKInfo(info);
    umVerifyHelper.checkEnvAvailable( UMVerifyHelper.SERVICE_TYPE_LOGIN);
//    /**
//     * 控件点击事件回调
//     */
//    umVerifyHelper.setUIClickListener(new UMAuthUIControlClickListener() {
//      @Override
//      public void onClick(String code, Context context, String jsonObj) {
//        Log.e("authSDK", "dddd_xxxx:code=" + code + ", jsonObj=" + jsonObj);
//      }
//    });
  }
  /* 检测环境 */
  @ReactMethod
  public void checkEnvAvailableWithAuthType(String authType, Promise promise){
    WritableMap decs = Arguments.createMap();
    decs.putString("resultCode", isLogin ? "600000" : "600017");
    decs.putString("msg",isLogin ? "解析密钥成功" : "解析密钥失败");
    promise.resolve(decs);
    if (umVerifyHelper != null){
      Boolean checkBool = false;
      WritableMap dic = Arguments.createMap();
      if (authType.equals(new String("UMPNSAuthTypeLoginToken")) ){
        //检测一键登录

        umVerifyHelper.checkEnvAvailable(UMVerifyHelper.SERVICE_TYPE_LOGIN);
      }else if (authType.equals(new String("UMPNSAuthTypeVerifyToken")) ){
        //检测手机号是否是本机号码

      }

    }
  }

  /* 预取号，需要在注册完成 && 环境可用的情况下才能成功 */
  @ReactMethod
  public void accelerateLoginPageWithTimeout( Callback callback){
    myCallBack = callback;

    umVerifyHelper.accelerateLoginPage(8000, new UMPreLoginResultListener() {
      @Override
      public void onTokenSuccess(final String s) {

          if (myCallBack != null){
            WritableMap dic = Arguments.createMap();
            dic.putString("resultCode", "600000");
            dic.putString("msg", "预取号成功");
            myCallBack.invoke(dic);
            myCallBack = null;
          }

      }

      @Override
      public void onTokenFailed(final String s, final String s1) {

        if (myCallBack != null){
          WritableMap dic = Arguments.createMap();
          dic.putString("resultCode", "600012");
          dic.putString("msg", "预取号失败");
          myCallBack.invoke(s1);
          myCallBack = null;
        }

      }
    });
  }
  /* 一键登录 */
  @ReactMethod
  public void getLoginTokenWithTimeout(String timeout, ReadableMap params){
    if (!isLogin) {
      //当前的环境不可用
      return;
    }
    String onePrivacy = "";
    String oneUrl = "";
    String twoPrivacy = "";
    String twoUrl = "";
    if (params.hasKey("privacyOne")){
      onePrivacy = params.getMap("privacyOne").getString("title");
      oneUrl = params.getMap("privacyOne").getString("url");
    }
    if (params.hasKey("privacyTwo")){
      twoPrivacy = params.getMap("privacyTwo").getString("title");
      twoUrl = params.getMap("privacyTwo").getString("url");
    }
    int authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
    if (Build.VERSION.SDK_INT == 26) {
      reactContext.getCurrentActivity().setRequestedOrientation(authPageOrientation);
      authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
    }
    updateScreenSize(authPageOrientation);
    final int logBtnOffsetY = (int) (mScreenHeightDp * 0.5) - 50;
    final int sloganHeight = 30;
    final int numberHeight = 50;
    final int logoHeight = 60;
    int marginV = logBtnOffsetY - logoHeight - sloganHeight - numberHeight;//按钮上面的所有内容高度排除之后所剩的留白
    final int soganY = logBtnOffsetY - sloganHeight - (int)(marginV * 0.14);
    final int numberY = soganY - numberHeight - (int)(marginV * 0.05);
    final int logoY = numberY - logoHeight - (int)(marginV * 0.3);

    //添加自定义按钮
    umVerifyHelper.removeAuthRegisterXmlConfig();
    umVerifyHelper.removeAuthRegisterViewConfig();
    if (params.hasKey("showCustomView") && params.getString("showCustomView").equals("1")) {
      umVerifyHelper.addAuthRegisterXmlConfig(new UMAuthRegisterXmlConfig.Builder().setLayout(R.layout.buttoms, new UMAbstractPnsViewDelegate() {
        @Override
        public void onViewCreated(View view) {

          findViewById(R.id.wexin_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
              //微信登录
              WritableMap dic = Arguments.createMap();
              dic.putString("resultCode","DD1");
              sendEvent(getReactApplicationContext(), "RN_DDVERIFY_EVENT", dic);
            }
          });
        }
      }).build());
    }

    umVerifyHelper.setAuthUIConfig(new UMAuthUIConfig.Builder()
            .setNavText("")
            .setNavColor(Color.WHITE)
            .setNavReturnImgPath("icon_close")
            .setNavReturnImgHeight(20)
            .setNavReturnImgWidth(20)
            .setNavReturnScaleType(ImageView.ScaleType.CENTER_INSIDE)
            .setLogBtnText( params.hasKey("loginBtnText") ? params.getString("loginBtnText") : "" )
            .setLogBtnTextColor(Color.WHITE)
            .setLogBtnBackgroundPath("login_btn_select")
            .setLogBtnOffsetY(logBtnOffsetY)
            .setLogBtnMarginLeftAndRight(20)
            .setSwitchAccText( params.hasKey("changeBtnTitle") ? params.getString("changeBtnTitle") : "" )
            .setSwitchAccHidden(false)
            .setSwitchAccTextColor(Color.GRAY)
            .setSwitchAccTextSize(16)
            .setSwitchOffsetY(logBtnOffsetY + 50 + 30)
            .setSloganHidden(false)
            .setSloganText( params.hasKey("sloganText") ? params.getString("sloganText") : "" )
            .setSloganOffsetY( soganY )
            .setSloganTextColor(Color.GRAY)
            .setSloganTextSize(16)
            .setNumberColor(Color.BLACK)
            .setNumberSize(30)
            .setNumFieldOffsetY( numberY )
            .setLogoImgPath("diandao")
            .setLogoWidth((int) (50 * 2.2))
            .setLogoHeight(50)
            .setLogoOffsetY( logoY )
            .setLogoScaleType(ImageView.ScaleType.CENTER_INSIDE)
            .setAppPrivacyOne(onePrivacy, oneUrl)
            .setAppPrivacyTwo(twoPrivacy, twoUrl)
            .setAppPrivacyColor(Color.GRAY, Color.rgb( 255,127,0))
            .setPrivacyState(true)
            .setPrivacyMargin(20)
            .setStatusBarHidden(true)
            .setCheckboxHidden(true)
            .setVendorPrivacyPrefix("《")
            .setVendorPrivacySuffix("》")

            .setAuthPageActIn("in_activity", "out_activity")
            .setAuthPageActOut("in_activity", "out_activity")
//            .setPageBackgroundPath("page_background_color")
            .setScreenOrientation(authPageOrientation)
            .create());

    umVerifyHelper.getLoginToken(reactContext, 5000);
  }
  /* 关闭一键登录授权页 */
  @ReactMethod
  public void cancelLoginVCAnimated(){
    reactContext.runOnUiQueueThread(new Runnable() {
      @Override
      public void run() {
        umVerifyHelper.hideLoginLoading();
        umVerifyHelper.quitLoginPage();
      }
    });

  }
}