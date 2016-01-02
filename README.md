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

### Usage

From your JS files
```js
var { NativeAppEventEmitter } = require('react-native');
var GoogleAppInvites = require('react-native-google-app-invites');

// configure API keys and access right
GoogleAppInvites.configure(
  CLIENT_ID, // from .plist file
  SCOPES // array of authorization names: eg ['https://www.googleapis.com/auth/plus.login']
);

// called on signin error
NativeAppEventEmitter.addListener('googleSignInError', (error) => {
  ....
});

// called on signin success, you get user data (email), access token and idToken
NativeAppEventEmitter.addListener('googleSignIn', (user) => {
  User: {
    name
    email
    accessToken
    idToken (IOS ONLY)
    accessTokenExpirationDate (IOS ONLY)
  }
});


// called when app is opened with new conversion
NativeAppEventEmitter.addListener('googleAppInviteConvertion', (body) => {
 console.log('User convertion:', body);
});


// called when user invited his/her contacts
NativeAppEventEmitter.addListener('googleAppInviteIds', (body) => {
  console.log('User invited these IDS:', body);
});

// call this method when user clicks the 'Signin with google' button
GoogleAppInvites.signIn();

// remove user credentials. next time user starts the application, a signin promp will be displayed
GoogleAppInvites.signOut();
```

## Android

### Google project configuration

- Open https://developers.google.com/app-invites/android/
- Follow the instalation steps

### Usage
```js
var GoogleAppInvites = require('react-native-google-app-invites');
var { DeviceEventEmitter } = require('react-native');

GoogleAppInvites.init(); // somewhere in a componentDidMount.

// called on signin error
DeviceEventEmitter.addListener('googleSignInError', (error) => {
  ....
});

// called on signin success, you get user data (email), access token and idToken
DeviceEventEmitter.addListener('googleSignIn', (user) => {
  User: {
    name
    email
    accessToken
    idToken (IOS ONLY)
    accessTokenExpirationDate (IOS ONLY)
  }
});


// called when app is opened with new conversion
DeviceEventEmitter.addListener('googleAppInviteConvertion', (body) => {
 console.log('User convertion:', body);
});


// called when user invited his/her contacts
DeviceEventEmitter.addListener('googleAppInviteIds', (body) => {
  console.log('User invited these IDS:', body);
});

// call this method when user clicks the 'Signin with google' button
GoogleAppInvites.signIn();

// remove user credentials. next time user starts the application, a signin promp will be displayed
GoogleAppInvites.signOut();

```
