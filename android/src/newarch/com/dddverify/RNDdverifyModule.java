package com.dddverify;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.proguard.annotations.DoNotStrip;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;

import java.util.Map;
import java.util.HashMap;

import javax.annotation.Nonnull;

public class RNDdverifyModule extends NativeDDVerifySpec {
    private RNDdverifyImpl dverifyImpl;

    public RNDdverifyModule(ReactApplicationContext reactContext) {
        super(reactContext);
        //新架构的 native to js event
        DverifyImplSendJSEvent callback = new DverifyImplSendJSEvent() {
            @Override
            public void send(String name, @Nullable WritableMap body) {
                WritableMap eventData = Arguments.createMap();
                eventData.putString("key", name);
                eventData.putMap("value", body);
                emitOnVerifyEvent(eventData);
            }
        };
        dverifyImpl= new RNDdverifyImpl(reactContext, callback);
    }
    @Override
    public String getName() {
        return RNDdverifyImpl.NAME;
    }
    @Override
    public void setVerifySDKInfo(String info, Promise promise){
        dverifyImpl.setVerifySDKInfo(info, promise);
    }
    @Override
    public void checkEnvAvailableWithAuthType(String authType, Promise promise){
        dverifyImpl.checkEnvAvailableWithAuthType(authType, promise);
    }
    @Override
    public void accelerateLoginPageWithTimeout(Callback callback){
        dverifyImpl.accelerateLoginPageWithTimeout(callback);
    }
    @Override
    public void getLoginTokenWithTimeout(String timeout, ReadableMap params){
        dverifyImpl.getLoginTokenWithTimeout(timeout, params);

    }
    @Override
    public void getVerifyToken(Promise promise){
        dverifyImpl.getVerifyToken(promise);
    }
    @Override
    public void cancelLoginVCAnimated(){
        dverifyImpl.cancelLoginVCAnimated();
    }
}