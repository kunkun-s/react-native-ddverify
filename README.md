
# react-native-ddverify

## Getting started

`$ npm install react-native-ddverify` or `$ yarn add react-native-ddverify`


### Manual installation


#### iOS
`pod install`



#### Android


### 基本流程
1. 先设置密钥
2. 验证“一键登录”或“本机号码校验”环境
3. 可以根据用户登录状态，决定是否“预取号”，仅可以调用一次。（如果预取号调用过于频繁，且不符合逻辑，则会被UM限制）
4. 发起“一键登录”or“本机号码校验”SDK
## Usage
```javascript
import RNDdverify from 'react-native-ddverify';
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
            })
```
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