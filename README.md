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


# Usage

From your JS files for both iOS and Android:

```js
var { NativeAppEventEmitter, DeviceEventEmitter } = require('react-native');
var GoogleAppInvites = require('react-native-google-app-invites');

if (Platform.OS === "ios") {
  GoogleSignin.configure(
    CLIENT_ID, // from .plist file
    SCOPES // array of authorization names: eg ['https://www.googleapis.com/auth/plus.login']
  );
} else {
  GoogleAppInvites.init()
}

let Emitter = (Platform.OS === "android") ? DeviceEventEmitter : NativeAppEventEmitter;

Emitter.addListener('googleSignInError', (error) => {
  console.log('ERROR signin in', error);
  this.props.navigator.push({ location: "/" });
});

Emitter.addListener('googleSignIn', () => {
  GoogleAppInvites.inviteTapped("Message", "Title", "URL");
});

Emitter.addListener('googleAppInviteConvertion', (body) => {
  console.log('User convertion:', body);
});

Emitter.addListener('googleAppInviteIds', (body) => {
  console.log('User invited these IDS:', body);
});

GoogleAppInvites.invite("Message", "Title", "http://deepLink");
```

