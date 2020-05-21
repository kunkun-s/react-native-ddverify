
import { NativeModules } from 'react-native';

const { RNDdverify } = NativeModules;

export const setVerifySDKInfo = () => {
    return  RNDdverify.setVerifySDKInfo()
}
/**
 * 
 * @param {UMPNSAuthTypeLoginToken UMPNSAuthTypeVerifyToken} authType 
 */
export const checkEnvAvailableWithAuthType = (authType) => {
    return RNDdverify.checkEnvAvailableWithAuthType(authType)
}
/**
 * 
 * @param { 回调函数返回一个数组，第一个元素就是版本号 [version]} complete 
 */
export const getVersion = (complete) => {
    RNDdverify.getVersion(complete)
}
/**
 * 
 * @param {最多等待多少秒} timeOut 
 */
export const getLoginTokenWithTimeout = ( timeOut ) => {
    return RNDdverify.getLoginTokenWithTimeout( timeOut )
}