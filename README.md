# GoogleMaps-ANE

Google Maps Adobe Air Native Extension for iOS 9.0+ and Android 19+. Also includes option to use Apple Maps on iOS.   

[ASDocs Documentation](https://tuarua.github.io/asdocs/googlemapsane/)   

-------------

Much time, skill and effort has gone into this. Help support the project

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=5UR2T52J633RC)

-------------
 
## The ANE
 
Download the latest from the [Releases](https://github.com/tuarua/Google-Maps-ANE/releases) page.

 
## Android
 
##### The ANE + Dependencies
 
From the command line cd into /example and run:   
 - OSX
````shell
bash get_android_dependencies.sh
`````
 - Windows Powershell
````shell
PS get_android_dependencies.ps1
`````

The dependencies can be downloaded directly from this repo: 
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
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
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

-------------

## iOS

##### The ANE + Dependencies

N.B. You must use a Mac to build an iOS app using this ANE. Windows is NOT supported.

From the command line cd into /example and run:
````shell
bash get_ios_dependencies.sh
`````


The folder, ios_dependencies/device/Frameworks, must be packaged as part of your app when creating the ipa. How this is done will depend on the IDE you are using.   
After the ipa is created unzip it and confirm there is a "Frameworks" folder in the root of the .app package.

### Modifications to the AIR SDK

For iOS we need some additions to the AIRSDK. 

Copy the files from **AIRSDK_additions** into the corresponding folders in your AIRSDK.

You will also need to include the following in your app manifest. Update accordingly.
````xml
<InfoAdditions><![CDATA[            
    <key>UIDeviceFamily</key>
    <array>
        <string>1</string>
        <string>2</string>
    </array>
    <key>MinimumOSVersion</key>
    <string>9.0</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Your message</string>
]]></InfoAdditions>
`````

You will need a Google API key   
[https://developers.google.com/maps/documentation/ios-sdk/get-api-key]


### Prerequisites

You will need:

- IntelliJ IDEA / Flash Builder
- AIR 32
- Xcode 10.1
- Android Studio 3 if you wish to edit the Android source
- wget on OSX
- Powershell on Windows

### References
* [https://developers.google.com/maps/documentation/android-api/]
* [https://developers.google.com/maps/documentation/ios-sdk/]
* [https://kotlinlang.org/docs/reference/android-overview.html] 
