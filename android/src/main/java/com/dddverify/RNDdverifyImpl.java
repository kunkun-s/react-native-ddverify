package com.dddverify;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Build;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.umeng.umverify.UMVerifyHelper;
import com.umeng.umverify.listener.UMAuthUIControlClickListener;
import com.umeng.umverify.listener.UMPreLoginResultListener;
import com.umeng.umverify.listener.UMTokenResultListener;
import com.umeng.umverify.model.UMTokenRet;
import com.umeng.umverify.view.UMAbstractPnsViewDelegate;
import com.umeng.umverify.view.UMAuthRegisterXmlConfig;
import com.umeng.umverify.view.UMAuthUIConfig;

import org.json.JSONObject;

import javax.annotation.Nullable;

//新旧架构通用原生核心方法
public class RNDdverifyImpl {
    public static final String NAME = "NativeDDVerify"; //与NativeDDVerify.ts文件中的get<Spec>('NativeDDVerify') 保持一致
    private static final String EVENT_NAME = "RN_DDVERIFY_EVENT";

    private final ReactApplicationContext reactContext;
    private Boolean privacyStatus = false;//同步一键登录组件的隐私政策是否勾选
    private UMTokenResultListener mTokenListener = null;
    private UMVerifyHelper umVerifyHelper = null;
    private Callback myCallBack = null;
    private int mScreenWidthDp;
    private int mScreenHeightDp;
    private Boolean isLogin = false;
    private DverifyImplSendJSEvent callback;
    //setVerifySDKInfo 的 Promise。SDK 回调会多次触发，只有首次回调 resolve，
    //这里必须是成员变量：监听器只在第一次 setVerifySDKInfo 时创建，
    //若把 Promise 放在方法局部变量里被闭包捕获，第二次调用时闭包仍指向第一次的 Promise，新 Promise 永远不会 resolve。
    private Promise mTokenPromise = null;
    private boolean mTokenRetFirst = true;

    /**
     * 所有下发给 JS 的结果统一走这里（RN_DDVERIFY_EVENT 事件，JS 侧 onVerifyEvent 监听）。
     *
     * 注意 params 交给 send 之后就被消费掉了（新架构的 send 内部走 putMap -> putNativeMap，
     * 会把 WritableNativeMap consume 掉），之后再读会抛 ObjectAlreadyConsumedException。
     * 所以这里不做任何读取，需要用到内容的话必须在调用前先取。
     */
    private void sendEvent(ReactApplicationContext reactContext, String eventName, @Nullable WritableMap params){
        this.callback.send(eventName, params);
    }

    public RNDdverifyImpl(ReactApplicationContext reactContext, DverifyImplSendJSEvent n_callback){
        this.callback = n_callback;
        this.reactContext = reactContext;
    }

    /**
     * 计算授权页控件坐标用的屏幕宽高（dp）。
     *
     * 授权页固定按竖屏全屏展示（见 getLoginTokenWithTimeout 里的 setScreenOrientation），所以这里统一取竖屏宽高。
     * 注意不要改回按 Display.getRotation() 分支赋值：宿主 Activity 的 requestedOrientation 为 UNSPECIFIED 时
     * rotation 是 ROTATION_0，旧实现只处理 ROTATION_180，会让宽高保持 0，下方所有偏移量被算成负数。
     */
    private void updateScreenSize() {
        mScreenWidthDp = AppUtils.px2dp(this.reactContext.getApplicationContext(), AppUtils.getPhoneWidthPixels(this.reactContext));
        mScreenHeightDp = AppUtils.px2dp(this.reactContext.getApplicationContext(), AppUtils.getPhoneHeightPixels(this.reactContext));
    }
    /**
     * 只有首次回调 resolve setVerifySDKInfo 的 Promise（保持原有行为），
     * 之后统一走 RN_DDVERIFY_EVENT 事件下发。
     */
    private void dispatchTokenResult(WritableMap dic) {
        if (mTokenRetFirst) {
            mTokenRetFirst = false;
            Promise promise = mTokenPromise;
            mTokenPromise = null;
            if (promise != null) {
                try {
                    //首次
                    promise.resolve(dic);
                } catch (Exception e) {
                    //Promise 已失效（如 JS 侧 reload），忽略
                }
            }
            return;
        }
        sendEvent(reactContext, EVENT_NAME, dic);
    }

