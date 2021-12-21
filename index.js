
import { NativeModules } from 'react-native';
import { IS_TAB_STYLE } from '../../app/config';

const { RNDdverify, } = NativeModules;
export default RNDdverify

/**
 * 设置密钥
 * @param {*} info 
 * @returns 
 */
export const setVerifySDKInfo = (info) => {

    return RNDdverify.setVerifySDKInfo(info)
}
/**
 * 检查环境 
 * UMPNSAuthTypeLoginToken 一键登录环境
 * UMPNSAuthTypeVerifyToken 本机号码校验环境
 * @param {UMPNSAuthTypeLoginToken UMPNSAuthTypeVerifyToken} authType 
 *  
 */
export const checkEnvAvailableWithAuthType = (authType) => {
    return RNDdverify.checkEnvAvailableWithAuthType(authType)
}
/**
 * 获取版本号
 * @param { 回调函数返回一个数组，第一个元素就是版本号 [version]} complete 
 */
export const getVersion = (complete) => {
    IS_TAB_STYLE && RNDdverify.getVersion(complete)
}
/**
 * 预取号，可以缩减一键登录初始化时间，不可以多次调用预取号（最好是打开APP后，验证用户登录信息，再决定是否调用一次预取号）
 * @param {*} BackHandler 
 * @returns 
 */
export const accelerateLoginPageWithTimeout = (BackHandler)=>{
    return RNDdverify.accelerateLoginPageWithTimeout(BackHandler);
}
/**
 * 一键登录
 * @param {最多等待多少秒} timeOut 
 * 授权页控件点击事件：700000（点击授权页返回按钮）、700001（点击切换其他登录方式）、
    700002（点击登录按钮事件，根据返回字典里面的 "isChecked"字段来区分check box是否被选中，只有被选中的时候        *          内部才会去获取Token）、700003（点击check box事件）、700004（点击协议富文本文字）
    接口回调其他事件：600001（授权页唤起成功）、600002（授权页唤起失败）、600000（成功获取Token）、 600011（获取Token失败）、600015（获取Token超时）、600013（运营商维护升级，该功能不可用）、600014（运营商维护升级，该功能已达最大调用次数）.....
 */
export const getLoginTokenWithTimeout = ( timeOut, params ) => {
    return RNDdverify.getLoginTokenWithTimeout( timeOut, params )
}
/**
 * 获取VerifyToken
 * 使用这个VerifyToken + 手机号码。去后端进行校验。
 * 返回一个 Promise
 * 
 */
export const getVerifyToken = () => {

    return new Promise((resolve, reject)=>{
        RNDdverify.getVerifyToken().then((token)=>{
            resolve(token)
        }).catch((e)=>{
            reject(-1)
        })
    })
}
//关闭授权页面
export const cancelLoginVCAnimated = () => {
     RNDdverify.cancelLoginVCAnimated()
}
//判断设备蜂窝网络是否开启
export const checkDeviceCellularDataEnable = (complete) => {
    IS_TAB_STYLE && RNDdverify.checkDeviceCellularDataEnable(complete)
}
////获取当前上网卡运营商名称中国移动，中国联通，中国电信等
export const getCurrentCarrierName = (complete) => {
    IS_TAB_STYLE && RNDdverify.getCurrentCarrierName(complete)
}