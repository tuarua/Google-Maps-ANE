#!/bin/sh

AneVersion="2.5.0"
FreKotlinVersion="1.8.0"
PlayerServicesVersion="16.0.1"
MapsVersion="16.1.0"
LocationVersion="16.0.0"
SupportV4Version="27.1.0"
GsonVersion="2.8.4"
EventBusVersion="3.0.0"

wget -O android_dependencies/com.tuarua.frekotlin-$FreKotlinVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/kotlin/com.tuarua.frekotlin-$FreKotlinVersion.ane?raw=true
wget -O android_dependencies/org.greenrobot.eventbus-$EventBusVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/misc/org.greenrobot.eventbus-$EventBusVersion-air33.ane?raw=true
wget -O android_dependencies/com.google.code.gson.gson-$GsonVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/misc/com.google.code.gson.gson-$GsonVersion-air33.ane?raw=true
wget -O android_dependencies/com.android.support.support-v4-$SupportV4Version.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/support/com.android.support.support-v4-$SupportV4Version-air33.ane?raw=true
wget -O android_dependencies/com.google.android.gms.play-services-base-$PlayerServicesVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/play-services/com.google.android.gms.play-services-base-$PlayerServicesVersion-air33.ane?raw=true
wget -O android_dependencies/com.google.android.gms.play-services-location-$LocationVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/play-services/com.google.android.gms.play-services-location-$LocationVersion-air33.ane?raw=true
wget -O android_dependencies/com.google.android.gms.play-services-maps-$MapsVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/play-services/com.google.android.gms.play-services-maps-$MapsVersion-air33.ane?raw=true
wget -O ../native_extension/ane/GoogleMapsANE.ane https://github.com/tuarua/Google-Maps-ANE/releases/download/$AneVersion/GoogleMapsANE.ane?raw=true
