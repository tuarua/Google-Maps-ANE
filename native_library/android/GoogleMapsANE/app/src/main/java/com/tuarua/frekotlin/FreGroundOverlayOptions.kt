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

package com.tuarua.frekotlin
import android.graphics.Bitmap
import com.adobe.fre.FREObject
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.GroundOverlay
import com.google.android.gms.maps.model.GroundOverlayOptions
import com.tuarua.frekotlin.display.Bitmap

class FreGroundOverlayOptions() : FreObjectKotlin() {
    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }
    override val value: GroundOverlayOptions
        @Throws(FreException::class)
        get() {
            val rv = rawValue
            if (rv != null) {
                val coordinate = LatLng(rv["coordinate"])
                val bearing = Float(rv["bearing"]) ?: 0f
                val clickable = Boolean(rv["isTappable"]) == true
                val visible = Boolean(rv["visible"]) == true
                val zIndex = Float(rv["zIndex"]) ?: 0f
                val transparency = Float(rv["transparency"]) ?: 0f
                val width = Float(rv["width"]) ?: 0f
                val imageFre = rv["image"]
                val image: Bitmap?
                try {
                    image = Bitmap(imageFre)
                } catch (e: FreException) {
                    throw e
                } catch (e: Exception) {
                    throw FreException(e)
                }

                return GroundOverlayOptions()
                        .position(coordinate, width)
                        .bearing(bearing)
                        .clickable(clickable)
                        .visible(visible)
                        .zIndex(zIndex)
                        .transparency(transparency)
                        .image(BitmapDescriptorFactory.fromBitmap(image))
            }
            return GroundOverlayOptions()
        }
}
fun GroundOverlayOptions(freObject: FREObject?): GroundOverlayOptions = FreGroundOverlayOptions(freObject = freObject).value

fun GroundOverlay.setPosition(value: FREObject?) {
    val coordinate = LatLng(value)
    this.position = coordinate
}

fun GroundOverlay.setBearing(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.bearing = v
    }
}

fun GroundOverlay.setZIndex(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.zIndex = v
    }
}

fun GroundOverlay.setTransparency(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.transparency = v
    }
}

fun GroundOverlay.setVisible(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isVisible = v
    }
}

fun GroundOverlay.setClickable(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isClickable = v
    }
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