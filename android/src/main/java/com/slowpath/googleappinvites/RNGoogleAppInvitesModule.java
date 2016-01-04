package com.slowpath.googleappinvites;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.appinvite.AppInviteInvitation;
import com.google.android.gms.appinvite.AppInvite;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

import javax.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;

public class AppInvitesModule extends ReactContextBaseJavaModule {
  private static final int REQUEST_INVITE = 0;
  private static final int RESULT_OK = -1;

  private ReactContext _context;
  private Activity _activity;

  public AppInvitesModule(ReactApplicationContext _reactContext, Activity activity) {
    super(_reactContext);
    _context = _reactContext;
    _activity = activity;
  }

  @Override
  public String getName() {
    return "RNGoogleAppInvites";
  }

  public void connectionFailed(ConnectionResult connectionResult) {
    WritableMap params = Arguments.createMap();
    params.putString("error", connectionResult.toString());
    sendEvent(_context, "googleAppInvitesConnectionError", params);
  }

  public void invitationsSentSuccessfully(String[] ids) {
    WritableMap params = Arguments.createMap();
    WritableArray paramsIds = Arguments.fromArray(ids);
    params.putArray("ids", paramsIds);
    sendEvent(_context, "googleAppInviteIds", params);
  }

  public void invitationsFailedOrCanceled() {
    WritableMap params = Arguments.createMap();
    params.putString("message", "Sending failed or it was canceled");
    sendEvent(_context, "googleAppInvitesError", params);
  }

  @ReactMethod
  public void init() {
    _activity.runOnUiThread(new Runnable() {
      @Override
      public void run() {
        new GoogleApiClient.Builder(_activity.getBaseContext())
          .addApi(AppInvite.API)
          //.enableAutoManage(_activity, _activity.getBaseContext())
          .build();
      }
    });
  }

  @ReactMethod
  public void invite(String message, String title, String deepLink) {
    _activity.runOnUiThread(new Runnable() {
        private String _message;
        private String _title;
        private String _deepLink;
        private Activity _activity;

        public Runnable init(String message, String title, String deepLink, Activity activity) {
          _message = message;
          _title = title;
          _deepLink = deepLink;
          _activity = activity;
          return (this);
        }

        @Override
        public void run() {
          Intent intent = new AppInviteInvitation.IntentBuilder(_title)
                  .setMessage(_message)
                  .setDeepLink(Uri.parse(_deepLink))
                  .build();
          _activity.startActivityForResult(intent, REQUEST_INVITE);
        }
    }.init(message, title, deepLink, _activity));
  }

  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    if (requestCode == REQUEST_INVITE) {
      if (resultCode == RESULT_OK) {
        String[] ids = AppInviteInvitation.getInvitationIds(resultCode, data);
        invitationsSentSuccessfully(ids);
      } else {
        // Sending failed or it was canceled, show failure message to the user
        invitationsFailedOrCanceled();
      }
    }
  }

  private void sendEvent(ReactContext reactContext,
                         String eventName,
                         @Nullable WritableMap params) {
    reactContext
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit(eventName, params);
  }

}
