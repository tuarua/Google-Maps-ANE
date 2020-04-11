#!/bin/sh

AneVersion="2.7.0"
FreKotlinVersion="1.10.0"
PlayerServicesVersion="17.0.0"
MapsVersion="17.0.0"
LocationVersion="17.0.0"
SupportV4Version="1.0.0"
GsonVersion="2.8.6"
EventBusVersion="3.0.0"

wget -O android_dependencies/com.tuarua.frekotlin-$FreKotlinVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/kotlin/com.tuarua.frekotlin-$FreKotlinVersion.ane?raw=true
wget -O android_dependencies/org.greenrobot.eventbus-$EventBusVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/misc/org.greenrobot.eventbus-$EventBusVersion.ane?raw=true
wget -O android_dependencies/com.google.code.gson.gson-$GsonVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/misc/com.google.code.gson.gson-$GsonVersion.ane?raw=true
wget -O android_dependencies/androidx.legacy.legacy-support-v4-$SupportV4Version.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/support/androidx.legacy.legacy-support-v4-$SupportV4Version.ane?raw=true
wget -O android_dependencies/com.google.android.gms.play-services-base-$PlayerServicesVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/play-services/com.google.android.gms.play-services-base-$PlayerServicesVersion.ane?raw=true
wget -O android_dependencies/com.google.android.gms.play-services-location-$LocationVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/play-services/com.google.android.gms.play-services-location-$LocationVersion.ane?raw=true
wget -O android_dependencies/com.google.android.gms.play-services-maps-$MapsVersion.ane https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/play-services/com.google.android.gms.play-services-maps-$MapsVersion.ane?raw=true
wget -O ../native_extension/ane/GoogleMapsANE.ane https://github.com/tuarua/Google-Maps-ANE/releases/download/$AneVersion/GoogleMapsANE.ane?raw=true
