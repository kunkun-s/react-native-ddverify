
# react-native-ddverify

## Getting started

`$ npm install react-native-ddverify --save`

### Mostly automatic installation

`$ react-native link react-native-ddverify`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-ddverify` and add `RNDdverify.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNDdverify.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.quenice.cardview.RNDdverifyPackage;` to the imports at the top of the file
  - Add `new RNDdverifyPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-ddverify'
  	project(':react-native-ddverify').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-ddverify/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-ddverify')
  	```


## Usage
```javascript
import RNDdverify from 'react-native-ddverify';

// TODO: What to do with the module?
RNDdverify;
```
  