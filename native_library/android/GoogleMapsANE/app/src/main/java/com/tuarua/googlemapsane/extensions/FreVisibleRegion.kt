package com.tuarua.googlemapsane.extensions

import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.VisibleRegion
import com.tuarua.frekotlin.FREObject

fun VisibleRegion.toFREObject(): FREObject? {
    return FREObject("com.tuarua.googlemaps.VisibleRegion",
            this.nearLeft.toFREObject(),
            this.nearRight.toFREObject(),
            this.farLeft.toFREObject(),
            this.farRight.toFREObject()
    )
}