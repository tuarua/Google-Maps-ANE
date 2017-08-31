# Google-Maps-ANE

Google Maps Adobe Air Native Extension for Android 19+.
This project is working but still in progress. More features are planned.

-------------

Much time, skill and effort has gone into this. Help support the project

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=5UR2T52J633RC)

-------------
 
 ## Android
 
 **Dependencies**
 Several dependency ANEs are needed.
 They can be found in this repo:  
 [https://github.com/tuarua/Android-ANE-Dependancies/tree/master/anes]
 
````xml
<extensions>
    <extensionID>com.tuarua.frekotlin</extensionID>
    <extensionID>org.greenrobot.eventbus</extensionID>
    <extensionID>com.google.android.gms.play-services-base</extensionID>
    <extensionID>com.google.android.gms.play-services-location</extensionID>
    <extensionID>com.google.android.gms.play-services-maps</extensionID>
    <extensionID>com.android.support.support-v4</extensionID>
    <extensionID>com.google.code.gson.gson</extensionID>
    ...
</extensions>
`````

You will need a Google API key   
[https://developers.google.com/maps/documentation/android-api/signup]

You will also need to include the following in your app manifest. Update accordingly.

````xml
<manifest android:installLocation="auto">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_COURSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <uses-permission android:name="com.google.android.providers.gsf.permission.READ_GSERVICES"/>
    <uses-feature android:glEsVersion="0x00020000" android:required="true"/>
    <application android:enabled="true">
        <meta-data android:name="com.google.android.geo.API_KEY" android:value="[Your API_KEY]"/>
        <meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version" />
        <activity android:name="com.tuarua.googlemapsane.PermissionActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar.Fullscreen" />
        <activity android:excludeFromRecents="false" android:hardwareAccelerated="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
`````
## iOS

Coming soon...   
The iOS version will also use GoogleMaps SDK

### Technical Details
The Android version is written in Kotlin. Kotlin is a joy to work with and provides a syntax more familiar to Actionscript or Swift developers.
Full source is provided.

### Prerequisites

You will need:

- IntelliJ IDEA
- AIR 26
- Android Studio 3 Beta if you wish to edit the source

### References
* [https://developers.google.com/maps/documentation/android-api/]
* [https://developers.google.com/maps/documentation/ios-sdk/]
* [https://kotlinlang.org/docs/reference/android-overview.html] 