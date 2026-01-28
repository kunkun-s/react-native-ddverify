import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { CodegenTypes, TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {

    readonly onVerifyEvent: CodegenTypes.EventEmitter<{ key: string; value:Object }>;//监听状态回调
    //设置秘钥
    setVerifySDKInfo(info: string): Promise<Object>;
    //检查环境
    checkEnvAvailableWithAuthType(authType: string): Promise<Object>;
    //预取号
    accelerateLoginPageWithTimeout(callback:(data?:Object|undefined|null) => void):void;
    //一键登录
    getLoginTokenWithTimeout(timeout:string, params:Object):void;
    //获取登录校验token
    getVerifyToken():Promise<string>;
    //关闭授权页面
    cancelLoginVCAnimated():void;
}

//此模块支持新旧框架，因此使用get兼容 而非getEnforcing
export default TurboModuleRegistry.get<Spec>('NativeDDVerify') as Spec|null;