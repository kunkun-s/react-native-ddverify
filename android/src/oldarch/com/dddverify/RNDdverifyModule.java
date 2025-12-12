
package com.dddverify;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMap;


public class RNDdverifyModule extends ReactContextBaseJavaModule {
    private RNDdverifyImpl dverifyImpl;

    public RNDdverifyModule(ReactApplicationContext reactContext) {
        super(reactContext);
        dverifyImpl = new RNDdverifyImpl(reactContext);
    }

    @Override
    public String getName() {
        return RNDdverifyImpl.NAME;
    };

    @ReactMethod
    public void setVerifySDKInfo(String info, final Promise promise){
        dverifyImpl.setVerifySDKInfo(info, promise);
    }
    /* 检测环境 */
    @ReactMethod
    public void checkEnvAvailableWithAuthType(String authType, Promise promise){
        dverifyImpl.checkEnvAvailableWithAuthType(authType, promise);
    }

    /* 预取号，需要在注册完成 && 环境可用的情况下才能成功 */
    @ReactMethod
    public void accelerateLoginPageWithTimeout( Callback callback){
        dverifyImpl.accelerateLoginPageWithTimeout(callback);
    }
    /* 本机号码校验 */
    @ReactMethod
    public void getVerifyToken(final Promise promise){
        dverifyImpl.getVerifyToken(promise);
    }
    /* 一键登录 */
    @ReactMethod
    public void getLoginTokenWithTimeout(String timeout, ReadableMap params){
        dverifyImpl.getLoginTokenWithTimeout(timeout, params);
    }
    /* 关闭一键登录授权页 */
    @ReactMethod
    public void cancelLoginVCAnimated(){
        dverifyImpl.cancelLoginVCAnimated();
    }
}