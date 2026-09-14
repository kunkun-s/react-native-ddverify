
# react-native-ddverify

## Getting started

`$ npm install react-native-ddverify` or `$ yarn add react-native-ddverify`


### iOS
如果项目没有UMCommon，则需要在你的工程目录下添加UMCommon依赖<br>
1. 在主项目的podfile中添加
```Ruby
pod 'UMCommon'    	#必须集成
pod 'UMDevice'    	#必须集成
pod 'UMCCommonLog'	#可选，日志插件
pod 'UMAPM' 		#必选，APM组件，原错误分析升级为独立产品U-APM

```
2. 或者去um官方sdk手动下载Verify的SDK<br>
手动将除了verify 文件夹之外的，其他sdk文件(common、thirdparties、umcommonlog)都依赖到你的主项目。
`注：thirdparties中的UTDID.framework 可能会与Alipay冲突，如果冲突，请删除um的thirdparties`

#### 添加完依赖后执行
`pod install`

#### 更换图片资源
ios/image 目录下是使用的一键登录logo、按钮、等图片资源，仅需更换图片，并保留原图片名称即可。

### Android

#### 更换图片资源
drawable 文件中中的图片更换，并保留图片名称即可。

### 基本流程
1. 先设置密钥
2. 验证“一键登录”或“本机号码校验”环境
3. 可以根据用户登录状态，决定是否“预取号”，仅可以调用一次。（如果预取号调用过于频繁，且不符合逻辑，则会被UM限制）
4. 发起“一键登录”or“本机号码校验”SDK
## Usage

`使用verifySDK之前，需要向完成UMCommon基础组件注册。完成友盟的注册之后才能使用`

```javascript
//本库只有具名导出，没有默认导出
import {
    onVerifyEvent,
    setVerifySDKInfo,
    checkEnvAvailableWithAuthType,
    accelerateLoginPageWithTimeout,
    getLoginTokenWithTimeout,
    getVerifyToken,
    cancelLoginVCAnimated,
} from 'react-native-ddverify';
```
设置密钥、验证环境、预取号
```javascript
		//密钥设置
        setVerifySDKInfo(UM_VERIFY_INFO).then((resultDic)=>{

            //注册成功、环境可以使用
            if (resultDic?.resultCode == '600000' || resultDic?.resultCode == '600024') {
                //密钥解析成功
				//验证一键登录环境
                checkEnvAvailableWithAuthType("UMPNSAuthTypeLoginToken").then((dic)=>{

                    // 环境认证可以
                    if (`${dic?.resultCode}` == '600000') {
                        // 当前环境可以使用
                        
                        if (!userToken) {
                            //预取号 //如果有没有token则进行一次预取号
                            accelerateLoginPageWithTimeout((params)=>{

								//成功失败不重要
                                // if (params && `${params.resultCode}` == '600000') {
                                   //预约取号成功 
                                // }else{
                              
                                // }
                            })
                        }
                        
                    }else {
                        // 当前环境不可用
                        
                    }
                
                })
          
            }else {
                //解析失败（之后的一键登录流程就会被打断了）
            }

        })
```

发起一键登录
```js
 //第三个参数可选。不传时和以前完全一样，只通过 onVerifyEvent(或下面的 onVerifyEvent 监听)收结果；
 //传了则本次授权页流程的事件会同时回调到这里，内容与 onVerifyEvent 完全一致、可能被多次调用，
 //需要自己按 resultCode 判断（700000 关闭、600001 唤起成功、700002 点击登录按钮、600000 取token成功 …）
 getLoginTokenWithTimeout("3",{
                navTitle: "",
                sloganText: I18n.t('login.title21'),
                loginBtnText: I18n.t('login.title30'),
                changeBtnTitle: I18n.t('login.title31'),
                showCustomView: "0",
                privacyOne: {
                    title:  I18n.t('login.title23'),
                    url: HTTP_USER_AGREEMENT_URL
                },
                // privacyTwo: {
                //     title: "《隐私政策》",
                //     url: ""
                // }
            },(params)=>{
                //本次授权页流程的结果（可选写法）
                if (`${params?.resultCode}` == '600000' && params.token) {
                    //获取token成功
                }
            })
```

> `timeOut` 单位是**秒**（与 iOS 一致）。Android 侧最少等待 5 秒，传小于 5 的值会被兜底到 5 秒。
>
> 环境不可用或未调用 `setVerifySDKInfo` 时，会回一个 `resultCode = "600002"`（授权页唤起失败）的结果，
> 事件与上面的回调都能收到，不会再像以前那样静默无响应。
关闭一键登录
```js
cancelLoginVCAnimated()
```
获取本机号码验证VerifyToken
```js
getVerifyToken().then((token)=>{
            //获取到token
        }).catch((e)=>{
            //获取失败
        })
```
