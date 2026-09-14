
import { EventSubscription, NativeEventEmitter, NativeModules } from 'react-native';

import NativeDDVerify from "./specs/NativeDDVerify";

const isTurboModuleEnabled = !!(global as any).__turboModuleProxy || !!(global as any).RN$Bridgeless;

const RNDdverify = isTurboModuleEnabled? NativeDDVerify:NativeModules.NativeDDVerify;

/**
 * 原生模块没有注册（未 link / 原生没编译进包）时的兜底。
 * 原来这里直接返回 undefined：Promise 既不 resolve 也不 reject 会永久 pending，
 * 而 `setVerifySDKInfo(...).then(...)` 会抛 "Cannot read property 'then' of undefined"，很难定位。
 */
const MODULE_MISSING_ERROR = '[react-native-ddverify] 原生模块 NativeDDVerify 未注册，请检查 react-native-ddverify 是否已完成原生集成';

const rejectMissingModule = ():Promise<never> => Promise.reject(new Error(MODULE_MISSING_ERROR));

export const onVerifyEvent = (callback:(value:Object ) => void):EventSubscription|null => {

    if (isTurboModuleEnabled) {
         return RNDdverify?.onVerifyEvent?.((event:{ key: string; value:Object }) => {
            if (event.key === "RN_DDVERIFY_EVENT") {
                callback(event.value);
            }
        })||null;
    }else if(RNDdverify){
        return new NativeEventEmitter(RNDdverify)?.addListener?.('RN_DDVERIFY_EVENT',(params)=>{
                callback(params);
            });
    }
    return null;


}

/**
 * 设置密钥
 * @param {*} info
 * @returns
 */
export const setVerifySDKInfo = (info:string):Promise<Object> => {
    if (!RNDdverify?.setVerifySDKInfo) {
        return rejectMissingModule();
    }
    return RNDdverify.setVerifySDKInfo(info);
}
/**
 * 检查环境
 * UMPNSAuthTypeLoginToken 一键登录环境
 * UMPNSAuthTypeVerifyToken 本机号码校验环境
 * @param {UMPNSAuthTypeLoginToken UMPNSAuthTypeVerifyToken} authType
 *
 */
export const checkEnvAvailableWithAuthType = (authType:string):Promise<Object> => {
    if (!RNDdverify?.checkEnvAvailableWithAuthType) {
        return rejectMissingModule();
    }
    return RNDdverify.checkEnvAvailableWithAuthType(authType);
}

/**
 * 预取号，可以缩减一键登录初始化时间，不可以多次调用预取号（最好是打开APP后，验证用户登录信息，再决定是否调用一次预取号）
 * @param {*} BackHandler
 * @returns
 */
export const accelerateLoginPageWithTimeout = (BackHandler:(data?:Object|undefined|null) => void)=>{
    if (!RNDdverify?.accelerateLoginPageWithTimeout) {
        console.warn(MODULE_MISSING_ERROR);
        return;
    }
    return RNDdverify.accelerateLoginPageWithTimeout(BackHandler);
}
/**
 * 一键登录
 * @param {最多等待多少秒} timeOut  （android 侧最少等待 5 秒）
 * @param {*} params 授权页配置
 * @param {*} callback 可选。与 onVerifyEvent 收到的事件内容完全一致（本次授权页流程的所有事件都会回调，
 *                     可能被多次调用），请按 resultCode 判断；不传不影响 onVerifyEvent 的使用
 * 授权页控件点击事件：700000（点击授权页返回按钮）、700001（点击切换其他登录方式）、
    700002（点击登录按钮事件，根据返回字典里面的 "isChecked"字段来区分check box是否被选中，只有被选中的时候        *          内部才会去获取Token）、700003（点击check box事件）、700004（点击协议富文本文字）
    接口回调其他事件：600001（授权页唤起成功）、600002（授权页唤起失败）、600000（成功获取Token）、 600011（获取Token失败）、600015（获取Token超时）、600013（运营商维护升级，该功能不可用）、600014（运营商维护升级，该功能已达最大调用次数）.....
 */
export const getLoginTokenWithTimeout = ( timeOut:string, params:Object, callback?:(data:Object) => void ) => {
    if (!RNDdverify?.getLoginTokenWithTimeout) {
        console.warn(MODULE_MISSING_ERROR);
        return;
    }
    //原生侧该参数是必传的（codegen 不支持可选回调），未传时补一个空函数
    return RNDdverify.getLoginTokenWithTimeout( timeOut, params, callback || (() => {}) );
}
/**
 * 获取VerifyToken
 * 使用这个VerifyToken + 手机号码。去后端进行校验。
 * 返回一个 Promise
 *
 */
export const getVerifyToken = ():Promise<string> => {

    if (!RNDdverify?.getVerifyToken) {
        return rejectMissingModule();
    }

    return new Promise<string>((resolve, reject)=>{
        RNDdverify.getVerifyToken()
            ?.then?.((token:string)=>{
                resolve(token)
            })
            ?.catch((e:Object)=>{
                //把原生的失败原因透传出去（原来只 reject(-1)，排查问题时没有任何信息）
                reject(e instanceof Error ? e : new Error(typeof e === 'string' ? e : JSON.stringify(e)))
            })
    })
}
//关闭授权页面
export const cancelLoginVCAnimated = () => {
     RNDdverify?.cancelLoginVCAnimated?.()
}
