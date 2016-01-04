# react-native-google-app-invites
Let your users sign in with their Google account and Invite your
contacts to use the app.

react-native-google-app-invites is a wrapper around Google App Invites so it can be used from an React Native application.

## Requirements

- iOS 7+
- React Native >0.14
- CocoaPods

## Installation

```bash
npm install react-native-google-app-invites --save
```

## iOS

You will need:

CocoaPods ([Setup](https://guides.cocoapods.org/using/getting-started.html#installation))

### Google project configuration for iOS

- Open https://developers.google.com/app-invites/ios/
- Follow the instalation steps for CocoaPods

## Android

### Google project configuration

- Open https://developers.google.com/app-invites/android/
- Follow the instalation steps

* In `android/setting.gradle`

```gradle
...
include ':react-native-google-app-invites', ':app'
project(':react-native-google-app-invites').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-google-app-invites/android')
```

* In `android/build.gradle`

```gradle
...
dependencies {
        classpath 'com.android.tools.build:gradle:1.3.1'
        classpath 'com.google.gms:google-services:1.5.0' // <--- add this
    }
```

* In `android/app/build.gradle`

```gradle
apply plugin: "com.android.application"
apply plugin: 'com.google.gms.google-services' // <--- add this at the TOP
...
dependencies {
    compile fileTree(dir: "libs", include: ["*.jar"])
    compile "com.android.support:appcompat-v7:23.0.1"
    compile "com.facebook.react:react-native:0.14.+"
    compile project(":react-native-google-app-invites") // <--- add this
}
```

* Register Module (in MainActivity.java)

```java
import co.apptailor.googleappinvites.RNGoogleAppInvitesModule; // <--- import
import co.apptailor.googleappinvites.RNGoogleAppInvitesPackage;  // <--- import

public class MainActivity extends Activity implements DefaultHardwareBackBtnHandler {
  ......

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    mReactRootView = new ReactRootView(this);

    mReactInstanceManager = ReactInstanceManager.builder()
      .setApplication(getApplication())
      .setBundleAssetName("index.android.bundle")
      .setJSMainModuleName("index.android")
      .addPackage(new MainReactPackage())
      .addPackage(new RNGoogleAppInvitesPackage(this)) // <------ add this line to yout MainActivity class
      .setUseDeveloperSupport(BuildConfig.DEBUG)
      .setInitialLifecycleState(LifecycleState.RESUMED)
      .build();

    mReactRootView.startReactApplication(mReactInstanceManager, "AndroidRNSample", null);

    setContentView(mReactRootView);
  }

  // add this method inside your activity class
  @Override
  protected void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
      if (requestCode == RNGoogleAppInvitesModule.RC_APP_INVITES_IN) {
          RNGoogleAppInvitesModule.onActivityResult(resultCode, data);
      }
      super.onActivityResult(requestCode, resultCode, data);
  }

  ......

}
```


# Usage

From your JS files for both iOS and Android:

```js
var { NativeAppEventEmitter, DeviceEventEmitter } = require('react-native');
var GoogleAppInvites = require('react-native-google-app-invites');

if (Platform.OS === "ios") {
  GoogleAppInvites.configure(
    CLIENT_ID, // from .plist file
    SCOPES // array of authorization names: eg ['https://www.googleapis.com/auth/plus.login']
  );
} else {
  GoogleAppInvites.init()
}

let Emitter = (Platform.OS === "android") ? DeviceEventEmitter : NativeAppEventEmitter;

Emitter.addListener('googleAppInvitesError', (error) => {
  console.log('ERROR App Invites in', error);
});

Emitter.addListener('googleAppInviteIds', (body) => {
  console.log('User invited these IDS:', body);
});

GoogleAppInvites.invite("Message", "Title", "http://deepLink");
```