    public void setVerifySDKInfo(String info, Promise promise){

        //每次设置密钥都重置 Promise 的接收方，避免第二次调用时 Promise 永远不 resolve
        mTokenPromise = promise;
        mTokenRetFirst = true;

        if (mTokenListener == null){
            //回调监听
            mTokenListener = new UMTokenResultListener() {
                @Override
                public void onTokenSuccess(final String ret) {
                    reactContext.runOnUiQueueThread(new Runnable() {
                        @Override
                        public void run() {
                            if (umVerifyHelper != null) {
                                umVerifyHelper.hideLoginLoading();
                            }
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
                            dispatchTokenResult(dic);
                        }
                    });
                }

                @Override
                public void onTokenFailed(final String ret) {
                    reactContext.runOnUiQueueThread(new Runnable() {
                        @Override
                        public void run() {

                            if (umVerifyHelper != null) {
                                umVerifyHelper.hideLoginLoading();
                            }
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

                            dispatchTokenResult(dic);
                        }
                    });
                }
            };
        }
        umVerifyHelper = UMVerifyHelper.getInstance(reactContext, mTokenListener);

        umVerifyHelper.setAuthListener(mTokenListener);
        umVerifyHelper.setAuthSDKInfo(info);
        umVerifyHelper.checkEnvAvailable( UMVerifyHelper.SERVICE_TYPE_LOGIN);
        /**
         * 控件点击事件回调
         */
        umVerifyHelper.setUIClickListener(new UMAuthUIControlClickListener() {
            @Override
            public void onClick(String code, Context context, String jsonObj) {
                //这里必须用 equals 比较字符串。用 == 只是依赖字符串常量池的巧合，
                //一旦 SDK 改成动态拼接或开启 R8 优化就会失效，privacyStatus 不再更新，
                //微信/苹果按钮会一直提示"请阅读并勾选底部服务条款与协议"
                if("700003".equals(code) || "700008".equals(code)){//70003点击底部同意按钮，700008点击二次弹窗协议同意并继续
                    try {
                        JSONObject jobje  = new JSONObject(jsonObj);
                        privacyStatus = jobje.getBoolean("isChecked");
                    }catch (Exception e){
                        privacyStatus = !privacyStatus;
                    }
                }
                // Log.e("authSDK", "dddd_xxxx:code=" + code + ", jsonObj=" + jsonObj);
            }
        });
    }

    public void checkEnvAvailableWithAuthType(String authType, Promise promise){
        WritableMap decs = Arguments.createMap();
        decs.putString("resultCode", isLogin ? "600000" : "600017");
        decs.putString("msg",isLogin ? "解析密钥成功" : "解析密钥失败");
        promise.resolve(decs);

        if (umVerifyHelper == null){
            return;
        }
        if ("UMPNSAuthTypeLoginToken".equals(authType) ){
            //检测一键登录
            umVerifyHelper.checkEnvAvailable(UMVerifyHelper.SERVICE_TYPE_LOGIN);
        }else if ("UMPNSAuthTypeVerifyToken".equals(authType) ){
            //检测手机号是否是本机号码
            umVerifyHelper.checkEnvAvailable(UMVerifyHelper.SERVICE_TYPE_AUTH);
        }
    }

