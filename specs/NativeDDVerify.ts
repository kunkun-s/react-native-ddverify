import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { TurboModuleRegistry } from 'react-native';

/**
 *   "codegenConfig": {
    "name": "NativeDDVerifySpec",
    "type": "modules",
    "jsSrcsDir": "specs", //这个目录下可以有多个NativeDDverify文件
    "android": {
      "javaPackageName": "com.dddverify"
    }
  },
 */
export interface Spec extends TurboModule {

    //设置秘钥
    setVerifySDKInfo(info: string): Promise<number>;
    //检查环境
    checkEnvAvailableWithAuthType(authType: string): Promise<number>;
    //预取号
    accelerateLoginPageWithTimeout(callback:(data?:Object|undefined|null) => void):void;
    //一键登录
    getLoginTokenWithTimeout(timeout:string, params:Object):void;
    //获取登录校验token
    getVerifyToken():Promise<string>;
    //关闭授权页面
    cancelLoginVCAnimated():void;
}

// 使用 getEnforcing 而不是 get，确保类型安全
export default TurboModuleRegistry.get<Spec>('RNDdverify') as Spec|null;