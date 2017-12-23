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
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.tuarua.frekotlin.display.Bitmap

class FreMarkerOptions() : FreObjectKotlin() {
    constructor(freObject: FREObject?) : this() {
        rawValue = freObject
    }

    override val value: MarkerOptions
        @Throws(FreException::class)
        get() {
            val rv = rawValue
            if (rv != null) {
                val coordinate = LatLng(rv["coordinate"])
                val title = String(rv["title"])
                val snippet = String(rv["snippet"])
                val draggable = Boolean(rv["isDraggable"]) == true
                val flat = Boolean(rv["isFlat"]) == true
                val alpha = Float(rv["alpha"]) ?: 1.0F
                val rotation = Float(rv["rotation"]) ?: 0.0F
                val colorFre = rv["color"]
                val color = colorFre?.toHSV(true) ?: 0.0F
                val iconFre = rv["icon"]
                val icon: Bitmap?
                try {
                    icon = Bitmap(iconFre)
                } catch (e: FreException) {
                    throw e
                } catch (e: Exception) {
                    throw FreException(e)
                }

                return MarkerOptions()
                        .position(coordinate)
                        .title(title)
                        .snippet(snippet)
                        .draggable(draggable)
                        .flat(flat)
                        .alpha(alpha)
                        .icon(if (icon is Bitmap) BitmapDescriptorFactory
                                .fromBitmap(icon) else BitmapDescriptorFactory
                                .defaultMarker(color))
                        .rotation(rotation)

            }
            return MarkerOptions()
        }
}

fun MarkerOptions(freObject: FREObject?): MarkerOptions = FreMarkerOptions(freObject = freObject).value
fun Marker.setFlat(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isFlat = v
    }
}

fun Marker.setTitle(value: FREObject?) {
    this.title = String(value)
}

fun Marker.setSnippet(value: FREObject?) {
    this.snippet = String(value)
}

fun Marker.setDraggable(value: FREObject?) {
    val v = Boolean(value)
    if (v != null) {
        this.isDraggable = v
    }
}

fun Marker.setAlpha(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.alpha = v
    }
}

fun Marker.setRotation(value: FREObject?) {
    val v = Float(value)
    if (v != null) {
        this.rotation = v
    }
}

fun Marker.setIcon(value: FREObject?) {
    val icon: Bitmap?
    try {
        icon = Bitmap(value)
    } catch (e: FreException) {
        return
    } catch (e: Exception) {
        return
    }
    this.setIcon(BitmapDescriptorFactory.fromBitmap(icon))
}

fun Marker.setColor(value: FREObject?) {
    val color = value?.toHSV(true)
    if (color != null) {
        this.setIcon(BitmapDescriptorFactory.defaultMarker(color))
    }
}

fun Marker.setPosition(value: FREObject?) {
    val coordinate = LatLng(value)
    this.position = coordinate
}