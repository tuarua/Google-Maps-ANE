/*
 *  Copyright 2017 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package com.tuarua.googlemapsane.extensions

import android.graphics.Bitmap
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.GroundOverlay
import com.google.android.gms.maps.model.GroundOverlayOptions
import com.tuarua.frekotlin.*
import com.tuarua.frekotlin.display.Bitmap

fun GroundOverlayOptions(freObject: FREObject?): GroundOverlayOptions {
    val rv = freObject ?: return GroundOverlayOptions()
    val bounds = LatLngBounds(rv["bounds"])
    val bearing = Float(rv["bearing"]) ?: 0f
    val clickable = Boolean(rv["isTappable"]) == true
    val visible = Boolean(rv["visible"]) == true
    val zIndex = Float(rv["zIndex"]) ?: 0f
    val transparency = Float(rv["transparency"]) ?: 0f
    val imageFre = rv["image"]
    val image: Bitmap?
    try {
        image = Bitmap(imageFre)
    } catch (e: Exception) {
        return GroundOverlayOptions()
    }

    return GroundOverlayOptions()
            .positionFromBounds(bounds)
            .bearing(bearing)
            .clickable(clickable)
            .visible(visible)
            .zIndex(zIndex)
            .transparency(transparency)
            .image(BitmapDescriptorFactory.fromBitmap(image))

}

fun GroundOverlay.setBounds(value: FREObject?) {
    this.setPositionFromBounds(LatLngBounds(value))
}

fun GroundOverlay.setBearing(value: FREObject?) {
    Float(value)?.let { this.bearing = it }
}

fun GroundOverlay.setZIndex(value: FREObject?) {
    Float(value)?.let { this.zIndex = it }
}

fun GroundOverlay.setTransparency(value: FREObject?) {
    Float(value)?.let { this.transparency = it }
}

fun GroundOverlay.setVisible(value: FREObject?) {
    Boolean(value)?.let { this.isVisible = it }
}

fun GroundOverlay.setClickable(value: FREObject?) {
    Boolean(value)?.let { this.isClickable = it }
}

fun GroundOverlay.setImage(value: FREObject?) {
    val image: Bitmap?
    try {
        image = Bitmap(value)
    } catch (e: FreException) {
        return
    } catch (e: Exception) {
        return
    }
    this.setImage(BitmapDescriptorFactory.fromBitmap(image))
}