    public void accelerateLoginPageWithTimeout(Callback callback){

        if (umVerifyHelper == null){
            //未调用 setVerifySDKInfo，直接回调错误，避免 NPE 崩在原生
            if (callback != null){
                WritableMap dic = Arguments.createMap();
                dic.putString("resultCode", "600012");
                dic.putString("msg", "未初始化，请先调用 setVerifySDKInfo");
                callback.invoke(dic);
            }
            return;
        }

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
                    //与 iOS 保持一致：失败同样返回字典，而不是只回一个字符串，
                    //否则 JS 侧按 params.resultCode 取值会全部拿到 undefined
                    dic.putString("resultCode", (s == null || s.isEmpty()) ? "600012" : s);
                    dic.putString("msg", (s1 == null || s1.isEmpty()) ? "预取号失败" : s1);
                    myCallBack.invoke(dic);
                    myCallBack = null;
                }

            }
        });
    }

    public void getLoginTokenWithTimeout(String timeout, ReadableMap params){

        if (umVerifyHelper == null || !isLogin) {
            //原来是静默 return，JS 侧永远收不到任何结果。这里补发一次"授权页唤起失败"，
            //不影响原有 resultCode 的判定逻辑
            WritableMap dic = Arguments.createMap();
            dic.putString("resultCode", "600002");
            dic.putString("msg", umVerifyHelper == null
                    ? "未初始化，请先调用 setVerifySDKInfo"
                    : "当前环境不可用，授权页未唤起");
            sendEvent(reactContext, EVENT_NAME, dic);
            return;
        }

        privacyStatus = false;
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
        if (Build.VERSION.SDK_INT == 26 && reactContext.getCurrentActivity() != null) {
            reactContext.getCurrentActivity().setRequestedOrientation(authPageOrientation);
            authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
        }
        updateScreenSize();
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

                            try {
                                if (privacyStatus){
                                    //隐私政策勾选
                                    //微信登录
                                    WritableMap dic = Arguments.createMap();
                                    dic.putString("resultCode","DD1");
                                    sendEvent(reactContext, "RN_DDVERIFY_EVENT", dic);
                                } else {
                                    //隐私政策未勾选
                                    Toast toast = Toast.makeText(reactContext,"请阅读并勾选底部服务条款与协议。",Toast.LENGTH_LONG);
                                    toast.show();

                                }
                            }catch (Exception e){
                                // Log.e("authSDK",e.getMessage());
                            }


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
                .setPrivacyState(false)
                .setCheckboxHidden(false)
                .setUncheckedImgPath("unchecked")
                .setCheckedImgPath("checked")
                .setLogBtnToastHidden(false)
                .setPrivacyMargin(20)
                .setStatusBarHidden(true)
                .setVendorPrivacyPrefix("《")
                .setVendorPrivacySuffix("》")
                .setAuthPageActIn("in_activity", "out_activity")
                .setAuthPageActOut("in_activity", "out_activity")
//            .setPageBackgroundPath("page_background_color")
                .setScreenOrientation(authPageOrientation)
                .create());

        //JS 侧与 iOS 保持一致，传的是秒；Android SDK 需要毫秒，最少等待 5 秒
        int nTimeout = 5000;
        if (timeout != null) {
            try {
                nTimeout = Integer.parseInt(timeout.trim()) * 1000;
            } catch (NumberFormatException e) {
                nTimeout = 5000;
            }
        }
        if (nTimeout < 5000) {
            nTimeout = 5000;
        }
        umVerifyHelper.getLoginToken(reactContext, nTimeout);
    }

    public void getVerifyToken(Promise promise){

        if (umVerifyHelper == null) {
            promise.reject("-1", "未初始化，请先调用 setVerifySDKInfo");
            return;
        }

        umVerifyHelper.setAuthListener(new UMTokenResultListener() {
            @Override
            public void onTokenSuccess(String s) {
                UMTokenRet tokenRet = null;
                try {
                    tokenRet = UMTokenRet.fromJson(s);
                } catch (Exception e) {
                    tokenRet = null;
                }
                if (tokenRet != null){
                    promise.resolve(tokenRet.getToken());
                } else {
                    promise.reject("-1","获取VerifyToken失败");
                }
                umVerifyHelper.setAuthListener(mTokenListener);

            }

            @Override
            public void onTokenFailed(String s) {
                promise.reject("-1","获取VerifyToken失败");
                umVerifyHelper.setAuthListener(mTokenListener);

            }
        });
        umVerifyHelper.getVerifyToken(5000);
    }

    public void cancelLoginVCAnimated(){
        if (umVerifyHelper == null) {
            //未初始化，无需关闭（避免 NPE，componentWillUnmount 里会直接调用）
            return;
        }
        reactContext.runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                if (umVerifyHelper != null) {
                    umVerifyHelper.hideLoginLoading();
                    umVerifyHelper.quitLoginPage();
                }
            }
        });
    }
}